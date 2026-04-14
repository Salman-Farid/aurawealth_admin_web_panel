import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config/api_config.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Admin-side real-time chat controller for a specific user conversation.
///
/// Strategy:
///   1. Fetch history via REST immediately so messages appear before WS connects.
///   2. Open a WebSocket — server pushes new_message / sent / message_read events.
///   3. All message state is in [messages] (RxList) so any Obx() on screen
///      rebuilds automatically — NO manual setState, NO refresh, NO re-init.
///   4. Exponential back-off reconnect (2 → 4 → … → 64 s).
class AdminChatController extends GetxController {
  // ── Constructor ────────────────────────────────────────────────────────────
  /// [targetUserId] = backend UUID of the user whose chat we are viewing.
  AdminChatController({required this.targetUserId})
      : _api = ApiService(),
        _storage = StorageService();

  final String targetUserId;
  final ApiService _api;
  final StorageService _storage;

  // ── Public reactive state ─────────────────────────────────────────────────
  /// THE reactive list. Wrap your ListView in Obx(() => ...) and read this.
  final messages = <Message>[].obs;
  final isConnected = false.obs;
  final isLoadingHistory = false.obs;
  final isSending = false.obs;
  final messageTypeFilter = 'all'.obs; // all, live, static
  final unreadCount = 0.obs;

