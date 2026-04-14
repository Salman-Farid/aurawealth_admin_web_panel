# Real-World Usage Examples — Admin Chat WebSocket

This document contains copy-paste ready examples for common scenarios.

---

## Example 1: Initialize Chat on Thread Selection

**Location**: `messages_screen.dart` → `_buildThreadItem()`

```dart
Widget _buildThreadItem(
    BuildContext context, MessageThread thread, MessageController controller) {
  return Obx(() {
    final isSelected = controller.selectedUserId.value == thread.userId;

    return ListTile(
      // ... other properties ...
      onTap: () {
        controller.loadUserMessages(thread.userId);
        
        // ✅ Initialize AdminChatController for WebSocket
        if (!Get.isRegistered<AdminChatController>(tag: thread.userId)) {
          Get.put(
            AdminChatController(targetUserId: thread.userId),
            tag: thread.userId,
            permanent: false,
          );
        }
      },
    );
  });
}
```

---

## Example 2: Display Messages with Live/Mail Toggle

**Location**: `messages_screen.dart` → `_buildConversation()` header

```dart
// Connection status indicator
Obx(() {
  final adminChat = Get.find<AdminChatController>(tag: controller.selectedUserId.value);
  return Row(
    children: [
      // Green dot if live, orange if reconnecting
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: adminChat.isConnected.value ? Colors.green : Colors.orange,
        ),
      ),
      SizedBox(width: 4),
      Text(
        adminChat.isConnected.value ? 'Live' : 'Connecting…',
        style: TextStyle(
          fontSize: 12,
          color: adminChat.isConnected.value ? Colors.green : Colors.orange,
        ),
      ),
    ],
  );
});
```

---

## Example 3: Reactive Message List

**Location**: `messages_screen.dart` → `_buildConversation()` message list

```dart
Expanded(
  child: Obx(() {
    final adminChat = Get.find<AdminChatController>(tag: controller.selectedUserId.value);
    
    // This automatically rebuilds whenever filteredMessages changes
    final displayMessages = adminChat.filteredMessages;

    if (adminChat.isLoadingHistory.value && displayMessages.isEmpty) {
      return LoadingWidget();
    }

    if (displayMessages.isEmpty) {
      return EmptyStateWidget(message: 'No messages');
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: displayMessages.length,
      itemBuilder: (context, index) {
        final message = displayMessages[index];
        return _buildMessageBubble(message);
      },
    );
  }),
),
```

---

## Example 4: Send Live Message

**Location**: Button handler or TextField.onSubmitted

```dart
Future<void> _sendLiveMessage(String text) async {
  final adminChat = Get.find<AdminChatController>(tag: currentUserId);
  
  await adminChat.sendMessage(
    body: text,
    messageType: 'live',
  );
  
  // Clear input field
  _textController.clear();
  
  // Optionally scroll to bottom
  _scrollToBottom();
}
```

**Usage**:
```dart
TextField(
  controller: _textController,
  onSubmitted: _sendLiveMessage,
  // ...
)
```

---

## Example 5: Send Formal Email Message

**Location**: Mail button handler

```dart
Future<void> _sendMailMessage(String subject, String body) async {
  final adminChat = Get.find<AdminChatController>(tag: currentUserId);
  
  // Validation
  if (subject.trim().isEmpty) {
    Get.snackbar('Error', 'Subject is required for formal messages');
    return;
  }
  if (body.trim().isEmpty) {
    Get.snackbar('Error', 'Message body cannot be empty');
    return;
  }
  
  // Send
  await adminChat.sendMessage(
    body: body,
    messageType: 'static',
    subject: subject,
  );
  
  // Clear form
  _subjectController.clear();
  _bodyController.clear();
}
```

---

## Example 6: Listen to Message Type Filter

**Location**: Filter buttons

```dart
Row(
  children: [
    // Show all messages
    _buildFilterButton(
      'All',
      adminChat.messageTypeFilter.value == 'all',
      () => adminChat.setMessageTypeFilter('all'),
    ),
    // Show only live chat
    _buildFilterButton(
      'Live 💬',
      adminChat.messageTypeFilter.value == 'live',
      () => adminChat.setMessageTypeFilter('live'),
    ),
    // Show only mail
    _buildFilterButton(
      'Mail 📧',
      adminChat.messageTypeFilter.value == 'static',
      () => adminChat.setMessageTypeFilter('static'),
    ),
  ],
)

Widget _buildFilterButton(String label, bool isActive, VoidCallback onPressed) {
  return Expanded(
    child: Container(
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    ),
  );
}
```

---

## Example 7: Distinguish Message UI by Type

**Location**: `_buildMessageBubble()`

```dart
Widget _buildMessageBubble(Message message) {
  final isFromUser = message.isFromUser;
  
  // Different UI for static vs live
  if (message.isStaticMessage) {
    return _buildStaticMailCard(message, isFromUser);
  }
  
  // Default: live chat bubble
  return Align(
    alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
    child: Container(
      constraints: BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFromUser ? Colors.grey[300]! : Colors.blue,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.body),
          SizedBox(height: 4),
          Text(
            Formatters.formatRelativeTime(message.parsedCreatedAt),
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}
```

