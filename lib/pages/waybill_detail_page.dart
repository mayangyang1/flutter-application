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
import './collection_and_delivery_page.dart';
import '../widget/detailPageWidget/preview_image_list.dart';
import '../components/full_screen_wrapper.dart';

class WaybillDetailPage extends StatefulWidget {
  
  final String code;
  WaybillDetailPage({Key key, this.code});
  @override
  _WaybillDetailPageState createState() => _WaybillDetailPageState();
}

class _WaybillDetailPageState extends State<WaybillDetailPage> {
  Map waybillInfo = {};
  bool _loading = false;
  var areaInfo;
  var configInfo;
  List loadingImageList = [];
  List unloadingImageList = [];
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getWaybillInfo();
    _getConfigMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('运单详情'),),
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
                      contentItemWidget('运单号:', waybillInfo['waybillNo'] ?? ''),
                      contentItemWidget('来源订单号:',waybillInfo['logisticsNo'] ?? ''),
                      contentItemWidget('调车模式:', waybillInfo['scheduleType'] == 'platform'? '委托调车' : '自助调车'),
                      contentItemWidget('来源货源:', waybillInfo['freightNo'] ?? ''),
                      contentItemWidget('运单状态:',waybillInfo['waybillStatus'] != null ? configWaybillStatus[waybillInfo['waybillStatus']] : ''),
                      contentItemWidget('客户:',waybillInfo['clientOrgName'] ?? ''),
                      contentItemWidget('结算方式:',waybillInfo['settleMethod'] != null? configSettleMethod[waybillInfo['settleMethod']] : ''),
                      contentItemWidget('支付状态:',waybillInfo['settlePaymentPayStatus'] != null? configPayStatus[waybillInfo['settlePaymentPayStatus']] : ''),
                      // contentItemWidget('支付渠道:',waybillInfo['settlePaymentPayStatus'] != null? configPayChannel[waybillInfo['settlePaymentPayStatus']] : ''),
                    ]),
                    headerTitleWidget('线路信息'),
                    companyBlockWidget(
                      context,
                      companyBlockItemWidget(context, 'f', [
                        text1('${waybillInfo['unloadingProvinceCode'] != null ? areaInfo['province'][waybillInfo['loadingProvinceCode']] : ''} ${waybillInfo['unloadingCityCode'] != null ? areaInfo['city'][waybillInfo['loadingCityCode']] : ''} ${waybillInfo['loadingCountyCode'] != null ? areaInfo['county'][waybillInfo['loadingCountyCode']] : ''}'),
                        text2(waybillInfo['loadingAddress'] ?? ''),
                        text2(waybillInfo['loadingOrgName'] ?? ''),
                        text2('${waybillInfo['loadingUserFullName'] ?? ''} ${waybillInfo['loadingUserPhone'] ?? ''}'),
                      ]),
                      companyBlockItemWidget(context, 'z', [
                        text1('${waybillInfo['unloadingProvinceCode'] != null ? areaInfo['province'][waybillInfo['unloadingProvinceCode']] : ''} ${waybillInfo['unloadingCityCode'] != null ? areaInfo['city'][waybillInfo['unloadingCityCode']] : ''} ${waybillInfo['unloadingCountyCode'] != null ? areaInfo['county'][waybillInfo['unloadingCountyCode']] : ''}'),
                        text2(waybillInfo['unloadingAddress'] ?? ''),
                        text2(waybillInfo['unloadingOrgName'] ?? ''),
                        text2('${waybillInfo['unloadingUserFullName'] ?? ''} ${waybillInfo['unloadingUserPhone'] ?? ''}'),
                      ])
                    ),
                    contentBlockWidget([
                      contentItemWidget('线路名称:', waybillInfo['routeName'] ?? ''),
                      contentItemWidget('业务类型:', waybillInfo['businessTypeCode'] != null ? configBusinessTypeCode[waybillInfo['businessTypeCode']] : ''),
                    ],borderTop: true),
                    headerTitleWidget('货物/运价'),
                    contentBlockWidget([
                      contentItemWidget('货物类型:', waybillInfo['cargoTypeClassificationCode'] != null ? configGoodsType[waybillInfo['cargoTypeClassificationCode']] : ''),
                      contentItemWidget('货物名称:', waybillInfo['goodsName'] ?? ''),
                      contentItemWidget('计量标准:', waybillInfo['meterageType'] != null ? configMeterageType[waybillInfo['meterageType']] : ''),
                      contentItemWidget('货物单价:',  '${waybillInfo['goodsPrice'] ?? ''}${waybillInfo['goodsPrice'] != null && waybillInfo['meterageType'] != null? unit[waybillInfo['meterageType']]['goods.price']['name'] : ''}'),
                      contentItemWidget('合理货差系数:', '${waybillInfo['goodsLossMethod'] != null? configGoodsLossMethod[waybillInfo['goodsLossMethod']] : ''}${waybillInfo['goodsLoss'] != null? waybillInfo['goodsLoss'] : ''} ${waybillInfo['goodsLossUnitCode'] != null? configGoodsLossUnitCode[waybillInfo['goodsLossUnitCode']] : ''}' ),
                      contentItemWidget('客户运价:', '${waybillInfo['clientFreightPrice']?? ''}${waybillInfo['meterageType'] != null && waybillInfo['clientFreightPriceUnitCode'] != null? unit[waybillInfo['meterageType']]['driver.prices'][waybillInfo['clientFreightPriceUnitCode']] : ''}'),
                      contentItemWidget('司机运价:', '${waybillInfo['driverReferPrice'] ?? ''}${waybillInfo['meterageType'] != null && waybillInfo['driverReferPriceUnitCode'] != null? unit[waybillInfo['meterageType']]['driver.prices'][waybillInfo['driverReferPriceUnitCode']] : ''}'),
                    ]),
                    headerTitleWidget('车辆司机'),
                    contentBlockWidget([         
                      imageTitle('car', '车辆'),
                      contentItemWidget('车牌号:', waybillInfo['truckLicenseNo'] ?? ''),
                      contentItemWidget('动力类型:', waybillInfo['truckPowerType'] == 'gas'? '气车': '油车'),
                      imageTitle('driver', '主驾'),
                      contentItemWidget('主驾:', waybillInfo['driverFullName'] ?? ''),
                      contentItemWidget('主驾手机号:', waybillInfo['driverPhone'] ?? ''),
                      contentItemWidget('主驾驾驶证:', waybillInfo['driverLicenseNo'] ?? ''),
                      imageTitle('fdriver', '副驾'),
                      contentItemWidget('副驾:', waybillInfo['viceDriverFullName'] ?? ''),
                      contentItemWidget('副驾手机号:', waybillInfo['viceDriverPhone'] ?? ''),
                      contentItemWidget('副驾驾驶证:', waybillInfo['viceDriverLicenseNo'] ?? ''),
                      
                    ]),
                    headerTitleWidget('收款账户'),
                    contentBlockWidget([         
                      imageTitle('driver', '主驾'),
                      contentItemWidget('收款人:', waybillInfo['payeeDriverFullName'] ?? ''),
                      contentItemWidget('开户行:', waybillInfo['driverPayeeBankName'] ?? ''),
                      contentItemWidget('银行户名:', waybillInfo['driverPayeeBankAccountName'] ?? ''),
                      contentItemWidget('银行账号:', waybillInfo['driverPayeeBankAccountNo'] ?? ''),
                      contentItemWidget('备注:', waybillInfo['driverPayeeBankAccountDescription'] ?? ''),
                      imageTitle('fdriver', '副驾'),
                      contentItemWidget('收款人:', waybillInfo['payeeViceDriverFullName'] ?? ''),
                      contentItemWidget('开户行:', waybillInfo['viceDriverPayeeBankName'] ?? ''),
                      contentItemWidget('银行户名:', waybillInfo['viceDriverPayeeBankAccountName'] ?? ''),
                      contentItemWidget('银行账号:', waybillInfo['viceDriverPayeeBankAccountNo'] ?? ''),
                      contentItemWidget('备注:', waybillInfo['viceDriverPayeeBankAccountDescription'] ?? ''),
                      
                    ]),
                    headerTitleWidget('收发信息'),
                    contentBlockWidget([         
                      imageTitle('fahuo', '发货'),
                      contentItemWidget('重量:', '${waybillInfo['loadingGoodsWeight'] ?? ''}吨'),
                      contentItemWidget('体积:', '${waybillInfo['loadingGoodsVolume'] ?? ''}方'),
                      contentItemWidget('数量:', '${waybillInfo['loadingGoodsNum'] ?? ''}件'),
                      contentItemWidget('发货时间:', waybillInfo['loadingTime'] ?? ''),
                      previewImageList('凭证',loadingImageList, _previewImage),
                      imageTitle('shouhuo', '收货'),
                      contentItemWidget('重量:', '${waybillInfo['unloadingGoodsWeight'] ?? ''}吨'),
                      contentItemWidget('体积:', '${waybillInfo['unloadingGoodsVolume'] ?? ''}方'),
                      contentItemWidget('数量:', '${waybillInfo['unloadingGoodsNum'] ?? ''}件'),
                      contentItemWidget('收货时间:', waybillInfo['unloadingTime'] ?? ''),
                      previewImageList('凭证',unloadingImageList, _previewImage),
                      
                    ]),
                    headerTitleWidget('其他信息'),
                    contentBlockWidget([         
                      contentItemWidget('运单原始托运方:', '${waybillInfo['originalConsignOrgName'] ?? ''}'),
                      contentItemWidget('运单托运方:', '${waybillInfo['consignOrgName'] ?? ''}'),
                      contentItemWidget('备注:', '${waybillInfo['description'] ?? ''}'),

                    ]),
                  ],
                ),
              ),
            ),
            bottomButtonListWidget([
              Expanded(
                child: Offstage(
                  offstage: waybillInfo['waybillStatus'] == 'unloading'? false : true,
                  child:commonBtnWidget(context, '取消', (){
                      showMyCupertinoDialog(context, '提示', '确定取消运单?', (res){
                        if(res == 'confirm'){
                          _cancelWaybill(waybillInfo['code']);
                        }
                      });
                  },mainColor: false),
                ),
                flex:waybillInfo['waybillStatus'] == 'unloading'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: waybillInfo['waybillStatus'] == 'unloading'? false : true,
                  child:commonBtnWidget(context, '发货', (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return CollectionAndDeliveryPage(code: waybillInfo['code'],type:0);
                      })).then((res){
                        if(res == 'loading'){
                          _getWaybillInfo();
                        }
                      });
                  }),
                ),
                flex:waybillInfo['waybillStatus'] == 'unloading'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: waybillInfo['waybillStatus'] == 'going'? false : true,
                  child:commonBtnWidget(context, '收货', (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return CollectionAndDeliveryPage(code: waybillInfo['code'],type:1);
                    })).then((res){
                      if(res == 'unloading'){
                        _getWaybillInfo();
                      }
                    });
                  }),
                ),
                flex: waybillInfo['waybillStatus'] == 'going'? 1 : 0,
              )
              
              
              
            ])
          ],
        ),
      )
    );
  }
  _previewImage(String url) {//预览图片
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return FullScreenWrapper(
        imageProvider:  NetworkImage(
          url
        )
      );
    }));
  }
  _getImageUrl(String code, String type) {//获取图片地址
    getAjaxStr('$serviceUrl/waybill/fw/image/$code/get', '', context).then((res){
      if(res['code'] == 200 && res['content']['resourceCode'] != '') {
        print(res['content']['thumbnailList'][0]['url']);
        if(type == 'loading'){//发货
          setState(() {
            loadingImageList.add(res['content']['thumbnailList'][0]['url']);
          });
        }else {//收货
          setState(() {
           unloadingImageList.add(res['content']['thumbnailList'][0]['url']); 
          });
        }
      }
    });
  }
  _getConfigMessage()async {//获取配置信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      configInfo = json.decode(prefs.getString('otherConfigs'));
      areaInfo = json.decode(prefs.getString('areaInfo'));
      // orgSelfInfo = json.decode(prefs.getString('orgSelfInfo'));
    });
  }
  _getWaybillInfo() {
    getAjaxStr('$serviceUrl/waybill/waybill/${widget.code}/info', '', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        setState(() {
          waybillInfo = res['content'] ?? {};
        });
        List loadingCodeList = waybillInfo['loadingAttachment']!= null && waybillInfo['loadingAttachment'] != ''? waybillInfo['loadingAttachment'].split(':') : [];
        List unLoadingCodeList = waybillInfo['unloadingAttachment'] != null && waybillInfo['unloadingAttachment'] != ''? waybillInfo['unloadingAttachment'].split(':') : [];
        if(loadingCodeList.length > 0) {
          loadingCodeList.forEach((item){
            _getImageUrl(item, 'loading');
          });
        }
        if(unLoadingCodeList.length > 0) {
          unLoadingCodeList.forEach((item){
            _getImageUrl(item, 'unloading');
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
          _getWaybillInfo();
        });
      }
    });
  }
}