  // ── Internal ──────────────────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  Timer? _reconnectTimer;
  int _reconnectDelay = 2;
  bool _manualClose = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  @override
  void onClose() {
    _manualClose = true;
    _reconnectTimer?.cancel();
    _wsSub?.cancel();
    _channel?.sink.close();
    _channel = null;
    // ⚠️ DO NOT close the broadcast stream — it stops all subscribers
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Boot
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _boot() async {
    await _loadHistory();        // Show persisted messages immediately via REST
    unawaited(_connectWs());     // WS in background — do not block UI
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REST History
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    isLoadingHistory.value = true;
    try {
      // Use admin chat history endpoint: GET /admin/chat/history/{user_id}
      final historyUrl = ApiConfig.adminChatHistoryUrl(targetUserId);
      final res = await _api.get(historyUrl);

      final loaded = (res as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
      _setMessages(loaded);
      print('[AdminChat] ✅ History loaded: ${loaded.length} messages for user $targetUserId');
    } catch (e) {
      print('[AdminChat] ❌ loadHistory failed: $e');
      Get.snackbar('Error', 'Failed to load message history: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WebSocket
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _connectWs() async {
    if (_manualClose) return;

    // Get the admin's bearer token from StorageService
    // Admin authentication uses JWT from /admin/login, NOT Firebase token
    final token = _storage.getAuthToken();
    if (token == null || token.isEmpty) {
      print('[AdminChat] ❌ No admin bearer token available');
      print('[AdminChat] ℹ️  Admin must be logged in via /admin/login');
      _scheduleReconnect();
      return;
    }

    // Admin WebSocket endpoint: wss://backend/ws/admin/chat/{userId}?token={admin_jwt}
    final wsUrl = ApiConfig.adminChatWebSocketUrl(targetUserId, token);
    print('[AdminChat] 🔌 Connecting WebSocket...');
    print('[AdminChat] ℹ️  URL: /ws/admin/chat/$targetUserId');
    print('[AdminChat] ℹ️  Auth: Bearer token (admin JWT)');

    try {
      // Clean up old connection
      await _wsSub?.cancel();
      _wsSub = null;
      _channel?.sink.close();
      _channel = null;

      // Connect to WebSocket
      print('[AdminChat] ⏳ Establishing WebSocket connection...');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen for events from server
      _wsSub = _channel!.stream.listen(
        _onEvent,
        onError: (e) {
          print('[AdminChat] ❌ WebSocket error: $e');
          isConnected.value = false;
          if (!_manualClose) _scheduleReconnect();
        },
        onDone: () {
          print('[AdminChat] ⚠️  WebSocket closed (code=${_channel?.closeCode})');
          isConnected.value = false;
          if (!_manualClose) _scheduleReconnect();
        },
        cancelOnError: false,
      );

      // Wait for connection to be ready
      await _channel!.ready;
      isConnected.value = true;
      _reconnectDelay = 2;  // Reset backoff
      print('[AdminChat] ✅ WebSocket connected successfully');
      print('[AdminChat] ✅ Waiting for init event with message history...');
    } catch (e) {
      print('[AdminChat] ❌ WebSocket connection failed: $e');
      print('[AdminChat] ℹ️  Checking: Is backend WebSocket endpoint accessible?');
      print('[AdminChat] ℹ️  Checking: Is admin token valid and not expired?');
      isConnected.value = false;
      _scheduleReconnect();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Event handler
  // ─────────────────────────────────────────────────────────────────────────

  void _onEvent(dynamic raw) {
    if (raw is! String) {
      print('[AdminChat] ⚠️  Received non-string event: ${raw.runtimeType}');
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final event = data['event'] as String? ?? 'unknown';

      print('[AdminChat] 📨 Received event: "$event"');

      switch (event) {
        case 'init':
          // Server sends message history on connect
          final list = (data['messages'] as List?)
                  ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          print('[AdminChat] ℹ️  Init event with ${list.length} messages');
          _mergeMessages(list);

        case 'message':
          // New message from user
          final msg = Message.fromJson(data['message'] as Map<String, dynamic>);
          print('[AdminChat] 📩 New message from user: "${msg.body.substring(0, 50)}"');
          _insertMessage(msg);
          if (msg.isFromUser) {
            unreadCount.value++;
          }

        case 'sent':
          // Server confirmed our message
          final confirmed = Message.fromJson(data['message'] as Map<String, dynamic>);
          print('[AdminChat] ✅ Message confirmed and sent');
          _replaceOldestTemp(confirmed);

        case 'message_read':
          // User read our messages
          print('[AdminChat] 👁️  User read our messages');
          _markAllOutboundRead();

        case 'error':
          final detail = (data['meta'] as Map?)?['detail']?.toString() ?? 'Unknown error';
          print('[AdminChat] ⚠️  Server error: $detail');
          Get.snackbar('Chat Error', detail, duration: Duration(seconds: 3));

        default:
          print('[AdminChat] ℹ️  Unknown event type: "$event"');
      }
    } catch (e) {
      print('[AdminChat] ❌ Failed to parse event: $e');
      print('[AdminChat] ℹ️  Raw data: $raw');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delay = _reconnectDelay;
    _reconnectDelay = (_reconnectDelay * 2).clamp(2, 64);
    print('[AdminChat] ⏰ Reconnect scheduled in ${delay}s (backoff: exponential)');
    print('[AdminChat] ℹ️  Attempt: ${(64 / _reconnectDelay).toStringAsFixed(0)}');
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_manualClose) {
        print('[AdminChat] 🔄 Attempting to reconnect...');
        unawaited(_connectWs());
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String body,
    String messageType = 'live',
    String? subject,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      Get.snackbar('Validation', 'Message body cannot be empty');
      return;
    }

    // Validation: static messages need subject
    if (messageType == 'static' && (subject == null || subject.trim().isEmpty)) {
      Get.snackbar('Validation', 'Subject is required for formal messages');
      return;
    }

    isSending.value = true;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    print('[AdminChat] 📤 Sending message (type: $messageType, id: $tempId)');

    _insertMessage(Message(
      id: tempId,
      direction: 'admin_to_user',
      messageType: messageType,
      subject: subject,
      body: trimmed,
      attachmentUrl: null,
      isRead: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    ));

    try {
      if (isConnected.value && _channel != null) {
        // Send via WebSocket (preferred)
        print('[AdminChat] ✉️  Sending via WebSocket...');
        _channel!.sink.add(jsonEncode({
          'message_type': messageType,
          'subject': subject,
          'body': trimmed,
          'attachment_url': null,
        }));
      } else {
        // HTTP fallback (when WS is down)
        print('[AdminChat] ✉️  WebSocket unavailable, using HTTP fallback...');
        final sendUrl = ApiConfig.adminChatSendUrl(targetUserId);
        print('[AdminChat] ℹ️  POST $sendUrl');

        final response = await _api.post(
          sendUrl,
          {
            'message_type': messageType,
            'body': trimmed,
            'subject': subject,
          },
        );

        print('[AdminChat] ✅ Message sent via HTTP fallback');
      }
    } catch (e) {
      print('[AdminChat] ❌ Send failed: $e');
      print('[AdminChat] ℹ️  Checking: Is backend API accessible?');
      print('[AdminChat] ℹ️  Checking: Is admin token valid?');
      Get.snackbar('Error', 'Failed to send message: $e', duration: Duration(seconds: 3));
    } finally {
      isSending.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Message list helpers — every method calls mutations that trigger Obx
  // ─────────────────────────────────────────────────────────────────────────

  void _setMessages(List<Message> loaded) {
    loaded.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    messages.assignAll(loaded);
  }

  void _insertMessage(Message msg) {
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx == -1) {
      messages.add(msg);
    } else {
      messages[idx] = msg;
    }
  }

  void _mergeMessages(List<Message> incoming) {
    if (incoming.isEmpty) return;
    final map = <String, Message>{for (final m in messages) m.id: m};
    for (final m in incoming) map[m.id] = m;
    final sorted = map.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    messages.assignAll(sorted);
  }

  void _replaceOldestTemp(Message confirmed) {
    final tempIdx = messages.indexWhere(
        (m) => m.id.startsWith('temp_') || m.id.startsWith('img_'));
    if (tempIdx != -1) {
      messages[tempIdx] = confirmed;
    } else {
      final idx = messages.indexWhere((m) => m.id == confirmed.id);
      if (idx != -1) messages[idx] = confirmed;
      else messages.add(confirmed);
    }
  }

  void _markAllOutboundRead() {
    final updated = messages.map((m) {
      if (m.direction == 'admin_to_user' && !m.isRead) {
        return Message(
          id: m.id,
          direction: m.direction,
          messageType: m.messageType,
          subject: m.subject,
          body: m.body,
          attachmentUrl: m.attachmentUrl,
          isRead: true,
          createdAt: m.createdAt,
        );
      }
      return m;
    }).toList();
    messages.assignAll(updated);
  }

  // Filter messages based on messageTypeFilter
  List<Message> get filteredMessages {
    if (messageTypeFilter.value == 'all') return messages;
    return messages.where((m) => m.messageType == messageTypeFilter.value).toList();
  }

  void setMessageTypeFilter(String type) {
    messageTypeFilter.value = type;
  }

  void clearUnreadCount() {
    unreadCount.value = 0;
  }
}




