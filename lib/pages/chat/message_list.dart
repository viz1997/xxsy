import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'message_bubble/text_message_bubble.dart';
import 'message_bubble/image_message_bubble.dart';
import 'message_bubble/file_message_bubble.dart';
import 'message_bubble/sound_message_bubble.dart';
import 'message_bubble/reply_message_bubble.dart';
import 'message_bubble/merger_message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<V2TimMessage> messages;
  const MessageList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        if (msg.elemType == 1) {
          return TextMessageBubble(message: msg);
        } else if (msg.elemType == 2) {
          return ImageMessageBubble(message: msg);
        } else if (msg.elemType == 3) {
          return SoundMessageBubble(message: msg);
        } else if (msg.elemType == 5) {
          return FileMessageBubble(message: msg);
        } else if (msg.elemType == 6) {
          return MergerMessageBubble(message: msg);
        } else if (msg.cloudCustomData != null && msg.cloudCustomData!.contains("messageReply")) {
          return ReplyMessageBubble(message: msg);
        } else {
          return Text("暂不支持的消息类型");
        }
      },
    );
  }
} 