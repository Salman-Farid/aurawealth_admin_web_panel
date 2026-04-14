# 🔧 Admin Chat — Corrected WebSocket + REST Integration

## ✅ FIXED ISSUES

### Issue 1: Wrong WebSocket Endpoint
**❌ Before**: `/ws/chat/{userId}` (user endpoint, needs Firebase token)  
**✅ After**: `/ws/admin/chat/{userId}` (admin endpoint, uses admin JWT)

### Issue 2: Wrong Auth Token
**❌ Before**: Trying to use Firebase ID token  
**✅ After**: Using admin bearer token from `/admin/login`

### Issue 3: Wrong REST Endpoints  
**❌ Before**: `/chat/send`, `/chat/history`, `/chat/upload-image`  
**✅ After**: `/admin/chat/send/{userId}`, `/admin/chat/history/{userId}`, etc.

### Issue 4: Minimal Logging
**❌ Before**: Generic error messages  
**✅ After**: Detailed troubleshooting logs with hints

---

## 🔌 WebSocket Connection — CORRECT

### Endpoint
```
WS /ws/admin/chat/{user_id}?token=<admin_jwt>
```

### Auth
- Token source: **Admin JWT** from `POST /admin/login`
- Storage: **StorageService.getAuthToken()**
- NOT Firebase token

### Example
```
wss://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/ws/admin/chat/862c0a31-e197-4fc4-9318-cf380b566f36?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 📨 WebSocket Events

### On Connect → `init` Event
```json
{
  "event": "init",
  "messages": [ ...last 50 messages... ],
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "phone": "+8801700000000",
    "is_online": true
  }
}
```

### New Message from User → `message` Event
```json
{
  "event": "message",
  "message": {
    "id": "uuid",
    "direction": "user_to_admin",
    "message_type": "live",
    "body": "I have a question",
    "attachment_url": null,
    "created_at": "2026-04-14T10:01:00Z"
  }
}
```

### Admin Sends Message → Server Echo
```
Client sends:
{
  "message_type": "live",
  "body": "Your issue has been resolved.",
  "subject": null,
  "attachment_url": null
}

Server responds (event: "sent"):
{
  "event": "sent",
  "message": {
    "id": "real-uuid",
    "direction": "admin_to_user",
    "message_type": "live",
    "body": "Your issue has been resolved.",
    "attachment_url": null,
    "created_at": "2026-04-14T10:00:00Z"
  }
}
```

### Other Events
```json
{ "event": "message_read", "meta": { "direction": "user_to_admin", "count": 3 } }
{ "event": "error", "meta": { "detail": "Invalid message format" } }
```

---

## 🔄 REST Endpoints — CORRECT

### Get Inbox
```
GET /admin/chat/inbox
Authorization: Bearer <admin_jwt>

Response:
[
  {
    "user_id": "uuid",
    "user_name": "John Doe",
    "unread_count": 2,
    "last_message": "I need help",
    "last_at": "2026-04-14T10:00:00Z",
    "is_online": true
  }
]
```

### Get User History
```
GET /admin/chat/history/{user_id}?limit=50&offset=0
Authorization: Bearer <admin_jwt>

Response:
[
  {
    "id": "uuid",
    "direction": "user_to_admin",
    "message_type": "live",
    "subject": null,
    "body": "I need help",
    "attachment_url": null,
    "is_read": true,
    "created_at": "2026-04-14T10:00:00Z"
  }
]
```

### Send Message (REST fallback)
```
POST /admin/chat/send/{user_id}
Authorization: Bearer <admin_jwt>
Content-Type: application/json

{
  "message_type": "live",
  "body": "Your request is approved.",
  "subject": null,
  "attachment_url": null
}

Response:
{
  "id": "uuid",
  "direction": "admin_to_user",
  "message_type": "live",
  "body": "Your request is approved.",
  "created_at": "2026-04-14T10:00:00Z"
}
```

### Send with Image
```
POST /admin/chat/send-with-image/{user_id}
Authorization: Bearer <admin_jwt>
Content-Type: multipart/form-data

Fields:
- image: (file)
- body: "See attached"
- message_type: "live"
- subject: (optional, required if message_type=static)
```

### Mark as Read
```
POST /admin/chat/read/{user_id}
Authorization: Bearer <admin_jwt>

Response:
{ "marked_read": 3 }
```

---

## 🎯 Implementation Details

### ApiConfig Methods (Updated)
```dart
// WebSocket for admin chat
String adminChatWebSocketUrl(String userId, String adminToken)
  // Returns: wss://backend/ws/admin/chat/{userId}?token={token}

// REST endpoints
String adminChatHistoryUrl(String userId)
  // Returns: https://backend/admin/chat/history/{userId}?limit=50&offset=0

String adminChatSendUrl(String userId)
  // Returns: https://backend/admin/chat/send/{userId}

String adminChatInboxUrl()
  // Returns: https://backend/admin/chat/inbox

String adminChatReadUrl(String userId)
  // Returns: https://backend/admin/chat/read/{userId}
