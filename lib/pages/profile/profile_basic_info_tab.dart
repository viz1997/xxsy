import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileBasicInfoTab extends StatefulWidget {
  const ProfileBasicInfoTab({super.key});

  @override
  State<ProfileBasicInfoTab> createState() => _ProfileBasicInfoTabState();
}

class _ProfileBasicInfoTabState extends State<ProfileBasicInfoTab> {
  String _selectedEthnicity = '汉族';
  TextEditingController _heightController = TextEditingController(text: '');
  TextEditingController _weightController = TextEditingController(text: '');
  int _selectedYear = 1985;
  String _selectedWorkLocation = '四川';
  String _selectedResidence = '四川';
  String _selectedJobType = '教师';
  String _selectedIncome = '5万以上/年';
  String _selectedEducation = '大专';

  // 择偶要求
  String _minHeight = '160';
  String _maxHeight = '190';
  String _minWeight = '45';
  String _maxWeight = '55';
  String _minAge = '95';
  String _maxAge = '01';
  String _partnerWorkLocation = '只接受本地';
  String _partnerResidence = '只接受本地';
  String _partnerJobType = '体制内';
  String _partnerIncome = '5万以上/年';
  String _partnerEthnicity = '无要求';
  String _partnerEducation = '无要求';

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildPersonalInfo(),
        const SizedBox(height: 20),
        _buildPartnerPreferences(),
      ],
    );
  }

  Widget _buildPersonalInfo() {
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
                Icon(Icons.person, color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  '个人基本信息',
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
                  '身高（cm）',
                  _buildNumberInputField(
                    controller: _heightController,
                    unit: 'cm',
                    min: 50,
                    max: 250,
                    hintText: '自行输入',
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '体重（kg）',
                  _buildNumberInputField(
                    controller: _weightController,
                    unit: 'kg',
                    min: 30,
                    max: 200,
                    hintText: '自行输入',
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '年龄（出生年份）',
                  _buildDropdownField(
                    value: _selectedYear.toString(),
                    items: List.generate(60, (i) => (1980 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _selectedYear = int.parse(v!);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '民族',
                  _buildDropdownField(
                    value: _selectedEthnicity,
                    items: ['汉族', '回族', '满族', '蒙古族', '藏族', '维吾尔族', '壮族', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _selectedEthnicity = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '学历',
                  _buildDropdownField(
                    value: _selectedEducation,
                    items: ['大专', '本科', '硕士', '博士'],
                    onChanged: (v) {
                      setState(() {
                        _selectedEducation = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '工作性质',
                  _buildDropdownField(
                    value: _selectedJobType,
                    items: ['教师', '体制内', '企业', '自由职业', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _selectedJobType = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '工作所在地',
                  _buildDropdownField(
                    value: _selectedWorkLocation,
                    items: ['四川', '北京', '上海', '广州', '深圳', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _selectedWorkLocation = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '居住所在地',
                  _buildDropdownField(
                    value: _selectedResidence,
                    items: ['四川', '北京', '上海', '广州', '深圳', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _selectedResidence = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '收入',
                  _buildDropdownField(
                    value: _selectedIncome,
                    items: ['5万以上/年', '10万以上/年', '20万以上/年',  '30万以上/年', '50万以上/年', '100万以上/年', '不限'],
                    onChanged: (v) {
                      setState(() {
                        _selectedIncome = v!;
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
                  '我的择偶要求',
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
                _buildRangeField(
                  '身高（cm）',
                  _buildDropdownField(
                    value: _minHeight,
                    items: List.generate(100, (i) => (100 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _minHeight = v!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    value: _maxHeight,
                    items: List.generate(100, (i) => (100 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _maxHeight = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildRangeField(
                  '体重（kg）',
                  _buildDropdownField(
                    value: _minWeight,
                    items: List.generate(100, (i) => (30 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _minWeight = v!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    value: _maxWeight,
                    items: List.generate(100, (i) => (30 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _maxWeight = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildRangeField(
                  '年龄',
                  _buildDropdownField(
                    value: _minAge,
                    items: List.generate(100, (i) => (20 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _minAge = v!;
                      });
                    },
                  ),
                  _buildDropdownField(
                    value: _maxAge,
                    items: List.generate(100, (i) => (20 + i).toString()),
                    onChanged: (v) {
                      setState(() {
                        _maxAge = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '工作所在地',
                  _buildDropdownField(
                    value: _partnerWorkLocation,
                    items: ['只接受本地', '不限'],
                    onChanged: (v) {
                      setState(() {
                        _partnerWorkLocation = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '居住所在地',
                  _buildDropdownField(
                    value: _partnerResidence,
                    items: ['只接受本地', '不限'],
                    onChanged: (v) {
                      setState(() {
                        _partnerResidence = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '工作性质',
                  _buildDropdownField(
                    value: _partnerJobType,
                    items: ['体制内', '不限'],
                    onChanged: (v) {
                      setState(() {
                        _partnerJobType = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '收入',
                  _buildDropdownField(
                    value: _partnerIncome,
                    items: ['5万以上/年', '10万以上/年', '20万以上/年',  '30万以上/年', '50万以上/年', '100万以上/年', '不限'],
                    onChanged: (v) {
                      setState(() {
                        _partnerIncome = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '民族',
                  _buildDropdownField(
                    value: _partnerEthnicity,
                    items: ['无要求', '汉族', '回族', '满族', '蒙古族', '藏族', '维吾尔族', '壮族', '其他'],
                    onChanged: (v) {
                      setState(() {
                        _partnerEthnicity = v!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  '学历',
                  _buildDropdownField(
                    value: _partnerEducation,
                    items: ['无要求', '大专', '本科', '硕士', '博士'],
                    onChanged: (v) {
                      setState(() {
                        _partnerEducation = v!;
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
