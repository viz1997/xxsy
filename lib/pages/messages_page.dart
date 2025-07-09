import 'package:flutter/material.dart';
import 'package:flutter_tencent_faceid/pages/chat/chat_page.dart';
import 'package:flutter_tencent_faceid/pages/system_notifications_page.dart';
import 'package:flutter_tencent_faceid/api/chat_message_api.dart';
import 'package:flutter_tencent_faceid/config/tencent_cloud_config.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_text_elem.dart';
import 'package:flutter_tencent_faceid/pages/chat/conversation.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  int _unreadSystemNotifications = 2;
  int _unreadMsgNum = 0;
  final ChatMessageApi _chatMessageApi = ChatMessageApi();
  bool _isIMInitialized = false;

  // 分页拉取相关
  String _nextSeq = "0";
  bool _isFinished = false;

  late V2TimConversationListener _conversationListener;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initIM();
    _fetchUnreadMsgNum();

    _conversationListener = V2TimConversationListener(
      onConversationChanged: (conversationList) {
        _loadConversationsOnce();
      },
      onNewConversation: (conversationList) {
        _loadConversationsOnce();
      },
      onTotalUnreadMessageCountChanged: (int totalUnreadCount) {
        setState(() {
          _unreadMsgNum = totalUnreadCount;
        });
      },
    );
    TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .addConversationListener(listener: _conversationListener);
  }

  Future<void> _initIM() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. 初始化SDK，listener 传 V2TimSDKListener 实例
      var initRes = await TencentImSDKPlugin.v2TIMManager.initSDK(
        sdkAppID: TencentCloudConfig.sdkAppID,
        loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
        listener: V2TimSDKListener(
          onConnectSuccess: () {
            print('IM SDK 连接成功');
            _login();
          },
          onConnectFailed: (code, error) {
            print('IM SDK 连接失败: $code, $error');
          },
          onKickedOffline: () {
            print('IM SDK 被踢下线');
            // TODO: 处理被踢下线的情况
          },
          // 你可以根据需要添加更多回调
        ),
      );

      if (initRes.code == 0) {
        setState(() {
          _isIMInitialized = true;
        });
        print("IM SDK初始化成功");
      } else {
        print("IM SDK初始化失败: ${initRes.code} ${initRes.desc}");
      }
    } catch (e) {
      print("初始化异常: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    try {
      String userID = "user1"; // 当前登录用户
      String userSig = TencentCloudConfig.getUserSig(userID);

      var loginRes = await TencentImSDKPlugin.v2TIMManager.login(
        userID: userID,
        userSig: userSig,
      );

      if (loginRes.code == 0) {
        print("登录成功");

        // 自动给 user2、user3 各发一条消息，确保会话被创建
        await _ensureConversationWith("user2");
        await _ensureConversationWith("user3");

        _loadConversationsOnce(); // 登录成功后加载会话列表
      } else {
        print("登录失败: [38;5;1m${loginRes.code} ${loginRes.desc}[0m");
      }
    } catch (e) {
      print("登录异常: $e");
    }
  }

