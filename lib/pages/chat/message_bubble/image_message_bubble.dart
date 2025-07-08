import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class ImageMessageBubble extends StatelessWidget {
  final V2TimMessage message;
  const ImageMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final imageList = message.imageElem?.imageList;
    final imageUrl = (imageList != null && imageList.isNotEmpty)
        ? imageList.first?.url ?? ''
        : '';
    return GestureDetector(
      onTap: () {
        if (imageUrl.isNotEmpty) {
          showDialog(context: context, builder: (_) => Dialog(child: Image.network(imageUrl)));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(imageUrl, width: 120, height: 120, fit: BoxFit.cover)
              : Container(width: 120, height: 120, color: Colors.grey[300], child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
} 