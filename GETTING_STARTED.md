# 🎯 Getting Started with AuraWealth Admin Panel

Welcome to your new admin panel! This guide will help you get started quickly.

## 📋 What You'll Get

```
╔═══════════════════════════════════════════════════════════════╗
║            AURAWEALTH ADMIN PANEL FEATURES                     ║
╚═══════════════════════════════════════════════════════════════╝

📊 DASHBOARD                   💳 TRANSACTIONS
  ├─ Total Transactions          ├─ View All Transactions
  ├─ Pending Count               ├─ Filter by Status/Type
  ├─ Gold Holdings               ├─ Search Transactions
  ├─ Revenue Tracking            ├─ Mark as Paid
  ├─ Buy/Sell Stats              ├─ Reject Transactions
  └─ Recent Activity             └─ View Details

👥 USERS                       💰 GOLD MANAGEMENT
  ├─ View All Users              ├─ Current Prices
  ├─ Search Users                ├─ Update Market Price
  ├─ User Details                ├─ Auto-Calculate Prices
  └─ Transaction History         └─ Fee Structure Info

💬 MESSAGES                    🛠 MANUAL OPERATIONS
  ├─ Inbox Overview              ├─ Credit Grams (In-Store)
  ├─ Conversation Threads        └─ Redeem Codes
  ├─ Reply to Users
  └─ Unread Counts
```

---

## ⚡ Quick Setup (3 Steps)

### Step 1: Install Flutter
```bash
# Download from: https://flutter.dev
# Or use snap (Linux):
sudo snap install flutter --classic

# Verify:
flutter --version
```

### Step 2: Setup Project
```bash
# Clone repository
git clone https://github.com/Salman-Farid/aurawealth_admin_web_panel.git
cd aurawealth_admin_web_panel

# Install dependencies
flutter pub get
```

### Step 3: Configure & Run
```bash
# Edit this file:
# lib/core/constants/app_constants.dart
# Change: baseUrl = 'YOUR_API_URL'

# Run the app
flutter run -d chrome
```

**🎉 That's it! Your admin panel is now running!**

---

## 🖥️ What You'll See

### 1. Login Screen
```
┌─────────────────────────────────┐
│                                 │
│         💎 AURAWEALTH          │
│          Admin Panel            │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Email                     │ │
│  │ admin@example.com         │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Password                  │ │
│  │ ••••••••                  │ │
│  └───────────────────────────┘ │
│                                 │
│     [  Sign In Button  ]        │
│                                 │
└─────────────────────────────────┘
```

**First Time Login:**
- Email: salmanfarid43@gmail.com
- Password: salman12345
- ⚠️ Change these credentials in production!

### 2. Dashboard (After Login)
```
┌─Sidebar──┬───────────────────────────────────────────────────┐
│          │ 📊 Dashboard                          [Profile ▼] │
│ [LOGO]   ├───────────────────────────────────────────────────┤
│ AuraWlth │                                                    │
│          │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐          │
│▸Dashboard│  │ 247  │  │  12  │  │125.5g│  │45,280│          │
│ Trans    │  │Trans │  │Pendng│  │ Gold │  │  ৳   │          │
│ Users    │  └──────┘  └──────┘  └──────┘  └──────┘          │
│ Gold     │                                                    │
│ Messages │  ⚠ PENDING TRANSACTIONS (12)                      │
│ Credit   │  [Transaction table with Mark Paid/Reject btns]   │
│ Redeem   │                                                    │
│          │  🕐 RECENT TRANSACTIONS                            │
│ v1.0.0   │  [Recent transaction table]                       │
└──────────┴────────────────────────────────────────────────────┘
```

### 3. Responsive on Mobile
```
┌─────────────────────┐
│ ☰  Dashboard  [👤] │
├─────────────────────┤
│  ┌───────────────┐  │
│  │ Total Trans   │  │
│  │     247       │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Pending       │  │
│  │      12       │  │
│  └───────────────┘  │
│                     │
│  [Stats cards...]   │
│                     │
│  ⚠ Pending (12)     │
│  [Transaction cards]│
└─────────────────────┘
```

