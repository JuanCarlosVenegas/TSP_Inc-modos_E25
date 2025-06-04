import 'package:ecoride/viewmodels/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoride/models/chat_model.dart';

class ChatScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ChatViewModel(
            currentUserId: currentUserId,
            otherUserId: otherUserId,
            requestId: requestId,
          ),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          _buildHeader(viewModel),
          _buildMessages(viewModel),
          if (!viewModel.canSendMessages)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "El chat solo está disponible durante la recolección.",
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          _buildInput(viewModel),
        ],
      ),
    );
  }

  Widget _buildHeader(ChatViewModel vm) {
    return Container(
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
                vm.otherUserName ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                vm.otherUserRole == null
                    ? ''
                    : 'Chat con el ${vm.otherUserRole}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(ChatViewModel vm) {
    return Expanded(
      child: StreamBuilder<List<ChatMessage>>(
        stream: vm.messagesStream,
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
              final isMe = msg.senderId == vm.currentUserId;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
    );
  }

  Widget _buildInput(ChatViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                vm.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Row(
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
                    controller: vm.messageController,
                    enabled: vm.canSendMessages,
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: vm.canSendMessages ? vm.sendMessage : null,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vm.canSendMessages ? Colors.green : Colors.grey,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
