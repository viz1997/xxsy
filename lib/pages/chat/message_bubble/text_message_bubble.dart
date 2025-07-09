import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

class TextMessageBubble extends StatelessWidget {
  final V2TimMessage message;
  const TextMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSelf == true ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        decoration: BoxDecoration(
          color: message.isSelf == true ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.textElem?.text ?? '[非文本消息]',
          style: TextStyle(color: message.isSelf == true ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
} 