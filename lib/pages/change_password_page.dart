import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/service_method.dart';
import '../components/componentsModel.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController sureNewPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('修改登录密码'),),
      body: Container(
        color: Color(0xFFF2F2F2),
        child: Column(
          children: <Widget>[
            Padding(
              child: null,
              padding: EdgeInsets.only(top: 10),
            ),
            inputModel('原  密  码:', oldPasswordController),
            Padding(
              child: null,
              padding: EdgeInsets.only(top: 10),
            ),
            inputModel('新  密  码:', newPasswordController),
            inputModel('确认密码:', sureNewPasswordController),
            Padding(
              child: null,
              padding: EdgeInsets.only(top: 20),
            ),
            commonBtnWidget(context, '确认', _changePassword)
          ],
        ),
      )
    );
  }
  Widget inputModel(String title, TextEditingController controller) {
   return Container(
      padding: EdgeInsets.only(left: 10,right:10),
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFFCCCCCC)
          )
        ),
        color: Colors.white
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(200),
            child: Text(title,style: TextStyle(
              fontSize: ScreenUtil().setSp(32)
            )),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: inputWidget(controller, '请输入手机号', (res){},border: false,obscureText: true),
            ),
          ),
        ],
      ),
    );
  }
  _changePassword() {
    if(newPasswordController.text.trim() == ''){
      return Toast.toast(context, '请输入新密码');
    }
    if(oldPasswordController.text.trim() == '') {
      return Toast.toast(context, '请输入原密码');
    }
    if(sureNewPasswordController.text.trim() == '') {
      return Toast.toast(context, '请输入确认密码');
    }
    Map<String, dynamic>params = {};
    params['oldPassword'] = oldPasswordController.text.trim();
    params['newPassword'] = newPasswordController.text.trim();
    postAjax('modifyPassword', params, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '修改成功');
        Future.delayed(Duration(milliseconds:1000),(){
          Navigator.of(context).pop();
        });
      }
    });
    
  }
}