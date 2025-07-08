import 'package:flutter/material.dart';

class BasicInfoFormPage extends StatefulWidget {
  const BasicInfoFormPage({super.key});

  @override
  State<BasicInfoFormPage> createState() => _BasicInfoFormPageState();
}

class _BasicInfoFormPageState extends State<BasicInfoFormPage> {
  String _selectedEthnicity = '汉族';
  String _selectedHeight = '144';
  String _selectedWeight = '40';
  String _selectedEducation = '小学';
  String _selectedIncome = '无';
  String _selectedOccupation = '无';
  String _selectedWorkLocation = '无';
  String _selectedHukou = '无';
  String _selectedMarriage = '未婚';
  String _selectedHousing = '无';
  String _selectedCar = '无';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('基本信息'),
        actions: [
          TextButton(
            onPressed: () {
              // Save information and navigate back
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
          _buildFormField('民族', _selectedEthnicity, ['汉族', '回族', '满族', '蒙古族', '藏族', '维吾尔族', '壮族', '其他']),
          _buildFormField('身高', _selectedHeight, ['144', '150', '155', '160', '165', '170', '175', '180', '185', '190']),
          _buildFormField('体重', _selectedWeight, ['40', '45', '50', '55', '60', '65', '70', '75', '80', '85', '90', '95']),
          _buildFormField('学历', _selectedEducation, ['小学', '初中', '高中', '中专', '大专', '本科', '硕士', '博士']),
          _buildFormField('年收入', _selectedIncome, ['无', '5万以下', '5-10万', '10-20万', '20-50万', '50万以上']),
          _buildFormField('职业', _selectedOccupation, ['无', '学生', '教师', '医生', '工程师', '销售', '服务业', '公务员', '自由职业', '企业管理', '其他']),
          _buildFormField('工作所在地', _selectedWorkLocation, ['无', '北京', '上海', '广州', '深圳', '杭州', '成都', '其他']),
          _buildFormField('户口所在地', _selectedHukou, ['无', '北京', '上海', '广州', '深圳', '杭州', '成都', '其他']),
          _buildFormField('婚姻状况', _selectedMarriage, ['未婚', '离异', '丧偶']),
          _buildFormField('房产情况', _selectedHousing, ['无', '有房无贷款', '有房有贷款', '与父母同住']),
          _buildFormField('车辆情况', _selectedCar, ['无', '有车无贷款', '有车有贷款']),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value, List<String> options) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _showOptionsBottomSheet(label, value, options);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 100, 
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFFFCC00),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(String label, String currentValue, List<String> options) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '请选择$label',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(option),
                      selected: currentValue == option,
                      selectedTileColor: const Color(0xFFFFF3D9),
                      selectedColor: const Color(0xFFFFCC00),
                      onTap: () {
                        setState(() {
                          // Update the selected value based on the field
                          if (label == '民族') {
                            _selectedEthnicity = option;
                          } else if (label == '身高') {
                            _selectedHeight = option;
                          } else if (label == '体重') {
                            _selectedWeight = option;
                          } else if (label == '学历') {
                            _selectedEducation = option;
                          } else if (label == '年收入') {
                            _selectedIncome = option;
                          } else if (label == '职业') {
                            _selectedOccupation = option;
                          } else if (label == '工作所在地') {
                            _selectedWorkLocation = option;
                          } else if (label == '户口所在地') {
                            _selectedHukou = option;
                          } else if (label == '婚姻状况') {
                            _selectedMarriage = option;
                          } else if (label == '房产情况') {
                            _selectedHousing = option;
                          } else if (label == '车辆情况') {
                            _selectedCar = option;
                          }
                        });
                        Navigator.pop(context);
                      },
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
} 