import 'package:flutter/material.dart';
import '../components/progressDialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/searchPageWidget/common_refresh_list_widget.dart';
import '../widget/widget_model.dart';
import '../components/search_bar.dart';
import '../common/service_method.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import './waybill_detail_page.dart';
import '../config/service_url.dart';
import '../components/componentsModel.dart';
import './collection_and_delivery_page.dart';

class WaybillListPage extends StatefulWidget {
  final bool disabledEditeStatus;
  final int statusIndex;
  WaybillListPage({Key key, this.disabledEditeStatus, this.statusIndex});
  @override
  _WaybillListPageState createState() => _WaybillListPageState();
}

class _WaybillListPageState extends State<WaybillListPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List waybillList = [];
  String waybillNo = '';
  String truckLicenseNo = '';
  String loadingProvinceCode = '';
  String loadingCityCode = '';
  String loadingCountyCode = '';
  String unloadingProvinceCode = '';
  String unloadingCityCode = '';
  String unloadingCountyCode = '';

  List<Map> singlePickerList = [
    {'key':'未完成运单', 'id': 'unloading,going,arrive'},
    {'key':'待发货运单', 'id': 'unloading'},
    {'key':'运输中运单', 'id': 'going'},
    {'key':'已完成运单', 'id': 'finish'},
    {'key':'已取消运单', 'id': 'cancel'},
    {'key':'全部运单', 'id': ''},
  ];
  int _index = 0;
  String waybillStatus = '';
  var configInfo;
  var areaInfo;
  @override
  void initState() { 
    super.initState();
    if(widget.statusIndex != null ){
      _index = widget.statusIndex;
    }
    _loading = true;
    _getWaybillList();
    _getConfigMessage();
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('运单列表'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'waybillSearchBarPage',
              singlePickerList,
              _index,
              (val){//搜索框
                print(val);
                setState(() {
                  loadingProvinceCode = val['startCodeMap'] != null? val['startCodeMap']['provinceCode'] : '';
                  loadingCityCode = val['startCodeMap'] !=null? val['startCodeMap']['cityCode'] : '';
                  loadingCountyCode = val['startCodeMap'] != null? val['startCodeMap']['areaCode'] : '';
                  unloadingProvinceCode = val['endCodeMap'] != null? val['endCodeMap']['provinceCode'] : '';
                  unloadingCityCode = val['endCodeMap'] != null? val['endCodeMap']['cityCode'] : '';
                  unloadingCountyCode = val['endCodeMap'] != null? val['endCodeMap']['areaCode'] : '';
                  waybillNo = val['waybillNo'] ?? '';
                  truckLicenseNo = val['truckLicenseNo'] ?? '';
                  _loading = true;
                });
                page = 1;
                waybillList = [];
                _getWaybillList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  waybillList = [];
                  _getWaybillList();
                }
              },
              disabledEditeStatus: widget.disabledEditeStatus
            ),
            Expanded(
              child: commonRereshListWidget(waybillList, _headerKey, _footerKey, '暂无订单', (){
                page ++;
                _getWaybillList();
              }, (){
                page = 1;
                waybillList = [];
                _getWaybillList();
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
            topContent(context,item['waybillNo'] ?? '', item['createTime'].toString().substring(0,16)),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return WaybillDetailPage(code: item['code'],);
        })).then((res){
          setState(() {
           _loading = true;
           page = 1;
           waybillList = [];
           _getWaybillList(); 
          });
        });
      },
    );
  }

  Widget topContent(BuildContext context, String logisticsNo, String rightTitle) {
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
            child: Text('运单号: $logisticsNo',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
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
              item['routeName'] != null
              ? Container(
                 width: ScreenUtil().setWidth(400),
                 child: Text(item['routeName'],style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
              )
              : Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(210),
                    child: Text("${areaInfo['province'][item['loadingProvinceCode']]} ${areaInfo['city'][item['loadingCityCode']]}",style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
                  ),
                  Image.asset('assets/images/arrows.png'),
                  Container(
                    width: ScreenUtil().setWidth(210),
                    child:Text("${areaInfo['province'][item['unloadingProvinceCode']]} ${areaInfo['city'][item['unloadingCityCode']]}",style: TextStyle(fontSize:  ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,)
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(240)),
                    child: Text(item['goodsName'] ?? '',style: TextStyle(height: 1.2),overflow: TextOverflow.ellipsis,),
                  ),
                  Text('  ${item['driverPrice'] != null? item['driverPrice'] : ''}${ item['driverPriceUnitCode'] != null && item['driverPrice'] != null && item['meterageType'] != null? unit[item['meterageType']]['driver.prices'][item['driverPriceUnitCode']] : ''}',style: TextStyle(height: 1.2),),
                ],
              ),
              Row(
                children: <Widget>[
                  Text('${item['truckLicenseNo'] ?? ''}',style: TextStyle(height: 1.2),),
                  Text('  ${item['driverFullName'] ?? ''} ',style: TextStyle(height: 1.2),),
                  InkWell(
                    child: Image.asset('assets/images/tel.png', width: ScreenUtil().setWidth(40), height: ScreenUtil().setHeight(40),),
                    onTap: ()async{
                      String url = 'tel:${item['driverPhone']}';
                      if(await canLaunch(url)){
                        await launch(url);
                      }else{
                        throw 'Could not launch $url';
                      }
                    },
                  )
                  
                ],
              )
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(160),
          child: Text( item['waybillStatus'] != null ? configWaybillStatus[item['waybillStatus']] : '',style: TextStyle(color: Theme.of(context).primaryColor),),
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
            offstage: item['waybillStatus'] == 'unloading'? false : true,
            child: minButton(context,'取消', false, (){
              showMyCupertinoDialog(context, '提示', '确定取消运单?',(res){
                if(res == 'confirm'){
                  _cancelWaybill(item['code']);
                }
              });
            }),
          ),
          Offstage(
            offstage: item['waybillStatus'] == 'unloading'? false : true,
            child: minButton(context,'发货', true, (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CollectionAndDeliveryPage(code: item['code'],type:0);
              })).then((res){
                if(res == 'loading'){
                  page =1;
                  waybillList = [];
                  _getWaybillList();
                }
              });
            }),
          ),
          Offstage(
            offstage: item['waybillStatus'] == 'going'? false : true,
            child: minButton(context,'收货', true, (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CollectionAndDeliveryPage(code: item['code'],type:1);
              })).then((res){
                if(res == 'unloading'){
                  page =1;
                  waybillList = [];
                  _getWaybillList();
                }
              });
            }),
          )
        ]
      ),
    );
  }
  _getConfigMessage()async {//获取配置信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      configInfo = json.decode(prefs.getString('otherConfigs'));
      areaInfo = json.decode(prefs.getString('areaInfo'));
      // orgSelfInfo = json.decode(prefs.getString('orgSelfInfo'));
    });
  }
  _getWaybillList() {//获取运单列表
    waybillStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size';
    if(waybillStatus != ''){
      stringParams += '&waybillStatus=$waybillStatus';
    }
    if(waybillNo != '' && waybillNo != null){
      stringParams += '&waybillNo=$waybillNo';
    }
    if(truckLicenseNo != null && truckLicenseNo != ''){
      stringParams += '&truckLicenseNo=$truckLicenseNo';
    }

    getAjax('waybillList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         waybillList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           waybillList = []; 
          });
        }
      }
    });
  }
  _cancelWaybill(String code) {//取消运单
    postAjaxStr('$serviceUrl/waybill/waybill/$code/execute/cancel', {}, context).then((res){
      if(res['code'] == 200){
        Toast.toast(context, '运单已取消');
        Future.delayed(Duration(milliseconds: 1000),(){
          page = 1;
          waybillList = [];
          _getWaybillList();
        });
      }
    });
  }
}