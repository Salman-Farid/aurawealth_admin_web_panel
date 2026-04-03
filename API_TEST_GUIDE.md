# Quick API Test Guide

## Test the Notification APIs from the Flutter App

### 1. Login to Admin Panel
```
Navigate to: http://localhost:XXXX (or your deployment URL)
Email: salmanfarid43@gmail.com (or your admin email)
Password: [Your admin password]
```

### 2. Navigate to Notifications
Click on **"Notifications"** in the sidebar menu (bell icon)

---

## Manual API Testing (cURL)

### Get Admin Token
```bash
curl -X POST "https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/admin/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=salmanfarid43@gmail.com&password=YOUR_PASSWORD"
```

Save the `access_token` from response.

### Test Device Statistics
```bash
curl "https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/admin/devices/stats" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Expected response:
```json
{
  "total_devices": 2,
  "active_devices": 2,
  "inactive_devices": 0,
  "android_devices": 2,
  "ios_devices": 0
}
```

### Get All Devices
```bash
curl "https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/admin/devices/all?active_only=true&limit=100" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Send Test Notification
```bash
curl -X POST "https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/admin/send-notification" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "USER_ID_HERE",
    "title": "Test Notification",
    "body": "This is a test from the admin panel",
    "data": {"test": "true"}
  }'
```

### Send Test Notification with Image
```bash
curl -X POST "https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/admin/send-notification-with-image" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "USER_ID_HERE",
    "title": "🎁 Special Offer!",
    "body": "Check out our latest deals",
    "image_url": "https://picsum.photos/1200/630",
    "data": {"offer_id": "123"}
  }'
```

### Send Broadcast
```bash
curl -X POST "https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/admin/send-broadcast" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "📢 Important Announcement",
    "body": "App maintenance tonight from 12 AM - 2 AM",
    "data": {"type": "maintenance"}
  }'
```

---

## Expected Behavior in Flutter App

### Send Tab
1. **Load Users**: Users dropdown should populate with all users
2. **Validation**: Empty title/body shows error snackbar
3. **Image Toggle**: Shows/hides image URL field
4. **Loading State**: Button shows spinner while sending
5. **Success**: Green snackbar with "Notification sent to N device(s)"
6. **Error**: Red snackbar with error message

### Device Management Tab
1. **Device List**: Shows all devices with user info
2. **Search**: Filters in real-time as you type
3. **Platform Filter**: Dropdown filters by Android/iOS/Web
4. **Active Toggle**: Shows only active or all devices
5. **Copy Token**: Copies to clipboard with success message
6. **View User Devices**: Opens dialog with all user's devices
7. **Deactivate**: Shows confirmation, then removes from list

### Statistics Tab
1. **Stat Cards**: Animates on load with scale effect
2. **Platform Bars**: Shows percentage distribution
3. **Auto-refresh**: Updates when you deactivate devices

---

## Troubleshooting

### "No devices found"
- Check if any users have registered devices
- Try toggling "Active Only" filter off
- Clear search filter

### "Failed to send notification"
- Verify user has at least one active device
- Check admin token is valid (not expired)
- Verify API endpoint is reachable

### "Error loading devices"
- Check internet connection
- Verify admin token in storage
- Check console for detailed error

### Users dropdown is empty
- UserController must be initialized first
- Try navigating to Users tab first, then back to Notifications

---

## Sample Use Cases

### Use Case 1: Flash Sale
```json
{
  "title": "🔥 Flash Sale Alert!",
  "body": "50% off all gold purchases for the next 2 hours only!",
  "image_url": "https://your-cdn.com/flash-sale-banner.jpg",
  "data": {
    "type": "flash_sale",
    "discount": "50",
    "expires_at": "2026-04-03T14:00:00Z"
  }
}
```

### Use Case 2: Price Update
```json
{
  "title": "💰 Gold Price Update",
  "body": "Current gold price: ৳6,200 per gram",
  "data": {
    "type": "price_update",
    "price": "6200",
    "currency": "BDT"
  }
}
```

### Use Case 3: Transaction Approved
```json
{
  "user_id": "abc-123-def",
  "title": "✅ Transaction Approved",
  "body": "Your sell request for 5.5g has been approved",
  "data": {
    "type": "transaction_status",
    "tx_id": "tx_456",
    "status": "approved"
  }
}
```

---

## Performance Tips

1. **Broadcast Carefully**: Only use when necessary (affects all users)
2. **Image URLs**: Use CDN links for faster loading
3. **Data Payload**: Keep under 4KB for best delivery
4. **Active Filter**: Keep enabled to avoid loading inactive devices
5. **Search Wisely**: Clear search when browsing all devices

---

**Happy Testing! 🎉**
