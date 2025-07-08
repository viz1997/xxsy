import 'package:flutter/material.dart';

class ProfileFamilyInfoTab extends StatefulWidget {
  const ProfileFamilyInfoTab({super.key});

  @override
  State<ProfileFamilyInfoTab> createState() => _ProfileFamilyInfoTabState();
}

class _ProfileFamilyInfoTabState extends State<ProfileFamilyInfoTab> {
  String _familyStructure = '原生家庭';
  String _parentsStatus = '退休';
  String _parentsInsurance = '无';
  String _familyMember = '独生子';
  String _house = '无';
  String _car = '无';

  // 择偶要求
  String _partnerFamilyStructure = '无所谓';
  String _partnerParentsStatus = '无所谓';
  String _partnerParentsInsurance = '无所谓';
  String _partnerFamilyMember = '无所谓';
  String _partnerHouse = '无所谓';
  String _partnerCar = '无所谓';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildFamilyInfo(),
        const SizedBox(height: 20),
        _buildFamilyPartnerPreferences(),
      ],
    );
  }

  Widget _buildFamilyInfo() {
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
                  '家庭结构',
                  _buildDropdownField(
                    value: _familyStructure,
                    items: ['原生家庭', '离异家庭', '单亲家庭', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _familyStructure = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '父母现状',
                  _buildDropdownField(
                    value: _parentsStatus,
                    items: ['退休有退休金', '退休无退休金', '在职', '离世', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _parentsStatus = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '父母社医保',
                  _buildDropdownField(
                    value: _parentsInsurance,
                    items: ['无', '父母均有'],
                    onChanged: (v) {
                      setState(() {
                        _parentsInsurance = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '家庭人员',
                  _buildDropdownField(
                    value: _familyMember,
                    items: ['独生子', '有哥哥', '有姐姐', '有弟弟', '有妹妹'],
                    onChanged: (v) {
                      setState(() {
                        _familyMember = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '房产',
                  _buildDropdownField(
                    value: _house,
                    items: ['无', '有，有贷款', '有，无贷款'],
                    onChanged: (v) {
                      setState(() {
                        _house = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '车辆',
                  _buildDropdownField(
                    value: _car,
                    items: ['无', '有，有贷款', '有，无贷款'],
                    onChanged: (v) {
                      setState(() {
                        _car = v!;
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

  Widget _buildFamilyPartnerPreferences() {
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
                  '家庭结构',
                  _buildDropdownField(
                    value: _partnerFamilyStructure,
                    items: ['无所谓', '只接受原生家庭', '只接受重组家庭', '只接受单亲家庭', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _partnerFamilyStructure = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '父母现状',
                  _buildDropdownField(
                    value: _partnerParentsStatus,
                    items: ['无所谓', '退休', '在职', '离世', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _partnerParentsStatus = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '父母社医保',
                  _buildDropdownField(
                    value: _partnerParentsInsurance,
                    items: ['无所谓', '无', '有'],
                    onChanged: (v) {
                      setState(() {
                        _partnerParentsInsurance = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '家庭人员',
                  _buildDropdownField(
                    value: _partnerFamilyMember,
                    items: ['无所谓', '独生子', '有兄弟姐妹'],
                    onChanged: (v) {
                      setState(() {
                        _partnerFamilyMember = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '房产',
                  _buildDropdownField(
                    value: _partnerHouse,
                    items: ['无所谓', '无', '有'],
                    onChanged: (v) {
                      setState(() {
                        _partnerHouse = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '车辆',
                  _buildDropdownField(
                    value: _partnerCar,
                    items: ['无所谓', '无', '有'],
                    onChanged: (v) {
                      setState(() {
                        _partnerCar = v!;
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