```

### AdminChatController Flow
```
onInit()
  → _boot()
    → _loadHistory()  (REST: GET /admin/chat/history/{userId})
    → _connectWs()    (WebSocket: wss://backend/ws/admin/chat/{userId}?token={adminJwt})
      → _onEvent()    (Handle init, message, sent, error events)
      → _reconnect()  (If disconnected: exponential backoff 2-64s)

sendMessage(body, type, subject)
  → If WS connected: Send JSON over WebSocket
  → Else: POST to /admin/chat/send/{userId}
  → Wait for "sent" event or HTTP response
  → Replace temp message ID with real ID
```

### Logging Output
```
[AdminChat] ✅ History loaded: 39 messages for user 862c0a31-e197-4fc4-9318-cf380b566f36
[AdminChat] 🔌 Connecting WebSocket...
[AdminChat] ℹ️  URL: /ws/admin/chat/862c0a31-e197-4fc4-9318-cf380b566f36
[AdminChat] ℹ️  Auth: Bearer token (admin JWT)
[AdminChat] ⏳ Establishing WebSocket connection...
[AdminChat] ✅ WebSocket connected successfully
[AdminChat] ✅ Waiting for init event with message history...
[AdminChat] 📨 Received event: "init"
[AdminChat] ℹ️  Init event with 39 messages
[AdminChat] 📩 New message from user: "Hello admin, I have a question"
[AdminChat] 📤 Sending message (type: live, id: temp_1234567890)
[AdminChat] ✉️  Sending via WebSocket...
[AdminChat] ✅ Message confirmed and sent
```

---

## 🐛 Troubleshooting

### "Failed to connect WebSocket"
**Cause**: Endpoint or token is wrong  
**Fix**:
1. Check WebSocket URL in logs: Should be `/ws/admin/chat/`
2. Verify admin token is present and valid
3. Check backend is running and endpoint is accessible

### "Invalid or expired Firebase token"
**Cause**: Code is trying to use Firebase token instead of admin JWT  
**Fix**:
1. Ensure StorageService.getAuthToken() returns admin JWT (from `/admin/login`)
2. NOT Firebase ID token
3. Check token is not expired

### "WebSocket 401"
**Cause**: Token is missing or invalid  
**Fix**:
1. Verify admin is logged in
2. Check token in StorageService
3. Test `/admin/login` endpoint manually

### "WebSocket 404"
**Cause**: Wrong endpoint path  
**Fix**:
1. Check logs for actual URL being used
2. Should contain `/ws/admin/chat/` (with `/admin/`)
3. Verify user ID format is UUID

### "Connection keeps reconnecting every 2s"
**Cause**: Backend endpoint or token is still wrong  
**Fix**:
1. Check detailed logs: URL and auth method
2. Test WebSocket endpoint manually with curl/Postman
3. Verify backend logs for connection attempts

---

## ✅ Verification Checklist

Before testing, verify in code:

- [ ] `ApiConfig.adminChatWebSocketUrl()` returns `/ws/admin/chat/`
- [ ] `AdminChatController._connectWs()` uses `StorageService.getAuthToken()`
- [ ] WebSocket URL includes `?token=<admin_jwt>`
- [ ] REST endpoints use `/admin/chat/` path
- [ ] All API calls include Bearer token header
- [ ] Logging shows correct URL and auth method

---

## 📝 API Endpoint Reference

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | `/admin/chat/inbox` | Bearer | Get all conversations |
| GET | `/admin/chat/history/{userId}` | Bearer | Get message history |
| POST | `/admin/chat/send/{userId}` | Bearer | Send message (HTTP fallback) |
| POST | `/admin/chat/read/{userId}` | Bearer | Mark thread read |
| POST | `/admin/chat/send-with-image/{userId}` | Bearer | Send with image |
| WS | `/ws/admin/chat/{userId}?token=` | Query | Real-time messages |

**All endpoints use `Authorization: Bearer <admin_jwt>`** (except WebSocket which uses query param)

---

## 🎓 Key Differences

| Component | User | Admin |
|-----------|------|-------|
| WebSocket endpoint | `/ws/chat/{userId}` | `/ws/admin/chat/{userId}` |
| Auth token type | Firebase ID token | Admin JWT |
| Auth method | Query param only | Query param (WS) + Bearer header (REST) |
| REST endpoints | `/chat/...` | `/admin/chat/...` |
| Init event | Includes last 50 messages | Includes user details + online status |

---

## 🚀 Testing

### Manual WebSocket Test (Browser DevTools)
```javascript
// Open WebSocket
const socket = new WebSocket('wss://backend/ws/admin/chat/UUID?token=ADMIN_JWT');

socket.onopen = () => {
  console.log('✅ Connected');
};

socket.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('📨 Event:', data.event);
};

socket.onerror = (error) => {
  console.error('❌ Error:', error);
};

// Send a message
socket.send(JSON.stringify({
  message_type: 'live',
  body: 'Hello from admin!',
  subject: null,
  attachment_url: null
}));
```

### Check Logs
In browser console (F12 → Console), look for:
- ✅ `[AdminChat] ✅ History loaded`
- ✅ `[AdminChat] ✅ WebSocket connected successfully`
- ✅ `[AdminChat] 📨 Received event: "init"`
- ✅ `[AdminChat] 📩 New message from user`

---

**Status**: ✅ Fixed and Ready  
**Updated**: April 14, 2026

