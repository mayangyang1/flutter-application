import 'package:flutter/material.dart';
import '../../widget/input.dart';
import '../../components/single_picker.dart';
class DriverListSearchBarPage extends StatefulWidget {
 final Function success;

  DriverListSearchBarPage({Key key, this.success}) : super(key: key);
  _DriverListSearchBarPageState createState() => _DriverListSearchBarPageState();
}

class _DriverListSearchBarPageState extends State<DriverListSearchBarPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController userStatusController = TextEditingController();
  String fullName = '';
  String phone = '';
  List<Map> singlePickerList = [
    {'key':'', 'id': ''},
    {'key':'已激活', 'id': 'activated'},
    {'key':'未激活', 'id': 'inactivated'},
  ];
  int _index = 0;
  @override
  void initState() { 
    super.initState();
    userStatusController.text = singlePickerList[_index]['key'];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索'),),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            input(fullNameController, '请输入司机姓名', true,(val){
              setState(() {
               fullName = val; 
              });
            }),
            input(phoneController, '请输入手机号', true,(val){
              setState(() {
               phone = val; 
              });
            }),
            InkWell(
              child: input(userStatusController, '请选择激活状态', false,(val){}),
              onTap: (){
                singlePicker(context, singlePickerList, _index, (val){
                  if(val['key'] == 'confirm'){
                    setState(() {
                     _index = val['value']; 
                     userStatusController.text = singlePickerList[_index]['key'];
                    });
                  }
                });
              },
            ),
            
            InkWell(
              child: Container(
                width: 200.0,
                height: 50.0,
                margin: EdgeInsets.only(top: 20.0),
               decoration: BoxDecoration(
                 color: Theme.of(context).primaryColor,
                 borderRadius: BorderRadius.circular(5.0)
               ),
                child: Center(
                  child: Text('搜索',style: TextStyle(color: Colors.white,fontSize: 16.0),),
                )
              ),
              onTap: (){
                Navigator.of(context).pop();
                Map result = { 'fullName':fullName, 'phone': phone, 'userStatus': singlePickerList[_index]['id']};
                widget.success(result);
              },
            )
          ],
        )
      ),
    );
  }
}