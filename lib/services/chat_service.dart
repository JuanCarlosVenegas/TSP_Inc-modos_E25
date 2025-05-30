import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoride/models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String requestId) {
    return _db
        .collection('chats')
        .doc(requestId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String requestId,
    required ChatMessage message,
  }) async {
    final chatRef = _db.collection('chats').doc(requestId);

    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      await chatRef.set({
        'userIds': [message.senderId, message.receiverId],
        'createdAt': Timestamp.now(),
      });
    }

    await chatRef.collection('messages').add(message.toMap());
  }

  Future<int> getUnreadMessagesCount(
      String currentUserId, String otherUserId, String requestId) async {
    final snapshot = await _db
        .collection('chats')
        .doc(requestId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('senderId', isEqualTo: otherUserId)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  Future<void> markMessagesAsRead(String currentUserId, String otherUserId, String requestId) async {
  final messagesRef = _db
      .collection('chats')
      .doc(requestId)
      .collection('messages');

  final snapshot = await messagesRef
      .where('receiverId', isEqualTo: currentUserId)
      .where('senderId', isEqualTo: otherUserId)
      .where('isRead', isEqualTo: false)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({'isRead': true});
  }
}

}
