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
import '../pages/logistics_detail_page.dart';
import '../pages/release_resource_page.dart';
import '../pages/build_waybill_page.dart';

class LogisticsListPage extends StatefulWidget {
  @override
  _LogisticsListPageState createState() => _LogisticsListPageState();
}

class _LogisticsListPageState extends State<LogisticsListPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List logisticsList = [];
  String logisticsNo = '';
  String loadingProvinceCode = '';
  String loadingCityCode = '';
  String loadingCountyCode = '';
  String unloadingProvinceCode = '';
  String unloadingCityCode = '';
  String unloadingCountyCode = '';

  List<Map> singlePickerList = [
    {'key':'未完成', 'id': 'todo,doing'},
    {'key':'全部', 'id': 'todo,doing,finish'},
    {'key':'待执行', 'id': 'todo'},
    {'key':'执行中', 'id': 'doing'},
    {'key':'订单完成', 'id': 'finish'},
  ];
  int _index = 0;
  String logisticsStatus = 'todo,doing';
  var configInfo;
  var areaInfo;
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getLogisticsList();
    _getConfigMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('订单列表'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'logisticsSearchPage',
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
                  logisticsNo = val['logisticsNo'] ?? '';
                  _loading = true;
                });
                page = 1;
                logisticsList = [];
                _getLogisticsList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  logisticsList = [];
                  _getLogisticsList();
                }
              }
            ),
            Expanded(
              child: commonRereshListWidget(logisticsList, _headerKey, _footerKey, '暂无订单', (){
                page ++;
                _getLogisticsList();
              }, (){
                page = 1;
                logisticsList = [];
                _getLogisticsList();
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
            topContent(context,item['logisticsNo'], item['createTime'].toString().substring(0,16)),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return LogisticsDetailPage(code: item['code'],);
        }));
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
            child: Text('订单号: $logisticsNo',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
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
              :Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(210),
                    child: Text("${areaInfo['province'][item['loadingProvinceCode']]} ${areaInfo['city'][item['loadingCityCode']]}",style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
                  ),
                  Image.asset('assets/images/arrows.png'),
                  Container(
                    width: ScreenUtil().setWidth(210),
                    child:Text("${areaInfo['province'][item['unloadingProvinceCode']]} ${areaInfo['city'][item['unloadingCityCode']]}",style: TextStyle(fontSize:  ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center)
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(item['goodsName'] ?? '',style: TextStyle(height: 1.2),),
                  Text('  ${item['goodsWeight'] != null? item['goodsWeight'].toString() + '吨' : ''}',style: TextStyle(height: 1.2),),
                  Text(' ${item['goodsVolume'] != null? item['goodsVolume'].toString() + '方' : ''}',style: TextStyle(height: 1.2),),
                  Text(' ${item['goodsAmount'] != null? item['goodsAmount'].toString() + '件' : ''}',style: TextStyle(height: 1.2),),
                ],
              ),
              Row(
                children: <Widget>[
                  Text('需求${item['truckQty'] ?? 0}${item['truckQtyUnitCode']} ',style: TextStyle(height: 1.2),),
                  Text(' 已派${item['shuntedNum'] ?? 0}车',style: TextStyle(height: 1.2),),
                ],
              )
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(160),
          child: Text(configLogisticsStatus[item['logisticsStatus']],style: TextStyle(color: Theme.of(context).primaryColor),),
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
          minButton(context,'发布货源', true, (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return ReleaseResourcePage(code: item['code'],);
            }));
          }),
          minButton(context,'派车', true, (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return BuildWaybillPage(code: item['code'],);
            }));
          })
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
  _getLogisticsList() {//获取订单列表
    logisticsStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size&logisticsStatus=$logisticsStatus';
    if(logisticsNo != '' && logisticsNo != null){
      stringParams += '&logisticsNo=$logisticsNo';
    }
    if(loadingProvinceCode != '' && loadingProvinceCode != null){
      stringParams += '&loadingProvinceCode=$loadingProvinceCode';
    }
    if(loadingCityCode != '' && loadingCityCode != null){
      stringParams += '&loadingCityCode=$loadingCityCode';
    }
    if(loadingCountyCode != '' && loadingCountyCode != null){
      stringParams += '&loadingCountyCode=$loadingCountyCode';
    }
    if(unloadingProvinceCode != '' && unloadingProvinceCode != null){
      stringParams += '&unloadingProvinceCode=$unloadingProvinceCode';
    }
    if(unloadingCityCode != '' && unloadingCityCode != null){
      stringParams += '&unloadingCityCode=$unloadingCityCode';
    }
    if(unloadingCountyCode != '' && unloadingCountyCode != null){
      stringParams += '&unloadingCountyCode=$unloadingCountyCode';
    }
    getAjax('logisticsList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         logisticsList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           logisticsList = []; 
          });
        }
      }
    });
  }
}