Future<void> _ensureConversationWith(String peerUserID) async {
  // 检查会话是否已存在
  var convRes = await TencentImSDKPlugin.v2TIMManager
      .getConversationManager()
      .getConversation(conversationID: "c2c_$peerUserID");
  if (convRes.code == 0 && convRes.data != null) {
    // 如果会话已存在且有消息，不需要再发
    if (convRes.data!.lastMessage != null) return;
  }
  // 先创建文本消息
  final createRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(
    text: "你好",
  );
  if (createRes.code == 0 && createRes.data != null) {
    await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
      id: createRes.data!.id!, // 注意这里是 id，不是 msgID
      receiver: peerUserID,
      groupID: "",
    );
  }
}

  Future<void> _loadConversations() async {
    if (!_isIMInitialized) {
      print("IM SDK未初始化");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      V2TimValueCallback<V2TimConversationResult> result = 
          await TencentImSDKPlugin.v2TIMManager
              .getConversationManager()
              .getConversationList(count: 100, nextSeq: "0");

      if (result.code == 0 && result.data != null) {
        setState(() {
          _conversations = result.data!.conversationList
              ?.where((conv) => conv != null)
              .map((conv) => Conversation.fromV2TimConversation(conv!))
              .toList() ?? [];
        });
      } else {
        print("获取会话列表失败: ${result.code} ${result.desc}");
      }
    } catch (e) {
      print("加载会话异常: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUnreadMsgNum() async {
    try {
      final num = await _chatMessageApi.getUnreadMsgNum();
      setState(() {
        _unreadMsgNum = num;
      });
    } catch (e) {
      // 可选：处理异常
    }
  }

  List<Conversation> get filteredConversations {
    if (_tabController.index == 0) {
      return _conversations.where((conv) => conv.unreadCount > 0).toList();
    } else {
      return _conversations.where((conv) => conv.unreadCount == 0).toList();
    }
  }

  void _onSearchChanged(String value) {
    // 实现搜索功能
    setState(() {
      if (value.isEmpty) {
        _loadConversations();
      } else {
        _conversations =
            _conversations
                .where(
                  (conv) =>
                      conv.userName.toLowerCase().contains(
                        value.toLowerCase(),
                      ) ||
                      conv.lastMessage.toLowerCase().contains(
                        value.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SystemNotificationsPage(),
                    ),
                  ).then((_) {
                    // 从系统通知页面返回后，重置未读计数
                    setState(() {
                      _unreadSystemNotifications = 0;
                    });
                  });
                },
              ),
              if (_unreadSystemNotifications > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadSystemNotifications > 99 ? '99+' : _unreadSystemNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (_unreadMsgNum > 0)
                Positioned(
                  right: 40,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadMsgNum > 99 ? '99+' : _unreadMsgNum.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: '搜索消息...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                onTap: (index) => setState(() {}),
                tabs: const [Tab(text: '未读'), Tab(text: '已读')],
              ),
            ],
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildConversationList(), _buildConversationList()],
              ),
    );
  }

  Widget _buildConversationList() {
    final conversations = filteredConversations;

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _tabController.index == 0 ? '没有未读消息' : '没有已读消息',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder:
          (context, index) => _buildConversationItem(conversations[index]),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return InkWell(
      onTap: () async {
        // 更新已读状态
        setState(() {
          final index = _conversations.indexWhere(
            (conv) => conv.id == conversation.id,
          );
          if (index != -1) {
            _conversations[index] = Conversation(
              id: conversation.id,
              userId: conversation.userId,
              userName: conversation.userName,
              userAvatar: conversation.userAvatar,
              lastMessage: conversation.lastMessage,
              lastMessageTime: conversation.lastMessageTime,
              unreadCount: 0,
              isOnline: conversation.isOnline,
            );
          }
        });
        // 直接传递 Conversation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(conversation: conversation),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(conversation.userAvatar),
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .removeConversationListener(listener: _conversationListener);
    TencentImSDKPlugin.v2TIMManager.logout();
    TencentImSDKPlugin.v2TIMManager.unInitSDK();
    super.dispose();
  }

  // 一次性拉取所有会话（100个以内）
  Future<void> _loadConversationsOnce() async {
    setState(() => _isLoading = true);
    try {
      final res = await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .getConversationList(count: 100, nextSeq: "0");
      if (res.code == 0 && res.data != null) {
        setState(() {
          _conversations = res.data!.conversationList
              ?.where((conv) => conv != null)
              .map((conv) => Conversation.fromV2TimConversation(conv!))
              .toList() ?? [];
          _nextSeq = res.data!.nextSeq ?? "0";
          _isFinished = res.data!.isFinished ?? true;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 分页拉取会话
  Future<void> _loadConversationsPage() async {
    if (_isFinished) return;
    setState(() => _isLoading = true);
    try {
      final res = await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .getConversationList(count: 50, nextSeq: _nextSeq);
      if (res.code == 0 && res.data != null) {
        setState(() {
          final newList = res.data!.conversationList
              ?.where((conv) => conv != null)
              .map((conv) => Conversation.fromV2TimConversation(conv!))
              .toList() ?? [];
          _conversations.addAll(newList);
          _nextSeq = res.data!.nextSeq ?? "0";
          _isFinished = res.data!.isFinished ?? true;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
