import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

class SoundMessageBubble extends StatelessWidget {
  final V2TimMessage message;
  const SoundMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final duration = message.soundElem?.duration ?? 0;
    final url = message.soundElem?.url ?? '';
    return Row(
      children: [
        Icon(Icons.volume_up),
        Text('语音消息 ($duration 秒)'),
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            // TODO: 播放语音
          },
        ),
      ],
    );
  }
} 