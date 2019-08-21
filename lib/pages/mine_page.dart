import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/service_method.dart';
import '../widget/widget_model.dart';
import '../components/componentsModel.dart';
import '../pages/change_phone_page.dart';
import '../pages/change_password_page.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Map userInfo = {};
  @override
  void initState() { 
    super.initState();
    _getUserInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人中心'),),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFF2F2F2),
          child: Column(
            children: <Widget>[
              personInfo(userInfo['fullName'] ?? '', userInfo['phone'] ?? '', userInfo['orgName'] ?? '',
              (){//修改用户名
                changeUserDialog(context, (res){
                  _editeUserInfo(res);
                });
              },(){//修改手机号
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return ChangePhonePage(oldPhone: userInfo['phone'],);
                }));
              }, (){//修改密码
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return ChangePasswordPage();
                }));
              }),
              loginOut()
            ],
          ),
        ),
      )
    );
  }
  Widget personInfo( String userName, String userPhone, String companyName, Function changeUserName, Function changeUserPhone, Function onTap) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(350),
              width: MediaQuery.of(context).size.width,
              child: Image.asset('assets/images/bg_mine.jpg',fit: BoxFit.cover,),
            ),
            Positioned(
              child: Container(
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(userName, style: TextStyle(fontSize: ScreenUtil().setSp(34)),),
                          Padding(child: null,padding: EdgeInsets.only(left: 5)),
                          InkWell(
                            child: Image.asset('assets/images/modify.png', width: ScreenUtil().setWidth(45),),
                            onTap: changeUserName,
                          )
                        ],
                      ),
                      Padding(child: null,padding: EdgeInsets.only(top: 10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(userPhone,style: TextStyle(fontSize: ScreenUtil().setSp(34)),),
                          Padding(child: null,padding: EdgeInsets.only(left: 5)),
                          InkWell(
                            child: Image.asset('assets/images/modify.png',width: ScreenUtil().setWidth(45),),
                            onTap: changeUserPhone,
                          )
                        ]
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right:10),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0xFFF2F2F2)
              ),
              top: BorderSide(
                width: 1,
                color: Color(0xFFF2F2F2)
              )
            ),
            color: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('所属公司',style: TextStyle(
                fontSize: ScreenUtil().setSp(32)
              ),),
              Text(companyName,style: TextStyle(
                fontSize: ScreenUtil().setSp(32)
              ),)
            ],
          ),
        ),
        InkWell(
          child: Container(
            padding: EdgeInsets.only(left: 10, right:10),
            height: ScreenUtil().setHeight(100),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                width: 1,
                color: Color(0xFFF2F2F2)
              )),
              color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('修改密码',style: TextStyle(
                  fontSize: ScreenUtil().setSp(32)
                ),),
                Image.asset('assets/images/arrow.png',width: ScreenUtil().setWidth(26),)
              ],
            ),
          ),
          onTap: onTap,
        )
      ],
    );
  }
  Widget loginOut() {
    return InkWell(
      child:  Container(
        margin: EdgeInsets.only(left:20, right:20,top: 40),
        height: ScreenUtil().setHeight(100),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color(0xFFcccccc)),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFcccccc),
              offset: Offset(1, 1)
            )
          ]
        ),
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text('退出登录',style: TextStyle(color: Color(0xFF666666)),),
        ),
      ),
      onTap: () {
        showMyCupertinoDialog(context, '提示', '确认要退出登录', (res){
          if(res == 'confirm'){
            _loginOutUser();
          }
        });
      },
    );
  }
  _getUserInfo() {//获取用户信息
    getAjax('selfInfo', '', context).then((res){
      if(res['code'] == 200 && res['content'] != null) {
        setState(() {
         userInfo = res['content']; 
        });
      }
    });
  }
  _editeUserInfo(String userName) {//编辑用户信息
    Map<String, dynamic> params = {};
    userInfo['fullName'] = userName;
    params = userInfo;
    postAjax('editeSelfInfo', params, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '修改成功');
        _getUserInfo();
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    userInfo = null;
  }
  _loginOutUser() {//退出登录
    getAjax('loginOut', '', context).then((res){
      if(res['code'] == 200) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route)=>false);
      }
    });
  }
}

changeUserDialog( BuildContext context, Function result) {
  TextEditingController userNameController = TextEditingController();
  bool showError = true;
  showDialog(
    context: context,
    builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                width: ScreenUtil().setWidth(500),
                height: ScreenUtil().setHeight(420),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          child: Text('修改用户名',style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                          ),),
                          padding: EdgeInsets.only(top: 10, bottom:30),
                        ),
                        Container(
                          margin: EdgeInsets.only(left:10,right:10),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1, color: Color(0xFFCCCCCC)))
                          ),
                          child: inputWidget(userNameController, '请输入用户名',(res) {},align: 'center', border: false),
                        ),
                        Padding(
                          child:Offstage(
                            child:  Text('用户名不能为空',style: TextStyle(
                              color: Theme.of(context).primaryColor
                            ),),
                            offstage: showError,
                          ),
                          padding: EdgeInsets.only(top: 5),
                        ),
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            width: ScreenUtil().setWidth(240),
                            height: ScreenUtil().setHeight(100),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Center(
                              child: Text('确定', style: TextStyle(
                                color: Colors.white
                              ),),
                            ),
                          ),
                          onTap: (){
        
                            String userName = userNameController.text;
                            if(userName == '') {
                              setState((){
                                showError = false;
                              });
                            }else{
                              setState((){
                                showError = true;
                              });
                              Navigator.of(context).pop();
                              result(userName);
                            }
                          },
                        )
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        alignment: Alignment.topRight,
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  );
}