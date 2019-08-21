import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import '../widget/detailPageWidget/content_block_widget.dart';
import '../common/service_method.dart';
import '../config/service_url.dart';
import '../components/progressDialog.dart';
import '../common/utils.dart';
import '../widget/detailPageWidget/bottom_button_list_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../components/componentsModel.dart';
import '../widget/detailPageWidget/preview_image_list.dart';
import '../components/full_screen_wrapper.dart';

class VehicleCertificationDetailPage extends StatefulWidget {
  
  final String code;
  VehicleCertificationDetailPage({Key key, this.code});
  @override
  _VehicleCertificationDetailPageState createState() => _VehicleCertificationDetailPageState();
}

class _VehicleCertificationDetailPageState extends State<VehicleCertificationDetailPage> {
  TextEditingController descriptionController = TextEditingController();
  Map vehicleInfo = {};
  bool _loading = false;
  var areaInfo;
  var configInfo;
  List driverImageList = [];//行驶证附件数组
  List transportImageLlist = []; //运输证附件数组
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getVehicleInfo();
    _getConfigMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('车辆认证详情'),),
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
                    
                    contentBlockWidget([
                      contentItemWidget('认证状态:', vehicleInfo['certStatus'] != null? configCertTruckStatus[vehicleInfo['certStatus']] : ''),
        
                    ]),
                    headerTitleWidget('行驶证'),
                    contentBlockWidget([
                      contentItemWidget('车牌号:', vehicleInfo['truckLicenseNo'] ?? ''),
                      contentItemWidget('牌照类型:', vehicleInfo['truckLicenseType'] != null? configLicensePlate[vehicleInfo['truckLicenseType']] : ''),
                      contentItemWidget('车长:', '${vehicleInfo['truckLength'] != null? vehicleInfo['truckLength'].toString()  + '米' : ''}' ),
                      contentItemWidget('载重:', '${vehicleInfo['regTonnage'] != null? vehicleInfo['regTonnage'].toString()  + '吨' : ''}' ),
                      contentItemWidget('发动机号码:', '${vehicleInfo['truckEngineNo'] != null && vehicleInfo['truckEngineNo'] != 'undefined'? vehicleInfo['truckEngineNo'] : ''}' ),
                      contentItemWidget('行驶证过期日期:', '${vehicleInfo['drivingLicenseExpirationDates'] ?? ''}' ),
                      previewImageList('附件',driverImageList,_previewImage)
                    ]),
                    headerTitleWidget('运输证'),
                    contentBlockWidget([
                      contentItemWidget('运输证号:', vehicleInfo['transportLicenseNo'] ?? ''),
                      contentItemWidget('运输证过期日期:', vehicleInfo['transportLicenseExpirationDates'] ?? ''),
                      previewImageList('附件',transportImageLlist,_previewImage)
                    ]),
                    headerTitleWidget('理由备注'),
                     contentBlockWidget([
                      inputWidget(descriptionController, '备注', (res){})
                    ]),

                  ],
                ),
              ),
            ),
            bottomButtonListWidget([
              Expanded(
                child: Offstage(
                  offstage: vehicleInfo['certStatus'] == 'authenticating'? false : true,
                  child: commonBtnWidget(context, '认证不通过', (){
                    showMyCupertinoDialog(context, '提示', '确认该操作吗?', (res){
                      if(res == 'confirm'){
                       _approveCertTruck('failed');
                      }
                    });
                  },mainColor: false),
                ),
                flex: vehicleInfo['certStatus'] == 'authenticating'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: vehicleInfo['certStatus'] == 'authenticating'? false : true,
                  child: commonBtnWidget(context, '认证通过', (){
                    showMyCupertinoDialog(context, '提示', '确认该操作吗?', (res){
                      if(res == 'confirm'){
                       _approveCertTruck('authenticated');
                      }
                    });
                  },),
                ),
                flex: vehicleInfo['certStatus'] == 'authenticating'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: vehicleInfo['certStatus'] == 'authenticated'? false : true,
                  child: commonBtnWidget(context, '打回', (){
                    showMyCupertinoDialog(context, '提示', '你确认打回车辆认证吗?', (res){
                      if(res == 'confirm') {
                        _revokeCertTruck();
                      }
                    });
                  },),
                ),
                flex: vehicleInfo['certStatus'] == 'authenticated'? 1 : 0,
              ),
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
    getAjaxStr('$serviceUrl/platform/fw/image/$code/get', '', context).then((res){
      if(res['code'] == 200 && res['content']['resourceCode'] != '') {
        print(res['content']['thumbnailList'][0]['url']);
        if(type == 'driver'){//行驶证附件
          setState(() {
            driverImageList.add(res['content']['thumbnailList'][0]['url']);
          });
        }else {//运输证附件
          setState(() {
           transportImageLlist.add(res['content']['thumbnailList'][0]['url']); 
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
  _getVehicleInfo() {
    getAjaxStr('$serviceUrl/platform/cert_truck/${widget.code}/info', '?code=${widget.code}', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        setState(() {
          vehicleInfo = res['content'] ?? {};
        });
        List driverCodeList = vehicleInfo['drivingLicenseRecourseCode']!= null && vehicleInfo['drivingLicenseRecourseCode'] != ''? vehicleInfo['drivingLicenseRecourseCode'].split(':') : [];
        List transportCodeList = vehicleInfo['transportLicenseRecourseCode'] != null && vehicleInfo['transportLicenseRecourseCode'] != ''? vehicleInfo['transportLicenseRecourseCode'].split(':') : [];
        if(driverCodeList.length > 0) {
          driverCodeList.forEach((item){
            _getImageUrl(item, 'driver');
          });
        }
        if(transportCodeList.length > 0) {
          transportCodeList.forEach((item){
            _getImageUrl(item, 'transport');
          });
        }
      }
    });
  }
  _approveCertTruck(String cerStatus) {//认证
    Map<String, dynamic> params = {};
    vehicleInfo['certStatus'] = cerStatus;
    vehicleInfo['auditDescription'] = descriptionController.text.trim();
    params = vehicleInfo;
    postAjax('certTruckApprove', params, context).then((res){
      if(res['code'] == 200){
        Toast.toast(context, '操成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          driverImageList = [];
          transportImageLlist = [];
          _getVehicleInfo();
        });
      }
    });
  }
  _revokeCertTruck() {//打回
    postAjaxStr('$serviceUrl//platform/cert_truck/${widget.code}/approve/revoke', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '操作成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          driverImageList = [];
          transportImageLlist = [];
          _getVehicleInfo();
        });
      }
    });
  }
}

