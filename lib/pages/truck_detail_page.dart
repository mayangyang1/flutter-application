import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import '../widget/detailPageWidget/content_block_widget.dart';
import '../common/service_method.dart';
import '../config/service_url.dart';
import '../components/progressDialog.dart';
import '../common/utils.dart';
import '../components/componentsModel.dart';
import '../widget/detailPageWidget/preview_image_list.dart';
import '../components/full_screen_wrapper.dart';

class TruckDetailPage extends StatefulWidget {
  
  final String code;
  TruckDetailPage({Key key, this.code});
  @override
  _TruckDetailPageState createState() => _TruckDetailPageState();
}

class _TruckDetailPageState extends State<TruckDetailPage> {
  TextEditingController descriptionController = TextEditingController();
  Map vehicleInfo = {};
  Map truckInfo = {};
  bool _loading = false;
  List driverImageList = [];//行驶证附件数组
  List transportImageLlist = []; //运输证附件数组
  List truckImageList = [];//车辆照片
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getTruckInfo();
    _getCertTruckInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('车辆详情'),),
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
                      contentItemWidget('车牌号:', vehicleInfo['truckLicenseNo'] ?? ''),
                      contentItemWidget('认证状态:', vehicleInfo['certStatus'] != null? configCertTruckStatus[vehicleInfo['certStatus']] : ''),
                      contentItemWidget('牌照类型:', vehicleInfo['truckLicenseType'] != null? configLicensePlate[vehicleInfo['truckLicenseType']] : ''),
                      previewImageList('车辆照片',truckImageList,_previewImage),
                      contentItemWidget('车型:', vehicleInfo['truckModelName'] ?? '' ),
                      contentItemWidget('车长:', '${vehicleInfo['truckLength'] != null? vehicleInfo['truckLength'].toString()  + '米' : ''}' ),
                      contentItemWidget('核定载质量:', '${vehicleInfo['regTonnage'] != null? vehicleInfo['regTonnage'].toString()  + '吨' : ''}' ),
                      previewImageList('行驶证附件',driverImageList,_previewImage),
                      contentItemWidget('车辆识别代号:', vehicleInfo['truckIdentifyCode'] ?? '' ),
                      contentItemWidget('发动机号码:', '${vehicleInfo['truckEngineNo'] != null && vehicleInfo['truckEngineNo'] != 'undefined'? vehicleInfo['truckEngineNo'] : ''}' ),
                      contentItemWidget('行驶证过期日期:', vehicleInfo['drivingLicenseExpirationDate'] ?? '' ),
                      previewImageList('运输证附件',transportImageLlist,_previewImage),
                      contentItemWidget('道路运输证号:', vehicleInfo['transportLicenseNo'] ?? ''),
                      contentItemWidget('道路经营许可证:', vehicleInfo['vehiclePermitNumber'] ?? ''),
                      contentItemWidget('运输证过期日期:', vehicleInfo['transportLicenseExpirationDate'] ?? ''),
                      contentItemWidget('总质量:', '${vehicleInfo['truckTotalWeight'] != null ? vehicleInfo['truckTotalWeight'].toString() + '吨' : ''}'),
                      contentItemWidget('准牵引总质量:', '${vehicleInfo['truckTowWeight'] != null ? vehicleInfo['truckTowWeight'].toString() + '吨' : ''}'),
                      contentItemWidget('车辆所有人:', vehicleInfo['truckOwner'] ?? '' ),

                    ]),
                    headerTitleWidget('附加信息'),
                    contentBlockWidget([
                      contentItemWidget('联系人:', vehicleInfo['truckLinkman'] ?? ' ' ),
                      contentItemWidget('联系手机号:', vehicleInfo['truckFixedMobile'] ?? ' ' ),
                      contentItemWidget('车宽:', '${vehicleInfo['truckWidth'] != null? vehicleInfo['truckWidth'].toString() + '吨' : ''}' ),
                      contentItemWidget('车高:', '${vehicleInfo['truckHeight'] != null? vehicleInfo['truckHeight'].toString() + '吨' : ''}' ),
                      contentItemWidget('容积:', '${vehicleInfo['cubage'] != null? vehicleInfo['cubage'].toString() + '方' : ''}' ),
                      contentItemWidget('动力类型:', vehicleInfo['powerType'] != null ? configPowerTypeMap[vehicleInfo['powerType']] ?? ' ' : ' ' ),
                      contentItemWidget('整备质量:', '${vehicleInfo['truckCurbWeight'] != null? vehicleInfo['truckCurbWeight'].toString() + '吨' : ''}' ),
                      contentItemWidget('注册日期:', vehicleInfo['truckRegisterDate'] ?? '' ),

                    ]),
                    headerTitleWidget('司机信息'),
                    contentBlockWidget([
                      contentItemWidget('主驾姓名:', vehicleInfo['driverFullName'] ?? ' ' ),
                      contentItemWidget('手机号:', vehicleInfo['driverPhone'] ?? ' ' ),
                      contentItemWidget('副驾姓名:', vehicleInfo['viceDriverFullName'] ?? ' ' ),
                      contentItemWidget('手机号:', vehicleInfo['viceDriverPhone'] ?? ' ' ),
                    ]),

                  ],
                ),
              ),
            ),
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
        }else if(type == 'transport') {//运输证附件
          setState(() {
           transportImageLlist.add(res['content']['thumbnailList'][0]['url']); 
          });
        }else{
          setState(() {
           truckImageList.add(res['content']['thumbnailList'][0]['url']); 
          });
        }
      }
    });
  }
  _getCertTruckInfo() {
    String stringParams = '?mainTruckCode=${widget.code}&page=1&size=1';
    getAjax('truckList', stringParams, context).then((res){
      if(res['code'] == 200 && res['content'].length > 0){
        setState(() {
          truckInfo = res['content'][0];
        });
        
      }
    });
  }
  _getTruckInfo() {
    getAjaxStr('$serviceUrl/truck/truck/${widget.code}/get', '?code=${widget.code}', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        setState(() {
          vehicleInfo = res['content'] ?? {};
        });
        List driverCodeList = vehicleInfo['drivingLicenseRecourseCode']!= null && vehicleInfo['drivingLicenseRecourseCode'] != ''? vehicleInfo['drivingLicenseRecourseCode'].split(':') : [];
        List truckCodeList = vehicleInfo['truckPictureResourceCode']!= null && vehicleInfo['truckPictureResourceCode'] != ''? vehicleInfo['truckPictureResourceCode'].split(':') : [];
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
        if(truckCodeList.length > 0) {
          truckCodeList.forEach((item){
            _getImageUrl(item, 'truck');
          });
        }
      }
    });
  }
}

