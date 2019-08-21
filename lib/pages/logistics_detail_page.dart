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
import '../pages/release_resource_page.dart';
import '../pages/build_waybill_page.dart';
import 'dart:convert';

class LogisticsDetailPage extends StatefulWidget {
  
  final String code;
  LogisticsDetailPage({Key key, this.code});
  @override
  _LogisticsDetailPageState createState() => _LogisticsDetailPageState();
}

class _LogisticsDetailPageState extends State<LogisticsDetailPage> {
  Map logisticsInfo = {};
  bool _loading = false;
  var areaInfo;
  var configInfo;
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getLogisticsInfo();
    _getConfigMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('订单详情'),),
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
                      contentItemWidget('订单号:', logisticsInfo['logisticsNo'] ?? ''),
                      contentItemWidget('订单状态:',logisticsInfo['logisticsStatus'] != null? configLogisticsStatus[logisticsInfo['logisticsStatus']] : ''),
                      contentItemWidget('托运客户:', logisticsInfo['clientOrgName'] ?? ''),
                      contentItemWidget('承运方:', logisticsInfo['carrierOrgName'] ?? ''),
                      contentItemWidget('结算方式:',logisticsInfo['settleMethod'] != null ? configSettleMethod[logisticsInfo['settleMethod']] : ''),
                    ]),
                    headerTitleWidget('线路信息'),
                    companyBlockWidget(
                      context,
                      companyBlockItemWidget(context, 'f', [
                        text1('${logisticsInfo['unloadingProvinceCode'] != null ? areaInfo['province'][logisticsInfo['loadingProvinceCode']] : ''} ${logisticsInfo['unloadingCityCode'] != null ? areaInfo['city'][logisticsInfo['loadingCityCode']] : ''} ${logisticsInfo['loadingCountyCode'] != null ? areaInfo['county'][logisticsInfo['loadingCountyCode']] : ''}'),
                        text2(logisticsInfo['loadingAddress'] ?? ''),
                        text2(logisticsInfo['loadingOrgName'] ?? ''),
                        text2('${logisticsInfo['loadingUserFullName'] ?? ''} ${logisticsInfo['loadingUserPhone'] ?? ''}'),
                      ]),
                      companyBlockItemWidget(context, 'z', [
                        text1('${logisticsInfo['unloadingProvinceCode'] != null ? areaInfo['province'][logisticsInfo['unloadingProvinceCode']] : ''} ${logisticsInfo['unloadingCityCode'] != null ? areaInfo['city'][logisticsInfo['unloadingCityCode']] : ''} ${logisticsInfo['unloadingCountyCode'] != null ? areaInfo['county'][logisticsInfo['unloadingCountyCode']] : ''}'),
                        text2(logisticsInfo['unloadingAddress'] ?? ''),
                        text2(logisticsInfo['unloadingOrgName'] ?? ''),
                        text2('${logisticsInfo['unloadingUserFullName'] ?? ''} ${logisticsInfo['unloadingUserPhone'] ?? ''}'),
                      ])
                    ),
                    contentBlockWidget([
                      contentItemWidget('线路名称:', logisticsInfo['routeName']?? ''),
                      contentItemWidget('业务类型:', logisticsInfo['businessTypeCode'] != null ? configBusinessTypeCode[logisticsInfo['businessTypeCode']] : ''),
                    ],borderTop: true),
                    headerTitleWidget('货物信息'),
                    contentBlockWidget([
                      contentItemWidget('货物类型:', logisticsInfo['cargoTypeClassificationCode'] != null ? configGoodsType[logisticsInfo['cargoTypeClassificationCode']] : ''),
                      contentItemWidget('货物名称:', logisticsInfo['goodsName'] ?? ''),
                      contentItemWidget('计量标准:', logisticsInfo['meterageType'] != null ? configMeterageType[logisticsInfo['meterageType']] : ''),
                      contentItemWidget('计划重量:', '${logisticsInfo['goodsWeight'] != null? logisticsInfo['goodsWeight'].toString() + '吨' : ''}'),
                      contentItemWidget('计划体积:', '${logisticsInfo['goodsVolume'] != null? logisticsInfo['goodsVolume'].toString() + '方' : ''}'),
                      contentItemWidget('计划数量:', '${logisticsInfo['goodsNum'] != null? logisticsInfo['goodsNum'].toString() + '件' : ''}'),
                    ]),
                    headerTitleWidget('其他信息'),
                    contentBlockWidget([         
                      contentItemWidget('客户运价:', '${logisticsInfo['clientFreightPrice']?? ''}${logisticsInfo['meterageType'] != null && logisticsInfo['clientFreightPriceUnitCode'] != null? unit[logisticsInfo['meterageType']]['driver.prices'][logisticsInfo['clientFreightPriceUnitCode']] : ''}'),
                      contentItemWidget('司机运价:', '${logisticsInfo['driverReferPrice'] ?? ''}${logisticsInfo['meterageType'] != null && logisticsInfo['driverReferPriceUnitCode'] != null? unit[logisticsInfo['meterageType']]['driver.prices'][logisticsInfo['driverReferPriceUnitCode']] : ''}'),
                      contentItemWidget('需求车次:', '${logisticsInfo['truckQty'] ?? ''}车'),
                      contentItemWidget('备注:', logisticsInfo['description'] ?? ''),
                    ]),

                  ],
                ),
              ),
            ),
            bottomButtonListWidget([
              Expanded(
                child: commonBtnWidget(context, '派车', (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return BuildWaybillPage( code:logisticsInfo['code']);
                  }));
                }),
              ),
              Expanded(
                child: commonBtnWidget(context, '发布货源', (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ReleaseResourcePage(code: logisticsInfo['code'],);
                  }));
                }),
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
  _getLogisticsInfo() {
    getAjaxStr('$serviceUrl/logistics/logistics/${widget.code}/get', '', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        setState(() {
          logisticsInfo = res['content'] ?? {};
        });
      }
    });
  }
}