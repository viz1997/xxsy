import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_tencent_faceid/pages/profile/profile_basic_info_tab.dart';
import 'package:flutter_tencent_faceid/pages/profile/profile_life_info_tab.dart';
import 'package:flutter_tencent_faceid/pages/profile/profile_family_info_tab.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGender = '女';
  DateTime _selectedDate = DateTime(1995, 5, 15);
  TextEditingController _heightController = TextEditingController(text: '');
  TextEditingController _weightController = TextEditingController(text: '');
  String _selectedEducation = '本科';
  String _selectedOccupation = '产品经理';
  String _selectedLocation = '上海市';
  TextEditingController _incomeController = TextEditingController(text: '');
  String _selectedWorkLocation = '上海';
  String _selectedSmoking = '无所谓';
  String _selectedDrinking = '无所谓';
  String _selectedMarriage = '未婚';
  String _selectedChildren = '是';
  String _selectedHousing = '有房无贷款';
  String _selectedCar = '有车';
  String _selectedHukou = '江苏';
  String _selectedEthnicity = '汉族';
  String _selectedHeightRange = '170cm-190cm';
  String _selectedEducationRequirement = '本科及以上';
  String _selectedIncomeRequirement = '20万以上';
  String _selectedGambling = '无所谓';
  String _selectedTattoo = '无所谓';
  String _selectedPets = '无所谓';
  String _selectedRelationshipExp = '无所谓';
  String _selectedOnlyChild = '是';
  String _selectedBornFamily = '是';
  String _selectedParentsStatus = '父母在世';
  String _selectedParentsSocialStatus = '无';
  String _selectedParentsRetirementPay = '无';
  String _selectedMinHeight = '144';
  String _selectedMaxHeight = '170';
  String _selectedMinAge = '5';
  String _selectedMaxAge = '5';
  String _selectedSmokingPreference = '无所谓';
  String _selectedDrinkingPreference = '无所谓';
  String _selectedGamblingPreference = '无所谓';
  String _selectedTattooPreference = '无所谓';
  String _selectedPetsPreference = '无所谓';
  String _selectedRelationshipExpPreference = '无所谓';
  String _selectedOnlyChildPreference = '无所谓';
  String _selectedBornFamilyPreference = '无所谓';
  String _selectedParentsStatusPreference = '无所谓';
  String _selectedParentsSocialStatusPreference = '无所谓';
  String _selectedParentsRetirementPayPreference = '无所谓';
  File? _profileImage;
  final TextEditingController _nicknameController = TextEditingController(text: '王先生');
  final TextEditingController _introController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _incomeController.dispose();
    _tabController.dispose();
    _nicknameController.dispose();
    _introController.dispose();
    super.dispose();
  }

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

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('选择城市', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: ['上海', '北京', '广州', '深圳', '杭州'].map((city) {
                    return ListTile(
                      title: Text(city),
                      onTap: () {
                        setState(() {
                          _selectedLocation = city;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('个人资料编辑'),
        actions: [
          TextButton(
            onPressed: () {
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
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: '基本信息'),
              Tab(text: '生活信息'),
              Tab(text: '家庭信息')
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProfileBasicInfoTab(),
                ProfileLifeInfoTab(),
                ProfileFamilyInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // 个人信息部分
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Theme.of(context).primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '个人信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              // 表单内容
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoField(
                      '民族',
                      _buildDropdownField(
                        value: _selectedEthnicity,
                        items: ['汉族', '回族', '满族', '蒙古族', '藏族', '维吾尔族', '壮族', '其他'],
                        onChanged: (value) {
                          setState(() {
                            _selectedEthnicity = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '身高',
                      _buildNumberInputField(
                        controller: _heightController,
                        unit: 'cm',
                        min: 50,
                        max: 250,
                        hintText: '请输入身高',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '体重',
                      _buildNumberInputField(
                        controller: _weightController,
                        unit: 'kg',
                        min: 30,
                        max: 200,
                        hintText: '请输入体重',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '学历',
                      _buildDropdownField(
                        value: _selectedEducation,
                        items: ['小学', '初中', '高中', '中专', '大专', '本科', '硕士', '博士'],
                        onChanged: (value) {
                          setState(() {
                            _selectedEducation = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '年收入',
                      _buildNumberInputField(
                        controller: _incomeController,
                        unit: '万元',
                        min: 0,
                        max: 1000,
                        hintText: '请输入年收入',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '职业',
                      _buildDropdownField(
                        value: _selectedOccupation,
                        items: [
                          '无',
                          '学生',
                          '教师',
                          '医生',
                          '工程师',
                          '销售',
                          '服务业',
                          '公务员',
                          '自由职业',
                          '企业管理',
                          '其他',
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedOccupation = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildPartnerPreferences(),
      ],
    );
  }

  Widget _buildPartnerPreferences() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  '择偶要求',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoField(
                  '民族',
                  _buildDropdownField(
                    value: _selectedEthnicity,
                    items: ['汉族', '回族', '满族', '蒙古族', '藏族', '维吾尔族', '壮族', '其他'],
                    onChanged: (value) {
                      setState(() {
                        _selectedEthnicity = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildRangeField(
                  '身高',
                  _buildDropdownField(
                    value: _selectedMinHeight,
                    items: List.generate(100, (index) => (100 + index).toString()),
                    onChanged: (value) {
                      setState(() {
                        _selectedMinHeight = value!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    value: _selectedMaxHeight,
                    items: List.generate(100, (index) => (100 + index).toString()),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaxHeight = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildRangeField(
                  '标准体重',
                  _buildDropdownField(
                    value: _selectedMinAge,
                    items: List.generate(200, (index) => index.toString()),
                    onChanged: (value) {
                      setState(() {
                        _selectedMinAge = value!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    value: _selectedMaxAge,
                    items: List.generate(200, (index) => index.toString()),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaxAge = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '学历',
                  _buildDropdownField(
                    value: '小学以下',
                    items: ['小学以下', '初中', '高中', '大专', '本科', '硕士', '博士'],
                    onChanged: (value) {
                      setState(() {
                        // Handle education change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '年收入',
                  _buildDropdownField(
                    value: '无所谓',
                    items: ['无所谓', '5万以下', '5-10万', '10-20万', '20-50万', '50万以上'],
                    onChanged: (value) {
                      setState(() {
                        // Handle income change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '职业',
                  _buildDropdownField(
                    value: '无所谓(可多选)',
                    items: ['无所谓(可多选)', '学生', '教师', '医生', '工程师', '公务员', '其他'],
                    onChanged: (value) {
                      setState(() {
                        // Handle occupation change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '工作所在地',
                  _buildDropdownField(
                    value: '无所谓',
                    items: ['无所谓', '北京', '上海', '广州', '深圳', '其他'],
                    onChanged: (value) {
                      setState(() {
                        // Handle work location change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '户口所在地',
                  _buildDropdownField(
                    value: '无所谓',
                    items: ['无所谓', '北京', '上海', '广州', '深圳', '其他'],
                    onChanged: (value) {
                      setState(() {
                        // Handle household registration change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '婚姻状况',
                  _buildDropdownField(
                    value: '无所谓',
                    items: ['无所谓', '未婚', '离异', '丧偶'],
                    onChanged: (value) {
                      setState(() {
                        // Handle marital status change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '房产情况',
                  _buildDropdownField(
                    value: '无所谓',
                    items: ['无所谓', '有房', '无房'],
                    onChanged: (value) {
                      setState(() {
                        // Handle housing situation change
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '车辆情况',
                  _buildDropdownField(
                    value: '无所谓',
                    items: ['无所谓', '有车', '无车'],
                    onChanged: (value) {
                      setState(() {
                        // Handle car ownership change
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeField(String label, Widget minField, Widget maxField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: minField),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('至',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            Expanded(child: maxField),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildLifeInfoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // 原有的生活信息部分
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Theme.of(context).primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '生活信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoField(
                      '抽烟',
                      _buildDropdownField(
                        value: _selectedSmoking,
                        items: ['无', '偶尔', '经常'],
                        onChanged: (value) {
                          setState(() {
                            _selectedSmoking = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '喝酒',
                      _buildDropdownField(
                        value: _selectedDrinking,
                        items: ['无', '偶尔', '经常'],
                        onChanged: (value) {
                          setState(() {
                            _selectedDrinking = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '打牌',
                      _buildDropdownField(
                        value: _selectedGambling,
                        items: ['无', '偶尔', '经常'],
                        onChanged: (value) {
                          setState(() {
                            _selectedGambling = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '纹身',
                      _buildDropdownField(
                        value: _selectedTattoo,
                        items: ['无', '有'],
                        onChanged: (value) {
                          setState(() {
                            _selectedTattoo = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '宠物',
                      _buildDropdownField(
                        value: _selectedPets,
                        items: ['无', '有'],
                        onChanged: (value) {
                          setState(() {
                            _selectedPets = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '感情经历',
                      _buildDropdownField(
                        value: _selectedRelationshipExp,
                        items: ['无', '有'],
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationshipExp = value!;
                          });
                        },
                      ),
                    ),
            
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 生活信息择偶要求部分
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite_outline, color: Theme.of(context).primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '择偶要求',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoField(
                      '抽烟',
                      _buildDropdownField(
                        value: _selectedSmokingPreference,
                        items: ['无所谓', '不能接受', '偶尔可以'],
                        onChanged: (value) {
                          setState(() {
                            _selectedSmokingPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '喝酒',
                      _buildDropdownField(
                        value: _selectedDrinkingPreference,
                        items: ['无所谓', '不能接受', '偶尔可以'],
                        onChanged: (value) {
                          setState(() {
                            _selectedDrinkingPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '打牌',
                      _buildDropdownField(
                        value: _selectedGamblingPreference,
                        items: ['无所谓', '不能接受', '偶尔可以'],
                        onChanged: (value) {
                          setState(() {
                            _selectedGamblingPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '纹身',
                      _buildDropdownField(
                        value: _selectedTattooPreference,
                        items: ['无所谓', '不能接受', '可以接受'],
                        onChanged: (value) {
                          setState(() {
                            _selectedTattooPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '宠物',
                      _buildDropdownField(
                        value: _selectedPetsPreference,
                        items: ['无所谓', '不能接受', '可以接受'],
                        onChanged: (value) {
                          setState(() {
                            _selectedPetsPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '感情经历',
                      _buildDropdownField(
                        value: _selectedRelationshipExpPreference,
                        items: ['无所谓', '必须没有', '有也可以'],
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationshipExpPreference = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyInfoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // 原有的家庭信息部分
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.family_restroom, color: Theme.of(context).primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '家庭信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoField(
                      '独生子女',
                      _buildDropdownField(
                        value: _selectedOnlyChild,
                        items: ['是', '否'],
                        onChanged: (value) {
                          setState(() {
                            _selectedOnlyChild = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '原生家庭',
                      _buildDropdownField(
                        value: _selectedBornFamily,
                        items: ['是', '否'],
                        onChanged: (value) {
                          setState(() {
                            _selectedBornFamily = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '父母状况',
                      _buildDropdownField(
                        value: _selectedParentsStatus,
                        items: ['父母在世', '单亲家庭', '父母离异', '父母均离世'],
                        onChanged: (value) {
                          setState(() {
                            _selectedParentsStatus = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '父母社会地位',
                      _buildDropdownField(
                        value: _selectedParentsSocialStatus,
                        items: ['无', '公务员', '事业单位', '企业高管', '私营业主', '其他'],
                        onChanged: (value) {
                          setState(() {
                            _selectedParentsSocialStatus = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '父母退休金',
                      _buildDropdownField(
                        value: _selectedParentsRetirementPay,
                        items: ['无', '有'],
                        onChanged: (value) {
                          setState(() {
                            _selectedParentsRetirementPay = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 家庭信息择偶要求部分
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite_outline, color: Theme.of(context).primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      '择偶要求',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoField(
                      '独生子女',
                      _buildDropdownField(
                        value: _selectedOnlyChildPreference,
                        items: ['无所谓', '必须是', '不能是'],
                        onChanged: (value) {
                          setState(() {
                            _selectedOnlyChildPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '原生家庭',
                      _buildDropdownField(
                        value: _selectedBornFamilyPreference,
                        items: ['无所谓', '必须是', '不能是'],
                        onChanged: (value) {
                          setState(() {
                            _selectedBornFamilyPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '父母状况',
                      _buildDropdownField(
                        value: _selectedParentsStatusPreference,
                        items: ['无所谓', '父母需在世', '单亲也可以', '不限'],
                        onChanged: (value) {
                          setState(() {
                            _selectedParentsStatusPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '父母社会地位',
                      _buildDropdownField(
                        value: _selectedParentsSocialStatusPreference,
                        items: ['无所谓', '需要有一定社会地位', '不限'],
                        onChanged: (value) {
                          setState(() {
                            _selectedParentsSocialStatusPreference = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoField(
                      '父母退休金',
                      _buildDropdownField(
                        value: _selectedParentsRetirementPayPreference,
                        items: ['无所谓', '需要有', '不限'],
                        onChanged: (value) {
                          setState(() {
                            _selectedParentsRetirementPayPreference = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items[0],
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFCC00)),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberInputField({
    required TextEditingController controller,
    required String unit,
    required int min,
    required int max,
    required String hintText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _NumberRangeInputFormatter(min, max),
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          hintText: hintText,
          suffixText: unit,
          suffixStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }
}

// 数字范围输入格式化器
class _NumberRangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _NumberRangeInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    int? value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (value < min) {
      return TextEditingValue(
        text: min.toString(),
        selection: TextSelection.collapsed(offset: min.toString().length),
      );
    }

    if (value > max) {
      return TextEditingValue(
        text: max.toString(),
        selection: TextSelection.collapsed(offset: max.toString().length),
      );
    }

    return newValue;
  }
}
