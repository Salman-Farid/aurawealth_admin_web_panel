import 'dart:async';
import 'package:get/get.dart';
import '../models/message.dart';
import '../services/firestore_admin_chat_service.dart';

/// Admin-side realtime chat controller backed by Cloud Firestore streams.
class AdminChatController extends GetxController {
  AdminChatController({
    required this.targetUserId,
    FirestoreAdminChatService? chatService,
  }) : _chatService = chatService ?? FirestoreAdminChatService();

  final String targetUserId;
  final FirestoreAdminChatService _chatService;

  final messages = <Message>[].obs;
  final liveMessages = <Message>[].obs;
  final mailMessages = <Message>[].obs;
  final isConnected = false.obs;
  final isLoadingHistory = false.obs;
  final isSending = false.obs;
  final messageTypeFilter = 'live'.obs;
  final unreadCount = 0.obs;

  StreamSubscription<List<Message>>? _messagesSub;
  StreamSubscription<List<Message>>? _mailsSub;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    _mailsSub?.cancel();
    super.onClose();
  }

  Future<void> _boot() async {
    await reloadHistory();
    _subscribe();
    unawaited(_chatService.markUserMessagesRead(targetUserId));
  }

  Future<void> reloadHistory() async {
    isLoadingHistory.value = true;
    try {
      final loadedLive = await _chatService.loadRecentMessages(
        targetUserId,
        limit: 1000,
      );
      final loadedMail = await _chatService.loadMailHistory(
        targetUserId,
        limit: 1000,
      );
      _setLiveMessages(loadedLive.where((m) => m.messageType == 'live'));
      _setMailMessages(loadedMail);
      _recomputeUnread();
      _log(
        'Firestore history loaded: ${liveMessages.length} live messages, '
        '${mailMessages.length} mails',
      );
    } catch (e, st) {
      _log('Firestore history load failed: $e');
      _log('$st');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void _subscribe() {
    _messagesSub?.cancel();
    _mailsSub?.cancel();

    _messagesSub = _chatService
        .watchMessages(targetUserId)
        .listen(
          (incoming) {
            isConnected.value = true;
            _setLiveMessages(incoming.where((m) => m.messageType == 'live'));
            _recomputeUnread();
            unawaited(_chatService.markUserMessagesRead(targetUserId));
          },
          onError: (e) {
            isConnected.value = false;
            _log('Firestore messages stream error: $e');
          },
        );

    _mailsSub = _chatService
        .watchMails(targetUserId)
        .listen(
          (incoming) {
            isConnected.value = true;
            _setMailMessages(incoming);
          },
          onError: (e) {
            isConnected.value = false;
            _log('Firestore mails stream error: $e');
          },
        );
  }

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
    if (messageType == 'static' &&
        (subject == null || subject.trim().isEmpty)) {
      Get.snackbar('Validation', 'Subject is required for formal messages');
      return;
    }

    isSending.value = true;
    try {
      if (messageType == 'static') {
        await _chatService.sendMail(
          userId: targetUserId,
          subject: subject!.trim(),
          content: trimmed,
        );
      } else {
        await _chatService.sendAdminMessage(
          userId: targetUserId,
          content: trimmed,
          messageType: messageType,
          subject: subject,
        );
      }
    } catch (e) {
      _log('sendMessage failed: $e');
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSending.value = false;
    }
  }

  void _setLiveMessages(Iterable<Message> loaded) {
    final sorted = loaded.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    liveMessages.assignAll(sorted);
    _syncMessages();
  }

  void _setMailMessages(Iterable<Message> loaded) {
    final sorted = loaded.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    mailMessages.assignAll(sorted);
    _syncMessages();
  }

  void _syncMessages() {
    final combined = <Message>[...liveMessages, ...mailMessages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    messages.assignAll(combined);
  }

  void _recomputeUnread() {
    unreadCount.value = liveMessages
        .where((m) => m.direction == 'user_to_admin' && !m.isRead)
        .length;
  }

  List<Message> get filteredMessages {
    final f = messageTypeFilter.value;
    if (f == 'all') return messages.toList();
    if (f == 'static') return mailMessages.toList();
    return liveMessages.toList();
  }

  void setMessageTypeFilter(String type) {
    messageTypeFilter.value = type;
  }

  void clearUnreadCount() => unreadCount.value = 0;

  void _log(String msg) {
    final prefix = targetUserId.length >= 8
        ? targetUserId.substring(0, 8)
        : targetUserId;
    // ignore: avoid_print
    print('[AdminChat:$prefix] $msg');
  }
}
