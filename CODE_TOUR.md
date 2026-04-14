# Code Tour — Understanding the WebSocket Chat Implementation

This guide walks you through the codebase to understand how everything works together.

---

## 🗺️ File Map

### Entry Point: `messages_screen.dart`

```dart
// When user taps a conversation thread:
onTap: () {
  controller.loadUserMessages(thread.userId);  // Load old HTTP way
  
  // NEW: Initialize WebSocket controller
  if (!Get.isRegistered<AdminChatController>(tag: thread.userId)) {
    Get.put(
      AdminChatController(targetUserId: thread.userId),
      tag: thread.userId,
      permanent: false,
    );
  }
}
```

**What happens:**
1. Thread is loaded via REST (backward compatible)
2. AdminChatController is created with target user ID
3. Controller is registered with GetX using user ID as tag
4. UI now has access to real-time WebSocket controller

### Controller Initialization: `admin_chat_controller.dart`

```dart
@override
void onInit() {
  super.onInit();
  _boot();  // Start everything
}

Future<void> _boot() async {
  await _loadHistory();        // Step 1: Load via REST (fast)
  unawaited(_connectWs());     // Step 2: Connect WS (background)
}
```

**Timeline:**
- T=0ms: Controller created
- T=100ms: History loaded from REST
- T=200ms: WebSocket connecting
- T=300ms: WebSocket ready, init event received

### WebSocket Connection: `_connectWs()`

```dart
Future<void> _connectWs() async {
  // Get admin's bearer token
  final token = _storage.getAuthToken();
  
  // Construct WebSocket URL: wss://backend/ws/chat/{userId}?token={token}
  final wsUrl = ApiConfig.chatWebSocketUrl(targetUserId, token);
  
  // Connect
  _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  
  // Listen for events
  _wsSub = _channel!.stream.listen(_onEvent);
  
  // Wait for connection ready
  await _channel!.ready;
}
```

**Key points:**
- URL constructed with user ID + admin token
- Stream subscription listens for all events
- Awaits ready state before marking `isConnected = true`

### Event Handling: `_onEvent()`

```dart
void _onEvent(dynamic raw) {
  final data = jsonDecode(raw) as Map<String, dynamic>;
  final event = data['event'] as String;
  
  switch (event) {
    case 'init':
      // Server sends last 50 messages on connect
      final messages = data['messages'] as List;
      _mergeMessages(messages.map(...).toList());
      
    case 'new_message':
      // New message from user → insert and rebuild
      final msg = Message.fromJson(data['message']);
      _insertMessage(msg);  // Adds to RxList → Obx rebuilds!
      
    case 'sent':
      // Server confirmed our message was sent
      final confirmed = Message.fromJson(data['message']);
      _replaceOldestTemp(confirmed);  // Replace temp ID with real ID
      
    case 'message_read':
      // User read our messages
      _markAllOutboundRead();
      
    case 'error':
      Get.snackbar('Error', data['meta']['detail']);
  }
}
```

**Flow example:**

```
User sends message from mobile app
        ↓
Admin receives WebSocket event: new_message
        ↓
_onEvent() parses JSON
        ↓
_insertMessage(msg) adds to RxList
        ↓
RxList mutated → Obx rebuilds
        ↓
ListView rebuilds automatically
        ↓
New message visible on screen
```

### UI Reactivity: `Obx()` Wrapper

```dart
// In messages_screen.dart
Expanded(
  child: Obx(() {  // ← Magic: This rebuilds when messages changes
    final displayMessages = adminChat.filteredMessages;
    
    return ListView.builder(
      itemCount: displayMessages.length,
      itemBuilder: (_, i) => _buildMessageBubble(displayMessages[i]),
    );
  }),
),
```

**How it works:**
1. `adminChat.messages` is an `RxList<Message>` (GetX observable)
2. Inside `Obx()`, reading `adminChat.messages` registers a watcher
3. When `messages.add()` or `messages.assignAll()` is called, Obx rebuilds
4. **No manual setState needed!**

### Sending a Message

