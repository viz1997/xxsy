import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onVoice;
  final VoidCallback onEmoji;
  final VoidCallback onMore;

  const InputBar({
    required this.onSend,
    required this.onVoice,
    required this.onEmoji,
    required this.onMore,
    Key? key,
  }) : super(key: key);

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // 监听输入内容变化，动态切换按钮
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get hasText => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // 语音按钮（左侧）
          IconButton(
            icon: Icon(Icons.mic, color: Colors.grey[700]),
            onPressed: widget.onVoice,
          ),
          // 输入框（居中扩展）
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '请输入消息',
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
          // 表情按钮（输入框右侧）
          IconButton(
            icon: Icon(Icons.emoji_emotions, color: Colors.grey[700]),
            onPressed: widget.onEmoji,
          ),
          // 加号/更多按钮（输入框右侧）
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey[700]),
            onPressed: widget.onMore,
          ),
          // 发送按钮（有内容时显示，否则隐藏）
          if (hasText)
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  widget.onSend(text);
                  _controller.clear();
                }
              },
            ),
        ],
      ),
    );
  }
} 