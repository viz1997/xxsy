import 'package:flutter/material.dart';
import 'package:flutter_tencent_faceid/pages/chat/chat_page.dart';
import 'package:flutter_tencent_faceid/pages/system_notifications_page.dart';
import 'package:flutter_tencent_faceid/api/activity_api.dart';
import 'package:flutter_tencent_faceid/models/activity.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../api/file_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:geocoding/geocoding.dart';

class ButlerPage extends StatefulWidget {
  const ButlerPage({super.key});

  @override
  State<ButlerPage> createState() => _ButlerPageState();
}

class _ButlerPageState extends State<ButlerPage> {
  final TextEditingController _searchController = TextEditingController();
  final ActivityApi _activityApi = ActivityApi();
  late Future<List<Activity>> _activitiesFuture;
  int _pageNum = 1;
  int _pageSize = 10;

  // 业务列表
  List<Map<String, dynamic>> _serviceCategoryList = [];
  bool _serviceLoading = false;

  // 创建活动表单控制器
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDateTime;
  File? _selectedImageFile;
  String? _uploadingTip;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _costController.dispose();
    _posterUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _fetchActivities();
    _fetchServiceCategoryList();
  }

  Future<List<Activity>> _fetchActivities() async {
    final result = await _activityApi.list(pageNum: _pageNum, pageSize: _pageSize);
    if (result != null && result['data'] != null && result['data']['list'] is List) {
      return (result['data']['list'] as List)
          .map((e) => Activity(
                activityId: e['activityId'] ?? 0,
                title: e['activityName'] ?? '无标题',
                time: DateTime.tryParse(e['startTime'] ?? '') ?? DateTime.now(),
                endTime: e['endTime'] != null ? DateTime.tryParse(e['endTime']) : null,
                location: e['locationName'] ?? '未知地点',
                address: e['address'],
                participants: '${e['registrationNum'] ?? 0}/${e['maxParticipants'] ?? 0}',
                price: (e['cost'] ?? 0).toString(),
                imageUrl: e['posterUrl'] ?? '',
                theme: e['activityTheme'],
                description: e['description'],
              ))
          .toList();
    }
    return [];
  }

  Future<void> _fetchServiceCategoryList() async {
    setState(() {
      _serviceLoading = true;
    });
    final list = await ActivityApi.getServiceCategoryList();
    setState(() {
      _serviceCategoryList = list;
      _serviceLoading = false;
    });
  }

  void _onActivitySignUp(int activityId, String title) async {
    final success = await _activityApi.registry(activityId: activityId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('报名成功: $title')),
      );
      // Refresh activities to update state (e.g., participant count)
      setState(() {
        _activitiesFuture = _fetchActivities();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('报名失败: $title')),
      );
    }
  }

  Future<void> _openMap(String address, String title) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      
      if (availableMaps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到可用的地图应用')),
        );
        return;
      }

      // 地址转经纬度
      List<Location> locations = [];
      try {
        locations = await locationFromAddress(address);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法解析地址为坐标: $address')),
        );
        return;
      }
      if (locations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('未找到该地址的坐标')),
        );
        return;
      }
      final coords = Coords(locations.first.latitude, locations.first.longitude);

      if (availableMaps.length == 1) {
        await availableMaps.first.showMarker(
          coords: coords,
          title: address,
          description: title,
        );
      } else {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      '选择地图应用打开',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(address),
                  ),
                  const Divider(height: 1),
                  ...availableMaps.map((map) => ListTile(
                    leading: SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(
                        map.icon,
                        package: 'map_launcher',
                      ),
                    ),
                    title: Text(map.mapName),
                    onTap: () async {
                      Navigator.pop(context);
                      await map.showMarker(
                        coords: coords,
                        title: address,
                        description: title,
                      );
                    },
                  )),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开地图失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务管家'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
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
              // 服务网格（无业务类型标题区）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _serviceLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: _serviceCategoryList
                            .map((item) => _buildServiceItemFromDict(item))
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
                    FutureBuilder<List<Activity>>(
                      future: _activitiesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('暂无热门活动'));
                        } else {
                          final activities = snapshot.data!;
                          return ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              return _buildActivityCard(activities[index]);
                            },
                            separatorBuilder: (context, index) => const SizedBox(height: 15),
                          );
                        }
                      },
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

  Widget _buildServiceItemFromDict(Map<String, dynamic> item) {
    final isOffline = item['dictLabel'] == '线下活动';
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了业务：${item['dictLabel'] ?? ''}')),
        );
      },
      child: Container(
        width: 72,
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isOffline ? const Color(0xFFFF4E74) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            item['dictLabel'] ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isOffline ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final String fullAddress = activity.address ?? '';

    return InkWell(
      onTap: () {
        _onActivitySignUp(activity.activityId, activity.title);
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片部分
            if (activity.imageUrl.isNotEmpty)
              Image.network(
                activity.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null ? child : _buildImageLoading(),
              ),
            // 内容部分
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (activity.theme != null && activity.theme!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('主题：${activity.theme!}', style: const TextStyle(fontSize: 14, color: Colors.blue)),
                    ),
                  const SizedBox(height: 4),
                  Text('时间：${_formatTimeRange(activity.time, activity.endTime)}', style: const TextStyle(fontSize: 14)),
                  if (fullAddress.isNotEmpty)
                    InkWell(
                      onTap: () => _openMap(fullAddress, activity.title),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '地点：$fullAddress',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.map,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  Text('费用：¥${activity.price}', style: const TextStyle(fontSize: 14)),
                  Text('人数：${activity.participants}', style: const TextStyle(fontSize: 14)),
                  if (activity.description != null && activity.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('简介：${activity.description!}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Text(
                              '已报名 ${activity.participants}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => _onActivitySignUp(activity.activityId, activity.title),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                        child: const Text(
                          '立即报名',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(),
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

  String _formatTimeRange(DateTime start, DateTime? end) {
    String format(DateTime dt) {
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
             '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }
    if (end == null) {
      return format(start);
    }
    return '${format(start)} ~ ${format(end)}';
  }
}