```dart
// User clicks send button in UI
await adminChat.sendMessage(
  body: "Hello!",
  messageType: "live",
  subject: null,
);
```

**Controller method:**
```dart
Future<void> sendMessage({
  required String body,
  String messageType = 'live',
  String? subject,
}) async {
  // 1. Create temporary message with id="temp_*"
  final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
  _insertMessage(Message(id: tempId, ...));  // Add to list immediately
  
  // 2. Send via WebSocket (if connected) or HTTP (fallback)
  try {
    if (isConnected.value && _channel != null) {
      // Send via WebSocket
      _channel!.sink.add(jsonEncode({
        'message_type': messageType,
        'body': body,
        'subject': subject,
      }));
    } else {
      // Fallback to HTTP
      await _api.post(ApiConfig.chatSendUrl(), {...});
    }
  } finally {
    isSending.value = false;
  }
}
```

**Timeline:**
- T=0ms: Click send
- T=10ms: Temp message added to RxList
- T=20ms: UI rebuilds showing pending message
- T=30ms: Send via WS/HTTP
- T=500ms: Server confirms with "sent" event
- T=510ms: `_replaceOldestTemp()` replaces ID
- T=520ms: UI updates with real message ID

### Message List Mutations

Key insight: **Every mutation must go through RxList methods**

```dart
// ✅ These trigger Obx rebuilds
messages.add(msg);                  // Add one
messages.assignAll(newList);        // Replace all
messages[i] = updatedMsg;           // Update one

// ❌ These DON'T trigger rebuilds
messages.clear();                   // Use assignAll([]) instead
messages.removeAt(i);               // Avoid remove operations
final m = messages;                 // Plain reference doesn't rebuild
```

**Real example from code:**

```dart
void _insertMessage(Message msg) {
  final idx = messages.indexWhere((m) => m.id == msg.id);
  if (idx == -1) {
    messages.add(msg);  // ✅ RxList mutation → rebuild
  } else {
    messages[idx] = msg;  // ✅ RxList mutation → rebuild
  }
}
```

### Reconnection Logic

```dart
// When WS disconnects:
onError: (e) {
  print('[AdminChat] ❌ WS error: $e');
  isConnected.value = false;
  if (!_manualClose) _scheduleReconnect();
}

void _scheduleReconnect() {
  _reconnectTimer?.cancel();
  final delay = _reconnectDelay;
  _reconnectDelay = (_reconnectDelay * 2).clamp(2, 64);  // Exponential
  print('[AdminChat] 🔄 Reconnect in ${delay}s');
  
  _reconnectTimer = Timer(Duration(seconds: delay), () {
    unawaited(_connectWs());  // Try again
  });
}
```

**Backoff sequence:**
- Attempt 1 fails at T=0s
- Schedule retry at T=2s
- Attempt 2 fails
- Schedule retry at T=4s
- Attempt 3 fails
- Schedule retry at T=8s
- ... up to 64s max
- Once reconnected: reset to 2s

---

## 🔄 Data Models

### Message Model Evolution

**Old (HTTP polling only):**
```dart
class Message {
  String id;
  String direction;  // user_to_admin | admin_to_user
  String body;
  bool isRead;
  DateTime createdAt;
}
```

**New (WebSocket + HTTP):**
```dart
class Message {
  String id;
  String direction;
  String messageType;      // ← NEW: "live" or "static"
  String? subject;         // ← NEW: for formal emails
  String body;
  String? attachmentUrl;   // ← NEW: image URL
  bool isRead;
  String createdAt;        // ← CHANGED: now ISO8601 string
  
  // Helpers
  bool get isLiveMessage => messageType == 'live';
  bool get isStaticMessage => messageType == 'static';
  DateTime get parsedCreatedAt => DateTime.parse(createdAt);
}
```

### API Response Example

**Server sends:**
```json
{
  "event": "new_message",
  "message": {
    "id": "uuid-123",
    "direction": "user_to_admin",
    "message_type": "live",
    "subject": null,
    "body": "Hello admin!",
    "attachment_url": null,
    "is_read": false,
    "created_at": "2026-04-14T18:49:54Z"
  }
}
```

