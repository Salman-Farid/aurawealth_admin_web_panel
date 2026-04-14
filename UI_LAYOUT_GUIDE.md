# UI Layout Guide — Admin Chat WebSocket

## 1. Messages Screen — Desktop Layout

```
┌────────────────────────────────────────────────────────────────────┐
│                    AuraWealth Admin Panel                          │
├─────────────────────┬──────────────────────────────────────────────┤
│                     │                                              │
│   CONVERSATIONS     │  USER: John Doe        🟢 Live  💬 📧  🔄    │
│  ┌─────────────────┐│                                              │
│  │ John Doe    [2] ││  ┌──────────────────────────────────────────┐│
│  │ Hi, when can...  ││  │                                          ││
│  │ 2 minutes ago    ││  │  📨 FORMAL MESSAGE                       ││
│  └─────────────────┘│  │  Subject: Account Verification           ││
│                     │  │  ┌──────────────────────────────────────┐││
│  ┌─────────────────┐│  │  │ We have verified your identity.      │││
│  │ Sarah Smith     ││  │  │ Your account is now fully active.     │││
│  │ Thanks for help!││  │  │ Best regards, Admin                   │││
│  │ 1 hour ago      ││  │  │                                       │││
│  └─────────────────┘│  │  2 minutes ago  ✓✓                      │││
│                     │  │ └──────────────────────────────────────┘││
│  ┌─────────────────┐│  │                                          ││
│  │ Mike Johnson    ││  │         Hello, how can I help?      ➡️   ││
│  │ Do you have...  ││  │                                 1s ago    ││
│  │ 3 hours ago     ││  │                                          ││
│  └─────────────────┘│  │  That sounds great! We'll process...➡️   ││
│                     │  │                                 30s ago    ││
│  [Load more...]     │  │                                          ││
│                     │  └──────────────────────────────────────────┘│
│                     │                                              │
│                     │  ┌──────────────────────────────────────────┐│
│                     │  │ 💬 Live  📧 Mail  [All] [Live] [Mail]   ││
│                     │  │ Type your message...          [Send]    ││
│                     │  └──────────────────────────────────────────┘│
│                     │                                              │
└─────────────────────┴──────────────────────────────────────────────┘
```

## 2. Message Types

### Live Chat (💬)
```
┌────────────────────────────────────────┐
│                                        │
│  Hello! How can I help?        [➡️ Admin]
│                         Just now        │
│                                        │
│  [Admin] I need help with my account  │
│         1 minute ago                   │
│                                        │
└────────────────────────────────────────┘
```

### Formal Email (📧)
```
┌────────────────────────────────────────────────────┐
│ 📧 FORMAL MESSAGE                                 │
│ Subject: Account Verification                     │
├────────────────────────────────────────────────────┤
│                                                   │
│ Hello John,                                       │
│                                                   │
│ We have successfully verified your identity.      │
│ Your account is now fully active and ready to use.│
│                                                   │
│ Best regards,                                     │
│ AuraWealth Admin Team                             │
│                                                   │
│ 2 minutes ago                          ✓✓         │
│                                                   │
└────────────────────────────────────────────────────┘
```

## 3. Header with Toggle

```
┌──────────────────────────────────────────────────┐
│ ← John Doe   [Expanded]                          │
│             🟢 Live  [💬 Live] [📧 Mail]  🔄    │
│                                                  │
│ Connection Status:    Message Type Filter:       │
│ • Green dot = live   • Click to toggle views    │
│ • Orange dot = reconnecting                      │
└──────────────────────────────────────────────────┘
```

## 4. Input Box - Live Mode

```
┌──────────────────────────────────────────┐
│ [💬 Live]  [📧 Mail]                    │
├──────────────────────────────────────────┤
│ Type your message...                     │
│                              [Send ➜]   │
│                                          │
│ Character count: 0/500                   │
└──────────────────────────────────────────┘
```

## 5. Input Box - Mail Mode

```
┌──────────────────────────────────────────┐
│ [💬 Live]  [📧 Mail]                    │
├──────────────────────────────────────────┤
│ Subject (required) *                     │
│ [📋 _____________________]               │
│                                          │
│ Message body                             │
│ [Your formal message here...]            │
│                              [Send ➜]   │
│                                          │
│ Character count: 0/500                   │
└──────────────────────────────────────────┘
```

## 6. Connection State Transitions

