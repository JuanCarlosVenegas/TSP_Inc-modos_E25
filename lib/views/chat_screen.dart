import 'package:ecoride/models/recoleccion_model.dart';
import 'package:ecoride/services/solicitud_service.dart';
import 'package:flutter/material.dart';
import 'package:ecoride/models/chat_model.dart';
import 'package:ecoride/services/chat_service.dart';
import 'package:ecoride/services/user_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String requestId;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.requestId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final PickupRequestService _pickupRequestService = PickupRequestService();

  String? _otherUserName;
  String? _otherUserRole;
  PickupRequest? _pickupRequest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _markMessagesAsRead(); // <- nueva función
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(
      widget.currentUserId,
      widget.otherUserId,
      widget.requestId,
    );
  }

  Future<void> _loadData() async {
    final name = await _userService.getUserNameById(widget.otherUserId);
    final role = await _userService.getUserRoleById(widget.otherUserId);
    final request = await _pickupRequestService.getPickupRequestById(
      widget.requestId,
    );

    setState(() {
      _otherUserName = name;
      _otherUserRole = role;
      _pickupRequest = request;
      _isLoading = false;
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final message = ChatMessage(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      message: _controller.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    _chatService.sendMessage(requestId: widget.requestId, message: message);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool canSendMessages = _pickupRequest?.status == "Recolección";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset('assets/locoEcoRide.png', height: 30),
            const SizedBox(width: 10),
            const Text("EcoRide", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 59, 194, 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _otherUserName ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _otherUserRole == null
                          ? ''
                          : 'Chat con el $_otherUserRole',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.requestId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[400] : Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (!canSendMessages)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "El chat solo está disponible durante la recolección.",
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: canSendMessages,
                      decoration: const InputDecoration(
                        hintText: "Escribe un mensaje",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: canSendMessages ? _sendMessage : null,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canSendMessages ? Colors.green : Colors.grey,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
