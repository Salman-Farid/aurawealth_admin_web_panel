import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/message_thread.dart';

/// Firestore-backed admin chat transport.
class FirestoreAdminChatService {
  FirestoreAdminChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesRef(String userId) =>
      _firestore.collection('chats').doc(userId).collection('messages');

  DocumentReference<Map<String, dynamic>> _chatRef(String userId) =>
      _firestore.collection('chats').doc(userId);

  Stream<List<MessageThread>> watchThreads() {
    return _firestore
        .collection('chats')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_threadFromDoc).toList());
  }

  Future<List<MessageThread>> loadThreads() async {
    final snapshot = await _firestore
        .collection('chats')
        .orderBy('lastMessageAt', descending: true)
        .get();
    return snapshot.docs.map(_threadFromDoc).toList();
  }

  Stream<List<Message>> watchMessages(String userId) {
    return _messagesRef(userId)
        .orderBy('createdAt', descending: false)
        .limitToLast(1000)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => messageFromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<List<Message>> loadRecentMessages(String userId, {int limit = 1000}) async {
    final snapshot = await _messagesRef(userId)
        .orderBy('createdAt', descending: false)
        .limitToLast(limit)
        .get();
    return snapshot.docs
        .map((doc) => messageFromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<Message> sendAdminMessage({
    required String userId,
    required String content,
    String messageType = 'live',
    String? subject,
    String? attachmentUrl,
  }) async {
    final docRef = _messagesRef(userId).doc();
    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'id': docRef.id,
      'chatId': userId,
      'userId': userId,
      'senderId': 'admin',
      'senderRole': 'admin',
      'type': messageType,
      'subject': subject,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'readByAdmin': true,
      'readByUser': false,
      'createdAt': now,
      'updatedAt': now,
    };

    await _chatRef(userId).set({
      'userId': userId,
      'lastMessage': content,
      'lastMessageAt': now,
      'lastSenderRole': 'admin',
      'updatedAt': now,
    }, SetOptions(merge: true));
    await docRef.set(payload);

    return Message(
      id: docRef.id,
      direction: 'admin_to_user',
      messageType: messageType,
      subject: subject,
      body: content,
      attachmentUrl: attachmentUrl,
      isRead: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> markUserMessagesRead(String userId) async {
    final snapshot = await _messagesRef(userId)
        .where('senderRole', isEqualTo: 'user')
        .where('readByAdmin', isEqualTo: false)
        .limit(100)
        .get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'readByAdmin': true});
    }
    batch.set(_chatRef(userId), {'unreadCount': 0}, SetOptions(merge: true));
    await batch.commit();
  }

  MessageThread _threadFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final timestamp = data['lastMessageAt'];
    final lastMessageAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse(data['last_message_at']?.toString() ?? '') ??
            DateTime.now();

    return MessageThread(
      userId: (data['userId'] as String?) ?? doc.id,
      userName: (data['userName'] as String?) ?? 'User',
      userEmail: data['userEmail'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastMessageAt: lastMessageAt,
      unreadCount: (data['unreadCount'] as int?) ?? 0,
    );
  }

  Message messageFromFirestore(String id, Map<String, dynamic> data) {
    final senderRole = data['senderRole'] as String? ?? 'user';
    final timestamp = data['createdAt'];
    final createdAt = timestamp is Timestamp
        ? timestamp.toDate().toUtc().toIso8601String()
        : (data['created_at'] as String? ?? DateTime.now().toUtc().toIso8601String());

    return Message(
      id: (data['id'] as String?) ?? id,
      direction: senderRole == 'admin' ? 'admin_to_user' : 'user_to_admin',
      messageType: (data['type'] as String?) ?? 'live',
      subject: data['subject'] as String?,
      body: (data['content'] as String?) ?? (data['body'] as String? ?? ''),
      attachmentUrl: data['attachmentUrl'] as String? ?? data['attachment_url'] as String?,
      isRead: senderRole == 'admin'
          ? (data['readByUser'] as bool? ?? false)
          : (data['readByAdmin'] as bool? ?? false),
      createdAt: createdAt,
    );
  }
}
