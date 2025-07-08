import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';

class ChatPage extends StatelessWidget {
  final V2TimConversation conversation;
  const ChatPage({Key? key, required this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TIMUIKitChat(
        conversation: conversation,
        // 可通过 config/morePanelConfig 等自定义扩展
      ),
    );
  }
}