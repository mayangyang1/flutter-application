import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/service_url.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../components/toast.dart';
import 'dart:convert';
import '../common/utils.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String account = '';
  String password = '';
  @override
  void initState() { 
    super.initState();
   
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录'),),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              logoModel(),
              loginModel(),
            ],
          ),
        ),
      ),
    );
  }
  Widget logoModel() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(200)),
      child: Center(
        child: Image.asset('assets/images/logo.png',width:ScreenUtil().setWidth(300),height:ScreenUtil().setWidth(300),),
      ),
    );
  }
  Widget loginModel() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: inputWidget(userController, '请输入用户名', (res){
              account = res;
            },imgUrl: 'assets/images/users.png', inputType: 'number'),
          ),
          Container(
             margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: inputWidget(passwordController, '请输入密码', (res){
              password = res.trim();
            },imgUrl: 'assets/images/password.png', obscureText: true),
          ),
          
          commonBtnWidget(context, '立即登录', (){
             _login();
          })
        ],
      ),
    );
  }
  _login() async {
    SharedPreferences prefs =await SharedPreferences.getInstance();

    if(account == '') {
     return Toast.toast(context, '请输入账号');
    }
    if(password == '') {
      return Toast.toast(context, '请输入密码');
    }
    try {
      print('获取数据');
      Response response;
      Dio dio = new Dio();

      // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      //   client.findProxy = (uri) {
      //     return "PROXY 192.168.10.120:8888";
      //   };
      //   client.badCertificateCallback =
      //       (X509Certificate cert, String host, int port) {
      //     return true;
      //   };
      // };

      dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
      response = await dio.post('$serviceUrl/account/login', data: {'account':account.trim(), 'password':password.trim()});
      print(response.data['code']);
      if(response.data['code'] == 200) {
        String cookies = getCookieAndSaveInStorage(response);
        prefs.setString('cookies', cookies);
        prefs.setString('roleInfo', json.encode(response.data['content']));
        Navigator.pushNamedAndRemoveUntil(context, '/workBench', (route)=>false);
      }else{
        Toast.toast(context, response.data['content']);
      }
    } on DioError catch (e) {
      if (e.response.data['code'] == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route)=>false);
      }
    }
  }
}