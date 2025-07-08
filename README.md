# 心动匹配 - 腾讯人脸核身集成应用

这是一个集成了腾讯人脸核身功能的Flutter应用，主要用于用户实名认证和身份验证。

## 功能特性

- 🔐 用户登录注册系统
- 📱 手机号验证码登录
- 🆔 实名认证（姓名+身份证号）
- 👤 人脸核身验证
- 🏠 主页面导航（发现、管家、消息、我的）
- 🎨 现代化UI设计

## 技术栈

- **Flutter**: 跨平台移动应用开发框架
- **Riverpod**: 状态管理
- **Dio**: HTTP客户端
- **腾讯云人脸核身SDK**: 人脸识别和活体检测

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── tencent_faceid.dart          # 腾讯人脸核身封装
├── pages/                       # 页面文件
│   ├── login_page.dart          # 登录页面
│   ├── register_page.dart       # 注册页面
│   ├── face_verification_page.dart # 人脸核身页面
│   ├── home_page.dart           # 首页
│   └── ...
├── services/                    # 服务层
│   ├── auth_service.dart        # 认证服务
│   └── tencent_auth_service.dart # 腾讯云认证服务
├── config/                      # 配置文件
└── ...
```

## 安装和运行

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd flutter_tencent_faceid
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置环境变量**
   创建 `.env` 文件并配置以下参数：
   ```
   TENCENT_SECRET_ID=your_secret_id_here
   TENCENT_SECRET_KEY=your_secret_key_here
   WB_APP_ID=your_wb_app_id_here
   WB_LICENCE=your_licence_key_here
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

## 使用流程

1. **登录/注册**
   - 使用手机号登录（测试账号：13800138000，密码：123456）
   - 或点击注册新账号

2. **实名认证**
   - 填写真实姓名和身份证号
   - 同意用户协议和隐私政策

3. **人脸核身**
   - 点击"下一步"开始人脸核身
   - 按照提示完成活体检测
   - 核身成功后完成注册

4. **主应用**
   - 进入主页面，可以浏览发现、管家、消息、我的等模块

## 人脸核身集成

应用使用腾讯云人脸核身SDK进行身份验证：

- **SDK初始化**: 通过 `TencentFaceId.initSDK()` 初始化
- **核身验证**: 通过 `TencentFaceId.startVerification()` 启动核身
- **结果处理**: 处理核身成功/失败的回调

## 开发说明

### 主要文件说明

- `main.dart`: 应用入口，配置路由和主题
- `tencent_faceid.dart`: 腾讯人脸核身SDK的Flutter封装
- `register_page.dart`: 注册页面，集成人脸核身功能
- `auth_service.dart`: 认证服务，处理登录注册逻辑

### 自定义配置

1. **修改主题颜色**: 在 `main.dart` 中修改 `ColorScheme`
2. **配置API地址**: 在 `auth_service.dart` 中修改 `_baseUrl`
3. **调整UI样式**: 在各个页面文件中修改样式配置

## 注意事项

- 请确保在正式环境中配置正确的腾讯云密钥
- 人脸核身功能需要网络连接
- 测试时请使用真实的身份证信息
- 建议在光线充足的环境下进行人脸核身

## 许可证

本项目仅供学习和研究使用。
