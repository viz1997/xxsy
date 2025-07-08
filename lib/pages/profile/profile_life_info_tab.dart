import 'package:flutter/material.dart';

class ProfileLifeInfoTab extends StatefulWidget {
  const ProfileLifeInfoTab({super.key});

  @override
  State<ProfileLifeInfoTab> createState() => _ProfileLifeInfoTabState();
}

class _ProfileLifeInfoTabState extends State<ProfileLifeInfoTab> {
  String _selectedSmoking = '无';
  String _selectedDrinking = '无';
  String _selectedGambling = '无';
  String _selectedTattoo = '无';
  String _selectedPets = '无';
  String _selectedRelationshipExp = '无';
  String _selectedSmokingPreference = '无所谓';
  String _selectedDrinkingPreference = '无所谓';
  String _selectedGamblingPreference = '无所谓';
  String _selectedTattooPreference = '无所谓';
  String _selectedPetsPreference = '无所谓';
  String _selectedRelationshipExpPreference = '无所谓';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildLifeInfo(),
        const SizedBox(height: 20),
        _buildLifePartnerPreferences(),
      ],
    );
  }

  Widget _buildLifeInfo() {
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
                  '宠物偏好',
                  _buildDropdownField(
                    value: _selectedPets,
                    items: ['无所谓', '可以接受', '不能接受'],
                    onChanged: (value) {
                      setState(() {
                        _selectedPets = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '恋爱同居史',
                  _buildDropdownField(
                    value: _selectedRelationshipExp,
                    items: ['无', '一段以上', '两段以上'],
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationshipExp = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '星座',
                  _buildDropdownField(
                    value: _selectedRelationshipExp,
                    items: ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'],
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationshipExp = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '婚姻',
                  _buildDropdownField(
                    value: _selectedRelationshipExp,
                    items: ['未婚', '离异无小孩', '离异有小孩', '丧偶无小孩', '丧偶有小孩'],
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationshipExp = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '是否想要孩子',
                  _buildDropdownField(
                    value: _selectedRelationshipExp,
                    items: ['无所谓', '想要', '不想要'],
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
    );
  }

  Widget _buildLifePartnerPreferences() {
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
                  '宠物偏好',
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
                  '恋爱同居史',
                  _buildDropdownField(
                    value: _selectedRelationshipExpPreference,
                    items: ['无所谓', '一段以上', '两段以上'],
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationshipExpPreference = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '星座',
                  _buildDropdownField(
                    value: _selectedRelationshipExpPreference,
                    items: ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'],
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationshipExpPreference = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '婚姻',
                  _buildDropdownField(
                    value: _selectedRelationshipExpPreference,
                    items: ['未婚', '离异无小孩', '离异有小孩', '丧偶无小孩', '丧偶有小孩'],
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationshipExpPreference = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '是否想要孩子',
                  _buildDropdownField(
                    value: _selectedRelationshipExpPreference,
                    items: ['无所谓', '想要', '不想要'],
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
}
