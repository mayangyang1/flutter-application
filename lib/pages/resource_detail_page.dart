import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import '../widget/detailPageWidget/content_block_widget.dart';
import '../common/service_method.dart';
import '../config/service_url.dart';
import '../components/progressDialog.dart';
import '../common/utils.dart';
import '../widget/detailPageWidget/company_block_widget.dart';
import '../widget/detailPageWidget/bottom_button_list_widget.dart';
import '../widget/textWidget/text_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../components/componentsModel.dart';
import './freight_accept_redcord_page.dart';

class ResourceDetailPage extends StatefulWidget {
  
  final String code;
  ResourceDetailPage({Key key, this.code});
  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  Map resourceInfo = {};
  bool _loading = false;
  var areaInfo;
  var configInfo;
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getReourceInfo();
    _getConfigMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('货源详情'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    headerTitleWidget('基本信息'),
                    contentBlockWidget([
                      contentItemWidget('货源号:', resourceInfo['freightNo'] ?? ''),
                      contentItemWidget('调车模式:',resourceInfo['scheduleType'] == 'platform'? '委托调车' : '自助调车'),
                      contentItemWidget('运单生成方式:', resourceInfo['dispatchMode']  == 'auto'? '自动确认' : '人工确认'),
                      contentItemWidget('状态:',resourceInfo['status'] != null? configFreightStatus[resourceInfo['status']] : ''),
                      contentItemWidget('发布范围:',resourceInfo['releaseRange'] == 'platform' ? '全平台' : ''),
                    ]),
                    headerTitleWidget('线路信息'),
                    companyBlockWidget(
                      context,
                      companyBlockItemWidget(context, 'f', [
                        text1('${resourceInfo['unloadingProvinceCode'] != null ? areaInfo['province'][resourceInfo['loadingProvinceCode']] : ''} ${resourceInfo['unloadingCityCode'] != null ? areaInfo['city'][resourceInfo['loadingCityCode']] : ''} ${resourceInfo['loadingCountyCode'] != null ? areaInfo['county'][resourceInfo['loadingCountyCode']] : ''}'),
                        text2(resourceInfo['loadingAddress'] ?? ''),
                        text2(resourceInfo['loadingOrgName'] ?? ''),
                        text2('${resourceInfo['loadingUserFullName'] ?? ''} ${resourceInfo['loadingUserPhone'] ?? ''}'),
                      ]),
                      companyBlockItemWidget(context, 'z', [
                        text1('${resourceInfo['unloadingProvinceCode'] != null ? areaInfo['province'][resourceInfo['unloadingProvinceCode']] : ''} ${resourceInfo['unloadingCityCode'] != null ? areaInfo['city'][resourceInfo['unloadingCityCode']] : ''} ${resourceInfo['unloadingCountyCode'] != null ? areaInfo['county'][resourceInfo['unloadingCountyCode']] : ''}'),
                        text2(resourceInfo['unloadingAddress'] ?? ''),
                        text2(resourceInfo['unloadingOrgName'] ?? ''),
                        text2('${resourceInfo['unloadingUserFullName'] ?? ''} ${resourceInfo['unloadingUserPhone'] ?? ''}'),
                      ])
                    ),
                    contentBlockWidget([
                      contentItemWidget('线路名称:', resourceInfo['routeName'] ?? ''),
                      contentItemWidget('业务类型:', resourceInfo['businessTypeCode'] != null ? configBusinessTypeCode[resourceInfo['businessTypeCode']] : ''),
                    ],borderTop: true),
                    headerTitleWidget('货物信息'),
                    contentBlockWidget([
                      contentItemWidget('货物类型:', resourceInfo['cargoTypeClassificationCode'] != null ? configGoodsType[resourceInfo['cargoTypeClassificationCode']] : ''),
                      contentItemWidget('货物名称:', resourceInfo['goodsName'] ?? ''),
                      contentItemWidget('计量标准:', resourceInfo['meterageType'] != null ? configMeterageType[resourceInfo['meterageType']] : ''),
                      contentItemWidget('货物单价:',  '${resourceInfo['goodsPrice'] ?? ''}${resourceInfo['goodsPrice'] != null && resourceInfo['meterageType'] != null? unit[resourceInfo['meterageType']]['goods.price']['name'] : ''}'),
                      contentItemWidget('合理货差系数:', '${resourceInfo['goodsLossMethod'] != null? configGoodsLossMethod[resourceInfo['goodsLossMethod']] : ''}${resourceInfo['goodsLoss'] != null? resourceInfo['goodsLoss'] : ''} ${resourceInfo['goodsLossUnitCode'] != null? configGoodsLossUnitCode[resourceInfo['goodsLossUnitCode']] : ''}' ),
                      contentItemWidget('货物重量:', '${resourceInfo['goodsWeight'] != null? resourceInfo['goodsWeight'].toString() + '吨' : ''}'),
                      contentItemWidget('货物体积:', '${resourceInfo['goodsVolume'] != null? resourceInfo['goodsVolume'].toString() + '方' : ''}'),
                      contentItemWidget('货物数量:', '${resourceInfo['goodsNum'] != null? resourceInfo['goodsNum'].toString() + '件' : ''}'),
                    ]),
                    headerTitleWidget('用车需求'),
                    contentBlockWidget([         
                      contentItemWidget('客户运价:', '${resourceInfo['clientFreightPrice']?? ''}${resourceInfo['meterageType'] != null && resourceInfo['clientFreightPriceUnitCode'] != null? unit[resourceInfo['meterageType']]['driver.prices'][resourceInfo['clientFreightPriceUnitCode']] : ''}'),
                      contentItemWidget('司机报价类型:', resourceInfo['quoteType'] == 'price'? '${resourceInfo['quotePrice'] ?? ''}${resourceInfo['meterageType'] != null && resourceInfo['quotePriceUnitCode'] != null? unit[resourceInfo['meterageType']]['driver.prices'][resourceInfo['quotePriceUnitCode']] : ''}' : '司机报价 ${resourceInfo['meterageType'] != null && resourceInfo['quotePriceUnitCode'] != null? unit[resourceInfo['meterageType']]['driver.prices'][resourceInfo['quotePriceUnitCode']] : ''}'),
                      contentItemWidget('需求车次:', '${resourceInfo['truckQty'] ?? ''}车'),
                      contentItemWidget('车型要求:', '${resourceInfo['truckModelRequire'] != null? configTruckModel[resourceInfo['truckModelRequire']] : ''}'),
                      contentItemWidget('联系人:', resourceInfo['contactUserFullName'] ?? ''),
                      contentItemWidget('联系电话:', resourceInfo['contactPhone'] ?? ''),
                      contentItemWidget('货源有效期:', resourceInfo['freightEndTime'] ?? ''),
                      contentItemWidget('备注:', resourceInfo['description'] ?? ''),
                      contentItemWidget('派车信息:', '需求${resourceInfo['truckQty'] ?? 0}${resourceInfo['truckQtyUnitCode']} 已派${resourceInfo['dispatchTruckNumber'] ?? 0}车 待派${((resourceInfo['acceptTruckNumber'] ?? 0) - (resourceInfo['ignoreTruckNumber'] ?? 0) - (resourceInfo['dispatchTruckNumber'] ?? 0)) > 0 ? ((resourceInfo['acceptTruckNumber'] ?? 0) - (resourceInfo['ignoreTruckNumber'] ?? 0) - (resourceInfo['dispatchTruckNumber'] ?? 0)) : 0}车'),
                    ]),

                  ],
                ),
              ),
            ),
            bottomButtonListWidget([
              Expanded(
                child: Offstage(
                  offstage: resourceInfo['status'] == 'pushling'? false : true,
                  child: commonBtnWidget(context, '结束货源', (){
                    showMyCupertinoDialog(context, '提示', '确定结束货源?', (res){
                      if(res == 'confirm'){
                        _closeFreight(resourceInfo['code']);
                      }
                    });
                  },mainColor: false),
                ),
                flex: resourceInfo['status'] == 'pushling'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: resourceInfo['status'] == 'pushling'? false : true,
                  child: commonBtnWidget(context, '立即派车', (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return FreightAcceptRecordPage(code: resourceInfo['code'],);
                    }));
                  },),
                ),
                flex: resourceInfo['status'] == 'pushling'? 1 : 0,
              ),
            ])
          ],
        ),
      )
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
  _getReourceInfo() {
    getAjaxStr('$serviceUrl/freight/freight/${widget.code}/get', '', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        setState(() {
          resourceInfo = res['content'] ?? {};
        });
      }
    });
  }
  _closeFreight(String code) {//结束货源
    postAjaxStr('$serviceUrl/freight/freight/$code/close', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '操作成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          _getReourceInfo();
        });
      }
    });
  }
}