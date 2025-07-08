import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImprovedInfoFormPage extends StatefulWidget {
  const ImprovedInfoFormPage({super.key});

  @override
  State<ImprovedInfoFormPage> createState() => _ImprovedInfoFormPageState();
}

class _ImprovedInfoFormPageState extends State<ImprovedInfoFormPage> {
  String _selectedEthnicity = '汉族';
  TextEditingController _heightController = TextEditingController(text: '');
  TextEditingController _weightController = TextEditingController(text: '');
  String _selectedEducation = '小学';
  TextEditingController _incomeController = TextEditingController(text: '');
  String _selectedOccupation = '无';
  String _selectedWorkLocation = '无';
  String _selectedHukou = '无';
  String _selectedMarriage = '未婚';
  String _selectedHousing = '无';
  String _selectedCar = '无';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('基本信息'),
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
      body: ListView(
        children: [
          const SizedBox(height: 12),
          buildFormSection([
            buildFormItem('民族', _selectedEthnicity, (value) {
              setState(() => _selectedEthnicity = value);
            }, ['汉族', '回族', '满族', '蒙古族', '藏族', '维吾尔族', '壮族', '其他']),
            buildNumberInputItem('身高', _heightController, '厘米', 50, 250),
            buildNumberInputItem('体重', _weightController, '公斤', 30, 200),
            buildFormItem('学历', _selectedEducation, (value) {
              setState(() => _selectedEducation = value);
            }, ['小学', '初中', '高中', '中专', '大专', '本科', '硕士', '博士']),
            buildNumberInputItem('年收入', _incomeController, '万元', 0, 1000),
            buildFormItem('职业', _selectedOccupation, (value) {
              setState(() => _selectedOccupation = value);
            }, ['无', '学生', '教师', '医生', '工程师', '销售', '服务业', '公务员', '自由职业', '企业管理', '其他']),
            buildFormItem('工作所在地', _selectedWorkLocation, (value) {
              setState(() => _selectedWorkLocation = value);
            }, ['无', '北京', '上海', '广州', '深圳', '杭州', '成都', '其他']),
            buildFormItem('户口所在地', _selectedHukou, (value) {
              setState(() => _selectedHukou = value);
            }, ['无', '北京', '上海', '广州', '深圳', '杭州', '成都', '其他']),
            buildFormItem('婚姻状况', _selectedMarriage, (value) {
              setState(() => _selectedMarriage = value);
            }, ['未婚', '离异', '丧偶']),
            buildFormItem('房产情况', _selectedHousing, (value) {
              setState(() => _selectedHousing = value);
            }, ['无', '有房无贷款', '有房有贷款', '与父母同住']),
            buildFormItem('车辆情况', _selectedCar, (value) {
              setState(() => _selectedCar = value);
            }, ['无', '有车无贷款', '有车有贷款']),
          ]),
        ],
      ),
    );
  }

  Widget buildFormSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget buildNumberInputItem(
    String label, 
    TextEditingController controller, 
    String unit,
    int min,
    int max,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 标签
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // 输入框
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _NumberRangeInputFormatter(min, max),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: const OutlineInputBorder(),
                    suffixText: unit,
                    hintText: '请输入$label',
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget buildFormItem(String label, String value, Function(String) onValueChanged, List<String> options) {
    return InkWell(
      onTap: () {
        _showSelectionDialog(label, value, options, onValueChanged);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 标签
                SizedBox(
                  width: 100,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // 值
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(String title, String currentValue, List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '选择$title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == currentValue;
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFFFCC00) : Colors.black,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected 
                      ? const Icon(Icons.check, color: Color(0xFFFFCC00)) 
                      : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
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