```
Initial Load
    ↓
[Loading History...]  ← REST call
    ↓
🟠 Connecting... ← WS connecting
    ↓
🟢 Live  ← WebSocket ready + init event
    ↓
If disconnected:
    ↓
🟠 Connecting... (2s backoff)
    ↓
🟠 Connecting... (4s backoff)
    ↓
🟢 Live  ← Reconnected
```

## 7. Message Filter States

```
[💬 Live] [📧 Mail] [All]
    ↓
When "Live" selected:
├─ Hello!
├─ Thanks for help
└─ Do you have issues?

When "Mail" selected:
├─ 📧 Account Verification
├─ 📧 Request Approved
└─ 📧 Transaction Confirmed

When "All" selected:
├─ Hello!
├─ 📧 Account Verification
├─ Thanks for help
├─ 📧 Request Approved
└─ Do you have issues?
```

## 8. Notification Badge

```
Thread List Item:

┌────────────────────┐
│ John Doe      [2]  │  ← Badge shows unread count
│ Hi there!          │
│ 2 minutes ago      │
└────────────────────┘

After opening conversation:
Badge clears automatically when:
- Chat is opened
- init event received
- First message displayed
```

## 9. Responsive Behavior

### Mobile View
```
When in portrait:
┌─────────────────┐
│ Thread List     │
│ (List view)     │
│                 │
│ [Select user]   │
└─────────────────┘

         ↓ Tap thread

┌─────────────────┐
│ Conversation    │
│ ← Back  [toggle]│
│                 │
│ [Messages]      │
│ [Input]         │
└─────────────────┘
```

### Desktop View
```
┌──────────────────────────┐
│ Thread List | Conversation│
│ (side-by-side)           │
│ Always visible           │
└──────────────────────────┘
```

## 10. Error States

### WebSocket Connection Failed
```
┌────────────────────────────┐
│ John Doe    🟠 Reconnecting │
│                             │
│ [Messages loading...]       │
│                             │
│ Trying to reconnect...      │
│ (Will retry in 2 seconds)   │
└────────────────────────────┘
```

### Message Send Failed
```
┌────────────────────────────┐
│                            │
│ ⚠️ Failed to send message   │
│ Please try again            │
│                            │
│ [Type message...]  [Retry] │
└────────────────────────────┘
```

### Empty State
```
┌────────────────────────────┐
│ John Doe                    │
│                            │
│        📭 No messages yet   │
│        Start a conversation│
│                            │
│ [Type your first message...│
│                     [Send] │
└────────────────────────────┘
```

## 11. Timeline

```
Admin Panel → User Mobile App

Admin sends live message "Hi!"
         │
         ├─→ WebSocket → Backend
         │                │
         │                ├─→ FCM Push → User Phone (if offline)
         │                │
         │                ├─→ WebSocket event: new_message
         │                │
         └─→ User receives in <1 second

User sends message "Thanks!"
         │
         ├─→ WebSocket → Backend
         │                │
         │                ├─→ FCM Push → Admin Browser (if offline)
         │                │
         │                ├─→ WebSocket event: new_message
         │                │
         └─→ Admin receives in <1 second (visible without refresh)
```

## 12. Color Scheme

| Element | Color | Usage |
|---------|-------|-------|
| Connection Live | 🟢 Green (#4CAF50) | Active WebSocket |
| Connection Connecting | 🟠 Orange (#FF9800) | Reconnecting |
| Admin Message | Blue (#2196F3) | From admin |
| User Message | Grey (#757575) | From user |
| Error | Red (#F44336) | Errors/validation |
| Success | Green (#4CAF50) | Sent/confirmed |
| Formal Card BG | Light Blue (#F0F4FF) | Mail from admin |
| Formal Card BG | Light Grey (#F5F5F5) | Mail from user |
| Badge | Red (#F44336) | Unread count |

## 13. Keyboard States

### Mobile
```
Avatar → Name → Badge → Unread count
  ↓
Swipe left to see more details

Conversation:
Tap on message → Show timestamp + copy option
Tap on image → Show full image
```

### Desktop
```
Hover on message → Show actions
  - Copy
  - Reply (quoted)
  - Mark read/unread
  - Delete (if own)
```

---

## Accessibility Features

- **Keyboard navigation**: Tab through messages and buttons
- **Screen reader**: All text labels included
- **Contrast**: Minimum WCAG AA compliance
- **Touch targets**: Minimum 48x48dp on mobile
- **Status indicators**: Both color + text (e.g., "Live" text + green dot)

---

This layout provides:
✅ Clear visual hierarchy  
✅ Easy distinction between message types  
✅ Status visibility  
✅ Mobile-friendly responsive design  
✅ Accessibility compliance  

