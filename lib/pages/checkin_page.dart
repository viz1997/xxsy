import 'package:flutter/material.dart';
import 'package:flutter_tencent_faceid/api/dating_api.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  final DatingApi _datingApi = DatingApi();
  int _pageNum = 1;
  int _pageSize = 10;
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDatingRecords();
  }

  Future<void> _fetchDatingRecords() async {
    setState(() => _isLoading = true);
    final result = await _datingApi.pageDatingRecords(pageNum: _pageNum, pageSize: _pageSize);
    setState(() {
      _isLoading = false;
      if (result != null && result['list'] is List) {
        _partners = (result['list'] as List).map((e) {
          return {
            'id': e['datingId']?.toString() ?? '',
            'myAvatar': e['myAvatar'] ?? '',
            'partnerAvatar': e['partnerAvatar'] ?? '',
            'name': e['name'] ?? '',
            'location': e['location'] ?? '',
            'dateCount': '${e['dateCount'] ?? 0}次约会',
            'lastDate': e['lastDate'] ?? '',
            'dates': e['dates'] ?? [],
            'isExpanded': false,
          };
        }).toList();
      } else {
        _partners = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('约会打卡记录'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _partners.length,
        itemBuilder: (context, index) {
          final partner = _partners[index];
          return Column(
            children: [
              _buildPartnerCard(partner),
              if (partner['isExpanded']) _buildDateHistory(partner),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    final isExpanded = partner['isExpanded'] as bool;
    return Card(
      margin: EdgeInsets.only(bottom: isExpanded ? 0 : 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(10),
          bottom: Radius.circular(isExpanded ? 0 : 10),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            partner['isExpanded'] = !partner['isExpanded'];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              _buildAvatarPair(
                partner['myAvatar'],
                partner['partnerAvatar'],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                        Text(
                          partner['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          partner['dateCount'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '上次约会: ${partner['lastDate']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                partner['isExpanded']
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPair(String myAvatar, String partnerAvatar) {
    return SizedBox(
      width: 80,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 5,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  myAvatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 5,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  partnerAvatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -2,
            left: 28,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHistory(Map<String, dynamic> partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
      child: Column(
        children: partner['dates'].map<Widget>((date) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    // 返回 yyyy-MM-dd HH:mm:ss
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}