---

## Example 8: Static Message Card (Mail Style)

**Location**: `_buildStaticMailCard()`

```dart
Widget _buildStaticMailCard(Message message, bool isFromUser) {
  return Align(
    alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
    child: Container(
      constraints: BoxConstraints(maxWidth: 600),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isFromUser ? Color(0xFFF5F5F5) : Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFromUser ? Colors.grey[300]! : Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with subject
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFromUser ? Colors.grey[300] : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FORMAL MESSAGE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        message.subject ?? '(No Subject)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.mail_outline, size: 20),
              ],
            ),
          ),
          // Body
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.body,
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.formatRelativeTime(message.parsedCreatedAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    if (message.isRead)
                      Icon(Icons.done_all, size: 14, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## Example 9: Dual Input Mode (Live + Mail)

**Location**: Reply/send box

```dart
class _ReplyBoxState extends State<_ReplyBox> {
  late final TextEditingController _bodyController;
  late final TextEditingController _subjectController;
  final messageType = 'live'.obs;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    _subjectController = TextEditingController();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminChat = Get.find<AdminChatController>(tag: userId);

    return Container(
      padding: EdgeInsets.all(16),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message type selector
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildModeButton('💬 Live', messageType.value == 'live', 
                      () => messageType.value = 'live'),
                    SizedBox(width: 8),
                    _buildModeButton('📧 Mail', messageType.value == 'static',
                      () => messageType.value = 'static'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          
          // Subject field (only for mail)
          if (messageType.value == 'static')
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Subject (required)...',
                  prefixIcon: Icon(Icons.subject),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          
          // Body input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: messageType.value == 'live' 
                        ? 'Type message...'
                        : 'Type message body...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    counterText: '',
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: adminChat.isSending.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.send),
                onPressed: adminChat.isSending.value ? null : _handleSend,
              ),
            ],
          ),
        ],
      )),
    );
  }

  void _handleSend() {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;

    final adminChat = Get.find<AdminChatController>(tag: userId);
    
    adminChat.sendMessage(
      body: body,
      messageType: messageType.value,
      subject: messageType.value == 'static' ? _subjectController.text.trim() : null,
    ).then((_) {
      _bodyController.clear();
      _subjectController.clear();
    });
  }

  Widget _buildModeButton(String label, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Example 10: Close Conversation (Cleanup)

**Location**: Back button or navigation away

```dart
void closeConversation(String userId) {
  // Delete the AdminChatController
  // This closes the WebSocket and prevents memory leaks
  Get.delete<AdminChatController>(tag: userId);
  
  // Navigate back
  Get.back();
}

// Usage in AppBar back button
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () {
    closeConversation(controller.selectedUserId.value);
  },
)
```

---

## Example 11: Handle Connection State in UI

**Location**: Conversation header

```dart
Obx(() {
  final adminChat = Get.find<AdminChatController>(tag: userId);
  
  return Row(
    children: [
      // Status indicator
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: adminChat.isConnected.value 
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: adminChat.isConnected.value ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(width: 6),
            Text(
              adminChat.isConnected.value ? 'Live' : 'Reconnecting…',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: adminChat.isConnected.value ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 12),
      
      // Reconnection timer (if applicable)
      if (!adminChat.isConnected.value)
        Text(
          'Will retry soon',
          style: TextStyle(fontSize: 10, color: Colors.orange),
        ),
    ],
  );
});
```

---

## Example 12: Show Unread Badge

**Location**: Thread list item

```dart
Obx(() {
  final adminChat = Get.find<AdminChatController>(tag: thread.userId);
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: adminChat.unreadCount.value > 0 ? Colors.red : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      adminChat.unreadCount.value > 0 
          ? adminChat.unreadCount.toString()
          : '',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
});

// Clear unread when user opens conversation
void openConversation(String userId) {
  final adminChat = Get.find<AdminChatController>(tag: userId);
  adminChat.clearUnreadCount();
}
```

---

## Tips & Tricks

### ✅ Do This

```dart
// ✅ Read in Obx - automatically rebuilds
Obx(() => ListView(itemBuilder: (_, i) => 
  ListTile(title: Text(controller.messages[i].body))
))

// ✅ Send via controller - uses WS or HTTP
await adminChat.sendMessage(body: text, messageType: 'live');

// ✅ Access reactive lists
adminChat.filteredMessages.length
```

### ❌ Don't Do This

```dart
// ❌ Read outside Obx - no rebuilds
final msgs = controller.messages;
ListView(itemBuilder: (_, i) => Text(msgs[i].body))

// ❌ Manual setState
setState(() { messages.add(msg); })

// ❌ Close the stream controller
_streamCtrl.close(); // This stops all rebuilds!
```

---

For more info, see `WEBSOCKET_CHAT_GUIDE.md`.

