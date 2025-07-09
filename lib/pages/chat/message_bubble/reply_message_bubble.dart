import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

class ReplyMessageBubble extends StatelessWidget {
  final V2TimMessage message;
  const ReplyMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> customData = message.cloudCustomData != null
        ? Map<String, dynamic>.from(jsonDecode(message.cloudCustomData!))
        : {};
    final reply = customData['messageReply'] ?? {};
    final replyText = reply['messageAbstract'] ?? '';
    final replySender = reply['messageSender'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(6),
          child: Text('$replySender: $replyText', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ),
        Text(message.textElem?.text ?? ''),
      ],
    );
  }
} 