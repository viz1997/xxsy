import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_tencent_faceid/pages/chat/chat_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/recommendation_api.dart';
import '../utils/dio_client.dart';
import 'package:flutter_tencent_faceid/pages/chat/conversation.dart';

class Particle {
  final Offset position;
  final Color color;
  final double size;
  final double speed;
  final double angle;

  Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _users = [];

  // 本地模拟推荐用户数据
  final List<Map<String, dynamic>> _mockRecommendations = [
    {
      'id': 1,
      'name': '林晓彤',
      'age': 24,
      'location': '北京市',
      'education': '硕士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '热爱生活，喜欢旅行和美食，期待遇见有趣的你。我平时喜欢在假期去不同的城市感受风土人情，也喜欢在家做各种美食，享受生活的每一个小确幸。工作之余会去健身房锻炼，保持健康的生活方式。希望能和你一起探索世界、分享生活的点滴。',
      'expectationText': '希望你阳光开朗，有责任心，能够包容和理解彼此。希望我们可以一起成长、互相支持，在未来的日子里共同面对生活的挑战，也能一起享受生活的美好时光。',
      'followers': 1234,
      'following': 321,
      'matchMe': 87,
      'matchThem': 92,
    },
    {
      'id': 2,
      'name': '王子轩',
      'age': 27,
      'location': '上海市',
      'education': '本科',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '程序员一枚，喜欢运动和摄影。平时喜欢打篮球、跑步，也会用相机记录生活中的美好瞬间。工作认真负责，喜欢钻研新技术。希望在忙碌的生活中找到那个可以一起分享快乐和烦恼的人。',
      'expectationText': '希望你善良、真诚，能够坦诚沟通。希望我们可以互相理解、互相包容，一起努力创造属于我们的幸福生活。',
      'followers': 800,
      'following': 150,
      'matchMe': 80,
      'matchThem': 85,
    },
    {
      'id': 3,
      'name': '陈思雨',
      'age': 26,
      'location': '广州市',
      'education': '博士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '喜欢安静的咖啡馆和阅读，偶尔也会和朋友一起去看展览、听音乐会。工作之余喜欢写作和画画，享受独处的时光，也珍惜与朋友的相聚。希望能遇到一个懂得欣赏生活、热爱艺术的你。',
      'expectationText': '希望你有上进心，懂得关心人，能够在生活中给予我温暖和支持。希望我们可以一起成长、一起追求梦想，在平凡的日子里创造属于我们的浪漫。',
      'followers': 500,
      'following': 200,
      'matchMe': 90,
      'matchThem': 88,
    },
    // 新增模拟用户
    {
      'id': 4,
      'name': '李明浩',
      'age': 29,
      'location': '深圳市',
      'education': '硕士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1465101178521-c1a9136a3fdc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '热爱运动，喜欢挑战新事物。平时喜欢爬山、骑行，也会参加马拉松比赛。工作上追求卓越，生活中注重健康和自律。希望能找到一个志同道合的伴侣，一起体验生活的精彩。',
      'expectationText': '希望你积极乐观，喜欢运动，能够和我一起坚持健康的生活方式。希望我们可以互相鼓励、共同进步，携手走过每一个春夏秋冬。',
      'followers': 1200,
      'following': 400,
      'matchMe': 85,
      'matchThem': 80,
    },
    {
      'id': 5,
      'name': '赵雅琴',
      'age': 26,
      'location': '成都市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '喜欢画画和音乐，温柔细腻。平时喜欢在安静的午后画画、弹钢琴，也会和朋友一起去看演出。希望能遇到一个懂得欣赏艺术、热爱生活的你。',
      'expectationText': '希望你有艺术气息，懂得欣赏生活的美好，能够和我一起体验生活的多彩。希望我们可以互相理解、共同成长。',
      'followers': 900,
      'following': 210,
      'matchMe': 88,
      'matchThem': 90,
    },
    {
      'id': 6,
      'name': '孙伟',
      'age': 28,
      'location': '南京市',
      'education': '硕士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1519340333755-c190485c5b4a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '喜欢科技和阅读，理性思考。平时喜欢看科幻小说、研究新技术，也会和朋友讨论各种有趣的话题。希望能遇到一个喜欢思考、乐于分享的你。',
      'expectationText': '希望你善解人意，喜欢交流，能够和我一起探讨生活的各种可能。希望我们可以互相支持、共同成长。',
      'followers': 700,
      'following': 180,
      'matchMe': 82,
      'matchThem': 84,
    },
    {
      'id': 7,
      'name': '周丽娜',
      'age': 25,
      'location': '武汉市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '热情开朗，喜欢结交朋友。平时喜欢参加各种社交活动，也会和朋友一起去旅行、尝试新鲜事物。希望能遇到一个同样热爱生活、乐观向上的你。',
      'expectationText': '希望你幽默风趣，喜欢旅行，能够和我一起发现生活的乐趣。希望我们可以互相陪伴、共同成长。',
      'followers': 650,
      'following': 170,
      'matchMe': 86,
      'matchThem': 89,
    },
    {
      'id': 8,
      'name': '吴建国',
      'age': 30,
      'location': '西安市',
      'education': '硕士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1465101178521-c1a9136a3fdc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '喜欢历史和美食，热爱生活。平时喜欢逛博物馆、品尝各地美食，也会和朋友一起下厨。希望能遇到一个同样热爱生活、喜欢美食的你。',
      'expectationText': '希望你善良大方，喜欢美食，能够和我一起探索世界的美味。希望我们可以互相理解、共同进步。',
      'followers': 1100,
      'following': 350,
      'matchMe': 83,
      'matchThem': 81,
    },
    {
      'id': 9,
      'name': '郑小雨',
      'age': 27,
      'location': '重庆市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1496440737103-cd88c0909231?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1496440737103-cd88c0909231?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '喜欢户外运动和摄影。假期喜欢去徒步、露营，用相机记录大自然的美丽。平时也喜欢和朋友一起聚会、分享生活的点滴。希望能遇到一个热爱自然、喜欢冒险的你。',
      'expectationText': '希望你热爱自然，喜欢冒险，能够和我一起探索世界的精彩。希望我们可以互相陪伴、共同成长。',
      'followers': 780,
      'following': 220,
      'matchMe': 89,
      'matchThem': 87,
    },
    {
      'id': 10,
      'name': '刘志强',
      'age': 31,
      'location': '广州市',
      'education': '博士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'photos': [
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1465101178521-c1a9136a3fdc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      ],
      'bio': '科研工作者，喜欢探索未知。平时喜欢看科普书籍、参加学术交流，也会和朋友一起讨论各种有趣的话题。希望能遇到一个同样热爱学习、喜欢思考的你。',
      'expectationText': '希望你有好奇心，喜欢学习，能够和我一起探索世界的奥秘。希望我们可以互相鼓励、共同进步。',
      'followers': 1300,
      'following': 500,
      'matchMe': 91,
      'matchThem': 93,
    },
  ];

  // 添加关注者数据
  final List<Map<String, dynamic>> _followers = [
    {
      'name': '李小明',
      'age': 25,
      'location': '北京市',
      'education': '本科',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '陈雅婷',
      'age': 27,
      'location': '上海市',
      'education': '硕士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '王浩然',
      'age': 29,
      'location': '深圳市',
      'education': '本科',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '张美琪',
      'age': 24,
      'location': '杭州市',
      'education': '硕士',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '刘志强',
      'age': 31,
      'location': '广州市',
      'education': '博士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
  ];

  final List<Map<String, dynamic>> _following = [
    {
      'name': '赵雅琴',
      'age': 26,
      'location': '成都市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '孙伟',
      'age': 28,
      'location': '南京市',
      'education': '硕士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '周丽娜',
      'age': 25,
      'location': '武汉市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '吴建国',
      'age': 30,
      'location': '西安市',
      'education': '硕士',
      'gender': '男',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': '郑小雨',
      'age': 27,
      'location': '重庆市',
      'education': '本科',
      'gender': '女',
      'avatar': 'https://images.unsplash.com/photo-1496440737103-cd88c0909231?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
  ];

  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;
  late AnimationController _effectController;
  AnimationController? _particleController;
  Animation<double>? _particleAnimation;
  Offset? _dragStart;
  bool _isDragging = false;
  double _dragX = 0;
  int _currentUserIndex = 0;
  bool _isLikeEffect = false;
  final List<Particle> _particles = [];
  final int _particleCount = 15;
  final math.Random _random = math.Random();
  late FToast fToast;
  late RecommendationApi _recommendationApi;
  List<Map<String, dynamic>> _recommendedUsers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  final Map<int, PageController> _photoControllers = {};

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _recommendationApi = RecommendationApi(DioClient());
    _loadRecommendations();
    
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _effectController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleAnimation = CurvedAnimation(
      parent: _particleController!,
      curve: Curves.easeOutQuart,
    );

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentUserIndex = (_currentUserIndex + 1) % _users.length;
          _dragX = 0;
          _swipeController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _effectController.dispose();
    _particleController?.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    _dragStart = box.globalToLocal(details.globalPosition);
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart != null) {
      final box = context.findRenderObject() as RenderBox;
      final currentPosition = box.globalToLocal(details.globalPosition);
      final newDragX = currentPosition.dx - _dragStart!.dx;
      
      final dampingFactor = newDragX > 0
          ? 0.6 - (newDragX.abs() / (box.size.width * 2))
          : 0.4 - (newDragX.abs() / (box.size.width * 2));
      final dampedDragX = newDragX * (0.5 + dampingFactor);
      
      setState(() {
        _dragX = dampedDragX;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStart = null;
    setState(() => _isDragging = false);
    
    final velocity = details.velocity.pixelsPerSecond.dx;
    final box = context.findRenderObject() as RenderBox;
    final screenWidth = box.size.width;
    
    final rightThreshold = screenWidth * 0.4;
    final leftThreshold = screenWidth * 0.5;
    
    final isQuickSwipe = velocity.abs() > 800;
    final hasReachedThreshold = _dragX > 0 
        ? _dragX > rightThreshold 
        : _dragX < -leftThreshold;
    
    if (isQuickSwipe || hasReachedThreshold) {
      final speed = velocity.abs();
      final duration = isQuickSwipe 
          ? (200 - (speed - 800) ~/ 20).clamp(100, 200)
          : _dragX > 0 ? 300 : 200;
          
      _swipeController.duration = Duration(milliseconds: duration);
      
      if (_dragX > 0 || velocity > 800) {
        _showLikeAnimation();
      } else {
        _showSkipAnimation();
      }
      
      _swipeAnimation = Tween<Offset>(
        begin: Offset(_dragX / screenWidth, 0),
        end: Offset(_dragX > 0 ? 1.5 : -1.5, _dragX > 0 ? 0 : 0.3),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: _dragX > 0 ? Curves.easeOutCubic : Curves.easeInQuad,
      ));
      
      _swipeController.forward();
    } else {
      final springController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      
      final springAnimation = Tween<double>(
        begin: _dragX,
        end: 0,
      ).animate(CurvedAnimation(
        parent: springController,
        curve: Curves.elasticOut,
      ));
      
      springAnimation.addListener(() {
        setState(() {
          _dragX = springAnimation.value;
        });
      });
      
      springAnimation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          springController.dispose();
        }
      });
      
      springController.forward();
    }
  }

  void _generateParticles(bool isLike) {
    _particles.clear();
    final baseColor = isLike ? const Color(0xFFFF4E74) : const Color(0xFF4CD964);
    
    for (int i = 0; i < _particleCount; i++) {
      final hue = isLike 
          ? (HSLColor.fromColor(baseColor).hue + _random.nextDouble() * 20 - 10)
          : (HSLColor.fromColor(baseColor).hue + _random.nextDouble() * 20 - 10);
          
      _particles.add(Particle(
        position: Offset.zero,
        color: HSLColor.fromAHSL(
            0.7 + _random.nextDouble() * 0.3,
            hue.clamp(0, 360), 
            0.7 + _random.nextDouble() * 0.3, 
            0.5 + _random.nextDouble() * 0.3
          ).toColor(),
        size: _random.nextDouble() * 8 + 2,
        speed: _random.nextDouble() * 100 + 50,
        angle: _random.nextDouble() * math.pi * 2,
      ));
    }
  }

  Widget _buildCustomToast(String message, bool isSuccess) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isSuccess ? const Color(0xFFFF4E74).withOpacity(0.9) : const Color(0xFF4CD964).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.favorite : Icons.close,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadRecommendations() async {
    // 使用本地模拟数据
    setState(() {
      _users = List<Map<String, dynamic>>.from(_mockRecommendations);
      _currentUserIndex = 0;
      _isLoading = false;
    });
  }

  Future<void> _refreshRecommendations() async {
    try {
      await _recommendationApi.refreshRecommendations();
      _currentPage = 1;
      await _loadRecommendations();
    } catch (e) {
      fToast.showToast(
        child: _buildCustomToast('刷新推荐列表失败', false),
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(seconds: 2),
        positionedToastBuilder: (context, child, gravity) => Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: child,
        ),
      );
    }
  }

  Future<void> _handleUserInteraction(int userId, String action) async {
    try {
      switch (action) {
        case 'view':
          await _recommendationApi.markAsViewed(userId);
          break;
        case 'like':
          await _recommendationApi.markAsLiked(userId);
          break;
        case 'dislike':
          await _recommendationApi.markAsDisliked(userId);
          break;
      }
    } catch (e) {
      fToast.showToast(
        child: _buildCustomToast('操作失败，请重试', false),
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(seconds: 2),
        positionedToastBuilder: (context, child, gravity) => Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: child,
        ),
      );
    }
  }

  void _showLikeAnimation() {
    // 立即显示 toast
    fToast.showToast(
      child: _buildCustomToast('已喜欢该用户', true),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: child,
      ),
    );
    setState(() => _isLikeEffect = true);
    _generateParticles(true);
    _effectController.reset();
    _particleController!.reset();
    
    _effectController.forward();
    _particleController!.forward();
    
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (mounted) {
        setState(() {
          _isLikeEffect = false;
        });
        
        if (_users.isNotEmpty) {
          final currentUser = _users[_currentUserIndex];
          await _handleUserInteraction(currentUser['id'], 'like');
        }
      }
    });
  }

  void _showSkipAnimation() {
    // 立即显示 toast
    fToast.showToast(
      child: _buildCustomToast('不感兴趣', false),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: child,
      ),
    );
    setState(() => _isLikeEffect = false);
    _generateParticles(false);
    _effectController.reset();
    _particleController!.reset();
    
    _effectController.forward();
    _particleController!.forward();
    
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (mounted) {
        setState(() {
          _isLikeEffect = false;
        });
        
        if (_users.isNotEmpty) {
          final currentUser = _users[_currentUserIndex];
          await _handleUserInteraction(currentUser['id'], 'dislike');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_users.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '暂无推荐用户',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshRecommendations,
                      child: const Text('刷新推荐'),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildUserCard(_users[_currentUserIndex]),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    int userId = user['id'];
    int photoIndex = user['photoIndex'] ?? 0;
    _photoControllers.putIfAbsent(userId, () => PageController(initialPage: photoIndex));
    final controller = _photoControllers[userId]!;
    final rotationFactor = math.min(_dragX.abs() / 1000, 0.2);
    final rotation = _isDragging ? (_dragX > 0 ? rotationFactor : -rotationFactor) : 0.0;
    final scale = _dragX < 0 
        ? 1.0 - ((_dragX.abs() / 1000).clamp(0.0, 0.2))
        : 1.0 - ((_dragX.abs() / 1500).clamp(0.0, 0.1));
    final tilt = _dragX / 1000;
    final likeOpacity = (_dragX > 0 ? _dragX : 0) / 200;
    final dislikeOpacity = (_dragX < 0 ? -_dragX : 0) / 200;
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..scale(scale)
          ..translate(_dragX)
          ..rotateZ(rotation)
          ..rotateY(tilt),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _dragX > 0 
                        ? const Color(0xFFFF4E74).withOpacity(0.2)
                        : _dragX < 0 
                            ? const Color(0xFF4CD964).withOpacity(0.2)
                            : Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildUserHeader(user),
                        _buildPhotoCarousel(user['photos'], photoIndex, controller, (newIndex) {
                          setState(() {
                            user['photoIndex'] = newIndex;
                          });
                        }),
                        _buildUserInfo(user),
                      ],
                    ),
                    if (_dragX != 0)
                      Positioned(
                        top: 20,
                        right: _dragX > 0 ? 20 : null,
                        left: _dragX < 0 ? 20 : null,
                        child: AnimatedScale(
                          scale: _dragX.abs() > 50 ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Transform.rotate(
                            angle: _dragX > 0 ? -0.3 : 0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _dragX > 0 ? const Color(0xFFFF4E74) : const Color(0xFF4CD964),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _dragX > 0 ? '喜欢' : '不喜欢',
                                style: TextStyle(
                                  color: _dragX > 0 ? const Color(0xFFFF4E74) : const Color(0xFF4CD964),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildUserHeader(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(user['avatar'], fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCC00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _buildBasicInfoChip(user['location']),
                        _buildBasicInfoChip(user['gender']),
                        _buildBasicInfoChip('${user['age']}岁'),
                        _buildBasicInfoChip(user['education']),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFollowStat('关注我的', user['followers'], Icons.person_outline),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFollowStat('我关注的', user['following'], Icons.person_add_outlined),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMatchStat('适合我?', user['matchMe']),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMatchStat('适合你?', user['matchThem']),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowStat(String label, int count, IconData icon) {
    String formattedCount = count >= 1000000
        ? '${(count / 1000000).toStringAsFixed(1)}M'
        : count >= 1000
            ? '${(count / 1000).toStringAsFixed(1)}k'
            : count.toString();

    return GestureDetector(
      onTap: () {
        if (label == '关注我的') {
          _showFollowersList();
        } else if (label == '我关注的') {
          _showFollowingList();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 11, color: const Color(0xFFFF4E74)),
                const SizedBox(width: 3),
                Text(
                  formattedCount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4E74),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildMatchStat(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF4E74),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPhotoCarousel(List<String> photos, int currentPhotoIndex, PageController controller, void Function(int) onPhotoIndexChanged) {
    return Container(
      height: 150,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: photos.length,
            controller: controller,
            onPageChanged: (index) {
              onPhotoIndexChanged(index);
            },
            itemBuilder: (context, index) {
              return Image.network(
                photos[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == currentPhotoIndex 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                _buildCarouselButton(Icons.chevron_left, () {
                  if (currentPhotoIndex > 0) {
                    controller.animateToPage(
                      currentPhotoIndex - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                }),
                const Spacer(),
                _buildCarouselButton(Icons.chevron_right, () {
                  if (currentPhotoIndex < photos.length - 1) {
                    controller.animateToPage(
                      currentPhotoIndex + 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: double.infinity,
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '自我介绍',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF4E74),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user['bio'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          const Text(
            '期待的他/她',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF4E74),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user['expectationText'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            Icons.close,
            const Color(0xFF4CD964),
            () {
              _showSkipAnimation();
              _swipeController.forward();
            },
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            Icons.chat_bubble_outline,
            const Color(0xFF38B0DE),
            () {
              final currentUser = _users[_currentUserIndex];
              final conversation = Conversation(
                id: 'c2c_${currentUser['name']}',
                userId: currentUser['name'],
                userName: currentUser['name'],
                userAvatar: currentUser['avatar'],
                lastMessage: '',
                lastMessageTime: DateTime.now(),
                unreadCount: 0,
                isOnline: true,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(conversation: conversation),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            Icons.favorite_border,
            const Color(0xFFFF4E74),
            () {
              _showLikeAnimation();
              _swipeController.forward();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  void _showFollowersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFollowersBottomSheet('关注我的', _followers),
    );
  }

  void _showFollowingList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFollowersBottomSheet('我关注的', _following),
    );
  }

  Widget _buildFollowersBottomSheet(String title, List<Map<String, dynamic>> users) {
    bool isFollowingList = title == '我关注的';
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
                child: ListView.builder(
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
                            width: 50,
                            height: 50,
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
                                Text(
                                  user['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
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
                          // 按钮
                          if (isFollowingList)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  users.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已取消关注${user['name']}')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '取消关注',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          if (!isFollowingList)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  user['followed'] = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已关注${user['name']}')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: user['followed'] == true ? Colors.grey.withOpacity(0.1) : const Color(0xFFFF4E74),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  user['followed'] == true ? '已关注' : '关注',
                                  style: TextStyle(
                                    color: user['followed'] == true ? Colors.grey : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
