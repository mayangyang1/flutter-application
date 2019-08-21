import 'package:flutter/material.dart';
import '../widget/widget_model.dart';
import '../pages/search_customer_page.dart';
import '../pages/search_route_line_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../common/utils.dart';
import '../common/service_method.dart';
import '../components/componentsModel.dart';
import '../config/service_url.dart';
import '../components/progressDialog.dart';

class ReleaseResourcePage extends StatefulWidget {
  final String code;
  ReleaseResourcePage({Key key,this.code});
  @override
  _ReleaseResourcePageState createState() => _ReleaseResourcePageState();
}

class _ReleaseResourcePageState extends State<ReleaseResourcePage> {
  ScrollController scrollerController = ScrollController();
  bool showToTopBtn = false;
  bool goodsLossType = true;//合理货差系数切换
  bool priceTyp = false;
  String logisticsNo = ''; //订单号
  TextEditingController logisticsNoController = TextEditingController();
  String logisticsCode = ''; //订单code
  List modelRadioList = [{'id':'self', 'index': 0, 'title': '自助调车'},{'id':'platform', 'index': 1, 'title': '自助调车'}];
  List waybillDispatchRaidoList = [{'id':'manual', 'index': 0, 'title': '人工确认'},{'id':'auto', 'index': 1, 'title': '自动确认'}];
  int modeIndexValue = 0;
  int dispacthIndexValue = 0;
  List<Map> releaseScopeList = [
    {'key': '全平台','id': 'platform'}
  ];
  int _releaseIndex = 0;
  String scheduleType = 'self';// 调车模式 self为自助 platform 为委托
  String dispatchMode = 'manual';//运单生成方式 auto为自动确认 manual人工确认
  String releaseRange = 'platform';//发布范围 platform为全平台
  String clientOrgName = '请选择';//客户名称
  String clientOrgCode = ''; //客户code
  String platformClientOrgCode = ''; //客户平台级code
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
  String cargoTypeClassificationCode = '';//货物类型code
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

