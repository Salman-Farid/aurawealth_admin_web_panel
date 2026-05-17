importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCh_gTalQ7Qv7KkS0N0SilKVHXcH7BRM5w',
  authDomain: 'aurawealth-c1e5e.firebaseapp.com',
  projectId: 'aurawealth-c1e5e',
  storageBucket: 'aurawealth-c1e5e.firebasestorage.app',
  messagingSenderId: '817794235254',
  appId: '1:817794235254:web:7aa4d8cf5317fc05601857',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  const notification = message.notification || {};
  const notificationTitle =
    notification.title || message.data?.title || 'AuraWealth';
  const notificationOptions = {
    body: notification.body || message.data?.body || '',
    icon: '/icons/Icon-192.png',
    data: message.data || {},
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
