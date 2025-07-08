import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileInfoEditPage extends StatefulWidget {
  const ProfileInfoEditPage({super.key});

  @override
  State<ProfileInfoEditPage> createState() => _ProfileInfoEditPageState();
}

class _ProfileInfoEditPageState extends State<ProfileInfoEditPage> {
  File? _avatarImage;
  List<File> _photoList = [];
  final int _maxPhotos = 6;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _expectationController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _introductionController.dispose();
    _expectationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, {bool isAvatar = false}) async {
    final ImagePicker picker = ImagePicker();
    if (isAvatar) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
      }
    } else {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          final newPhotos = images.map((xFile) => File(xFile.path)).toList();
          if (_photoList.length + newPhotos.length > _maxPhotos) {
            // 如果选择的照片加上现有的照片超过最大数量，只取到最大数量
            _photoList = [..._photoList, ...newPhotos].take(_maxPhotos).toList();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('最多只能选择$_maxPhotos张照片')),
            );
          } else {
            _photoList = [..._photoList, ...newPhotos];
          }
        });
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoList.removeAt(index);
    });
  }

  void _showImagePickerDialog({bool isAvatar = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '选择照片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isAvatar) ...[
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
                    _pickImage(ImageSource.gallery, isAvatar: true);
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
                    _pickImage(ImageSource.camera, isAvatar: true);
                  },
                ),
              ] else
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
                  title: Text('从相册选择（还可以选择${_maxPhotos - _photoList.length}张）'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _photoList.length < _maxPhotos ? _photoList.length + 1 : _maxPhotos,
      itemBuilder: (context, index) {
        if (index == _photoList.length) {
          // 添加照片的按钮
          return GestureDetector(
            onTap: () => _showImagePickerDialog(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '添加照片',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 已选择的照片
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _photoList[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
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
      appBar: AppBar(
        title: const Text('编辑信息'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save changes
              Navigator.pop(context);
            },
            child: Text(
              '保存',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            Center(
              child: GestureDetector(
                onTap: () => _showImagePickerDialog(isAvatar: true),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _avatarImage != null
                            ? Image.file(
                                _avatarImage!,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 昵称
            const Text(
              '昵称',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '请输入昵称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 照片墙
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '照片墙',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_photoList.length}/$_maxPhotos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPhotoGrid(),
            const SizedBox(height: 24),

            // 自我介绍
            const Text(
              '自我介绍',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _introductionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '介绍一下自己吧',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 期待的他/她
            const Text(
              '期待的他/她',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _expectationController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '说说你期待的另一半是怎样的',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 