  String goodsWeight = ''; //货物重量
  TextEditingController goodsWeightController = TextEditingController();
  String goodsWeightUnitCode = 'ton';//货物重量单位
  String goodsVolume = '';//货物体积
  TextEditingController goodsVolumeController = TextEditingController();
  String goodsVolumeUnitCode = 'cube';//货物体积单位
  String goodsAmount = ''; //货物数量
  TextEditingController goodsAmountController = TextEditingController();
  String goodsAmountUnitCode = 'item';//货物数量单位
  String truckQty = ''; //需求车次
  TextEditingController truckQtyController = TextEditingController();
  String truckQtyUnitCode = '车';//需求车次单位编码
  String clientFreightPrice = ''; //客户运价
  TextEditingController clientFreightPriceController = TextEditingController();
  String clientFreightPriceUnitCode = ''; //客户运价单位
  List<Map> clientPriceList = unit['ton']['driver.price'];//客户运价单位 默认计量标准为吨
  String clientPriceValue = unit['ton']['driver.price'][0]['id'];//客户运价初始值
  List offerTypeList = [//司机报价类型
    {'id':'quote', 'index': 0, 'title': '司机报价'},
    {'id':'price', 'index': 1, 'title': '一口价'}
  ];
  int _offerTypeIndex = 0;
  String quoteType = 'quote';//司机报价类型 price 一口价 quote 司机报价
  String quotePrice = '';//一口价值
  TextEditingController quotePriceController = TextEditingController();
  List quotePriceList = unit['ton']['driver.price'];//司机报价单位列表
  String quotePriceUnitCode = unit['ton']['driver.price'][0]['id'];//司机报价单位
  String truckModelRequire ='';//车型要求
  List<Map> truckModelRequireList = [//车型列表
    { 'id': "", 'key': "请选择"},
    { 'id': "H01", 'key': "普通货车"},
    { 'id': "H02", 'key': "厢式货车" },
    { 'id': "H04", 'key': "罐式货车" },
    { 'id': "H09", 'key': "仓栅式货车"},
    { 'id': "H03", 'key': "封闭货车" },
    { 'id': "H05", 'key': "平板货车" },
    { 'id': "H06", 'key': "集装箱车" },
    { 'id': "H07", 'key': "自卸货车" },
    { 'id': "H08", 'key': "特殊结构货车"},
    { 'id': "G01", 'key': "普通挂车"},
    { 'id': "G03", 'key': "罐式挂车"},
    { 'id': "G05", 'key': "集装箱挂车"},
    { 'id': "G02", 'key': "厢式挂车"},
    { 'id': "G07", 'key': "仓栅式挂车"},
    { 'id': "G04", 'key': "平板挂车"},
    { 'id': "G06", 'key': "自卸挂车"},
    { 'id': "G09", 'key': "专项作业挂车"},
    { 'id': "Q00", 'key': "牵引车"},
    { 'id': "Z00", 'key': "专项作业车"},
    { 'id': "X91", 'key': "车辆运输车"},
    { 'id': "X92", 'key': "车辆运输车（单排）"}
  ];
  int _truckModelRequireIndex = 0;
  String truckLengthRequire = '请选择'; //车长要求
  List truckLengthRequireList = [
    {'check':false, 'value': '4.2米'},
    {'check':false, 'value': '5米'},
    {'check':false, 'value': '6.2米'},
    {'check':false, 'value': '6.3米'},
    {'check':false, 'value': '6.8米'},
    {'check':false, 'value': '7.2米'},
    {'check':false, 'value': '7.5米'},
    {'check':false, 'value': '7.7米'},
    {'check':false, 'value': '7.8米'},
    {'check':false, 'value': '8米'},
    {'check':false, 'value': '8.7米'},
    {'check':false, 'value': '9.6米'},
    {'check':false, 'value': '12米'},
    {'check':false, 'value': '12.5米'},
    {'check':false, 'value': '13米'},
    {'check':false, 'value': '13.5米'},
    {'check':false, 'value': '16米'},
    {'check':false, 'value': '17.5米'},
  ];
  String contactUserFullName = '';//l联系人
  TextEditingController contactUserFullNameController = TextEditingController();
  String contactPhone = '';//联系电话
  TextEditingController contactPhoneController = TextEditingController();
  String freightEndTime = '';//货源有效期
  String description = '';//备注
  TextEditingController descriptionController = TextEditingController();
  bool isAgree = false;
  var configInfo;//other 配置信息
  var areaInfo;//省市区信息
  var orgSelfInfo;//登录用户信息
  bool _loading = false;
  @override
  void initState() { 
    super.initState();
    freightEndTime = DateTime.now().add(Duration(days: 1)).toString().split('.')[0];
    _getConfigMessage();
    scrollerController.addListener((){
      print(scrollerController.offset);
      if(scrollerController.offset < 1000 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      }else if (scrollerController.offset >= 1000 && !showToTopBtn){
        setState(() {
         showToTopBtn = true; 
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('发布货源'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: SingleChildScrollView(
          controller: scrollerController,
          child: Container(
            child: Column(
              children: <Widget>[
                headerTitleWidget('基本信息'),
                Offstage(
                  offstage: logisticsNoController.text != null && logisticsNoController.text != ''? false : true,
                  child: commonRowWidget(context, false, '订单号:', commonInputWidget(logisticsNoController, '', (res){},enabled: false) ),
                ),
                commonRowWidget(context, true, '吊车模式:', radioWidget( modelRadioList, modeIndexValue, (res){
                  print(res);
                  setState(() {
                  modeIndexValue = res; 
                  });
                },)),
                commonRowWidget(context, true, '运单生成方式:', radioWidget( waybillDispatchRaidoList, dispacthIndexValue, (res){
                  setState(() {
                    dispacthIndexValue = res;
                  });
                  if(res == 1) {//自动派车时
                    setState(() {
                      _offerTypeIndex = 1; 
                      priceTyp = true;
                    });
                  }
                },),width: 240.0),
                commonRowWidget(context, true, '发布范围:', singleSelectWidget(releaseScopeList[_releaseIndex]['key'],context, releaseScopeList, _releaseIndex, (res){
                  if(res['key'] == 'confirm'){
                    setState(() {
                      _releaseIndex = res['value'];
                    });
                  }
                })),
                commonRowWidget(context, true, '客户:', searchWidget(context,clientOrgName,SearchCustomerPage(),(res){
                  print(res);
                  setState(() {
                    clientOrgName = res['orgName'];
                    clientOrgCode= res['code'];
                    platformClientOrgCode = res['orgCode'];
                  });
                })),
                commonRowWidget(context, true, '结算方式:', singleSelectWidget(settleMethodList[_settleIndex]['key'],context, settleMethodList, _settleIndex, (res){
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
                    routeName = res['routeName'];
                    routeCode = res['code']; 
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
                headerTitleWidget('货物信息'),
                commonRowWidget(context, true, '货物类型:', singleSelectWidget(cargoTypeList[_cargoTyepIndex]['key'],context, cargoTypeList, _cargoTyepIndex, (res){
                  if(res['key'] == 'confirm'){
                    setState(() {
                      _cargoTyepIndex = res['value'];
                    });
                  }
                })),
                commonRowWidget(context, true, '货物名称:', commonInputWidget(goodsNameController, '请输入货物名称', (res){},)),
                commonRowWidget(context, true, '计量标准:', radioWidget( meterageTypeList, _meterageTypeIndex, (res){
                  print(unit[meterageTypeList[res]['id']]['driver.price'][0]['id']);
                  setState(() {
                    _meterageTypeIndex = res; 
                    goodsPriceName = unit[meterageTypeList[_meterageTypeIndex]['id']]['goods.price']['name'];//货物单价名称
                    goodsPriceUnitCode = unit[meterageTypeList[_meterageTypeIndex]['id']]['goods.price']['id'];//货物单价单位code
                    cargoUnitName = unit[meterageTypeList[_meterageTypeIndex]['id']]['goods.loss'][meterageTypeList[_meterageTypeIndex]['id']];//合理货差系数单位名

                    clientPriceValue = unit[meterageTypeList[res]['id']]['driver.price'][0]['id'];//客户运价单位
                    clientPriceList = unit[meterageTypeList[res]['id']]['driver.price'];//客户运价单位list

                    quotePriceList = unit[meterageTypeList[res]['id']]['driver.price'];//司机报价单位list
                    quotePriceUnitCode = unit[meterageTypeList[res]['id']]['driver.price'][0]['id'];//司机报价单位

                  });
                  print(clientPriceValue);
                  print(clientPriceList);
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
                commonRowWidget(context, false, '货物重量:', commonInputWidget(goodsWeightController, '请输入货物数量', (res){},title: '吨')),
                commonRowWidget(context, false, '货物体积:', commonInputWidget(goodsVolumeController, '请输入货物体积', (res){},title: '方')),
                commonRowWidget(context, false, '货物数量:', commonInputWidget(goodsAmountController, '请输入货物数量', (res){},title: '件')),
                Padding(child: null,padding: EdgeInsets.only(top: 10)),
                headerTitleWidget('用车需求'),
                commonRowWidget(context, false, '需求车次:', commonInputWidget(truckQtyController, '请输入需求车次', (res){},title: '车')),
                commonRowWidget(
                  context, false, '客户运价:',
                  commonInputSelectButtonWidget(clientFreightPriceController, '请输入客户运价', (res){}, clientPriceList, clientPriceValue, (respon){
                      setState(() {
                        clientPriceValue = respon;
                      });
                    })
                  ),
                commonRowWidget(
                  context, true, '司机报价类型:',
                  radioWidget( offerTypeList, _offerTypeIndex, (res){
                  print(res);
                  setState(() {
                  _offerTypeIndex = res; 
                  priceTyp = !priceTyp;
                  });
                },),width: 240.0
                ),
                commonRowWidget(context, true, '运价:', commonInputSelectButtonWidget(quotePriceController, '请输入一口价', (res){}, quotePriceList, quotePriceUnitCode, (respon){
                  setState(() {
                    quotePriceUnitCode = respon;
                  });
                },offstage: priceTyp)),
                commonRowWidget(context, false, '车型要求:', singleSelectWidget(truckModelRequireList[_truckModelRequireIndex]['key'],context, truckModelRequireList, _truckModelRequireIndex, (res){
                  if(res['key'] == 'confirm'){
                    setState(() {
                      _truckModelRequireIndex = res['value'];
                    });
                  }
                })),
                commonRowWidget(context, false, '车长要求:', mulitipleSelectWidget(context, truckLengthRequireList, truckLengthRequire, (res){
                  setState(() {
                  truckLengthRequire = res; 
                  });
                })),
                commonRowWidget(context, true, '联系人:', commonInputWidget(contactUserFullNameController, '请输入联系人', (res){})),
                commonRowWidget(context, true, '联系电话:', commonInputWidget(contactPhoneController, '请输入联系电话', (res){})),
                commonRowWidget(context, true, '货源有效期:', dateSelectWidget(freightEndTime,context,(res){
                  setState(() {
                    freightEndTime = res;
                  });
                })),
                commonRowWidget(context, false, '备注:', commonInputWidget(descriptionController, '请输入备注', (res){})),
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
                      commonBtnWidget(context, '提交', _releaseResource)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !showToTopBtn? null : FloatingActionButton(
        child: Icon(Icons.arrow_upward),
        onPressed: (){
          scrollerController.animateTo(.0,
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
      orgSelfInfo = json.decode(prefs.getString('orgSelfInfo'));
      int radioIndex;
      modelRadioList.forEach((item){
        if(item['id'] == configInfo['other.defaultScheduleType']){
          radioIndex = item['index'];
        }
      });
      // setState(() {
       contactUserFullNameController.text =  orgSelfInfo['linkmanFullName'] ?? '';
       contactPhoneController.text = orgSelfInfo['linkmanPhone'] ?? '';
       modeIndexValue = radioIndex;
      // });
      _getLogisticsInfo();
    });
  }
  _releaseResource(){
    if(isAgree){//同意协议
      if(configInfo['other.certControl'] == 'TRUE' && orgSelfInfo['certStatus'] != 'authenticated'){//需要去校验企业是否是认证通过
        return Toast.toast(context, '公司未认证，不能开展业务，请先提交认证');
      }
      _freightAdd();
    }else{
      return Toast.toast(context, '请先同意平台交易规则');
    }
  }
  _getLogisticsInfo() {//基于订单发布货源
    if(widget.code == null){
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
        offerTypeList.forEach((item){//司机报价类型
          if(item['id'] == logisticsInfo['driverReferPrice'] ?? 'quote'){
            setState(() {
             _offerTypeIndex = item['index']; 
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
          goodsWeightController.text = logisticsInfo['goodsWeight'] != null ? logisticsInfo['goodsWeight'].toString() : '';
          goodsWeightUnitCode = logisticsInfo['goodsWeightUnitCode'] ?? '';
          goodsVolumeController.text = logisticsInfo['goodsVolume'] != null? logisticsInfo['goodsVolume'].toString() : '';
          goodsVolumeUnitCode = logisticsInfo['goodsVolumeUnitCode'] ?? '';
          goodsAmountController.text = logisticsInfo['goodsNum'] != null ? logisticsInfo['goodsNum'].toString() : '';
          goodsAmountUnitCode = logisticsInfo['goodsNumUnitCode'] ?? '';
          truckQtyController.text = logisticsInfo['truckQty'] != null ? logisticsInfo['truckQty'] : '';
          truckQtyUnitCode = logisticsInfo['truckQtyUnitCode'] ?? '';
          clientFreightPriceController.text = logisticsInfo['clientFreightPrice'] != null ? logisticsInfo['clientFreightPrice'].toString() : '';
          clientFreightPriceUnitCode = logisticsInfo['clientFreightPriceUnitCode'] ?? '';
          quotePriceController.text = logisticsInfo['driverReferPrice'] != null ? logisticsInfo['driverReferPrice'].toString() : '';
          quotePriceList = unit[meterageTypeList[_meterageTypeIndex]['id']]['driver.price'];
          quotePriceUnitCode = logisticsInfo['driverReferPriceUnitCode'] ?? unit[meterageTypeList[_meterageTypeIndex]['id']]['driver.price'][0]['id'];


         
        });

      }
    });
  }
  _freightAdd() {//发布货源
    Map<String, dynamic> params ={};
    if(logisticsCode != '' && logisticsNo != null && logisticsCode != '' && logisticsCode != null){
      params['logisticsNo'] = logisticsNo;
      params['logisticsCode'] = logisticsCode;
    }
    params['status'] = 'pushling';//默认货源新建出来都是发布中
    params['scheduleType'] = modelRadioList[modeIndexValue]['id'];//调车模式
    params['dispatchMode'] = waybillDispatchRaidoList[dispacthIndexValue]['id'];//运单生成方式
    params['releaseRange'] = releaseScopeList[_releaseIndex]['id'];//发布范围
    if(clientOrgCode == ''){
      return Toast.toast(context, '请选择客户');
    }
    params['clientOrgName'] = clientOrgName ?? '';//客户名称
    params['clientOrgCode'] = clientOrgCode ?? '';//客户code
    params['platformClientOrgCode'] = platformClientOrgCode ?? '';//平台级客户code
    if(_settleIndex == 0){
      return Toast.toast(context, '请选择结算方式');
    }
    params['settleMethod'] = settleMethodList[_settleIndex]['id'];//结算方式
    if(routeCode != ''){
      params['routeName'] = routeName;//线路名称
      params['routeCode'] = routeCode;//线路code
    }
    if(standardDistanceController.text != ''){
      params['standardDistance'] = standardDistanceController.text;//标准运距
    }
    params['standardDistanceUnitCode'] = standardDistanceUnitCode;//标准运距code
    if(_businessIndex == 0){
      return Toast.toast(context, '请选择业务类型');
    }
    params['businessTypeCode'] = businessList[_businessIndex]['id'];//业务类型
    params['loadingOrgName'] = loadingOrgNameController.text;//发货单位 
    if(loadingProvinceCode == ''){
      return Toast.toast(context, '请输入发货地');
    }
    params['loadingProvinceCode'] = loadingProvinceCode;//发货省code
    params['loadingCityCode'] = loadingCityCode ?? '';//发货市code
    params['loadingCountyCode'] = loadingCountyCode;//发货区code
    params['loadingAddress'] = loadingAddressController.text;//发货地址
    params['loadingUserFullName'] = loadingUserFullNameController.text;//发货联系人
    params['loadingUserPhone'] = loadingUserPhoneController.text;//发货联系人电话
    params['unloadingOrgName'] = unloadingOrgNameController.text;//收货单位
    if(unloadingProvinceCode == ''){
      return Toast.toast(context, '请选择收货地');
    }
    params['unloadingProvinceCode'] = unloadingProvinceCode;//收货省code
    params['unloadingCityCode'] = unloadingCityCode ?? '';//收货省code
    params['unloadingCountyCode'] = unloadingCountyCode ?? '';//收货省code
    params['unloadingAddress'] = unloadingAddressController.text;//收货地址
    params['unloadingUserFullName'] = unloadingUserFullNameController.text;//收货联系人
    params['unloadingUserPhone'] = unloadingUserPhoneController.text;//收货联系人电话
    if(_cargoTyepIndex == 0){
      return Toast.toast(context, '请选择货物类型');
    }
    params['cargoTypeClassificationCode'] = cargoTypeList[_cargoTyepIndex]['id'];//货物类型
    if(goodsNameController.text == ''){
      return Toast.toast(context, '请输入货物名称');
    }
    params['goodsName'] = goodsNameController.text;//货物名称
    params['meterageType'] = meterageTypeList[_meterageTypeIndex]['id'];//计量标准
    params['goodsPrice'] = goodsPriceController.text;//货物单价
    params['goodsPriceUnitCode'] = goodsPriceUnitCode;//货物单价编码
    params['goodsLossMethod'] = goodsLossMethod;//合理货差系数
    params['goodsLossUnitCode'] = goodsLossUnitCode;//合理货差系数值单位
    if(goodsLossMethod == 'goods.loss.ration'){//按系数
      params['goodsLoss'] = goodsLossValueController1.text;
    }else{
      params['goodsLoss'] = goodsLossValueController2.text;
    }
    params['goodsWeight'] = goodsWeightController.text;//货物重量
    params['goodsWeightUnitCode'] = goodsWeightUnitCode;//货物重量单位
    params['goodsVolume'] = goodsVolumeController.text;//货物体积
    params['goodsVolumeUnitCode'] = goodsVolumeUnitCode;//货物体积单位
    params['goodsAmount'] = goodsAmountController.text;//货物件数
    params['goodsAmountUnitCode'] = goodsAmountUnitCode;//货物件数单位
    if(waybillDispatchRaidoList[dispacthIndexValue]['id'] == 'auto' && truckQtyController.text == ''){
      return Toast.toast(context, '请输入需求车次');
    }
    if(truckQtyController.text != ''){
      params['truckQty'] = truckQtyController.text;
    }
    params['truckQtyUnitCode'] = truckQtyUnitCode;//需求车次code

    params['clientFreightPrice'] = clientFreightPriceController.text;//客户运价；
    params['clientFreightPriceUnitCode'] = clientPriceValue;//客户运价code
    params['quoteType'] = offerTypeList[_offerTypeIndex]['id'];//司机报价类型
    if(offerTypeList[_offerTypeIndex]['id'] == 'price'){//一口价
      if(quotePriceController.text == ''){
        return Toast.toast(context, '请输入运价');
      }
      params['quotePrice'] = quotePriceController.text;
    }
    params['quotePriceUnitCode'] = quotePriceUnitCode;//司机运价单位
    if(_truckModelRequireIndex != 0){
      params['truckModelRequire'] = truckModelRequireList[_truckModelRequireIndex]['id'];//车型要求
    }
    params['truckLengthRequire'] = truckLengthRequire != '请选择'? truckLengthRequire : '';//车长要求
    if(contactUserFullNameController.text == ''){
      return Toast.toast(context, '请输入联系人');
    }
    params['contactUserFullName'] = contactUserFullNameController.text;//联系人
    params['contactPhone'] = contactPhoneController.text;//联系电话
    if(contactPhoneController.text == ''){
      return Toast.toast(context, '请输入联系电话');
    }
    params['freightEndTime'] = freightEndTime;//货源游戏期
    params['description'] = descriptionController.text;//备注

    //运单原始托运方
    params['originalConsignOrgCode'] = orgSelfInfo['code'];
    params['originalConsignOrgName'] = orgSelfInfo['orgName'];
    //平台原始托运方
    params['platformOriginalConsignOrgCode'] = orgSelfInfo['code'];
    
    if(params['scheduleType'] == 'self'){
      //托运方
      params['consignOrgCode'] = orgSelfInfo['code'];
      params['consignOrgName'] = orgSelfInfo['orgName'];
    }else{
      //托运方
      params['consignOrgCode'] = orgSelfInfo['coreOrgCode'];
      params['consignOrgName'] = orgSelfInfo['coreOrgName'];
      //平台级托运方
      params['platformConsignOrgCode'] = orgSelfInfo['coreOrgCode'];

    }

    postAjax('freightAdd', params, context).then((res){
      if(res['code'] == 200){
        Toast.toast(context, '发布成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          Navigator.of(context).pop();
        });
      }
    });
  }
  @override
  void dispose() { 
    scrollerController.dispose();
    super.dispose();
  }
}