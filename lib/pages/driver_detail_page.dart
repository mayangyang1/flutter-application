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
import '../components/full_screen_wrapper.dart';

class DriverDetailPage extends StatefulWidget {
  
  final String code;
  DriverDetailPage({Key key, this.code});
  @override
  _DriverDetailPageState createState() => _DriverDetailPageState();
}

class _DriverDetailPageState extends State<DriverDetailPage> {
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
      appBar: AppBar(title: Text('司机详情'),),
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
                    headerTitleWidget('认证信息'),
                    contentBlockWidget([
                      contentItemWidget('司机姓名:', driverInfo['fullName'] ?? ''),
                      contentItemWidget('认证状态:', driverInfo['certStatus'] != null? configCertTruckStatus[driverInfo['certStatus']] : ''),
                      contentItemWidget('手机号:', driverInfo['phone'] ?? ''),
                      contentItemWidget('性别:',  '${driverInfo['gender'] != null? configGender[driverInfo['gender']] ?? '' : ''}'),
                      previewImageList('身份证附件',identityImageList,_previewImage),
                      contentItemWidget('身份证号:', driverInfo['identityNumber'] ?? ''),
                      contentItemWidget('身份证过期日期:', '${driverInfo['identityExpirationDates'] ?? ''}' ),
                      previewImageList('驾驶证附件',driverImageList,_previewImage),
                      contentItemWidget('准驾车型:', driverInfo['driverLicenseAcceptType'] ?? ''),
                      contentItemWidget('驾驶证过期日期:', driverInfo['driverLicenseExpirationDates'] ?? ''),
                      contentItemWidget('驾照档案编号:', driverInfo['driverLicenseNo'] ?? ''),
                      previewImageList('资格证附件',qualificationImageList,_previewImage),
                      contentItemWidget('从业资格证号:', driverInfo['qualificationCertificateNumber'] ?? ''),
                      contentItemWidget('驾驶证过期日期:', driverInfo['qualificationCertificateExpirationDates'] ?? ''),

                    ]),
                    headerTitleWidget('银行账户信息'),
                    contentBlockWidget([
                      contentItemWidget('银行户名:', driverInfo['bankAccountName'] ?? ' '),
                      contentItemWidget('开户行:', driverInfo['bankName'] ?? ' '),
                      contentItemWidget('银行账号:', driverInfo['bankAccountNo'] ?? ' '),
                      contentItemWidget('描述:', driverInfo['bankAccountDescription'] ?? ''),

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
                    
                  },mainColor: false),
                ),
                flex: driverInfo['certStatus'] == 'authenticating'? 1 : 0,
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
    getAjaxStr('$serviceUrl/person/person/driver/${widget.code}/get', '?code=${widget.code}', context).then((res){
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
  
}

