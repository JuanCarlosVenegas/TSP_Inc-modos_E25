import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoride/models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  Stream<List<ChatMessage>> getMessages(String userId1, String userId2) {
    final chatId = getChatId(userId1, userId2);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList());
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final chatRef = _db.collection('chats').doc(chatId);

    // Opcional: guardar info del chat si no existe
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      await chatRef.set({
        'userIds': [senderId, receiverId],
        'createdAt': Timestamp.now(),
      });
    }

    await chatRef.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.now(),
      'isRead': false
    });
  }

  Future<int> getUnreadMessagesCount(String currentUserId, String otherUserId, String requestId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(requestId)
      .collection('messages')
      .where('receiverId', isEqualTo: currentUserId)
      .where('senderId', isEqualTo: otherUserId)
      .where('isRead', isEqualTo: false)
      .get();

  return snapshot.docs.length;
}

}
