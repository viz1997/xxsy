import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _cacheSize = '23.5MB';

  Future<void> _clearCache() async {
    // TODO: Implement actual cache clearing logic
    setState(() {
      _cacheSize = '0B';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('缓存已清除')),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement actual logout logic
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                '退出',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildSection(
            '通用设置',
            [
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: '消息通知',
                onTap: () {
                  Navigator.pushNamed(context, '/settings/notifications');
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: '隐私设置',
                onTap: () {
                  Navigator.pushNamed(context, '/settings/privacy');
                },
              ),
              _buildMenuItem(
                icon: Icons.delete_outline,
                title: '清除缓存',
                trailing: Text(
                  _cacheSize,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                onTap: _clearCache,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            '账号管理',
            [
              _buildMenuItem(
                icon: Icons.phone_android,
                title: '更换手机号',
                onTap: () {
                  Navigator.pushNamed(context, '/settings/change_phone');
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_reset,
                title: '更换密码',
                onTap: () {
                  Navigator.pushNamed(context, '/settings/change_password');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            '关于与帮助',
            [
              _buildMenuItem(
                icon: Icons.info_outline,
                title: '关于我们',
                onTap: () {
                  Navigator.pushNamed(context, '/settings/about');
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: '帮助与反馈',
                onTap: () {
                  Navigator.pushNamed(context, '/settings/help');
                },
              ),
              _buildMenuItem(
                icon: Icons.star_outline,
                title: '给我们评分',
                onTap: () {
                  // TODO: Implement app store rating
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            '',
            [
              _buildMenuItem(
                icon: Icons.logout,
                title: '退出登录',
                titleColor: Colors.red,
                showArrow: false,
                onTap: _showLogoutDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '当前版本 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFEEEEEE),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
} 