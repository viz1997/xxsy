import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreview extends StatelessWidget {
  final String path;
  const ImagePreview({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          child: path.startsWith('http')
              ? Image.network(path)
              : Image.file(File(path)),
        ),
      ),
    );
  }
} 