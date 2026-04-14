# Admin Panel WebSocket Chat Integration — Complete Implementation Guide

## Overview

The admin panel now has **real-time WebSocket chat** with **live (💬) and static mail (📧) message modes**, replacing the old HTTP-only polling system. All connections automatically fall back to HTTP if WebSocket fails.

---

## Architecture

### Components Created

1. **`AdminChatController`** (`lib/controllers/admin_chat_controller.dart`)
   - Manages WebSocket lifecycle for a single user conversation
   - Handles automatic reconnection with exponential backoff
   - Reactive `RxList<Message>` that triggers UI rebuilds automatically
   - HTTP fallback for send operations if WS is down
   - Message type filtering (live/static/all)

2. **`ApiConfig`** (`lib/core/config/api_config.dart`)
   - Centralized API endpoint builder
   - WebSocket URL construction with token
   - HTTP endpoint helpers

3. **Updated UI** (`lib/views/messages/messages_screen.dart`)
   - Live/Mail toggle button in conversation header
   - Connection status indicator (green dot = live, orange = reconnecting)
   - Two distinct message UI styles:
     - **Live**: Compact chat bubbles (like WhatsApp)
     - **Static**: Email-style formal cards with subject/body
   - Dual input mode: live or static message composition

4. **Enhanced Message Model** (`lib/models/message.dart`)
   - New fields: `messageType`, `subject`, `attachmentUrl`
   - Helper getters: `isLiveMessage`, `isStaticMessage`
   - ISO8601 string timestamps (from server)

---

## Data Flow

### Initialization
```
User opens conversation
  ↓
AdminChatController created + registered with tag (userId)
  ↓
_boot() → _loadHistory() (HTTP REST) + _connectWs() (background)
  ↓
Messages displayed from history immediately
  ↓
WebSocket connects → init event with last 50 messages
  ↓
Messages merged (deduplication by ID)
```

### Real-time Events
```
New message from user
  ↓
WebSocket event: "new_message"
  ↓
_onEvent() decodes JSON
  ↓
_insertMessage() adds to RxList<Message>
  ↓
Obx(() => ListView) automatically rebuilds
  ↓
New message visible without refresh
```

### Send (Admin → User)
```
Admin types + selects Live/Mail
  ↓
Validates: Live needs body; Mail needs subject + body
  ↓
Creates temporary message with id="temp_*"
  ↓
Sends via WebSocket (if connected) OR HTTP (fallback)
  ↓
Server confirms → "sent" event
  ↓
_replaceOldestTemp() replaces temp with confirmed ID
  ↓
isSending flag cleared
```

---

## Key Features

### 1. Live Chat (💬) Mode
- **Fast**, real-time WhatsApp-style bubbles
- No subject required
- Supports image attachments
- Emoji + formatting preserved
- Maximum 500 chars

### 2. Static/Email (📧) Mode
- **Formal** message card with visible subject
- Subject **required** (validation enforced)
- Professional email-like design
- Best for support queries, formal responses
- No emoji, plain text body

### 3. WebSocket Resilience
- **Automatic reconnection** with exponential backoff: 2s → 4s → 8s → ... → 64s
- **HTTP fallback** if WS unavailable
- **Connection indicator** shows live/reconnecting status
- No message loss — history always fetched first

### 4. Reactive UI
- Uses `RxList<Message>` — mutations automatically trigger rebuilds
- No `setState`, no `StreamBuilder`
- Wrap message list in `Obx(() => ...)` and read `controller.messages`
- Filter by message type: Live, Mail, or All

---

## Implementation Details

### AdminChatController Setup

```dart
// When user taps a conversation thread:
if (!Get.isRegistered<AdminChatController>(tag: thread.userId)) {
  Get.put(
    AdminChatController(targetUserId: thread.userId),
    tag: thread.userId,
    permanent: false,
  );
}

// When user closes conversation:
Get.delete<AdminChatController>(tag: userId);
```

### Retrieve Controller in UI

```dart
final adminChat = Get.find<AdminChatController>(tag: controller.selectedUserId.value);

// Read filtered messages (reactive)
Obx(() {
  final msgs = adminChat.filteredMessages; // auto-updates with filter
  return ListView(
    itemCount: msgs.length,
    itemBuilder: (_, i) => _buildMessageBubble(msgs[i]),
  );
});
```

### Send a Message

```dart
await adminChat.sendMessage(
  body: "Your message text",
  messageType: "live",  // or "static"
  subject: null,        // required only for static
);
```

---

## WebSocket Event Reference

| Event | Sent By | Payload | Action |
|---|---|---|---|
| `init` | Server (on connect) | `messages: [MessageObject]` | Merge with existing; dedup by ID |
| `new_message` | Server | `message: MessageObject` | Insert; increment unread; rebuild |
| `sent` | Server | `message: MessageObject` | Replace temp ID with confirmed; clear sending flag |
| `message_read` | Server | `meta: {direction, count}` | Mark outbound messages as read |
| `error` | Server | `meta: {detail: string}` | Show snackbar error |

