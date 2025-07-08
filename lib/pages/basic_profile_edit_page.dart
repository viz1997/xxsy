import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BasicProfileEditPage extends StatefulWidget {
  const BasicProfileEditPage({super.key});

  @override
  State<BasicProfileEditPage> createState() => _BasicProfileEditPageState();
}

class _BasicProfileEditPageState extends State<BasicProfileEditPage> {
  File? _profileImage;
  final List<File> _photoWall = [];
  final TextEditingController _nicknameController = TextEditingController(text: '王先生');
  final TextEditingController _introController = TextEditingController(text: '');
  final TextEditingController _expectationController = TextEditingController(text: '');

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickPhotoWallImage() async {
    if (_photoWall.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传6张照片')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _photoWall.add(File(image.path));
      });
    }
  }

  void _removePhotoWallImage(int index) {
    setState(() {
      _photoWall.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('编辑信息', style: TextStyle(color: Colors.black)),
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 头像编辑
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(_profileImage!),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1552058544-f2b08422138a'),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 昵称编辑
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditField(
                    label: '昵称',
                    controller: _nicknameController,
                    maxLength: 20,
                  ),
                  const SizedBox(height: 25),
                  // 照片墙
                  const Text(
                    '照片墙',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '最多上传6张照片',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _photoWall.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _photoWall.length) {
                        return _buildAddPhotoButton();
                      }
                      return _buildPhotoItem(index);
                    },
                  ),
                  const SizedBox(height: 25),
                  // 自我介绍
                  _buildEditField(
                    label: '自我介绍',
                    controller: _introController,
                    maxLength: 500,
                    maxLines: 5,
                    hintText: '介绍一下自己，让别人更了解你~',
                  ),
                  const SizedBox(height: 25),
                  // 期待的他/她
                  _buildEditField(
                    label: '期待的他/她',
                    controller: _expectationController,
                    maxLength: 300,
                    maxLines: 4,
                    hintText: '说说你期待的另一半是什么样的~',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickPhotoWallImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(_photoWall[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => _removePhotoWallImage(index),
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
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required int maxLength,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
} 