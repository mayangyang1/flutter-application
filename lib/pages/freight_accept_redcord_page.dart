import 'package:flutter/material.dart';
import '../components/progressDialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/service_method.dart';
import '../config/service_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widget/searchPageWidget/common_refresh_list_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/componentsModel.dart';
import '../common/utils.dart';
import './waybill_detail_page.dart';

class FreightAcceptRecordPage extends StatefulWidget {
  final String code;
  FreightAcceptRecordPage({Key key,this.code});
  @override
  _FreightAcceptRecordPageState createState() => _FreightAcceptRecordPageState();
}

class _FreightAcceptRecordPageState extends State<FreightAcceptRecordPage> {
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  var areaInfo;
  Map resourceInfo = {};
  int selectIndex = 2;
  List resourceRecordList = [];
  int ingnoreNum = 0;
  int dispatchNum = 0;
  int needDispatchNum = 0;
  int page = 1;
  String driverAcceptStatus = 'undispatched';
  bool isAdd = true;
  Map dispatchStatus = {
    'ignored': '已忽略',
    'dispatched': '已派',
    'undispatched': '待派',
  };
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getConfigMessage();
    _getRecordList();
    _getStatusRecordList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('接货记录'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF2F2F2),
          ),
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: <Widget>[
              freightMessage(),
              statusBar(),
              acceptRecordList()
            ],
          ),
        ),
      ),
    );
  }
  Widget freightMessage() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('货源号:${resourceInfo['freightNo']}'),
                Text('${resourceInfo['freightEndTime'] != null? resourceInfo['freightEndTime'].toString().substring(0,16) : ''}')
              ],
            ),
            padding: EdgeInsets.only(left: 10,right:10,top: 10),
          ),
          Divider(
            color:Color(0xFFCCCCCC),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                  Container(
                    height: ScreenUtil().setHeight(120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            children: <Widget>[
                              Container(
                                width: ScreenUtil().setWidth(210),
                                child: Text("${resourceInfo['loadingCityCode'] != null ? areaInfo['city'][resourceInfo['loadingCityCode']] : ''} ${resourceInfo['loadingCountyCode'] != null ? areaInfo['county'][resourceInfo['loadingCountyCode']] : ''}",style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
                              ),
                              Image.asset('assets/images/arrows.png'),
                              Container(
                                width: ScreenUtil().setWidth(210),
                                child:Text("${resourceInfo['loadingCityCode'] != null ? areaInfo['city'][resourceInfo['loadingCityCode']] : ''} ${resourceInfo['unloadingCountyCode'] != null ? areaInfo['county'][resourceInfo['unloadingCountyCode']] : ''}",style: TextStyle(fontSize:  ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
                              ),
                            ],
                        ),
                        Padding(
                          child: Row(
                            children: <Widget>[
                              Text('${resourceInfo['goodsName'] ?? ''} '),
                              Text('${resourceInfo['meterageType'] != null && resourceInfo['goodsWeight'] != null? resourceInfo['goodsWeight'].toString() + '吨' : ''}'),
                              Text(' ${resourceInfo['meterageType'] != null && resourceInfo['goodsVolume'] != null? resourceInfo['goodsVolume'].toString() + '方' : ''}'),
                              Text(' ${resourceInfo['meterageType'] != null && resourceInfo['goodsAmount'] != null? resourceInfo['goodsAmount'].toString() + '件' : ''}'),
                              Text('需求: ${resourceInfo['truckQty'] ?? ''}')
                            ],
                          ),
                          padding: EdgeInsets.only(top:10),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          width: 1,
                          color: Color(0xFFCCCCCC)
                        )
                      )
                    ),
                    width: ScreenUtil().setWidth(140),
                    height: ScreenUtil().setHeight(100),
                    child: Center(
                      child: Text(resourceInfo['status'] != null? configFreightStatus[resourceInfo['status']] : '',style: TextStyle(color: Theme.of(context).primaryColor),),
                    )
                  ),
              ],
            ),
            padding: EdgeInsets.only(left: 10, right:10),
          )
        ],
      ),
    );
  }
  Widget statusBar() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: Row(
        children: <Widget>[
          statusBarItem('已忽略',ingnoreNum, 0),
          statusBarItem('已派',dispatchNum, 1),
          statusBarItem('待派',needDispatchNum, 2,),
        ],
      ),
    );
  }
  Widget statusBarItem(String title, int numbers, int type,){
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width/3 -8,
        margin: EdgeInsets.only(left: 6),
        height: ScreenUtil().setHeight(100),
        decoration: BoxDecoration(
          color: selectIndex == type? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: selectIndex == type? Border.all(width: 1,color: Colors.transparent) :Border.all(width: 1,color: Color(0xFFCCCCCC))
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(title,style: TextStyle(color: selectIndex == type? Colors.white : Color(0xFF454545)),),
              Text('(${numbers.toString()})',style: TextStyle(color: selectIndex == type? Colors.white : Color(0xFF454545)),)
            ],
          ),
        ),
      ),
      onTap: (){
        if(selectIndex != type){
          List driverList = ['ignored', 'dispatched', 'undispatched'];
          page = 1;
          setState(() {
            selectIndex = type; 
            driverAcceptStatus = driverList[type];
          });
          resourceRecordList = [];
          _getStatusRecordList();
        }
      },
    );
  }
  Widget acceptRecordList() {
    return Expanded(
      child: commonRereshListWidget(resourceRecordList, _headerKey, _footerKey, '暂无接货记录', (){
        page++;
        _getStatusRecordList();
      }, (){
        page = 1;
        resourceRecordList = [];
        _getStatusRecordList();
      }, itemCardWidget),
    );
  }
  Widget itemCardWidget(index, item) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 10,bottom: 10,right: 10),
      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow:[
          BoxShadow(
            color: Color(0xFFCCCCCC),
            blurRadius: 1.0
          )
        ]
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text('${item['truckLicenseNo'] ?? ''}',style: TextStyle(
                    fontSize: ScreenUtil().setSp(34),
                    fontWeight: FontWeight.bold,
                    height: 1.3
                  ),),
                  Text('${item['regTonnage'] != null? item['regTonnage'].toString() + '吨' : ''}  ${item['truckLength'] != null? item['truckLength'].toString() + '米' : ''}',style: TextStyle(
                    height: 1.2
                  ),)
                ],
              ),
              Padding(child: Text('${item['createTime'] != null? item['createTime'].toString().substring(0,16) : ''}'),padding: EdgeInsets.only(right:10),)
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${item['driverPrice'] ?? ''}${item['meterageType'] != null && item['driverPriceUnitCode'] != null? unit[item['meterageType']]['driver.prices'][item['driverPriceUnitCode']] : ''}',style: TextStyle(height: 1.3,)),
                  Text('${item['driverFullName'] ?? ''}',style: TextStyle(height: 1.3,)),
                  Row(
                    children: <Widget>[
                      Padding(child: Text(item['driverPhone']),padding: EdgeInsets.only(right:4),),
                      InkWell(
                        child: Image.asset('assets/images/tel.png',width:ScreenUtil().setWidth(40)),
                        onTap: ()async{
                          var url = 'tel:${item['driverPhone']}';
                          if(await canLaunch(url)){
                            await launch(url);
                          }else{
                            throw 'Could not launch $url';
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
              Container(
                width: ScreenUtil().setWidth(360),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 1,
                      color: Color(0xFFE2E2E2)  
                    )
                  )
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      child: Text('${dispatchStatus[item['driverAcceptStatus']]}'),
                      padding: EdgeInsets.only(top: 10, bottom:10),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Offstage(
                          offstage: item['driverAcceptStatus'] == 'undispatched'? false : true,
                          child: Padding(
                            child: minButton('忽略',(){
                              showMyCupertinoDialog(context, '提示', '确定忽略该接单记录', (res){
                                if(res == 'confirm'){
                                  _ignoreAcceptRecode();
                                }
                              });
                            }),
                            padding: EdgeInsets.only(right: 10),
                          ),
                        ),
                        Offstage(
                          offstage: item['driverAcceptStatus'] == 'undispatched'? false : true,
                          child: Padding(
                            child: minButton('派车',(){
                              dispatchDialog(item['truckLicenseNo'], item['driverFullName'], item['driverPhone'], item['scheduleType'],(){
                                if(isAdd) {
                                  _addTruckAndDriver(item);
                                }else{
                                  _dispatchTruck(item['code']);
                                }
                                Navigator.pop(context);
                              });
                            },mainColor: true),
                            padding: EdgeInsets.only(right: 10),
                          ),
                        ),
                        Offstage(
                          offstage: item['driverAcceptStatus'] == 'dispatched'? false : true,
                          child:minButton('查看运单',(){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return WaybillDetailPage(code: item['waybillCode'],);
                            })).then((res){
                              page = 1;
                              resourceRecordList = [];
                              _getRecordList();
                              _getStatusRecordList();
                            });
                          },mainColor: true),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  Widget minButton( String title, Function onTap,{bool mainColor}) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left:14,right:14),
        // width: ScreenUtil().setWidth(140),
        height: ScreenUtil().setHeight(70),
        decoration: BoxDecoration(
          color: mainColor == null || mainColor == false? Colors.white : Theme.of(context).primaryColor,
          border: mainColor == null || mainColor == false? Border.all(width: 1,color: Color(0xFFCCCCCC)) : Border.all(width: 1,color: Colors.transparent),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Center(
          child: Text(title,style: TextStyle(
            color: mainColor == null || mainColor == false? Color(0xFF454545) : Colors.white
          ),),
        ),
      ),
      onTap: onTap,
    );
  }
  dispatchDialog(String truckLicenseNo, String driverFullName, String driverPhone, String scheduleType,Function onTap) {
    showDialog(
      context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return SimpleDialog(
                  title: Text('派车提示',textAlign: TextAlign.center,),
                  titlePadding: EdgeInsets.all(10),
                  contentPadding: EdgeInsets.only(bottom: 10),
                  children: <Widget>[
                    Text('确认给以下车辆和司机派车吗?',textAlign: TextAlign.center,style: TextStyle(
                      color: Theme.of(context).primaryColor
                    ),),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1,color: Color(0xFFF2F2F2))
                      ),

                      child: Column(
                        children: <Widget>[
                          Padding(child: Text(truckLicenseNo),padding: EdgeInsets.only(top: 2,bottom:4),),
                          Text('$driverFullName $driverPhone')
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(value: isAdd,onChanged: (res){                  
                          print(res);
                          setState(() {
                            isAdd  = !isAdd;
                          });
                        },),
                        Text('同时把车辆司机添加到我的车辆库')
                      ],
                    ),
                    Padding(
                      child: Row(
                        children: <Widget>[
                          Text('注: 你当前选择的吊车模式是'),
                          Text('${scheduleType == 'platform'? '委托调车' : '自助调车'}',style: TextStyle(
                            color: Theme.of(context).primaryColor
                          ),)
                        ],
                      ),
                      padding: EdgeInsets.only(left:10, right:10),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10,right:10),
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              padding: EdgeInsets.only(top: 4,bottom:4),
                              child: Text('取消'),
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(child: null,padding: EdgeInsets.only(left: 30),),
                          Expanded(
                            child: RaisedButton(
                              padding: EdgeInsets.only(top: 6,bottom:6),
                              color: Theme.of(context).primaryColor,
                              child: Text('确认',style: TextStyle(color: Colors.white),),
                              onPressed: onTap,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              }
            );
          },
        );
  }
  _getConfigMessage()async {//获取配置信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // configInfo = json.decode(prefs.getString('otherConfigs'));
      areaInfo = json.decode(prefs.getString('areaInfo'));
      // orgSelfInfo = json.decode(prefs.getString('orgSelfInfo'));
      _getReourceInfo();
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
  _getRecordList() {//获取接货记录all
    String stringParams = '?size=1000&freightCode=${widget.code}';
    getAjax('freigthAcceptRecord', stringParams, context).then((res){
      if(res['code'] == 200 && res['content'].length >0){
        List recordList = res['content'];
        int num1 = 0;
        int num2 = 0;
        int num3 = 0;
        recordList.forEach((item){
          if(item['driverAcceptStatus'] == 'ignored'){
            num1++;
          }else if(item['driverAcceptStatus'] == 'dispatched'){
            num2++;
          }else if(item['driverAcceptStatus'] == 'undispatched'){
            num3++;
          }
        });
        setState(() {
          ingnoreNum = num1;
          dispatchNum = num2;
          needDispatchNum = num3;
        });
      }
    });
  }
  _getStatusRecordList() {//获取单个状态下的数
    String stringParams = '?page=$page&size=1000&freightCode=${widget.code}&driverAcceptStatus=$driverAcceptStatus';
    getAjax('freigthAcceptRecord', stringParams, context).then((res){
      setState(() {
        _loading = false; 
      });
      if(res['code'] == 200 && res['content'].length > 0){
        setState(() {
          resourceRecordList.addAll(res['content']); 
        });
      }else{
        if(res['code'] == 200 && page == 1 &&  res['content'].length == 0){
          setState(() {
            resourceRecordList = []; 
          });
        }
      }
    });
  }
  _ignoreAcceptRecode() {//忽略接单记录
    postAjaxStr('$serviceUrl/freight/freight_accept_record/${widget.code}/ignored', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '操作成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          setState(() {
            _loading = true; 
          });
          page = 1;
          resourceRecordList = [];
          _getRecordList();
          _getStatusRecordList();
        });
      }
    });
  }
  _dispatchTruck(code) {
    postAjaxStr('$serviceUrl/freight/freight_accept_record/$code/dispatch_applets', {}, context).then((res){
      if(res['code'] == 200) {
        Toast.toast(context, '派车成功');
        Future.delayed(Duration(milliseconds: 1000),(){
          setState(() {
            _loading = true; 
          });
          page = 1;
          resourceRecordList = [];
          _getRecordList();
          _getStatusRecordList();
        });
      }
    });
  }
  _addTruckAndDriver(Map item) {//添加车辆和司机到我的车辆库
    postAjaxStr('$serviceUrl/truck/truck/add/${item['platformTruckCode']}', {}, context).then((res){
      if(res['code'] == 200) {
        _dispatchTruck(item['code'] ?? '');
      }
    });
  }
}