**Client processes:**
```dart
final msg = Message.fromJson(data['message']);
// msg.messageType = "live"
// msg.isLiveMessage = true
// msg.parsedCreatedAt = DateTime(2026, 4, 14, 18, 49, 54)
```

---

## 🎨 UI Building Blocks

### Live Chat Bubble

```dart
Widget _buildMessageBubble(Message message) {
  if (message.isStaticMessage) {
    return _buildStaticMailCard(message, message.isFromUser);
  }
  
  // Live bubble
  return Align(
    alignment: message.isFromUser ? Alignment.centerLeft : Alignment.centerRight,
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: message.isFromUser ? Colors.grey : Colors.blue,
        ),
      ),
      child: Column(
        children: [
          Text(message.body),
          SizedBox(height: 4),
          Text(
            Formatters.formatRelativeTime(message.parsedCreatedAt),
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
```

### Static Email Card

```dart
Widget _buildStaticMailCard(Message message, bool isFromUser) {
  return Container(
    decoration: BoxDecoration(
      color: isFromUser ? Color(0xFFF5F5F5) : Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        // Header with subject
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isFromUser ? Colors.grey[300] : Colors.blue.withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FORMAL MESSAGE'),
              Text(message.subject ?? '(No Subject)'),
            ],
          ),
        ),
        // Body
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(message.body),
        ),
      ],
    ),
  );
}
```

---

## 🔌 API Integration Points

### ApiConfig Helper

```dart
class ApiConfig {
  // WebSocket URL: wss://backend/ws/chat/{userId}?token={token}
  static String chatWebSocketUrl(String userId, String adminToken) {
    final baseUrl = AppConstants.baseUrl
        .replaceAll('https://', 'wss://')
        .replaceAll('http://', 'ws://');
    return '$baseUrl/ws/chat/$userId?token=$adminToken';
  }
  
  // HTTP endpoints
  static String chatHistoryUrl(String userId) => '...';
  static String chatSendUrl() => '...';
}
```

### ApiService Methods

**Generic methods for chat:**
```dart
// Send any JSON payload
Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
  final response = await http.post(
    Uri.parse(endpoint),
    headers: _getHeaders(),
    body: json.encode(body),
  );
  return _parseResponse(response);
}

// Get any endpoint
Future<dynamic> get(String endpoint) async {
  final response = await http.get(
    Uri.parse(endpoint),
    headers: _getHeaders(),
  );
  return _parseResponse(response);
}
```

**Usage in controller:**
```dart
// Fallback send via HTTP
await _api.post(ApiConfig.chatSendUrl(), {
  'message_type': messageType,
  'body': body,
  'subject': subject,
});

// Load history
final res = await _api.getUserMessages(userId, limit: 50, offset: 0);
```

---

## 🔐 State Management with GetX

### Reactive Variables

```dart
// In AdminChatController
final messages = <Message>[].obs;          // RxList — observable
final isConnected = false.obs;             // RxBool — observable
final isLoading = false.obs;               // RxBool — observable
final messageTypeFilter = 'all'.obs;       // RxString — observable
```

### Controller Registration

```dart
// Register per conversation
Get.put(
  AdminChatController(targetUserId: userId),
  tag: userId,  // ← Tag is IMPORTANT for multiple instances
  permanent: false,  // ← Auto-delete on close
);

// Retrieve in UI
final adminChat = Get.find<AdminChatController>(tag: userId);

// Delete when done
Get.delete<AdminChatController>(tag: userId);
```

### Reactive Widgets

```dart
// Obx rebuilds when any read reactive variable changes
Obx(() => Text(adminChat.isConnected.value ? 'Live' : 'Reconnecting'))

// Can have multiple Obx reading different variables
Obx(() => messages.isEmpty ? EmptyWidget() : MessageList())
Obx(() => adminChat.isSending.value ? Spinner() : SendButton())
```

---

## ⚡ Performance Optimizations

### 1. History Loaded First
```dart
// Message history available immediately
await _loadHistory();  // Takes ~100-200ms

// WebSocket connects in background
unawaited(_connectWs());  // Non-blocking
```

