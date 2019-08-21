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
import './resource_detail_page.dart';
import '../config/service_url.dart';
import '../components/componentsModel.dart';
import './freight_accept_redcord_page.dart';

class ResourceListPage extends StatefulWidget {
  @override
  _ResourceListPageState createState() => _ResourceListPageState();
}

class _ResourceListPageState extends State<ResourceListPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List resourceList = [];
  String freightNo = '';
  String loadingProvinceCode = '';
  String loadingCityCode = '';
  String loadingCountyCode = '';
  String unloadingProvinceCode = '';
  String unloadingCityCode = '';
  String unloadingCountyCode = '';

  List<Map> singlePickerList = [
    {'key':'发布中', 'id': 'pushling'},
    {'key':'已结束', 'id': 'finished'},
    {'key':'全部', 'id': ''},
  ];
  int _index = 0;
  String resourceStatus = '';
  var configInfo;
  var areaInfo;
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getResourceList();
    _getConfigMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('货源列表'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'resourceSearchPage',
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
                  freightNo = val['freightNo'] ?? '';
                  _loading = true;
                });
                page = 1;
                resourceList = [];
                _getResourceList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  resourceList = [];
                  _getResourceList();
                }
              }
            ),
            Expanded(
              child: commonRereshListWidget(resourceList, _headerKey, _footerKey, '暂无订单', (){
                page ++;
                _getResourceList();
              }, (){
                page = 1;
                resourceList = [];
                _getResourceList();
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
            topContent(context,item['freightNo'] ?? '', item['createTime'].toString().substring(0,16)),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ResourceDetailPage(code: item['code'],);
        })).then((res){
          page = 1;
          resourceList = [];
          _getResourceList();
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
            child: Text('货源号: $logisticsNo',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
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
              ?Container(
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
                    child:Text("${areaInfo['province'][item['unloadingProvinceCode']]} ${areaInfo['city'][item['unloadingCityCode']]}",style: TextStyle(fontSize:  ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,)
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(item['goodsName'] ?? '',style: TextStyle(height: 1.2),),
                  Text('  ${item['meterageType'] == 'ton' && item['goodsWeight'] != null? item['goodsWeight'].toString() + '吨' : ''}',style: TextStyle(height: 1.2),),
                  Text(' ${item['meterageType'] == 'cube' && item['goodsVolume'] != null? item['goodsVolume'].toString() + '方' : ''}',style: TextStyle(height: 1.2),),
                  Text(' ${item['meterageType'] == 'item' && item['goodsAmount'] != null? item['goodsAmount'].toString() + '件' : ''}',style: TextStyle(height: 1.2),),
                  Text('  ${item['quotePrice'] != null? item['quotePrice'] : ''}${ item['quotePriceUnitCode'] != null && item['quotePrice'] != null? unit[item['meterageType']]['driver.prices'][item['quotePriceUnitCode']] : ''}',style: TextStyle(height: 1.2),),
                ],
              ),
              Row(
                children: <Widget>[
                  Text('需求${item['truckQty'] ?? 0}${item['truckQtyUnitCode']} ',style: TextStyle(height: 1.2),),
                  Text(' 已派${item['dispatchTruckNumber'] ?? 0}车',style: TextStyle(height: 1.2),),
                  Text(' 待派${((item['acceptTruckNumber'] ?? 0) - (item['ignoreTruckNumber'] ?? 0) - (item['dispatchTruckNumber'] ?? 0)) > 0 ? ((item['acceptTruckNumber'] ?? 0) - (item['ignoreTruckNumber'] ?? 0) - (item['dispatchTruckNumber'] ?? 0)) : 0}车',style: TextStyle(height: 1.2),),
                ],
              )
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(160),
          child: Text( item['status'] != null ? configFreightStatus[item['status']] : '',style: TextStyle(color: Theme.of(context).primaryColor),),
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
            offstage: item['status'] == 'pushling'? false : true,
            child: minButton(context,'结束货源', false, (){
              showMyCupertinoDialog(context, '提示', '确定结束货源?', (res){
                if(res == 'confirm'){
                  _closeFreight(item['code']);
                }
              });
            }),
          ),
          Offstage(
            offstage: item['status'] == 'pushling'? false : true,
            child: minButton(context,'立即派车', true, (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return FreightAcceptRecordPage(code: item['code'],);
              })).then((res){
                page = 1;
                resourceList = [];
                _getResourceList();
              });
            }),
          ),
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
  _getResourceList() {//获取订单列表
    resourceStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size';
    if(resourceStatus != ''){
      stringParams += '&status=$resourceStatus';
    }
    if(freightNo != '' && freightNo != null){
      stringParams += '&freightNo=$freightNo';
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
    getAjax('freightList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         resourceList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           resourceList = []; 
          });
        }
      }
    });
  }
  _closeFreight(String code) {//结束货源
    postAjaxStr('$serviceUrl/freight/freight/$code/close', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '操作成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          page = 1;
          resourceList = [];
          _getResourceList();
        });
      }
    });
  }
}