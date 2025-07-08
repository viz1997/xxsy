import 'package:flutter/material.dart';
import 'package:flutter_tencent_faceid/api/system_notification_api.dart';

class SystemNotification {
  final String id;
  final String title;
  final String content;
  final DateTime time;
  final bool isRead;

  SystemNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.isRead = false,
  });

  factory SystemNotification.fromJson(Map<String, dynamic> json) {
    return SystemNotification(
      id: json['noticeId'].toString(),
      title: json['noticeTitle'] ?? '无标题',
      content: json['noticeContent'] ?? '无内容',
      time: DateTime.tryParse(json['createTime'] ?? '') ?? DateTime.now(),
      isRead: json['status'] == '0',
    );
  }
}

class SystemNotificationsPage extends StatefulWidget {
  const SystemNotificationsPage({super.key});

  @override
  State<SystemNotificationsPage> createState() => _SystemNotificationsPageState();
}

class _SystemNotificationsPageState extends State<SystemNotificationsPage> {
  final SystemNotificationApi _notificationService = SystemNotificationApi();
  late Future<List<SystemNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<SystemNotification>> _loadNotifications() async {
    try {
      final data = await _notificationService.getSystemNotifications();
      return data.map((json) => SystemNotification.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统通知'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _notificationsFuture = _loadNotifications();
              });
            },
            child: const Text('全部已读', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: FutureBuilder<List<SystemNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '暂无系统通知',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _notificationsFuture = _loadNotifications();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.white : Colors.blue[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatTime(notification.time),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
} 