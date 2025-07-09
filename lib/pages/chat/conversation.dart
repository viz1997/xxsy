import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_text_elem.dart';

class Conversation {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory Conversation.fromV2TimConversation(V2TimConversation conv) {
    return Conversation(
      id: conv.conversationID ?? "",
      userId: conv.userID ?? "",
      userName: conv.showName ?? "",
      userAvatar: conv.faceUrl ?? "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
      lastMessage: conv.lastMessage?.textElem?.text ?? "",
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch((conv.lastMessage?.timestamp ?? 0) * 1000),
      unreadCount: conv.unreadCount ?? 0,
      isOnline: false,
    );
  }
} 