import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

class FileMessageBubble extends StatelessWidget {
  final V2TimMessage message;
  const FileMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fileName = message.fileElem?.fileName ?? '文件';
    final fileUrl = message.fileElem?.url ?? '';
    return ListTile(
      leading: Icon(Icons.insert_drive_file, color: Colors.blue),
      title: Text(fileName),
      trailing: IconButton(
        icon: Icon(Icons.download),
        onPressed: () {
          // TODO: 实现文件下载
        },
      ),
    );
  }
} 