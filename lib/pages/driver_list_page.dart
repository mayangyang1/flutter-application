import 'package:flutter/material.dart';
import '../components/progressDialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/searchPageWidget/common_refresh_list_widget.dart';
import '../widget/widget_model.dart';
import '../components/search_bar.dart';
import '../common/service_method.dart';
import '../common/utils.dart';
import '../components/componentsModel.dart';
import './driver_detail_page.dart';
import '../config/service_url.dart';

class DriverListPage extends StatefulWidget {
  @override
  _DriverListPageState createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List driverList = [];
  String fullName = '';
  String phone = '';
  String userStatus = '';
  List<Map> singlePickerList = [
    {'key':'全部', 'id': ''},
    {'key':'未认证', 'id': 'unauthenticated'},
    {'key':'认证中', 'id': 'authenticating'},
    {'key':'已认证', 'id': 'authenticated'},
    {'key':'认证失败', 'id': 'failed'},
  ];
  int _index = 0;
  String certStatus = '';
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getDriverList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('司机列表'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'driverListPage',
              singlePickerList,
              _index,
              (val){//搜索框
                print(val);
                setState(() {
                  fullName = val['fullName'] ?? '';
                  phone = val['phone'] ?? '';
                  userStatus = val['userStatus'];
                  _loading = true;
                });
                page = 1;
                driverList = [];
                _getDriverList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  driverList = [];
                  _getDriverList();
                }
              }
            ),
            Expanded(
              child: commonRereshListWidget(driverList, _headerKey, _footerKey, '暂无车辆', (){
                page ++;
                _getDriverList();
              }, (){
                page = 1;
                driverList = [];
                _getDriverList();
              }, itemCardWidget),
            )
          ],
        ),
      ),
    );
  }
  Widget itemCardWidget(int index, Map item){
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.all(10.0),
        // height: 200,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1,color: Color(0XFFCCCCCC)),top: BorderSide(width: 1,color: Color(0xFFCCCCCC))),
          color: Color(0xFFFFFFFF)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            topContent(context,item['fullName'] ?? '', item['certStatus'] != null? configResourceTruckStatus[item['certStatus']] ?? '' : ''),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return DriverDetailPage(code: item['code'],);
        }));
      },
    );
  }

  Widget topContent(BuildContext context, String fullName, String rightTitle) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1,color: Color(0xFFF2F2F2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
           Container(
            width: ScreenUtil().setWidth(400),
            child: Text('$fullName',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
          ),
          Text(rightTitle,style: TextStyle( fontSize:  ScreenUtil().setSp(32),color: Color(0xFF8E8E8E)),)
        ],
      ),
    ); 
  }
  Widget centerContent(Map item){
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(400),
                child: Text('手机号: ${item['phone'] ?? ''} ${item['gender'] == 'female'? '女' : '男'}',style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
              ),
              Row(
                children: <Widget>[
                  Text('身份证号:${item['identityNumber'] ?? ''}' ,style: TextStyle(height: 1.2),),
                ],
              ),
              
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(160),
          child: Text( '${item['userStatus'] == 'activated'? '已激活' : '未激活'}',style: TextStyle(color: Theme.of(context).primaryColor),),
        )
      ]
    );
  }
  Widget bottomContent(Map item) {
    return Container(
      height: ScreenUtil().setHeight(100),
      padding: EdgeInsets.only(top: 10),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(
          width: 1,
          color: Color(0xFFF2F2F2)
        ))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Offstage(
            offstage: item['certStatus'] == 'unauthenticated' || item['certStatus'] == 'failed'? false : true,
            child: minButton(context,'认证', true, (){
              _verifyDriver(item['code']);
            }),
          ),
          
        ]
      ),
    );
  }
  _getDriverList() {//获取司机列表
    certStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size';
    if(certStatus != ''){
      stringParams += '&certStatus=$certStatus';
    }
    if(fullName != '') {
      stringParams += '&fullName=$fullName';
    }
    if(phone != '') {
      stringParams += '&phone=$phone';
    }
    if(userStatus != ''){
      stringParams += '&userStatus=$userStatus';
    }
    getAjax('driverList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         driverList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           driverList = []; 
          });
        }
      }
    });
  }

  _verifyDriver(code) {
    postAjaxStr('$serviceUrl/person/person/driver/$code/verify', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '认证成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          page = 1;
          driverList = [];
          _getDriverList();
        });
      }
    });
  }
  
}