import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import '../widget/detailPageWidget/content_block_widget.dart';
import '../common/service_method.dart';
import '../config/service_url.dart';
import '../components/progressDialog.dart';
import '../common/utils.dart';
import '../widget/detailPageWidget/bottom_button_list_widget.dart';
import '../widget/detailPageWidget/preview_image_list.dart';
import '../components/componentsModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/full_screen_wrapper.dart';

class DriverCertificationDetailPage extends StatefulWidget {
  
  final String code;
  DriverCertificationDetailPage({Key key, this.code});
  @override
  _DriverCertificationDetailPageState createState() => _DriverCertificationDetailPageState();
}

class _DriverCertificationDetailPageState extends State<DriverCertificationDetailPage> {
  TextEditingController descriptionController = TextEditingController();
  Map driverInfo = {};
  bool _loading = false;
  var areaInfo;
  var configInfo;
  List identityImageList = [];//身份证附件数组
  List driverImageList = []; //驾驶证附件数组
  List qualificationImageList = []; //从业资格证附件数组
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getDriverInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('司机认证详情'),),
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
                      contentItemWidget('认证状态:', driverInfo['certStatus'] != null? configCertTruckStatus[driverInfo['certStatus']] : ''),
        
                    ]),
                    headerTitleWidget('身份证'),
                    contentBlockWidget([
                      contentItemWidget('司机姓名:', driverInfo['fullName'] ?? ''),
                      contentItemWidget('身份证号:', driverInfo['identityNumber'] ?? ''),
                      contentItemWidget('身份证过期日期:', '${driverInfo['identityExpirationDates'] ?? ''}' ),
                      previewImageList('附件',identityImageList,_previewImage)
                    ]),
                    headerTitleWidget('驾驶证'),
                    contentBlockWidget([
                      contentItemWidget('档案编号:', driverInfo['driverLicenseNo'] ?? ''),
                      contentItemWidget('准驾车型:', driverInfo['driverLicenseAcceptType'] ?? ''),
                      contentItemWidget('驾驶证过期日期:', driverInfo['driverLicenseExpirationDates'] ?? ''),
                      previewImageList('附件',driverImageList,_previewImage)
                    ]),
                    headerTitleWidget('从业资格证'),
                    contentBlockWidget([
                      contentItemWidget('从业资格证号:', driverInfo['qualificationCertificateNumber'] ?? ''),
                      contentItemWidget('驾驶证过期日期:', driverInfo['qualificationCertificateExpirationDates'] ?? ''),
                      previewImageList('附件',qualificationImageList,_previewImage)
                    ]),
                    Container(
                      child: Text(''),
                      height: ScreenUtil().setHeight(20),
                      color: Color(0xFFF2F2F2),
                    ),
                     contentBlockWidget([
                      contentItemWidget('手机号:', driverInfo['phone'] ?? ''),
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
                  offstage: driverInfo['certStatus'] == 'authenticating'? false : true,
                  child: commonBtnWidget(context, '认证不通过', (){
                    showMyCupertinoDialog(context, '提示', '确认该操作吗?', (res){
                      if(res == 'confirm'){
                       _approveCertDriver('failed');
                      }
                    });
                  },mainColor: false),
                ),
                flex: driverInfo['certStatus'] == 'authenticating'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: driverInfo['certStatus'] == 'authenticating'? false : true,
                  child: commonBtnWidget(context, '认证通过', (){
                    showMyCupertinoDialog(context, '提示', '确认该操作吗?', (res){
                      if(res == 'confirm'){
                       _approveCertDriver('authenticated');
                      }
                    });
                  },),
                ),
                flex: driverInfo['certStatus'] == 'authenticating'? 1 : 0,
              ),
              Expanded(
                child: Offstage(
                  offstage: driverInfo['certStatus'] == 'authenticated'? false : true,
                  child: commonBtnWidget(context, '打回', (){
                    showMyCupertinoDialog(context, '提示', '你确认打回车辆认证吗?', (res){
                      if(res == 'confirm') {
                        _revokeCertDriver();
                      }
                    });
                  },),
                ),
                flex: driverInfo['certStatus'] == 'authenticated'? 1 : 0,
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
        if(type == 'identity'){//身份证附件
          setState(() {
            identityImageList.add(res['content']['thumbnailList'][0]['url']);
          });
        }else if(type == 'driver') {//驾驶证附件
          setState(() {
           driverImageList.add(res['content']['thumbnailList'][0]['url']); 
          });
        }else{//从业资格证
          setState(() {
           qualificationImageList.add(res['content']['thumbnailList'][0]['url']); 
          });
        }
      }
    });
  }
  _getDriverInfo() {
    getAjaxStr('$serviceUrl/platform/cert_person/${widget.code}/info', '?code=${widget.code}', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        setState(() {
          driverInfo = res['content'] ?? {};
        });
        List identityCodeList = driverInfo['identityResourceCode']!= null && driverInfo['identityResourceCode'] != ''? driverInfo['identityResourceCode'].split(':') : [];
        List driverCodeList = driverInfo['driverLicenseResourceCode'] != null && driverInfo['driverLicenseResourceCode'] != ''? driverInfo['driverLicenseResourceCode'].split(':') : [];
        List qualificationCodeList = driverInfo['qualificationCertificateResourceCode'] != null && driverInfo['qualificationCertificateResourceCode'] != ''? driverInfo['qualificationCertificateResourceCode'].split(':') : [];
        if(identityCodeList.length > 0) {
          identityCodeList.forEach((item){
            _getImageUrl(item, 'identity');
          });
        }
        if(driverCodeList.length > 0) {
          driverCodeList.forEach((item){
            _getImageUrl(item, 'driver');
          });
        }
        if(qualificationCodeList.length > 0) {
          qualificationCodeList.forEach((item){
            _getImageUrl(item, 'qualification');
          });
        }
      }
    });
  }
  _approveCertDriver(String cerStatus) {//认证
    Map<String, dynamic> params = {};
    driverInfo['certStatus'] = cerStatus;
    driverInfo['auditDescription'] = descriptionController.text.trim();
    params = driverInfo;
    postAjax('certDriverApprove', params, context).then((res){
      if(res['code'] == 200){
        Toast.toast(context, '操成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          identityImageList = [];
          driverImageList = [];
          qualificationImageList = [];
          _getDriverInfo();
        });
      }
    });
  }
  _revokeCertDriver() {//打回
    postAjaxStr('$serviceUrl//platform/cert_person/${widget.code}/approve/revoke', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '操作成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          identityImageList = [];
          driverImageList = [];
          qualificationImageList = [];
          _getDriverInfo();
        });
      }
    });
  }
}

