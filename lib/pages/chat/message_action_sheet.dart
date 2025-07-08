import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

enum MessageType { text, image }

class MessageActionSheet extends StatelessWidget {
  final MessageType type;
  final bool isSelf;
  final bool isRevoked;
  final VoidCallback onCopy;
  final VoidCallback onRevoke;
  final VoidCallback onDelete;
  const MessageActionSheet({
    super.key,
    required this.type,
    required this.isSelf,
    required this.isRevoked,
    required this.onCopy,
    required this.onRevoke,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canRevoke = isSelf && !isRevoked;
    final canCopy = type == MessageType.text && !isRevoked;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canCopy)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制'),
              onTap: onCopy,
            ),
          if (canRevoke)
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('撤回'),
              onTap: onRevoke,
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('删除'),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
} 