---

## 🎮 How to Use

### Managing Transactions

**1. View All Transactions:**
- Click "Transactions" in sidebar
- See complete list of all transactions

**2. Filter Transactions:**
- Use Status dropdown (Pending/Approved/Paid/Rejected)
- Use Type dropdown (5 transaction types)
- Search by ID, email, or code

**3. Take Actions:**
- **Pending Transactions**: Click "Reject" to reject
- **Approved Bank Sells**: Click "Mark as Paid" to complete

### Managing Gold Prices

**1. View Current Prices:**
- Click "Gold Management" in sidebar
- See market price and calculated prices

**2. Update Price:**
- Enter new market price per gram
- Click "Update Price"
- All other prices auto-calculate:
  - Bank Sell: -2%
  - Store Sell: -17%
  - Exchange: -10%

### Handling Messages

**1. View Inbox:**
- Click "Messages" in sidebar
- See all conversation threads
- Unread counts shown

**2. Read & Reply:**
- Click a thread to view conversation
- Type reply in text box
- Click "Send" to reply

### Manual Operations

**1. Credit Grams (In-Store Purchase):**
- Click "Credit Grams" in sidebar
- Enter User ID
- Enter grams amount (min 0.5g, increment 0.5g)
- Click "Credit Grams"
- Transaction auto-approved

**2. Redeem Code (Store/Exchange):**
- Click "Redeem Code" in sidebar
- Enter 6-character code (e.g., A3X9KL)
- Click "Redeem Code"
- Transaction auto-approved if valid

---

## 🎨 Navigation Guide

### Desktop Navigation
- **Sidebar**: Always visible on left
- **Click menu items**: Navigate between screens
- **Profile menu**: Access logout

### Tablet Navigation
- **Drawer icon**: Open/close sidebar
- **Menu items**: Navigate between screens
- **Profile menu**: Access logout

### Mobile Navigation
- **Hamburger menu (☰)**: Open navigation drawer
- **Select screen**: From drawer menu
- **Back button**: Return to previous screen

---

## 💡 Tips & Tricks

### Keyboard Shortcuts
- **Enter**: Submit forms (login, filters)
- **Escape**: Close dialogs
- **Tab**: Navigate between fields

### Quick Actions
- **Dashboard cards**: Click for detailed view
- **Transaction rows**: Click for details
- **User emails**: Click for user details
- **Refresh buttons**: Update data

### Search Tips
- Search transactions by ID, email, or code
- Search users by ID, email, or phone
- Use filters to narrow results
- Combine search with filters

### Performance Tips
- Clear filters when not needed
- Refresh data periodically
- Use pagination for large lists
- Keep browser cache cleared for updates

---

## 🔧 Configuration Checklist

Before first run:

1. **✅ Install Flutter** (3.10.4+)
   ```bash
   flutter --version
   ```

2. **✅ Clone Repository**
   ```bash
   git clone [repo-url]
   cd aurawealth_admin_web_panel
   ```

3. **✅ Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **✅ Configure API**
   ```dart
   // lib/core/constants/app_constants.dart
   static const String baseUrl = 'YOUR_API_URL';
   ```

5. **✅ Verify Backend**
   - API must be running
   - CORS must be configured
   - Admin user must exist

6. **✅ Run Application**
   ```bash
   flutter run -d chrome
   ```

7. **✅ Test Login**
   - Use admin credentials
   - Verify dashboard loads
   - Test each feature

---

## 🎯 Feature Testing Guide

### Test Dashboard
- [ ] Login successfully
- [ ] Verify 8 stat cards display
- [ ] Check pending transactions section
- [ ] Check recent transactions section
- [ ] Try refresh button

### Test Transactions
- [ ] View transaction list
- [ ] Apply status filter
- [ ] Apply type filter
- [ ] Use search
- [ ] Click "Mark as Paid" (if applicable)
- [ ] Click "Reject" and add note
- [ ] Clear filters

### Test Gold Management
- [ ] View current prices
- [ ] Update market price
- [ ] Verify auto-calculations
- [ ] Check price information panel

