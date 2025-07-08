import 'package:flutter/material.dart';
import 'package:mop/mop.dart';
import 'dart:io';

class ButlerPage extends StatefulWidget {
  const ButlerPage({super.key});

  @override
  State<ButlerPage> createState() => _ButlerPageState();
}

class _ButlerPageState extends State<ButlerPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  final List<ServiceItem> _services = [
    ServiceItem(title: '线下活动', color: Colors.pink, isHighlighted: true, miniProgramId: ''),
    ServiceItem(title: '旅拍服务', color: Colors.blue, miniProgramId: '5e3c147a188211000141e9b1'),
    ServiceItem(title: '婚庆服务', color: Colors.red, miniProgramId: '5e4d123647edd60001055df1'),
    ServiceItem(title: '形象顾问', color: Colors.purple, miniProgramId: '5f7f1e3e8a9b1a0001a1b1c1'),
    ServiceItem(title: '心理咨询', color: Colors.orange, miniProgramId: '5f7f1e3e8a9b1a0001a1b1c2'),
    ServiceItem(title: '兴趣培养', color: Colors.green, miniProgramId: '5f7f1e3e8a9b1a0001a1b1c3'),
    ServiceItem(title: '家庭服务', color: Colors.brown, miniProgramId: '5f7f1e3e8a9b1a0001a1b1c4'),
    ServiceItem(title: '更多服务', color: Colors.grey, miniProgramId: '5f7f1e3e8a9b1a0001a1b1c5'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeFinClip();
  }

  Future<void> _initializeFinClip() async {
    try {
      if (Platform.isIOS) {
        await Mop.instance.initialize(
          '22LyZEib0gLTQdU3MUauARlLry7JL/2fRpscC9kpGZQA', 
          '1c11d7252c53e0b6',
          apiServer: 'https://api.finclip.com', 
          apiPrefix: '/api/v1/mop'
        );
      } else if (Platform.isAndroid) {
        await Mop.instance.initialize(
          '22LyZEib0gLTQdU3MUauARjmmp6QmYgjGb3uHueys1oA', 
          '98c49f97a031b555',
          apiServer: 'https://api.finclip.com', 
          apiPrefix: '/api/v1/mop'
        );
      }
      
      // 注册小程序事件处理器
      Mop.instance.registerAppletHandler(_AppletHandler());
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('FinClip初始化失败: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '服务管家',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // 搜索框
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '搜索活动、服务...',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 服务网格
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: _services
                      .map((service) => _buildServiceItem(service))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              // 活动列表
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '热门活动',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildActivityCard(
                      title: '周末单身派对',
                      time: '2023-06-15 19:00',
                      location: '上海市静安区南京西路1788号',
                      participants: '28/50',
                      price: '¥199',
                      imageUrl: 'https://via.placeholder.com/120x120',
                    ),
                    const SizedBox(height: 15),
                    _buildActivityCard(
                      title: '户外徒步交友活动',
                      time: '2023-06-18 08:00',
                      location: '上海市松江区佘山国家森林公园',
                      participants: '42/60',
                      price: '¥99',
                      imageUrl: 'https://via.placeholder.com/120x120',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service) {
    return InkWell(
      onTap: () {
        if (service.miniProgramId.isNotEmpty && _isInitialized) {
          Mop.instance.openApplet(service.miniProgramId);
        } else if (service.miniProgramId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了 ${service.title}')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: service.isHighlighted
              ? const Color(0xFFFF4E74)
              : service.title == '旅拍服务'
                  ? const Color(0xFFE8F4FF)
                  : service.title == '婚庆服务'
                      ? const Color(0xFFFFF0F0)
                      : service.title == '形象顾问'
                          ? const Color(0xFFF4F0FF)
                          : service.title == '心理咨询'
                              ? const Color(0xFFFFF5F0)
                              : service.title == '兴趣培养'
                                  ? const Color(0xFFF0FFF5)
                                  : service.title == '家庭服务'
                                      ? const Color(0xFFF5F0FF)
                                      : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          service.title,
          style: TextStyle(
            fontSize: 14,
            color: service.isHighlighted ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String time,
    required String location,
    required String participants,
    required String price,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了 $title')),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '已报名 $participants 人',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                price,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('报名 $title')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    '报名',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceItem {
  final String title;
  final Color color;
  final bool isHighlighted;
  final String miniProgramId;

  ServiceItem({
    required this.title,
    required this.color,
    this.isHighlighted = false,
    required this.miniProgramId,
  });
}

// 小程序事件处理器
class _AppletHandler extends AppletHandler {
  @override
  void forwardApplet(Map<String, dynamic> appletInfo) {
    print('转发小程序: $appletInfo');
    // 在这里实现转发逻辑
  }

  @override
  Future<Map<String, dynamic>> getUserInfo() async {
    // 返回用户信息，可以从你的用户系统中获取
    return {
      "userId": "123456",
      "nickName": "Flutter用户",
      "avatarUrl": "https://via.placeholder.com/150",
      "jwt": "your_jwt_token",
      "accessToken": "your_access_token"
    };
  }

  @override
  Future<List<CustomMenu>> getCustomMenus(String appId) async {
    // 返回自定义菜单
    return [
      CustomMenu(menuId: 1, name: "菜单1"),
      CustomMenu(menuId: 2, name: "菜单2"),
    ];
  }

  @override
  Future onCustomMenuClick(String appId, int menuId) async {
    print('小程序 $appId 的菜单 $menuId 被点击');
    // 处理菜单点击事件
  }
}