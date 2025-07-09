import 'package:flutter/material.dart';
import 'conversation.dart';
import 'message_list.dart';
import 'input_bar.dart';
import 'more_panel.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  const ChatPage({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<V2TimMessage> _messages = [];
  bool _isLoading = false;
  bool _showMorePanel = false;

  @override
  void initState() {
    super.initState();
    _loadHistoryMessages();
    TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(
      listener: V2TimAdvancedMsgListener(
        onRecvNewMessage: (msg) {
          if (msg.userID == widget.conversation.userId || msg.sender == widget.conversation.userId) {
            setState(() {
              _messages.insert(0, msg);
            });
          }
        },
      ),
    );
  }

  Future<void> _loadHistoryMessages() async {
    setState(() => _isLoading = true);
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getC2CHistoryMessageList(
          userID: widget.conversation.userId,
          count: 30,
        );
    if (res.code == 0 && res.data != null) {
      setState(() {
        _messages = res.data!;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;
    final createRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: text);
    if (createRes.code == 0 && createRes.data != null) {
      final sendRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createRes.data!.id!,
        receiver: widget.conversation.userId,
        groupID: "",
      );
      if (sendRes.code == 0 && sendRes.data != null) {
        setState(() {
          _messages.insert(0, sendRes.data!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('消息发送失败: \\${sendRes.desc ?? sendRes.code}')),
        );
      }
    }
  }

  Future<void> _handleSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _sendImageToIM(pickedFile.path);
    }
  }

  Future<void> _handleTakePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _sendImageToIM(pickedFile.path);
    }
  }

  Future<void> _handleSendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      await _sendFileToIM(filePath, fileName);
    }
  }

  Future<void> _sendImageToIM(String path) async {
    final createRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createImageMessage(imagePath: path);
    if (createRes.code == 0 && createRes.data != null) {
      final sendRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createRes.data!.id!,
        receiver: widget.conversation.userId,
        groupID: "",
      );
      if (sendRes.code == 0 && sendRes.data != null) {
        await _loadHistoryMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片发送失败: \\${sendRes.desc ?? sendRes.code}')),
        );
      }
    }
  }

  Future<void> _sendFileToIM(String path, String fileName) async {
    final createRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createFileMessage(
      filePath: path,
      fileName: fileName,
    );
    if (createRes.code == 0 && createRes.data != null) {
      final sendRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createRes.data!.id!,
        receiver: widget.conversation.userId,
        groupID: "",
      );
      if (sendRes.code == 0 && sendRes.data != null) {
        await _loadHistoryMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('文件发送失败: \\${sendRes.desc ?? sendRes.code}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.userName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : MessageList(messages: _messages),
          ),
          // 输入栏+更多面板整体，面板弹出时输入栏随之上移
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputBar(
                onSend: _handleSend,
                onVoice: () {/* TODO: 语音输入 */},
                onEmoji: () {/* TODO: 表情面板 */},
                onMore: () {
                  setState(() {
                    _showMorePanel = !_showMorePanel;
                  });
                },
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: _showMorePanel ? 220 : 0,
                child: _showMorePanel ? _buildMorePanel() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMorePanel() {
    return GestureDetector(
      onTap: () => setState(() => _showMorePanel = false),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          height: 220,
          color: Colors.white,
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            children: [
              _buildMorePanelItem(
                icon: Icons.image,
                label: '照片',
                onTap: () {
                  setState(() => _showMorePanel = false);
                  _handleSendImage();
                },
              ),
              _buildMorePanelItem(
                icon: Icons.camera_alt,
                label: '拍照',
                onTap: () {
                  setState(() => _showMorePanel = false);
                  _handleTakePhoto();
                },
              ),
              _buildMorePanelItem(
                icon: Icons.insert_drive_file,
                label: '文件',
                onTap: () {
                  setState(() => _showMorePanel = false);
                  _handleSendFile();
                },
              ),
              // 可继续添加更多功能项
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMorePanelItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            child: Icon(icon, size: 28),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    TencentImSDKPlugin.v2TIMManager.getMessageManager().removeAdvancedMsgListener();
    super.dispose();
  }
} 