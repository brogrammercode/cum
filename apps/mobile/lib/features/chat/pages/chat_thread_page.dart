import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color.dart';
import '../../../services/api_client.dart';
import '../controllers/chat_repository.dart';
import '../models/chat_model.dart';

class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  late final ChatRepository _repository;
  late Future<List<MessageModel>> _messages;
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _repository = ChatRepository(apiClient: context.read<ApiClient>());
    _messages = _repository.getMessages(widget.conversationId);
    _repository.markRead(widget.conversationId);
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repository.sendMessage(widget.conversationId, body);
      _composer.clear();
      await _repository.markRead(widget.conversationId);
      setState(
        () => _messages = _repository.getMessages(widget.conversationId),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<MessageModel>>(
              future: _messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? const <MessageModel>[];
                if (messages.isEmpty) {
                  return const Center(child: Text('Start the conversation.'));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(24.r),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Align(
                      alignment: message.mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: message.mine
                              ? AppColors.brandAccent
                              : AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.faintGrey),
                        ),
                        child: Text(
                          message.body,
                          style: TextStyle(
                            color: message.mine
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 12.r),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _composer,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'Message'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send, color: AppColors.brandAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
