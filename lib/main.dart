import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tencent_faceid/pages/home_page.dart';
import 'package:flutter_tencent_faceid/pages/butler_page.dart';
import 'package:flutter_tencent_faceid/pages/messages_page.dart';
import 'package:flutter_tencent_faceid/pages/profile_page.dart';
import 'package:flutter_tencent_faceid/pages/chat/chat_page.dart';
import 'package:flutter_tencent_faceid/pages/chat/conversation.dart';
import 'package:flutter_tencent_faceid/pages/checkin_page.dart';
import 'package:flutter_tencent_faceid/pages/profile_edit_page.dart';
import 'package:flutter_tencent_faceid/pages/login_page.dart';
import 'package:flutter_tencent_faceid/pages/register_page.dart';
import 'package:flutter_tencent_faceid/pages/face_verification_page.dart';
import 'package:flutter_tencent_faceid/pages/register_success_page.dart';
import 'package:flutter_tencent_faceid/pages/settings_page.dart';
import 'package:flutter_tencent_faceid/pages/change_phone_page.dart';
import 'package:flutter_tencent_faceid/pages/change_password_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tencent_faceid/services/tencent_auth_service.dart';
import 'utils/dio_client.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 尝试加载环境变量，如果失败则使用默认值
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('警告: 无法加载 .env 文件，将使用默认配置');
  }
  
  TencentAuthService.init(); // 初始化腾讯云认证服务
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '心动匹配',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF4E74),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4E74),
          primary: const Color(0xFFFF4E74),
          secondary: const Color(0xFF764AF1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFFF4E74),
          unselectedItemColor: Colors.grey,
        ),
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterPage(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const MainNavigationPage(),
            );
          case '/chat':
            final conversation = settings.arguments as Conversation;
            return MaterialPageRoute(
              builder: (context) => ChatPage(conversation: conversation),
            );
          case '/checkin':
            return MaterialPageRoute(builder: (context) => const CheckinPage());
          case '/profile/edit':
            return MaterialPageRoute(
              builder: (context) => const ProfileEditPage(),
            );
          case '/face_verification':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FaceVerificationPage(
                name: args['name'] as String,
                idCard: args['idCard'] as String,
                phone: args['phone'] as String,
                password: args['password'] as String,
              ),
            );
          case '/register_success':
            return MaterialPageRoute(
              builder: (context) => const RegisterSuccessPage(),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            );
          case '/settings/change_phone':
            return MaterialPageRoute(
              builder: (context) => const ChangePhonePage(),
            );
          case '/settings/change_password':
            return MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            );
          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ButlerPage(),
    const MessagesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: '管家',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}