import 'package:flutter/material.dart';
import 'package:ecoride/services/chat_service.dart';
import 'package:ecoride/services/user_service.dart';
import 'package:ecoride/services/solicitud_service.dart';
import 'package:ecoride/models/chat_model.dart';
import 'package:ecoride/models/recoleccion_model.dart';

class ChatViewModel extends ChangeNotifier {
  final String currentUserId;
  final String otherUserId;
  final String requestId;
  String? errorMessage;

  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final PickupRequestService _pickupRequestService = PickupRequestService();

  String? otherUserName;
  String? otherUserRole;
  PickupRequest? pickupRequest;
  bool isLoading = true;
  final TextEditingController messageController = TextEditingController();

  ChatViewModel({
    required this.currentUserId,
    required this.otherUserId,
    required this.requestId,
  }) {
    cargarDatos();
    markMessagesAsRead();
  }

  Stream<List<ChatMessage>> get messagesStream =>
      _chatService.getMessages(requestId);

  Future<void> cargarDatos() async {
    otherUserName = await _userService.getUserNameById(otherUserId);
    otherUserRole = await _userService.getUserRoleById(otherUserId);
    pickupRequest = await _pickupRequestService.getPickupRequestById(requestId);
    isLoading = false;
    notifyListeners();
  }

  void markMessagesAsRead() {
    _chatService.markMessagesAsRead(currentUserId, otherUserId, requestId);
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      senderId: currentUserId,
      receiverId: otherUserId,
      message: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      errorMessage = null; // limpia error previo
      notifyListeners();

      await _chatService.sendMessage(requestId: requestId, message: message);

      messageController.clear();
    } catch (e) {
      errorMessage = 'Error enviando mensaje: $e';
      notifyListeners();
    }
  }

  bool get canSendMessages => pickupRequest?.status == "Recolección";
}
