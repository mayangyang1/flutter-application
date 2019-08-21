import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/widget_model.dart';
import 'dart:async';
import '../common/service_method.dart';
import '../components/componentsModel.dart';
import '../config/service_url.dart';

class ChangePhonePage extends StatefulWidget {
  final String oldPhone;
  ChangePhonePage({Key key, this.oldPhone});
  @override
  _ChangePhonePageState createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  TextEditingController oldPhoneController = TextEditingController();
  TextEditingController newPhoneController = TextEditingController();
  TextEditingController code1Controller = TextEditingController();
  TextEditingController code2Controller = TextEditingController();
  String newPhone = '';
  String newVerifyCode = '';
  String oldVerifyCode = '';
  Timer _timer1;
  int _countDownTime1 = 0;

  Timer _timer2;
  int _countDownTime2 = 0;

  @override
  void initState() { 
    super.initState();
    oldPhoneController.text = widget.oldPhone;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('修改手机号'),),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Color(0xFFF2F2F2)
          ),
          child: Column(
            children: <Widget>[
              Padding(
                child: null,
                padding: EdgeInsets.only(top: 10),
              ),
              phoneModel('原手机号:', oldPhoneController, false),
              verificationCodeModel('验  证  码:',code1Controller, 0, (){
                _getOldPhoneVerifyCode();
              }),
              Padding(
                child: null,
                padding: EdgeInsets.only(top: 10),
              ),
              phoneModel('新手机号:', newPhoneController, true),
              verificationCodeModel('验  证  码:',code2Controller, 1, (){
                _geetNewPhoneVerifyCode();
              }),
              Padding(child: null,padding: EdgeInsets.only(top: 30),),
              commonBtnWidget(context, '确认', _modifyLoginAccount)
            ],
          ),
        ),
      ),
    );
  }
  Widget phoneModel(String title, TextEditingController controller, bool enabled) {
    return Container(
      padding: EdgeInsets.only(left: 10,right:10),
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFFF2F2F2)
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
              child: inputWidget(controller, '请输入手机号', (res){}, enabled: enabled,border: false),
            ),
          ),
        ],
      ),
    );
  }
  Widget verificationCodeModel(String title, TextEditingController controller, int number, Function getCode) {
    String _message = '获取验证码';
    bool _doing = false;
    if(number == 0) {
      if(_countDownTime1 >0) {
        setState(() {
          _doing = true; 
          _message = '重新获取($_countDownTime1)';
        });
      }else{
        _doing = false;
        _message = '获取验证码';
      }
    }else {
      if(_countDownTime2 >0) {
        setState(() {
          _doing = true; 
          _message = '重新获取($_countDownTime2)';
        });
      }else{
        _doing = false;
        _message = '获取验证码';
      }
    }
    return Container(
      padding: EdgeInsets.only(left: 10,right:10),
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFFF2F2F2)
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
            ),),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: inputWidget(controller, '请输入验证码', (res){},border: false),
            ),
          ),
          Material(
            color: _doing? Colors.white : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              child: Container(
                width: ScreenUtil().setWidth(200),
                height: ScreenUtil().setHeight(80),
                child: Center(
                  child: Text(_message,style: TextStyle(
                    color: _doing? Color(0xFF666666) :  Colors.white
                  ),),
                ),
              ),
              onTap: getCode,
            ),
          )
        ],
      ),
    ); 
  }

  //获取原来手机号验证码 -start
  startCountDownTimer1(){
    const oneSec = const Duration(seconds: 1);

    var callback = (timer){
      setState((){
        if(_countDownTime1 < 1) {
          _timer1.cancel();
        }else{
          _countDownTime1 = _countDownTime1 -1;
        }
      });
    };
    _timer1 = Timer.periodic(oneSec, callback);
  }
  //获取原来手机号验证码 -end
  //获取新手机号验证码 -start
  startCountDownTimer2(){
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) {
      setState(() {
        if(_countDownTime2 < 1) {
          _timer2.cancel();
        }else{
          _countDownTime2 = _countDownTime2 - 1;
        } 
      });
    };
    _timer2 = Timer.periodic(oneSec, callback);
  }
  //获取新手机号验证码 -end
    _getVerifyCode(String phone, Function result) {//获取验证码
    Map<String, dynamic> params = {};
    params['mobilePhone'] = phone;
    postAjax('verifyCode', params, context).then((res) {
      result(res);
    });
  }
  _getOldPhoneVerifyCode() {
    if(_countDownTime1 == 0) {
      _getVerifyCode(widget.oldPhone, (res){
        if(res['code'] == 200) {
          setState(() {
            _countDownTime1 = 60; 
          });
          startCountDownTimer1();
        }
      });
      
    }
  }
  _geetNewPhoneVerifyCode() {
    if(_countDownTime2 == 0){
      newPhone = newPhoneController.text.toString();
      RegExp regM = RegExp(r'(^1[23456789]{1}\d{9}$)');//匹配手机号
      if(!regM.hasMatch(newPhone)){
        return Toast.toast(context, '手机号码不正确');
      }
      _validatePhone(newPhone);
      
    }
  }
  _validatePhone(newPhone) {//检验新手机号码是否存在
    Map<String, dynamic> params = {};
    params['loginAccount'] = newPhone;
    postAjaxStr('$serviceUrl/account/account/$newPhone/validate', params, context).then((res){
      if(res['code'] == 200) {
        _getVerifyCode(newPhone, (res){
          if(res['code'] == 200) {
            setState(() {
              _countDownTime2 = 60; 
            });
            startCountDownTimer2();
          }
        });
      }else{
        Toast.toast(context, res['content']);
      }
    });
  }
  _modifyLoginAccount() {//修改手机号
    if(newPhoneController.text.trim() == '') {
      return Toast.toast(context, '请填写新手机号');
    }
    if(code1Controller.text.trim() == ''){
      return Toast.toast(context, '请填写旧手机验证码');
    }
    if(code2Controller.text.trim() == ''){
      return Toast.toast(context, '请填写新手机验证码');
    }
    Map<String, dynamic> params = {};
    params['newLoginAccount'] = newPhoneController.text.trim();
    params['newVerifyCode'] = code1Controller.text.trim();
    params['oldVerifyCode'] = code2Controller.text.trim();
    postAjax('modifyAccount', params, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '修改成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          Navigator.of(context).pop();
        });
      }else{
        Toast.toast(context, res['content']);
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    _timer1.cancel();
    _timer2.cancel();
  }
}