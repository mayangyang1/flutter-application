import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/service_method.dart';
import './search_customer_page.dart';
import './release_resource_page.dart';
import './build_waybill_page.dart';
import './resource_list_page.dart';
import './logistics_list_page.dart';
import './waybill_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../common/utils.dart';
import '../components/progressDialog.dart';
import './vehicle_certification_page.dart';
import './driver_certification_page.dart';
import './truck_list_page.dart';
import './driver_list_page.dart';

class WorkBenchPage extends StatefulWidget {
  @override
  _WorkBenchPageState createState() => _WorkBenchPageState();
}

class _WorkBenchPageState extends State<WorkBenchPage>  {

  bool isLogisticsGet = false; //查看订单列表权限
  bool isFreightAdd = false; //发布货源权限
  bool isFreightGet = false; //货源列表权限
  bool isWaybillGet = false; //运单列表权限
  bool isWaybillAdd = false; //直接派车权限
  bool isTruckGet = false; //车辆认证权限
  bool isDriverGet = false; //司机认证权限
  bool isTransportGet = false; //车辆列表权限
  bool isDriverListGet = false; //司机列表权限
  bool isLogisticsAffirmGet = false; //订单确认列表
  bool isTransportAdd = false; //新建车辆
  bool isDriverAdd = false; //新建司机
  bool _loading = false;
  @override
  void initState() { 
    super.initState();
    _getFreightList();
    _getOtherConfigMessage();
    _getAreaInfo();
    _getOrgSelfInfo();
    _loading = true;
    _checkedPremission();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('工作台'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        alpha: 0.5,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 20),
            color: Color(0xFFF2F2F2),
            child: Column(
              children: <Widget>[
                bannerModel(),
                taskModel(),
              ],
            ),
          )
        ),
      ),
    );
  }
  Widget bannerModel() {
    return Container(
      child: Image.asset('assets/images/banner.png',),
    );
  }
  Widget taskModel() {
    return Container(
      child: Column(
        children: <Widget>[
          b2cTaskModel(),
          certificationModel(),
          Offstage(
            offstage: !isTransportGet && !isDriverListGet,
            child: resourceModel(),
          )
          
        ],
      ),
    );
  }
  Widget b2cTaskModel() {
    return Container(
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          commonTitle('B2C业务'),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1,color: Color(0xFFF2F2F2))),
              color: Colors.white
            ),
            child:  Wrap(
              spacing: 0.0,
              runSpacing: 0.0,
              children: <Widget>[
                itemModel('订单确认', 'confirm-order',isLogisticsAffirmGet,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return SearchCustomerPage();
                  }));
                }),
                itemModel('订单列表', 'logistics', isLogisticsGet ,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return LogisticsListPage();
                  }));
                }),
                itemModel('发布货源', 'releaseResource',isFreightAdd,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ReleaseResourcePage();
                  }));
                }),
                itemModel('货源列表', 'goodsList', isFreightGet,(){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ResourceListPage();
                  }));
                }),
                itemModel('直接派车', 'directCar',isWaybillAdd, (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return BuildWaybillPage();
                  }));
                }),
                itemModel('运单列表', 'orderList', isWaybillGet,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return WaybillListPage();
                  }));
                }),
                itemModel('发货列表', 'fahuo', true,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return WaybillListPage(disabledEditeStatus: true,statusIndex: 1,);
                  }));
                }),
                itemModel('收货列表', 'receiptList', true, (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return WaybillListPage(disabledEditeStatus: true,statusIndex: 2,);
                  }));
                }),
                itemModel('', '', !isLogisticsAffirmGet,(){}),
                itemModel('', '', !isLogisticsGet,(){}),
                itemModel('', '', !isFreightAdd,(){}),
                itemModel('', '', !isFreightGet,(){}),
                itemModel('', '', !isWaybillAdd,(){}),
                itemModel('', '', !isWaybillGet,(){}),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget certificationModel() {
    return Container(
     child:Column(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          commonTitle('认证管理'),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1,color: Color(0xFFF2F2F2))),
              color: Colors.white
            ),
            child:  Wrap(
              spacing: 0.0,
              runSpacing: 0.0,
              children: <Widget>[
                itemModel('车辆认证', 'certifiedTruck', isTruckGet,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return VehicleCertificationPage();
                  }));
                }),
                itemModel('司机认证', 'certifiedDriver', isDriverGet,(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return DriverCertificationPage();
                  }));
                }),
                itemModel('', '', true, (){}),
                itemModel('', '', true, (){}),
                itemModel('', '', !isTruckGet, (){}),
                itemModel('', '', !isDriverGet,(){}),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget resourceModel() {
    return Container(
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          commonTitle('资源库'),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1,color: Color(0xFFF2F2F2))),
              color: Colors.white
            ),
            child:  Wrap(
              spacing: 0.0,
              runSpacing: 0.0,
              children: <Widget>[
                itemModel('车辆列表', 'invitingMotivation', isTransportGet, (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return TruckListPage();
                  }));
                }),
                itemModel('司机列表', 'driverList', isDriverListGet, (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return DriverListPage();
                  }));
                }),
                itemModel('', '', true, (){}),
                itemModel('', '', true, (){}),
                itemModel('', '', !isTransportGet, (){}),
                itemModel('', '', !isDriverListGet, (){}),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget commonTitle(String title) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      height: ScreenUtil().setHeight(80),
      color: Color(0xFFF2F2F2),
      child: Text(title),
    );
  }
  Widget itemModel(String title, String imgUrl, bool offstage, Function result) {
    return Offstage(
      offstage: !offstage,
      child: Material(
        color: Colors.white,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.only(top: 15,bottom:15),
            width: MediaQuery.of(context).size.width/4,
            height: ScreenUtil().setHeight(200),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(width: 1, color: Color(0xFFF2F2F2)),bottom: BorderSide(width: 1, color: Color(0xFFF2F2F2)))
            ),
            child: Column(
              children: <Widget>[
                imgUrl != ''
                ? Image.asset('assets/images/$imgUrl.png',width: ScreenUtil().setWidth(65),height: ScreenUtil().setHeight(65),)
                : Container(
                  width: ScreenUtil().setWidth(65),
                  height: ScreenUtil().setHeight(65),
                  child: null,
                ),
                Padding(child: null,padding: EdgeInsets.only(top: 10),),
                Text(title)
              ],
            ),
          ),
          onTap: () {
            return result();
          },
        ),
      )
    );
    
  }
  _getFreightList() {
    getAjax('apiFreightlist', '?size=10', context).then((res){
      if(res['code'] == 200) {
        print(res['content']);
      }
    });
  }
  _getOtherConfigMessage()async {//获取登录配置信息
    SharedPreferences prefs = await SharedPreferences.getInstance();

    getAjax('otherConfig', '', context).then((res){
      if(res['code'] == 200){
        prefs.setString('otherConfigs', json.encode(res['content']));
      }
    });
  }
  _getAreaInfo()async {//获取省市区map
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getAjax('areaInfo', '', context).then((res){
      if(res['code'] == 200){
        prefs.setString('areaInfo', json.encode(res['content']));
      }
    });
  }
  _getOrgSelfInfo()async {//获取登录用户信息
  SharedPreferences prefs = await SharedPreferences.getInstance();
    getAjax('orgSelf', '', context).then((res){
      if(res['code'] == 200){
        prefs.setString('orgSelfInfo', json.encode(res['content']));
      }
    });
  }
  _checkedPremission()async {//权限校验
    
    var logisticsGet = await checkedPermission('logistics.get');
    var waybillGet = await checkedPermission('waybill.get');
    var freightAdd = await checkedPermission('freight.add');
    var freightGet = await checkedPermission('freight.get');
    var waybillAdd = await checkedPermission('waybill.add');
    var truckGet = await checkedPermission('opr.truck.cert');
    var driverGet = await checkedPermission('opr.person.cert');
    var transportGet = await checkedPermission('transport.get');
    var driverListGet = await checkedPermission('driver.get');
    var logisticsAffirmGet = await checkedPermission('logisticsAffirm.get');
    var transportAdd = await checkedPermission('transport.add');
    var driverAdd = await checkedPermission('driver.add');
    
    setState(() {
      isLogisticsGet =  logisticsGet;
      isWaybillGet =  waybillGet;
      isFreightAdd =  freightAdd;
      isFreightGet =  freightGet;
      isWaybillAdd =  waybillAdd;
      isTruckGet =  truckGet;
      isDriverGet =  driverGet;
      isTransportGet =  transportGet;
      isDriverListGet =  driverListGet;
      isLogisticsAffirmGet =  logisticsAffirmGet;
      isTransportAdd =  transportAdd;
      isDriverAdd =  driverAdd;
      
    });
    Future.delayed(Duration(milliseconds: 600),(){
      setState(() {
       _loading = false; 
      });
    });
  }
}