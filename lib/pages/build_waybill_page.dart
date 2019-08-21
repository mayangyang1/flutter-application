import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import './search_customer_page.dart';
import './search_route_line_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../common/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import './search_truck_page.dart';
import './search_driver_page.dart';
import '../common/service_method.dart';
import '../components/componentsModel.dart';
import '../config/service_url.dart';
import '../components/progressDialog.dart';

class BuildWaybillPage extends StatefulWidget {
  final String code;
  BuildWaybillPage({Key key, this.code});
  @override
  _BuildWaybillPageState createState() => _BuildWaybillPageState();
}

class _BuildWaybillPageState extends State<BuildWaybillPage> {
  ScrollController scrollController = ScrollController();
  bool isShowUpToBtn = false;
  bool isAgree = false;
  bool goodsLossType = true;//合理货差系数切换
  bool _loading =false;
  var areaInfo;
  var configInfo;
  var orgSelfInfo;
  TextEditingController logisticsNoController = TextEditingController();
  String logisticsNo = '';//订单号
  String logisticsCode = ''; //订单code
  List modelRadioList = [{'id':'self', 'index': 0, 'title': '自助调车'},{'id':'platform', 'index': 1, 'title': '自助调车'}];
  int modeIndexValue = 0;
  String scheduleType = 'self';//调车模式 self为自主 platform为委托
  String clientOrgName = '请选择'; //客户名称
  String clientOrgCode = ''; //客户code
  String platformClientOrgCode = ''; //平台级code
   List<Map> settleMethodList = [//结算方式
    {'key': '请选择', 'id': ''},
    {'key': '按发货量', 'id': 'loadingweight'},
    {'key': '按收货货量', 'id': 'unloadingweight'},
    {'key': '发货与收货两者取小', 'id': 'smaller'},
    {'key': '发货与收货两者取大', 'id': 'bigger'},
    {'key': '按车次', 'id': 'trucknumber'},
  ];
  int _settleIndex = 0;
  String routeName = '请选择'; //线路名称
  String routeCode = ''; //线路code
  String standardDistance = '';
  String standardDistanceUnitCode = 'km';
  TextEditingController standardDistanceController = TextEditingController();
  String businessTypeCode = ''; //业务类型code
  List<Map> businessList = [//业务类型
    {'key': '请选择', 'id': ''},
    {'key': '干线普货运输', 'id': '1002996'},
    {'key': '城市配送', 'id': '1003997'},
    {'key': '农村配送', 'id': '1003998'},
    {'key': '集装箱运输', 'id': '1002998'},
    {'key': '其他', 'id': '1003999'},
  ];
  int _businessIndex = 0;
  TextEditingController loadingOrgNameController = TextEditingController();
  String loadingOrgName = '';//发货单位
  String loadingAdd = '请选择'; //发货地
  String loadingAddress = '';//发货地址
  TextEditingController loadingAddressController = TextEditingController();
  String loadingUserFullName = ''; //发货联系人
  TextEditingController loadingUserFullNameController = TextEditingController();
  String loadingUserPhone = ''; //发货联系电话
  TextEditingController loadingUserPhoneController = TextEditingController();
  String loadingProvinceCode = '';// 发货省code
  String loadingCityCode = ''; //发货市code
  String loadingCountyCode = ''; //发货地区code
  String unloadingAdd = '请选择'; //收货地
  String unloadingOrgName = ''; //收货单位
  TextEditingController unloadingOrgNameController = TextEditingController();
  String unloadingAddress = ''; //收货地址
  TextEditingController unloadingAddressController = TextEditingController();
  String unloadingUserFullName = ''; //收货联系人
  TextEditingController unloadingUserFullNameController = TextEditingController();
  String unloadingUserPhone = ''; //收货联系电话
  TextEditingController unloadingUserPhoneController = TextEditingController();
  String unloadingProvinceCode = ''; //收货省code
  String unloadingCityCode = ''; //收货市code
  String unloadingCountyCode = ''; // 收货地区code
    List<Map> cargoTypeList = [//货物类型
    {'key': '请选择', 'id': ''},
    {'key': '电子产品', 'id': '90'},
    {'key': '商品汽车', 'id': '92'},
    {'key': '冷藏货物', 'id': '93'},
    {'key': '大宗货物', 'id': '94'},
    {'key': '快速消费品', 'id': '95'},
    {'key': '农产品', 'id': '96'},
    {'key': '其他', 'id': '999'},
  ];
  int _cargoTyepIndex = 0;
  String goodsName = ''; //货物名称
  TextEditingController goodsNameController = TextEditingController();
  String meterageType = 'ton'; //计量标准
  List<Map> meterageTypeList =[//计量标准
    {'id':'ton', 'index': 0, 'title': '吨'},
    {'id':'cube', 'index': 1, 'title': '方'},
    {'id':'item', 'index': 2, 'title': '件'},
  ];
  int _meterageTypeIndex = 0;
  String goodsPrice = ''; //货物单价
  TextEditingController goodsPriceController = TextEditingController();
  String goodsPriceName = unit['ton']['goods.price']['name'];//货物单价名称
  String goodsPriceUnitCode = 'yuanperton';//货物单价编码 默认计量标准吨
  String cargoUnitName = unit['ton']['goods.loss']['ton'];//合理货差系数单位名 默认是吨
  List coefficientCargoList = [//合理货差系数
    {'id':'goods.loss.ration', 'index': 0, 'title': '按系数'},
    {'id':'goods.loss', 'index': 1, 'title': '按量'}
  ];
  int _coefficientCargoIndex = 0;
  TextEditingController goodsLossValueController1 = TextEditingController();
  TextEditingController goodsLossValueController2 = TextEditingController();
  String goodsLossMethod = 'goods.loss.ration';//合理货差系数选择  按系数 goods.loss.ration 按量 goods.loss
  String goodsLossUnitCode = 'percent';//货差标准单位编码  按系数时值 percent  按量时 ton item cube
  String goodsLoss = '';//合理货差系数值
  String clientFreightPrice = ''; //客户运价
  TextEditingController clientFreightPriceController = TextEditingController();
  String clientFreightPriceUnitCode = ''; //客户运价单位
  List<Map> clientPriceList = unit['ton']['driver.price'];//客户运价单位 默认计量标准为吨
  String clientPriceValue = unit['ton']['driver.price'][0]['id'];//客户运价初始值
  String driverPrice = ''; //司机运价值
  TextEditingController driverPriceController = TextEditingController();
  String driverPriceUnitCode = ''; //司机运价单位
  List<Map> driverPriceList = unit['ton']['driver.price'];//司机运价单位 默认计量标准为吨
  String driverPriceValue = unit['ton']['driver.price'][0]['id'];//司机运价初始值
  String truckLicenseNo = '请选择'; //车牌号
  String truckCode = ''; //车辆编码
  String licensePlateTypeCode = '';//牌照类型
  String platformTruckCode = ''; //平台级truckCode
  String trailerTruckLicenseNo = '请选择'; //挂车车牌号
  String trailerTruckCode = ''; //挂车车牌编码code
  String platformTrailerTruckCode = '';
  String truckPowerType = 'oil';//动力类型 oil油车 gas气车
  List truckPowerTypeList = [//动力类型
    {'id':'oil', 'index': 0, 'title': '油车'},
    {'id':'gas', 'index': 1, 'title': '气车'}
  ];
  int _truckPowerTypeIndex = 0;
  String driverFullName = '请选择'; //主驾姓名
  String driverCode = ''; //主驾编码
  String platformDriverCode = '';
  String driverPhone = ''; //主驾手机号
  TextEditingController driverPhoneController = TextEditingController();
  String driverIdentityNumber = ''; // 主驾身份证号
  String driverLicenseNo = ''; //主驾驾驶证
  TextEditingController driverLicenseNoController = TextEditingController();
  String fuelCardNo = ''; //油卡卡号
  String viceDriverCode = ''; //副驾编码
  String platformViceDriverCode = '';//平台级副驾编码
  String viceDriverFullName = '请选择'; //副驾姓名
  String viceDriverPhone = ''; //副驾手机号
  TextEditingController viceDriverPhoneController = TextEditingController();
  String viceDriverIdentityNumber = ''; //副驾身份证号
  String viceDriverLicenseNo = ''; //副驾驾驶证号
  TextEditingController viceDriverLicenseNoController = TextEditingController();
  String payeeDriverFullName = '请选择'; //主驾收款人姓名
  String payeeDriverCode = ''; //主驾收款人编码code
  String payeeDriverPhone = '';//主驾收款人手机号
  String payeePlatformDriverCode = '';//主驾收款人平台级code
  String driverPayeeBankName = ''; //主驾收款人开户行
  TextEditingController driverPayeeBankNameController = TextEditingController();
  String driverPayeeBankAccountName = ''; //主驾收款人银行户名
  TextEditingController driverPayeeBankAccountNameController = TextEditingController();
  String driverPayeeBankAccountNo = ''; //主驾收款人银行账户
  TextEditingController driverPayeeBankAccountNoController = TextEditingController();
  String driverPayeeBankAccountDescription = ''; //主驾收款人备注
  TextEditingController driverPayeeBankAccountDescriptionController = TextEditingController();
  String payeeViceDriverFullName = '请选择'; //副驾收款人姓名
  String payeeViceDriverCode = ''; //副驾收款人编码code
  String payeeViceDriverPhone = '';//副驾收款人手机号
  String viceDriverPayeeBankName = ''; //副驾收款人开户行
  TextEditingController viceDriverPayeeBankNameController = TextEditingController();
  String viceDriverPayeeBankAccountName = ''; //副驾收款人银行户名
  TextEditingController viceDriverPayeeBankAccountNameController = TextEditingController();
  String viceDriverPayeeBankAccountNo = ''; //副驾收款人银行账号
  TextEditingController viceDriverPayeeBankAccountNoController = TextEditingController();
  String viceDriverPayeeBankAccountDescription = ''; //副驾收款人备注
  TextEditingController viceDriverPayeeBankAccountDescriptionController = TextEditingController();
  String settleConfigValue1 = ''; //油气费值
  String settleConfigUnitCode1 = ''; //油气费code
  String settleConfigValue2 = ''; //保险费值
  String settleConfigUnitCode2 = ''; //保险费code
  String settleConfigValue3 = ''; //信息费值
  String settleConfigUnitCode3 = ''; //信息费code
  @override
  void initState() { 
    super.initState();
    _getConfigMessage();
    scrollController.addListener((){
      if(scrollController.offset < 1000 && isShowUpToBtn) {
        setState(() {
          isShowUpToBtn = false; 
        }); 
      }else if(scrollController.offset >= 1000 && !isShowUpToBtn){
        setState(() {
         isShowUpToBtn = true; 
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('直接派车'),
      ),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: SingleChildScrollView(
          controller: scrollController,
          child: Container(
            child: Column(
              children: <Widget>[
                headerTitleWidget('基本信息'),
                Offstage(
                  offstage: logisticsNoController.text != null && logisticsNoController.text != ''? false : true,
                  child: commonRowWidget(context, false, '订单号:', commonInputWidget(logisticsNoController, '', (res){},enabled: false) ),
                ),
                commonRowWidget(
                  context, true, '调车模式',
                  radioWidget( modelRadioList,modeIndexValue,(res){
                    setState(() {
                      modeIndexValue = res; 
                    });
                  },)
                ),
                commonRowWidget(context, true, '客户', searchWidget(context, clientOrgName, SearchCustomerPage(), (res){
                  setState(() {
                    clientOrgName = res['orgName'] ?? '请选择';
                    clientOrgCode= res['code'] ?? '';
                    platformClientOrgCode = res['orgCode'] ?? '';
                  });
                })),
                commonRowWidget(context, true, '结算方式', singleSelectWidget(settleMethodList[_settleIndex]['key'], context, settleMethodList, _settleIndex, (res){
                  if(res['key'] == 'confirm'){
                    setState(() {
                      _settleIndex = res['value'];
                    });
                  }
                })),
                headerTitleWidget('线路信息'),
                commonRowWidget(context, false, '线路名称:', searchWidget(context,routeName,SearchRouteLinePage(),(res){
                  print(res);
                  setState(() {
                    routeName = res['routeName'] ?? '请选择';
                    routeCode = res['code'] ?? ''; 
                    loadingOrgNameController.text = res['loadingOrgName'] ?? '';
                    loadingAdd = '${areaInfo['province'][res['loadingProvinceCode']]}-${areaInfo['city'][res['loadingCityCode']]}-${areaInfo['county'][res['loadingCountyCode']]}' ?? '请选择';
                    loadingAddressController.text = res['loadingAddress'] ?? '';
                    loadingUserFullNameController.text = res['loadingLinkmanFullName'] ?? '';
                    loadingUserPhoneController.text = res['loadingContact'] ?? '';
                    loadingProvinceCode = res['loadingProvinceCode']?? '';
                    loadingCityCode = res['loadingCityCode']?? '';
                    loadingCountyCode = res['loadingCountyCode']?? '';
                    unloadingOrgNameController.text = res['unloadingOrgName'] ?? '';
                    unloadingAdd = '${areaInfo['province'][res['unloadingProvinceCode']]}-${areaInfo['city'][res['unloadingCityCode']]}-${areaInfo['county'][res['unloadingCountyCode']]}' ?? '请选择';
                    unloadingAddressController.text = res['unloadingAddress'] ?? '';
                    unloadingUserFullNameController.text = res['unloadingLinkmanFullName'] ?? '';
                    unloadingUserPhoneController.text = res['unloadingContact'] ?? '';
                    unloadingProvinceCode = res['unloadingProvinceCode'] ?? '';
                    unloadingCityCode = res['unloadingCityCode'] ?? '';
                    unloadingCountyCode = res['unloadingCountyCode'] ?? '';
                  });
                  
                })),
                commonRowWidget(context, false, '标准运距:', commonInputWidget(standardDistanceController, '请输入标准运距', (res){},title: '公里') ),
                commonRowWidget(context, true, '业务类型:', singleSelectWidget(businessList[_businessIndex]['key'],context, businessList, _businessIndex, (res){
                  if(res['key'] == 'confirm'){
                    setState(() {
                      _businessIndex = res['value'];
                    });
                  }
                })),
                commonRowWidget(context, false, '发货单位:', commonInputWidget(loadingOrgNameController, '请输入发货单位', (res){},) ),
                commonRowWidget(context, true, '发货地:', citySelectWidget(loadingAdd, context, (res){
                  print(res);
                  setState(() {
                    loadingAdd = res['textValue']?? '';
                    loadingProvinceCode = res['provinceCode']?? '';
                    loadingCityCode = res['cityCode']?? '';
                    loadingCountyCode = res['areaCode']?? '';
                    
                  });
                }, true)),
                commonRowWidget(context, false, '发货地址:', commonInputWidget(loadingAddressController, '请输入发货地址', (res){},) ),
                commonRowWidget(context, false, '发货联系人:', commonInputWidget(loadingUserFullNameController, '请输入发货联系人', (res){},) ),
                commonRowWidget(context, false, '发货联系电话:', commonInputWidget(loadingUserPhoneController, '请输入发货联系电话', (res){},),width: 240.0 ),
                commonRowWidget(context, false, '收货单位:', commonInputWidget(unloadingOrgNameController, '请输入收货单位', (res){},) ),
                commonRowWidget(context, true, '收货地:', citySelectWidget(unloadingAdd, context, (res){
                  print(res);
                  setState(() {
                    unloadingAdd = res['textValue'];
                    unloadingProvinceCode = res['provinceCode']?? '';
                    unloadingCityCode = res['cityCode']?? '';
                    unloadingCountyCode = res['areaCode']?? '';
                  });
                }, true)),
                commonRowWidget(context, false, '收货地址:', commonInputWidget(unloadingAddressController, '请输入收货地址', (res){},) ),
                commonRowWidget(context, false, '收货联系人:', commonInputWidget(unloadingUserFullNameController, '请输入收货联系人', (res){},) ),
                commonRowWidget(context, false, '收货联系电话:', commonInputWidget(unloadingUserPhoneController, '请输入收货联系电话', (res){},),width: 240.0 ),
                Padding(child: null,padding: EdgeInsets.only(top: 10)),
                headerTitleWidget('货物/运价'),
                commonRowWidget(context, true, '货物类型:', singleSelectWidget(cargoTypeList[_cargoTyepIndex]['key'],context, cargoTypeList, _cargoTyepIndex, (res){
                  if(res['key'] == 'confirm'){
                    setState(() {
                      _cargoTyepIndex = res['value'];
                    });
                  }
                })),
                commonRowWidget(context, true, '货物名称:', commonInputWidget(goodsNameController, '请输入货物名称', (res){},)),
                commonRowWidget(context, true, '计量标准:', radioWidget(meterageTypeList, _meterageTypeIndex,(res){
                  print(unit[meterageTypeList[res]['id']]['driver.price'][0]['id']);
                  setState(() {
                    _meterageTypeIndex = res; 
                    goodsPriceName = unit[meterageTypeList[_meterageTypeIndex]['id']]['goods.price']['name'];//货物单价名称
                    goodsPriceUnitCode = unit[meterageTypeList[_meterageTypeIndex]['id']]['goods.price']['id'];//货物单价单位code
                    cargoUnitName = unit[meterageTypeList[_meterageTypeIndex]['id']]['goods.loss'][meterageTypeList[_meterageTypeIndex]['id']];//合理货差系数单位名

                    clientPriceValue = unit[meterageTypeList[res]['id']]['driver.price'][0]['id'];//客户运价单位
                    clientPriceList = unit[meterageTypeList[res]['id']]['driver.price'];//客户运价单位list

                    driverPriceList = unit[meterageTypeList[res]['id']]['driver.price'];//司机报价单位list
                    driverPriceValue = unit[meterageTypeList[res]['id']]['driver.price'][0]['id'];//司机报价单位

                  });
                },)),
                commonRowWidget(context, false, '货物单价:', commonInputWidget(goodsPriceController, '请输入货物单价', (res){},title: goodsPriceName)),
                commonRowWidget(context, false, '合理货差系数:', radioWidget( coefficientCargoList, _coefficientCargoIndex,  (res){
                  setState(() {
                    _coefficientCargoIndex = res; 
                    goodsLossType = res == 0? true : false; 
                    goodsLossValueController1.text = '';
                    goodsLossValueController2.text = '';
                    goodsLossMethod = res == 0? 'goods.loss.ration' : 'goods.loss';
                    goodsLossUnitCode = res == 0? 'percent' : meterageTypeList[_meterageTypeIndex]['id'];//合理货差系数值单位 按系数时percent 按量 则根据计量标准值来

                  });
                },),width: 240.0),
                commonRowWidget(
                  context, false, '值:',
                  goodsLossType == true
                  ? commonInputWidget(goodsLossValueController1, '', (res){},title: '‰')
                  : commonInputWidget(goodsLossValueController2, '', (res){},title: cargoUnitName)
                ),
                commonRowWidget(
                  context, false, '客户运价:',
                  commonInputSelectButtonWidget(clientFreightPriceController, '请输入客户运价', (res){}, clientPriceList, clientPriceValue, (respon){
                    setState(() {
                      clientPriceValue = respon;
                    });
                  })
                ),
                commonRowWidget(
                  context, false, '司机运价:',
                  commonInputSelectButtonWidget(driverPriceController, '请输入司机运价', (res){}, driverPriceList, driverPriceValue, (respon){
                    setState(() {
                      driverPriceValue = respon;
                    });
                  })
                ),
                Padding(child: null,padding: EdgeInsets.only(top: 10)),
                headerTitleWidget('车辆司机'),
                Padding(child: imageTitle('car','车辆'),padding: EdgeInsets.only(left: 10),),
                commonRowWidget(context, true, '车牌号:', searchWidget(context, truckLicenseNo, SearchTruckPage(type: 'mainTruck'), (res){
                  print(res);
                  truckPowerTypeList.forEach((item){
                      if(item['id'] == res['powerType']){
                        setState(() {
                        _truckPowerTypeIndex = 1; 
                        });
                      }else {
                        if(res['powerType'] == null){
                          setState(() {
                          _truckPowerTypeIndex = -1; 
                          });
                        }
                      }
                    });
                  setState(() {
                    truckLicenseNo = res['mainTruckLicenseNo'] ?? '请选择';
                    truckCode = res['code'] ?? '';
                    licensePlateTypeCode = res['mainTruckLicenseType'] ?? '';
                    platformTruckCode = res['platformMainTruckCode'] ?? '';
                    truckPowerType = res['powerType'] ?? '';

                    trailerTruckLicenseNo = res['trailerTruckLicenseNo'] ?? '请选择';
                    trailerTruckCode = res['code'] ?? '';
                    platformTrailerTruckCode = res['trailerTruckCode'] ?? '';
                    
                  });
                  if(res['platformDriverCode'] != null){
                    _getDriverInfo(res['platformDriverCode'], 'driver');
                  }
                  if(res['platformViceDriverCode'] != null){
                    _getDriverInfo(res['platformViceDriverCode'], 'viceDriver');
                  }
                })),
                commonRowWidget(context, true, '挂车牌号:', searchWidget(context, trailerTruckLicenseNo, SearchTruckPage(type:'trailer'), (res){

                })),
                commonRowWidget(context, true, '动力类型:', radioWidget( truckPowerTypeList, _truckPowerTypeIndex, (res){
                  setState(() {
                  _truckPowerTypeIndex = res; 
                  });
                },)),
                Divider(),
                Padding(child: imageTitle('driver','主驾'),padding: EdgeInsets.only(left: 10),),
                commonRowWidget(context, false, '主驾:', searchWidget(context, driverFullName, SearchDriverPage(), (res){
                  if(res['code'] != null){
                    _getDriverInfo(res['userCode'], 'driver');
                  }
                  
                })),
                commonRowWidget(context, false, '主驾手机号:', commonInputWidget(driverPhoneController, '请输入主驾手机号', (res){})),
                commonRowWidget(context, false, '主驾驾驶证:', commonInputWidget(driverLicenseNoController, '请输入主驾驾驶证', (res){})),
                Padding(child: imageTitle('fdriver','副驾'),padding: EdgeInsets.only(top: 10,left:10)),
                
                commonRowWidget(context, false, '副驾:', searchWidget(context, viceDriverFullName, SearchDriverPage(), (res){
                  if(res['code'] != null) {
                    _getDriverInfo(res['userCode'], 'viceDriver');
                  }
                })),
                commonRowWidget(context, false, '副驾手机号:', commonInputWidget(viceDriverPhoneController, '请输入副驾手机号', (res){})),
                commonRowWidget(context, false, '副驾驾驶证:', commonInputWidget(viceDriverLicenseNoController, '请输入副驾驾驶证', (res){})),
                Padding(child: null,padding: EdgeInsets.only(top: 10)),
                headerTitleWidget('收款账户'),
                Padding(child: imageTitle('driver','主驾'),padding: EdgeInsets.only(left:10),),
                commonRowWidget(context, false, '收款人:', searchWidget(context, payeeDriverFullName, SearchDriverPage(), (res){
                  if(res['code'] != null) {
                    _getDriverInfo(res['userCode'], 'mainReceive');
                  }
                })),
                commonRowWidget(context, false, '收款人银行户名:', commonInputWidget(driverPayeeBankAccountNameController, '请输入银行户名', (res){}),width: 240.0),
                commonRowWidget(context, false, '银行卡号:', commonInputWidget(driverPayeeBankAccountNoController, '请输入银行卡号', (res){})),
                commonRowWidget(context, false, '开户银行:', commonInputWidget(driverPayeeBankNameController, '请输入开户银行', (res){})),
                commonRowWidget(context, false, '备注:', commonInputWidget(driverPayeeBankAccountDescriptionController, '请输入备注', (res){})),
                Padding(child: imageTitle('fdriver','副驾'),padding: EdgeInsets.only(top: 10,left: 10)),
                commonRowWidget(context, false, '收款人:', searchWidget(context, payeeViceDriverFullName, SearchDriverPage(), (res){
                  if(res['code'] != null) {
                    _getDriverInfo(res['userCode'], 'viceReceive');
                  }
                })),
                commonRowWidget(context, false, '收款人银行户名:', commonInputWidget(viceDriverPayeeBankAccountNameController, '请输入银行户名', (res){}),width: 240.0),
                commonRowWidget(context, false, '银行卡号:', commonInputWidget(viceDriverPayeeBankAccountNoController, '请输入银行卡号', (res){})),
                commonRowWidget(context, false, '开户银行:', commonInputWidget(viceDriverPayeeBankNameController, '请输入开户银行', (res){})),
                commonRowWidget(context, false, '备注:', commonInputWidget(viceDriverPayeeBankAccountDescriptionController, '请输入备注', (res){})),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                  color: Color(0xFFF2F2F2),
                  child: Column(
                    children: <Widget>[
                      agreementWidget(context,isAgree, configInfo !=null && configInfo['other.statement.tradeRulesName'] != null? configInfo['other.statement.tradeRulesName'] : '',(res){
                        setState(() {
                          isAgree = !isAgree;
                        });
                      },()async{
                        String url = configInfo['other.statement.tradeRulesUrl'];
                        if(await canLaunch(url)){
                          await launch(url);
                        }else{
                          throw 'Could not launch $url';
                        }

                      }),
                      commonBtnWidget(context, '提交', _bindInput)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !isShowUpToBtn? null : FloatingActionButton(
        child: Icon(Icons.arrow_upward),
        onPressed: (){
          scrollController.animateTo(
            .0,
            duration: Duration(milliseconds: 200),
            curve: Curves.ease
          );
        },
      ),
    );
  }
  _getConfigMessage()async {//获取配置信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      configInfo = json.decode(prefs.getString('otherConfigs'));
      areaInfo = json.decode(prefs.getString('areaInfo'));
      orgSelfInfo = json.decode(prefs.getString('areaInfo'));
    });
    _getLogisticsInfo();
  }
  _getDriverInfo(String code, String type) {//根据主副驾code获取司机信息
    var stringParams = '?userCode=$code';
    getAjax('driverGet', stringParams, context).then((res){
      if( res != null && res['code'] == 200) {
        Map dataObj = res['content'] ?? {};
        if (type == 'driver') { //主驾
            setState((){
              driverFullName = dataObj['fullName'] ?? '请选择';
              driverCode = dataObj['code'] ?? '';
              platformDriverCode =dataObj['userCode'] ?? '';
              driverPhoneController.text = dataObj['phone'] ?? '';
              driverIdentityNumber = dataObj['identityNumber'] ?? '';
              driverLicenseNoController.text = dataObj['driverLicenseNo'] ?? '';
              payeeDriverFullName = dataObj['fullName'] ?? '请选择';
              payeeDriverCode = dataObj['code'] ?? '';
              payeeDriverPhone = dataObj['phone'] ?? '';
              payeePlatformDriverCode = dataObj['userCode'] ?? '';
              driverPayeeBankNameController.text = dataObj['bankName'] ?? '';
              driverPayeeBankAccountNameController.text = dataObj['bankAccountName'] ?? '';
              driverPayeeBankAccountNoController.text =  dataObj['bankAccountNo'] ?? '';
              driverPayeeBankAccountDescriptionController.text = dataObj['bankAccountDescription'] ?? '';
              fuelCardNo = dataObj['fuelCardNo'] ?? '';
            });
          } else if (type == 'viceDriver') { //副驾
            setState((){
              viceDriverCode = dataObj['code'] ?? '请选择';
              platformViceDriverCode =  dataObj['userCode'] ?? '';
              viceDriverFullName = dataObj['fullName'] ?? '';
              viceDriverPhoneController.text = dataObj['phone'] ?? '';
              viceDriverIdentityNumber = dataObj['identityNumber'] ?? '';
              viceDriverLicenseNoController.text = dataObj['driverLicenseNo'] ?? '';
              payeeViceDriverFullName = dataObj['fullName'] ?? '请选择';
              payeeViceDriverCode = dataObj['code'] ?? '';
              payeeViceDriverPhone = dataObj['phone'] ?? '';
              viceDriverPayeeBankNameController.text = dataObj['bankName'] ?? '';
              viceDriverPayeeBankAccountNameController.text = dataObj['bankAccountName'] ?? '';
              viceDriverPayeeBankAccountNoController.text = dataObj['bankAccountNo'] ?? '';
              viceDriverPayeeBankAccountDescriptionController.text = dataObj['bankAccountDescription'] ?? '';
            });
          } else if (type == 'mainReceive'){
            setState((){
              payeeDriverFullName = dataObj['fullName'] ?? '请选择';
              payeeDriverCode = dataObj['code'] ?? '';
              driverPayeeBankNameController.text = dataObj['bankName'] ?? '';
              driverPayeeBankAccountNameController.text = dataObj['bankAccountName'] ?? '';
              driverPayeeBankAccountNoController.text = dataObj['bankAccountNo'] ?? '';
              driverPayeeBankAccountDescriptionController.text = dataObj['bankAccountDescription'] ?? '';
            });
          } else if (type == 'viceReceive') {
            setState((){
              payeeViceDriverFullName = dataObj['fullName'] ?? '请选择';
              payeeViceDriverCode = dataObj['code'] ?? '';
              viceDriverPayeeBankNameController.text = dataObj['bankName'] ?? '';
              viceDriverPayeeBankAccountNameController.text = dataObj['bankAccountName'] ?? '';
              viceDriverPayeeBankAccountNoController.text = dataObj['bankAccountNo'] ?? '';
              viceDriverPayeeBankAccountDescriptionController.text = dataObj['bankAccountDescription'] ?? '';
            });
          }
      }
    });
  }
  _getLogisticsInfo() {//基于订单派车
    if(widget.code == null) {
      return;
    }
    setState(() {
      _loading = true; 
    });
    getAjaxStr('$serviceUrl/logistics/logistics/${widget.code}/get', '', context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200) {
        Map logisticsInfo = res['content'];
        
        for (var i = 0; i < settleMethodList.length; i++) {//结算方式
          if(settleMethodList[i]['id'] == logisticsInfo['settleMethod'] ?? ''){
            setState(() {
             _settleIndex = i; 
            });
          }
        }

        for (var i = 0; i < businessList.length; i++) {//业务类型
          if(businessList[i]['id'] == logisticsInfo['businessTypeCode'] ?? ''){
            setState(() {
              _businessIndex = i; 
            });
          }
        }
        for (var i = 0; i < cargoTypeList.length; i++) {//货物类型
          if(cargoTypeList[i]['id'] == logisticsInfo['cargoTypeClassificationCode']){
            setState(() {
             _cargoTyepIndex = i; 
            });
          }
        }
        meterageTypeList.forEach((item){//计量标准
          if(item['id'] == logisticsInfo['meterageType']){
            setState(() {
              _meterageTypeIndex = item['index']; 
            });
          }
        });
        coefficientCargoList.forEach((item){//合理货差系数
          if(item['id'] == logisticsInfo['goodsLossMethod']){
            setState(() {
              _coefficientCargoIndex = item['index']; 
              if(item['id'] == 'goods.loss.ration') {
                goodsLossValueController1.text = logisticsInfo['goodsLoss'] != null? logisticsInfo['goodsLoss'].toString() : '';
              }else{
                goodsLossValueController2.text = logisticsInfo['goodsLoss'] != null ? logisticsInfo['goodsLoss'].toString() : '';
              }
            });
          }
        });
        //-----发货地 -- start -------------//
        String loadingAddName;
        if(logisticsInfo['loadingProvinceCode'] != null && logisticsInfo['loadingCityCode'] != null && logisticsInfo['loadingCountyCode'] != null){
          loadingAddName = '${areaInfo['province'][logisticsInfo['loadingProvinceCode']]} - ${areaInfo['city'][logisticsInfo['loadingCityCode']]} - ${areaInfo['county'][logisticsInfo['loadingCountyCode']]}';
        }else if(logisticsInfo['loadingProvinceCode'] != null && logisticsInfo['loadingCityCode'] != null && logisticsInfo['loadingCountyCode'] == null){
          loadingAddName = '${areaInfo['province'][logisticsInfo['loadingProvinceCode']]} - ${areaInfo['city'][logisticsInfo['loadingCityCode']]}';
        }else if(logisticsInfo['loadingProvinceCode'] != null && logisticsInfo['loadingCityCode'] == null && logisticsInfo['loadingCountyCode'] == null){
          loadingAddName = '${areaInfo['province'][logisticsInfo['loadingProvinceCode']]}';
        }
        //-----发货地 -- end -------------//
        //-----收货地 -- start -------------//
        String unloadingAddName;
        if(logisticsInfo['unloadingProvinceCode'] != null && logisticsInfo['unloadingCityCode'] != null && logisticsInfo['unloadingCountyCode'] != null){
          unloadingAddName = '${areaInfo['province'][logisticsInfo['unloadingProvinceCode']]} - ${areaInfo['city'][logisticsInfo['unloadingCityCode']]} - ${areaInfo['county'][logisticsInfo['unloadingCountyCode']]}';
        }else if(logisticsInfo['unloadingProvinceCode'] != null && logisticsInfo['unloadingCityCode'] != null && logisticsInfo['unloadingCountyCode'] == null){
          unloadingAddName = '${areaInfo['province'][logisticsInfo['unloadingProvinceCode']]} - ${areaInfo['city'][logisticsInfo['unloadingCityCode']]}';
        }else if(logisticsInfo['unloadingProvinceCode'] != null && logisticsInfo['unloadingCityCode'] == null && logisticsInfo['unloadingCountyCode'] == null){
          unloadingAddName = '${areaInfo['province'][logisticsInfo['unloadingProvinceCode']]}';
        }
        //-----收货地 -- end -------------//


        setState(() {
          logisticsNoController.text = logisticsInfo['logisticsNo'] ?? '';
          logisticsCode = logisticsInfo['code'] ?? '';
          clientOrgName = logisticsInfo['clientOrgName'] ?? '';
          clientOrgCode = logisticsInfo['clientOrgCode'] ?? '';
          platformClientOrgCode = logisticsInfo['platformClientOrgCode'] ?? '';
          routeName = logisticsInfo['routeName'] ?? '';
          routeCode = logisticsInfo['routeCode'] ?? '';
          standardDistanceController.text = logisticsInfo['standardDistance'] != null? logisticsInfo['standardDistance'].toString() : '';
          standardDistanceUnitCode = logisticsInfo['standardDistanceUnitCode'] ?? '';

          loadingOrgNameController.text = logisticsInfo['loadingOrgName'] ?? '';
          loadingAddressController.text = logisticsInfo['loadingAress'] ?? '';
          loadingAdd = loadingAddName;
          loadingProvinceCode = logisticsInfo['loadingProvinceCode'] ?? '';
          loadingCityCode = logisticsInfo['loadingCityCode'] ?? '';
          loadingCountyCode = logisticsInfo['loadingCountyCode'] ?? '';
          loadingUserFullName = logisticsInfo['loadingUserFullName'] ?? '';
          loadingUserPhone = logisticsInfo['loadingUserPhone'] ?? '';

          unloadingOrgNameController.text = logisticsInfo['unloadingOrgName'] ?? '';
          unloadingAdd = unloadingAddName;
          unloadingProvinceCode = logisticsInfo['unloadingProvinceCode'] ?? '';
          unloadingCityCode = logisticsInfo['unloadingCityCode'] ?? '';
          unloadingCountyCode = logisticsInfo['unloadingCountyCode'] ?? '';
          unloadingAddressController.text =  logisticsInfo['unloadingAddress'] ?? '';
          unloadingUserFullNameController.text =  logisticsInfo['unloadingUserFullName'] ?? '';
          unloadingUserPhoneController.text =  logisticsInfo['unloadingUserPhone'] ?? '';

          goodsNameController.text =  logisticsInfo['goodsName'] ?? '';
          goodsPriceController.text =  logisticsInfo['goodsPrice'] != null ? logisticsInfo['goodsPrice'].toString() : '';
          goodsPriceUnitCode = logisticsInfo['goodsPriceUnitCode'] ?? '';
          goodsLossUnitCode = logisticsInfo['goodsLossUnitCode'] ?? '';
         
          clientFreightPriceController.text = logisticsInfo['clientFreightPrice'] != null ? logisticsInfo['clientFreightPrice'].toString() : '';
          clientFreightPriceUnitCode = logisticsInfo['clientFreightPriceUnitCode'] ?? '';
          driverPriceController.text = logisticsInfo['driverReferPrice'] != null? logisticsInfo['driverReferPrice'].toString() :  '';
          driverPriceUnitCode = logisticsInfo['driverReferPriceUnitCode'] ?? '';

          settleConfigValue1 = logisticsInfo['settleConfigValue1'] ?? '';
          settleConfigUnitCode1 = logisticsInfo['settleConfigUnitCode1'] ?? '';
          settleConfigValue2 = logisticsInfo['settleConfigValue2'] ?? '';
          settleConfigUnitCode2 = logisticsInfo['settleConfigUnitCode2'] ?? '';
          settleConfigValue3 = logisticsInfo['settleConfigValue3'] ?? '';
          settleConfigUnitCode3 = logisticsInfo['settleConfigUnitCode3'] ?? '';
          // informationFee = logisticsInfo['informationFee'] ?? '';
          // informationFeeSet = logisticsInfo['informationFeeSet'] ?? 'notsetup';


        });

      }
    });
  }
  _bindInput() {//提交
    RegExp mobile = new RegExp(r"1[0-9]\d{10}$");//验证手机号
    RegExp _number = new RegExp(r"^[0-9]+(.[0-9]{0,9})?$");//可以带有小数的数字
    if(!isAgree){
      return Toast.toast(context, '请同意平台交易规则');
    }
    if(clientOrgCode == ''){
      return Toast.toast(context, '请选择客户');
    }
    if(_settleIndex == 0){
      return Toast.toast(context, '请选择结算方式');
    }
    if(!_number.hasMatch(standardDistanceController.text)){
      return Toast.toast(context, '标准运距格式有误');
    }
    if(_businessIndex == 0){
      return Toast.toast(context, '请选择业务类型');
    }
    if(loadingProvinceCode == ''){
      return Toast.toast(context, '请选择发货地');
    }
    if(loadingUserPhoneController.text != '' && mobile.hasMatch(loadingUserPhoneController.text)){
      return Toast.toast(context, '发货联系电话有误');
    }
    if(unloadingProvinceCode == ''){
      return Toast.toast(context, '请选择收货地');
    }
    if( unloadingUserPhoneController.text != '' && mobile.hasMatch(unloadingUserPhoneController.text)){
      return Toast.toast(context, '收货联系电话有误');
    }
    if(_cargoTyepIndex == 0){
      return Toast.toast(context, '请选择货物类型');
    }
    if(goodsNameController.text.trim() == ''){
      return Toast.toast(context, '请输入货物名称');
    }
    if(clientFreightPriceController.text != '' && !_number.hasMatch(clientFreightPriceController.text)){
      return Toast.toast(context, '客户运价有误');
    }
    if(driverPriceController.text != '' && !_number.hasMatch(driverPriceController.text)){
      return Toast.toast(context, '司机运价有误');
    }
    if(driverPhoneController.text != '' && mobile.hasMatch(driverPhoneController.text)){
      return Toast.toast(context, '主驾手机号有误');
    }
    if(viceDriverPhoneController.text != '' && mobile.hasMatch(viceDriverPhoneController.text)){
      return Toast.toast(context, '副驾手机号有误');
    }
    if(driverPayeeBankAccountNoController.text != '' && !_number.hasMatch(driverPayeeBankAccountNoController.text)){
      return Toast.toast(context, '主驾银行卡号有误');
    }
    if(viceDriverPayeeBankAccountNoController.text != '' && !_number.hasMatch(viceDriverPayeeBankAccountNoController.text)){
      return Toast.toast(context, '副驾银行卡号有误');
    }
    if(truckLicenseNo == '' || truckLicenseNo == '请选择' ){
      return Toast.toast(context, '请选择车牌号');
    }
    if(_truckPowerTypeIndex < 0){
      return Toast.toast(context, '请选择动力类型');
    }
    
    _waybillAdd();

  }
  
  _waybillAdd() {//新建运单
    Map<String, dynamic> params = {};
    if(logisticsNoController.text != null && logisticsNoController.text != '' && logisticsCode != null && logisticsCode != '') {
      params['logisticsNo'] = logisticsNoController.text;
      params['logisticsCode'] = logisticsCode;
    }
    params['scheduleType'] = modelRadioList[modeIndexValue]['id'];
    params['clientOrgName'] = clientOrgName;
    params['clientOrgCode'] = clientOrgCode;
    params['platformClientOrgCode'] = platformClientOrgCode;
    params['settleMethod'] = settleMethodList[_settleIndex]['id'];
    params['routeName'] = routeName != '请选择'? routeName : '';
    params['routeCode'] = routeCode;
    params['standardDistance'] = standardDistanceController.text;
    params['standardDistanceUnitCode'] = standardDistanceUnitCode;
    params['reportBusinessTypeCode'] = businessList[_businessIndex]['id'];
    params['loadingOrgName'] = loadingOrgNameController.text;
    params['loadingProvinceCode'] = loadingProvinceCode;
    params['loadingCityCode'] = loadingCityCode;
    params['loadingCountyCode'] = loadingCountyCode;
    params['loadingAddr'] = loadingAddressController.text;
    params['loadingUserFullName'] = loadingUserFullNameController.text;
    params['loadingUserPhone'] = loadingUserPhoneController.text;
    params['unloadingOrgName'] = unloadingOrgNameController.text;
    params['unloadingProvinceCode'] = unloadingProvinceCode;
    params['unloadingCityCode'] = unloadingCityCode;
    params['unloadingCountyCode'] = unloadingCountyCode;
    params['unloadingAddr'] = unloadingAddressController.text;
    params['unloadingUserFullName'] = unloadingUserFullNameController.text;
    params['unloadingUserPhone'] = unloadingUserPhoneController.text;
    params['reportCargoTypeClassificationCode'] = cargoTypeList[_cargoTyepIndex]['id'];
    params['goodsName'] = goodsNameController.text;
    params['goodsPrice'] = goodsPriceController.text;
    params['goodsPriceUnitCode'] = goodsPriceUnitCode;
    params['goodsLossMethod'] = goodsLossMethod;
    params['goodsLossUnitCode'] = goodsLossUnitCode;
    if(goodsLossMethod == 'goods.loss'){
      params['goodsLoss'] = goodsLossValueController2.text ?? '';
    }else if(goodsLossMethod == 'goods.loss.ration'){
      params['goodsLoss'] = goodsLossValueController1.text ?? '';
    }
    params['meterageType'] = meterageTypeList[_meterageTypeIndex]['id'];
    params['clientFreightPrice'] = clientFreightPriceController.text;
    params['clientFreightPriceUnitCode'] = clientPriceValue;
    params['driverPrice'] = driverPriceController.text;
    params['driverPriceUnitCode'] = driverPriceValue;
    params['truckLicenseNo'] = truckLicenseNo;
    params['truckCode'] = truckCode;
    params['licensePlateTypeCode'] = licensePlateTypeCode;
    params['platformTruckCode'] = platformTruckCode;
    if(trailerTruckLicenseNo != ''&& trailerTruckLicenseNo != '请选择'){
      params['trailerTruckLicenseNo'] = trailerTruckLicenseNo;
    }
    if(trailerTruckCode != ''){
      params['trailerTruckCode'] = trailerTruckCode;
    }
    if(platformTrailerTruckCode != ''){
      params['platformTrailerTruckCode'] = platformTrailerTruckCode;
    }
    params['truckPowerType'] = truckPowerTypeList[_truckPowerTypeIndex]['id'];
    if(driverFullName != '' && driverFullName != '请选择'){
      params['driverFullName'] = driverFullName;
    }
    if(driverCode != ''){
      params['driverCode'] = driverCode;
    }
    if(platformDriverCode != ''){
      params['platformDriverCode'] = platformDriverCode;
    }
    if(driverPhone != ''){
      params['driverPhone'] = driverPhone;
    }
    if(driverIdentityNumber != '') {
      params['driverIdentityNumber'] = driverIdentityNumber;
    }
    if(driverLicenseNo != ''){
      params['driverLicenseNo'] = driverLicenseNo;
    }
    if(fuelCardNo != ''){
      params['fuelCardNo'] = fuelCardNo;
    }
    if(viceDriverCode != '') {
      params['viceDriverCode'] = viceDriverCode;
    }
    if(platformViceDriverCode != ''){
      params['platformViceDriverCode'] = platformViceDriverCode;
    }
    if(viceDriverFullName != '' && viceDriverFullName != '请选择'){
      params['viceDriverFullName'] = viceDriverFullName;
    }
    if(viceDriverPhone != ''){
      params['viceDriverPhone'] = viceDriverPhone;
    }
    if(viceDriverIdentityNumber != ''){
      params['viceDriverIdentityNumber'] = viceDriverIdentityNumber;
    }
    if(viceDriverLicenseNo != ''){
      params['viceDriverLicenseNo'] = viceDriverLicenseNo;
    }
    if(payeeDriverFullName != '' && payeeDriverFullName != '请选择'){
      params['payeeDriverFullName'] = payeeDriverFullName;
    }
    if(payeeDriverCode != ''){
      params['payeeDriverCode'] = payeeDriverCode;
    }
    if(payeePlatformDriverCode != ''){
      params['payeePlatformDriverCode'] = payeePlatformDriverCode;
    }
    if(payeeDriverPhone != ''){
      params['payeeDriverPhone'] = payeeDriverPhone;
    }
    if(driverPayeeBankName != ''){
      params['driverPayeeBankName'] = driverPayeeBankName;
    }
    if(driverPayeeBankAccountName != ''){
      params['driverPayeeBankAccountName'] = driverPayeeBankAccountName;
    }
    if(driverPayeeBankAccountNo != '') {
      params['driverPayeeBankAccountNo'] = driverPayeeBankAccountNo;
    }
    if(driverPayeeBankAccountDescription != ''){
      params['driverPayeeBankAccountDescription'] = driverPayeeBankAccountDescription;
    }
    if(payeeViceDriverFullName != '' && payeeViceDriverFullName != '请选择'){
      params['payeeViceDriverFullName'] = payeeViceDriverFullName;
    }
    if(payeeViceDriverCode != ''){
      params['payeeViceDriverCode'] = payeeViceDriverCode;
    }
    if(payeeViceDriverPhone != ''){
      params['payeeViceDriverPhone'] = payeeViceDriverPhone;
    }
    if(viceDriverPayeeBankName != ''){
      params['viceDriverPayeeBankName'] = viceDriverPayeeBankName;
    }
    if(viceDriverPayeeBankAccountName != ''){
      params['viceDriverPayeeBankAccountName'] = viceDriverPayeeBankAccountName;
    }
    if(viceDriverPayeeBankAccountNo != ''){
      params['viceDriverPayeeBankAccountNo'] = viceDriverPayeeBankAccountNo;
    }
    if(viceDriverPayeeBankAccountDescription != ''){
      params['viceDriverPayeeBankAccountDescription'] = viceDriverPayeeBankAccountDescription;
    }
    //运单原始托运方
    params['originalConsignOrgCode'] = orgSelfInfo['code'];
    params['originalConsignOrgName'] = orgSelfInfo['orgName'];
    //平台原始托运方
    params['platformOriginalConsignOrgCode'] = orgSelfInfo['code'];

    if(modelRadioList[modeIndexValue]['id'] == 'self'){
      //托运方
      params['consignOrgCode'] = orgSelfInfo['code'];
      params['consignOrgName'] = orgSelfInfo['orgName'];
      //平台级托运方
      params['platformConsignOrgCode'] = orgSelfInfo['code'];

    }else{
      //托运方
      params['consignOrgCode'] = configInfo['coreOrgCode'];
      params['consignOrgName'] = configInfo['coreOrgName'];
      //平台级托运方
      params['platformConsignOrgCode'] = configInfo['coreOrgCode'];

    }
    if(settleConfigValue1 != ''){
      params['settleConfigValue1'] = settleConfigValue1;
      params['settleConfigUnitCode1'] = settleConfigUnitCode1;
    }
    if(settleConfigValue2 != ''){
      params['settleConfigValue2'] = settleConfigValue2;
      params['settleConfigUnitCode2'] = settleConfigUnitCode2;
    }
    if(settleConfigValue3 != ''){
      params['settleConfigValue3'] = settleConfigValue3;
      params['settleConfigValue3'] = settleConfigValue3;
    }

    postAjax('waybillAdd', params, context).then((res){
      if(res != null && res['code'] == 200){
        Toast.toast(context, '提交成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          Navigator.of(context).pop();
        });
      }
    });
  }
  @override
  void dispose() { 
    scrollController.dispose();
    super.dispose();
  }
}