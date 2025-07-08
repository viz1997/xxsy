import 'package:flutter/material.dart';

class ButlerPage extends StatefulWidget {
  const ButlerPage({super.key});

  @override
  State<ButlerPage> createState() => _ButlerPageState();
}

class _ButlerPageState extends State<ButlerPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<ServiceItem> _services = [
    ServiceItem(title: '线下活动', color: Colors.pink, isHighlighted: true),
    ServiceItem(title: '旅拍服务', color: Colors.blue),
    ServiceItem(title: '婚庆服务', color: Colors.red),
    ServiceItem(title: '形象顾问', color: Colors.purple),
    ServiceItem(title: '心理咨询', color: Colors.orange),
    ServiceItem(title: '兴趣培养', color: Colors.green),
    ServiceItem(title: '家庭服务', color: Colors.brown),
    ServiceItem(title: '更多服务', color: Colors.grey),
  ];

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
                  spacing: 8, // 水平间距
                  runSpacing: 10, // 垂直间距
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
        // 点击服务项的逻辑（可以替换成导航到新页面）
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('点击了 ${service.title}')));
      },
      child: Container(
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
        // 点击活动卡片逻辑（可以替换成导航到详情页）
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('点击了 $title')));
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
                                    // 报名按钮逻辑
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

  ServiceItem({
    required this.title,
    required this.color,
    this.isHighlighted = false,
  });
}