### 2. Message Deduplication
```dart
void _mergeMessages(List<Message> incoming) {
  final map = <String, Message>{for (final m in messages) m.id: m};
  for (final m in incoming) map[m.id] = m;  // Overwrites if exists
  final sorted = map.values.toList()..sort(...);
  messages.assignAll(sorted);  // Atomic update
}
```

### 3. Single WebSocket Connection
```dart
// One WS per conversation
_channel = WebSocketChannel.connect(Uri.parse(wsUrl));

// Shared stream to all listeners
_wsSub = _channel!.stream.listen(_onEvent);
```

### 4. Controller Cleanup
```dart
@override
void onClose() {
  _channel?.sink.close();  // Close connection
  _wsSub?.cancel();        // Cancel subscription
  _reconnectTimer?.cancel();  // Cancel timer
  // Do NOT close stream controller — lets it be GC'd
}
```

---

## 🧪 Testing Points

### Unit Test Example: Message Model

```dart
void main() {
  group('Message Model', () {
    test('parses live message', () {
      final json = {
        'id': 'msg-1',
        'direction': 'admin_to_user',
        'message_type': 'live',
        'subject': null,
        'body': 'Hello',
        'is_read': false,
        'created_at': '2026-04-14T18:00:00Z',
      };
      final msg = Message.fromJson(json);
      
      expect(msg.isLiveMessage, true);
      expect(msg.isStaticMessage, false);
      expect(msg.isFromAdmin, true);
    });
  });
}
```

### Widget Test Example: Message Bubble

```dart
void main() {
  testWidgets('displays live message correctly', (tester) async {
    final msg = Message(
      id: 'msg-1',
      direction: 'user_to_admin',
      messageType: 'live',
      body: 'Hello admin',
      isRead: false,
      createdAt: '2026-04-14T18:00:00Z',
    );
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: _buildMessageBubble(msg)),
    ));
    
    expect(find.text('Hello admin'), findsOneWidget);
    expect(find.byType(Align), findsOneWidget);
  });
}
```

---

## 🐛 Debugging Tips

### Check WebSocket Connection

```dart
// In browser DevTools → Network → WS
// Should see:
// GET /ws/chat/{userId}?token=... HTTP/1.1
// → HTTP/1.1 101 Switching Protocols
// → Connected
```

### Monitor Events

```dart
void _onEvent(dynamic raw) {
  print('[AdminChat] 📨 Raw event: $raw');  // Log before parsing
  try {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final event = data['event'] as String;
    print('[AdminChat] Event type: $event');  // Log parsed event
    // ...
  } catch (e) {
    print('[AdminChat] ❌ Parse error: $e');
  }
}
```

### Check Reactive Updates

```dart
// In UI, verify Obx is reading correct variable
Obx(() {
  print('Building with messages: ${adminChat.messages.length}');
  return ListView(...);
})
```

### Trace Message Flow

```
User sends message
  ↓
sendMessage() called
  ↓
Temp message added to RxList
  ↓
UI rebuilds (check Obx print)
  ↓
Send via WS/HTTP
  ↓
Server responds
  ↓
_onEvent() receives 'sent' event
  ↓
_replaceOldestTemp() updates RxList
  ↓
UI rebuilds again with real ID
```

---

## 📖 Reading Order

### First Time Understanding
1. Read `IMPLEMENTATION_SUMMARY.md` (overview)
2. Look at `messages_screen.dart` (UI entry point)
3. Read `AdminChatController.onInit()` and `_boot()`
4. Trace `_connectWs()` → `_onEvent()`
5. See `sendMessage()` implementation
6. Check UI `Obx()` rebuilds

### Deep Dive
1. Read `WEBSOCKET_CHAT_GUIDE.md` (technical details)
2. Study message model evolution
3. Review all event handlers
4. Check performance optimizations
5. Review error handling

### Reference
- `WEBSOCKET_USAGE_EXAMPLES.md` for code patterns
- `UI_LAYOUT_GUIDE.md` for visual reference
- This file for architecture walkthrough

---

This should give you a solid understanding of how the WebSocket chat system works!

