import 'package:flutter/material.dart';
import 'package:flutter_tencent_faceid/pages/profile_edit_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import the BasicInfoFormPage with an alias to avoid conflicts
import 'package:flutter_tencent_faceid/pages/basic_info_form_page.dart' as basic_info;
// Import the improved version
import 'package:flutter_tencent_faceid/pages/improved_info_form_page.dart';
import 'package:flutter_tencent_faceid/pages/basic_profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final String _defaultProfileImage = 'https://images.unsplash.com/photo-1552058544-f2b08422138a';

  // 添加用户数据
  final List<Map<String, dynamic>> _likedUsers = [
    {
      'name': '林小雨',
      'age': 28,
      'location': '北京市',
      'education': '硕士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '张思琪',
      'age': 26,
      'location': '上海市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '王梦琳',
      'age': 30,
      'location': '广州市',
      'education': '博士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
  ];

  final List<Map<String, dynamic>> _likedMeUsers = [
    {
      'name': '陈雅婷',
      'age': 27,
      'location': '上海市',
      'education': '硕士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '李小明',
      'age': 25,
      'location': '北京市',
      'education': '本科',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
  ];

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '更换头像',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('从相册选择'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFrom(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.green),
                  ),
                  title: const Text('拍摄照片'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFrom(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImageFrom(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像已更新')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  children: [
                                    ClipOval(
                                  child: _profileImage != null 
                                    ? Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                      )
                                    : Image.network(
                                        _defaultProfileImage,
                                        fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '王先生',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '28岁 · 上海',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BasicProfileEditPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('编辑信息'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // _buildStatsBar(),
                _buildMenuSection(
                  context,
                  [
                    _MenuItem(
                      icon: Icons.person_outline,
                      iconColor: Colors.green,
                      title: '编辑资料',
                      onTap: () => Navigator.pushNamed(context, '/profile/edit'),
                    ),
                    _MenuItem(
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      title: '我喜欢的',
                      badge: '3',
                      onTap: () => _showLikedUsersList(),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_border,
                      iconColor: Colors.pink,
                      title: '喜欢我的',
                      badge: '2',
                      onTap: () => _showLikedMeUsersList(),
                    ),
                    _MenuItem(
                      icon: Icons.monetization_on,
                      iconColor: Colors.amber,
                      title: '我的收益',
                    ),
                    _MenuItem(
                      icon: Icons.calendar_today,
                      iconColor: Colors.blue,
                      title: '我的约会打卡',
                      badge: '今日',
                      onTap: () => Navigator.pushNamed(context, '/checkin'),
                    ),
                    _MenuItem(
                      icon: Icons.tune,
                      iconColor: Colors.purple,
                      title: '匹配度阈值',
                      trailing: '75%',
                      onTap: () => _showMatchThresholdDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStatsBar() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 15),
  //     color: Colors.white,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         _buildStatItem('访客', '128'),
  //         _buildStatItem('喜欢', '45'),
  //         _buildStatItem('匹配', '12'),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    List<_MenuItem> items,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: items.map((item) => item.build(context)).toList(),
      ),
    );
  }

  void _showMatchThresholdDialog(BuildContext context) {
    double _currentValue = 75.0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('设置匹配度阈值'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '匹配度低于${_currentValue.toInt()}%的用户无法向您发起聊天',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _currentValue,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: Theme.of(context).primaryColor,
                    label: '${_currentValue.toInt()}%',
                    onChanged: (double value) {
                      setState(() {
                        _currentValue = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('0%', style: TextStyle(color: Colors.grey)),
                      Text('100%', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    // 保存匹配度阈值
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已设置匹配度阈值为${_currentValue.toInt()}%')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showLikedUsersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUsersBottomSheet('我喜欢的', _likedUsers, true),
    );
  }

  void _showLikedMeUsersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUsersBottomSheet('喜欢我的', _likedMeUsers, false),
    );
  }

  Widget _buildUsersBottomSheet(String title, List<Map<String, dynamic>> users, bool isLikedByMe) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 分割线
              Container(
                height: 1,
                color: Colors.grey.withOpacity(0.1),
              ),
              // 用户列表
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLikedByMe ? Icons.favorite_border : Icons.favorite,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isLikedByMe ? '还没有喜欢的用户' : '还没有人喜欢您',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 头像
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF4E74).withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      user['avatar'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 用户信息
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user['name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                          ),
                                          if (!isLikedByMe) ...[
                                            IconButton(
                                              icon: Icon(Icons.favorite, color: Color(0xFFFF4E74), size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('已喜欢${user['name']}')),
                                                );
                                              },
                                              tooltip: '喜欢',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('正在打开与${user['name']}的聊天')),
                                                );
                                              },
                                              tooltip: '聊天',
                                            ),
                                          ],
                                          if (isLikedByMe) ...[
                                            IconButton(
                                              icon: Icon(Icons.favorite_border, color: Colors.red, size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                setModalState(() {
                                                  users.removeAt(index);
                                                });
                                                setState(() {
                                                  _likedUsers.removeAt(index);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('已取消喜欢${user['name']}')),
                                                );
                                              },
                                              tooltip: '取消喜欢',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('正在打开与${user['name']}的聊天')),
                                                );
                                              },
                                              tooltip: '聊天',
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildInfoChip(user['location']),
                                          const SizedBox(width: 6),
                                          _buildInfoChip(user['gender']),
                                          const SizedBox(width: 6),
                                          _buildInfoChip('${user['age']}岁'),
                                          const SizedBox(width: 6),
                                          _buildInfoChip(user['education']),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.badge,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? badge;
  final String? trailing;
  final VoidCallback? onTap;

  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