### Test Users
- [ ] View user list
- [ ] Search for user
- [ ] Open user details
- [ ] View user transactions

### Test Messages
- [ ] View inbox
- [ ] Check unread counts
- [ ] Open conversation
- [ ] Send reply
- [ ] Verify message sent

### Test Credit Grams
- [ ] Enter valid user ID
- [ ] Enter grams (e.g., 5.0)
- [ ] Verify fee calculation
- [ ] Submit form
- [ ] Check success message

### Test Redeem Code
- [ ] Enter 6-character code
- [ ] Verify auto-uppercase
- [ ] Submit code
- [ ] Check success/error

### Test Responsive
- [ ] Resize browser window
- [ ] Test mobile view (< 600px)
- [ ] Test tablet view (600-1200px)
- [ ] Test desktop view (> 1200px)
- [ ] Verify navigation changes

---

## 🐛 Common First-Time Issues

### Issue: Can't connect to API
**Solution:** Update API URL in `app_constants.dart`

### Issue: CORS error
**Solution:** Configure CORS in backend API

### Issue: Login fails
**Solution:** 
- Verify admin user exists in database
- Check credentials are correct
- Ensure API is running

### Issue: Blank screen
**Solution:**
- Check browser console (F12)
- Verify Flutter is running
- Clear browser cache

---

## 📱 Browser Compatibility

**Fully Tested:**
- ✅ Google Chrome (Recommended)
- ✅ Microsoft Edge
- ✅ Firefox
- ✅ Safari

**Requirements:**
- Modern browser (2020+)
- JavaScript enabled
- Cookies enabled
- Local storage enabled

---

## 🚀 Production Deployment

### Quick Deploy to Firebase
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Build
flutter build web --release

# Deploy
firebase deploy --only hosting
```

### Quick Deploy to Netlify
```bash
# Build
flutter build web --release

# Drag & drop build/web/ folder to:
# https://app.netlify.com/drop
```

**See DEPLOYMENT.md for more options!**

---

## 📊 Success Metrics

After deployment, you should see:

- ✅ Fast loading (< 3 seconds)
- ✅ Responsive on all devices
- ✅ All features functional
- ✅ No console errors
- ✅ Professional appearance
- ✅ Smooth interactions

---

## 🎓 Learning Resources

### Internal Docs
- **FEATURES.md** - What the panel can do
- **SCREENS.md** - Visual guide to all screens
- **ARCHITECTURE.md** - How it's built
- **API_INTEGRATION.md** - How APIs work

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Flutter Web Guide](https://flutter.dev/web)

---

## 🆘 Need Help?

1. **Check Documentation**
   - Start with QUICKSTART.md
   - Check TROUBLESHOOTING.md
   - Review relevant .md files

2. **Run Verification**
   ```bash
   ./setup_check.sh
   ```

3. **Check Browser Console**
   - Press F12
   - Look for errors
   - Check Network tab

4. **Review API Logs**
   - Check backend logs
   - Verify endpoints are accessible

---

## 🎉 You're Ready!

Once setup is complete:

1. **Login** with admin credentials
2. **Explore** the dashboard
3. **Test** each feature
4. **Customize** as needed
5. **Deploy** to production
6. **Enjoy** your new admin panel! 💎

---

## 📞 Quick Links

| Need | Document |
|------|----------|
| Setup in 5 minutes | [QUICKSTART.md](QUICKSTART.md) |
| Detailed installation | [INSTALLATION.md](INSTALLATION.md) |
| Configure settings | [CONFIG.md](CONFIG.md) |
| Deploy to production | [DEPLOYMENT.md](DEPLOYMENT.md) |
| Fix problems | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| Understand features | [FEATURES.md](FEATURES.md) |
| See all screens | [SCREENS.md](SCREENS.md) |
| Technical details | [ARCHITECTURE.md](ARCHITECTURE.md) |
| API reference | [API_INTEGRATION.md](API_INTEGRATION.md) |
| Project summary | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) |

---

**Happy Administrating! 🚀**

*Your admin panel is production-ready and waiting for you to configure and deploy it!*