---

## Testing Checklist

### Local Testing

- [ ] **Boot**: Open a user conversation → message history loads immediately
- [ ] **WebSocket**: Live dot turns green within 3 seconds
- [ ] **Send Live**: Type message → send → appears instantly (no refresh)
- [ ] **Send Mail**: Type mail with subject → send → formal card appears
- [ ] **Validation**: Try to send mail without subject → snackbar error
- [ ] **Reconnect**: Kill network → watch timer count up (2s, 4s, 8s...)
- [ ] **Fallback**: Turn off WS but keep HTTP → send message via HTTP
- [ ] **Filter**: Click "Live" or "Mail" button → messages filter correctly
- [ ] **Unread**: Close and re-open → unread count badge visible
- [ ] **Connection Status**: Watch dot change color as connection state changes

### Production Testing

1. Deploy to staging
2. Open admin panel in browser
3. Open user mobile app in parallel
4. Send message from user → admin panel receives instantly (no refresh)
5. Admin sends live message → user receives within 1 second
6. Admin sends mail message → user sees formal card
7. Close browser → mobile can still send
8. Reopen browser → history loads, reconnects live

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Messages not updating | Using `setState` or old `StreamBuilder` pattern | Use `Obx(() => controller.messages)` |
| Must refresh to see new message | `_insertMessage()` not called | Check `_onEvent()` handler in controller |
| WebSocket never connects | Missing/expired admin token | Check `StorageService.getAuthToken()` returns valid JWT |
| "WebSocket 401" | Token is not included in URL | `ApiConfig.chatWebSocketUrl()` must pass token as query param |
| "WebSocket 404" | Wrong user ID in path | Use backend UUID, not Firebase UID |
| Message appears as temp ID forever | `sent` event never received | Check WebSocket stream subscription |
| Reconnect loop at 2s | Server keeps rejecting | Check token expiry; refresh token if needed |
| Image upload 400 "format not accepted" | Missing `Content-Type` on multipart field | Pass `contentType: MediaType('image', 'jpeg')` to MultipartFile |

---

## API Endpoints Used

| Method | Path | Notes |
|---|---|---|
| GET | `/admin/messages/{userId}?limit=50&offset=0` | Fetch history (HTTP fallback) |
| POST | `/chat/send` | Send message via HTTP (fallback) |
| WebSocket | `/ws/chat/{userId}?token={admin_token}` | Real-time bi-directional |

---

## Dependencies Added

```yaml
web_socket_channel: ^3.0.3  # WebSocket client
http_parser: ^4.0.2         # MIME type support (for multipart uploads)
```

---

## Code Examples

### Example 1: Sending a Live Message

```dart
final adminChat = Get.find<AdminChatController>(tag: userId);

await adminChat.sendMessage(
  body: "Hello! How can I help?",
  messageType: "live",
);
```

### Example 2: Sending a Static (Email) Message

```dart
await adminChat.sendMessage(
  body: "We have reviewed your request and approved the transaction.",
  messageType: "static",
  subject: "Request Approved",
);
```

### Example 3: Filtering Messages

```dart
Obx(() {
  adminChat.setMessageTypeFilter('live'); // Show only live
  adminChat.setMessageTypeFilter('static'); // Show only mail
  adminChat.setMessageTypeFilter('all'); // Show both
  
  final filtered = adminChat.filteredMessages;
  // ...
});
```

### Example 4: Observing Connection Status

```dart
Obx(() {
  if (adminChat.isConnected.value) {
    // Show green dot
  } else {
    // Show orange dot + reconnecting text
  }
});
```

---

## Migration from Old System

**Before** (HTTP polling):
- Message list never auto-updated
- Admin had to manually refresh or navigate away/back
- No distinction between live chat and formal email
- All messages looked the same

**After** (WebSocket + dual modes):
- Messages appear **instantly** without any refresh
- Live chat for quick back-and-forth
- Mail mode for formal, structured responses
- Automatic connection status indication
- HTTP fallback if WebSocket unavailable

---

## Performance Notes

- **Memory**: One `AdminChatController` per open conversation; auto-deleted on close
- **Network**: WebSocket reuses single connection; exponential backoff prevents reconnect spam
- **UI**: `Obx()` only rebuilds widgets reading reactive values; no full-page rebuilds
- **History**: First 50 messages loaded from REST; WebSocket backfills real-time events

---

## Support

For issues:
1. Check browser console for WebSocket errors
2. Verify admin token is valid and not expired
3. Ensure user ID is backend UUID format
4. Check that `/ws/chat/{userId}` endpoint is accessible
5. Review API logs on backend for "new_message" events

