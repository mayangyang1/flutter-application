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
import './truck_detail_page.dart';
import '../config/service_url.dart';

class TruckListPage extends StatefulWidget {
  @override
  _TruckListPageState createState() => _TruckListPageState();
}

class _TruckListPageState extends State<TruckListPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List truckList = [];
  String truckLicenseNo = '';
  String driverFullName = '';
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
    _getTruckList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('车辆列表'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'truckListPage',
              singlePickerList,
              _index,
              (val){//搜索框
                print(val);
                setState(() {
                  truckLicenseNo = val['truckLicenseNo'] ?? '';
                  driverFullName = val['driverFullName'] ?? '';
                  _loading = true;
                });
                page = 1;
                truckList = [];
                _getTruckList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  truckList = [];
                  _getTruckList();
                }
              }
            ),
            Expanded(
              child: commonRereshListWidget(truckList, _headerKey, _footerKey, '暂无车辆', (){
                page ++;
                _getTruckList();
              }, (){
                page = 1;
                truckList = [];
                _getTruckList();
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
            topContent(context,item['mainTruckLicenseNo'] ?? '', item['mainTruckCertStatus'] != null? configResourceTruckStatus[item['mainTruckCertStatus']] : ''),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return TruckDetailPage(code: item['code'],);
        }));
      },
    );
  }

  Widget topContent(BuildContext context, String truckLicenseNo, String rightTitle) {
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
            child: Text('$truckLicenseNo',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
          ),
          Text(rightTitle,style: TextStyle( fontSize:  ScreenUtil().setSp(32),color:Theme.of(context).primaryColor),)
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
                child: Text(item['truckModelCode'] != null? configTruckModel[item['truckModelCode']]?? '' : '',style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
              ),
              Row(
                children: <Widget>[
                  Text('${item['truckLength'] != null? item['truckLength'].toString() + '米' : ''}' ,style: TextStyle(height: 1.2),),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setWidth(180)
                    ),
                    child: Text('  ${item['mainTruckRegTonnage'] != null? item['mainTruckRegTonnage'].toString() + '吨' : ''}',style: TextStyle(height: 1.2),overflow: TextOverflow.ellipsis,),
                  )
                  
                ],
              ),
              
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text( '主: ${item['driverFullName'] ?? ''} ${item['driverPhone'] ?? ''}',style: TextStyle(height: 1.3),),
              Text( '副: ${item['viceDriverFullName'] ?? ''} ${item['viceDriverPhone'] ?? ''}',style: TextStyle(height: 1.3)),
            ],
          )
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
            offstage: item['mainTruckCertStatus'] == 'unauthenticated' || item['mainTruckCertStatus'] == 'failed' ? false : true,
            child: minButton(context,'认证', true, (){
              _verifyTruck(item['mainTruckCode']);
            }),
          ),
        ]
      ),
    );
  }
  _getTruckList() {//获取车辆列表
    certStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size';
    if(certStatus != ''){
      stringParams += '&mainTruckCertStatus=$certStatus';
    }
    if(truckLicenseNo != ''){
      stringParams += '&mainTruckLicenseNo=$truckLicenseNo';
    }
    if(driverFullName != ''){
      stringParams += '&driverFullName=$driverFullName';
    }
    getAjax('truckList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         truckList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           truckList = []; 
          });
        }
      }
    });
  }
  _verifyTruck(code) {
    postAjaxStr('$serviceUrl/truck/truck/$code/verify', {}, context).then((res){
      if(res['code'] == 200 ){
        Toast.toast(context, '认证成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          page = 1;
          truckList = [];
          _getTruckList();
        });
      }
    });
  }
  
}