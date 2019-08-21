import 'package:flutter/material.dart';
import '../components/progressDialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/searchPageWidget/common_refresh_list_widget.dart';
import '../widget/widget_model.dart';
import '../components/search_bar.dart';
import '../common/service_method.dart';
import '../common/utils.dart';
import '../components/componentsModel.dart';
import './vehicle_certification_detail_page.dart';

class VehicleCertificationPage extends StatefulWidget {
  @override
  _VehicleCertificationPageState createState() => _VehicleCertificationPageState();
}

class _VehicleCertificationPageState extends State<VehicleCertificationPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List certTruckList = [];
  String truckLicenseNo = '';
  List<Map> singlePickerList = [
    {'key':'待认证', 'id': 'authenticating'},
    {'key':'未提交', 'id': 'unauthenticated'},
    {'key':'认证通过', 'id': 'authenticated'},
    {'key':'认证不通过', 'id': 'failed'},
  ];
  int _index = 0;
  String certStatus = '';
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getCertTruckList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('车辆认证'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'certTruckList',
              singlePickerList,
              _index,
              (val){//搜索框
                print(val);
                setState(() {
                  truckLicenseNo = val['truckLicenseNo'] ?? '';
                  _loading = true;
                });
                page = 1;
                certTruckList = [];
                _getCertTruckList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  certTruckList = [];
                  _getCertTruckList();
                }
              }
            ),
            Expanded(
              child: commonRereshListWidget(certTruckList, _headerKey, _footerKey, '暂无车辆', (){
                page ++;
                _getCertTruckList();
              }, (){
                page = 1;
                certTruckList = [];
                _getCertTruckList();
              }, itemCardWidget),
            )
          ],
        ),
      ),
    );
  }
  Widget itemCardWidget(int index, Map item){
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.all(10.0),
        // height: 200,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1,color: Color(0XFFCCCCCC)),top: BorderSide(width: 1,color: Color(0xFFCCCCCC))),
          color: Color(0xFFFFFFFF)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            topContent(context,item['truckLicenseNo'] ?? '', item['requestTime'].toString().substring(0,16)),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return VehicleCertificationDetailPage(code: item['code'],);
        })).then((res){
          setState(() {
            _loading = true; 
          });
          page =1;
          certTruckList = [];
          _getCertTruckList();
        });
      },
    );
  }

  Widget topContent(BuildContext context, String truckLicenseNo, String rightTitle) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1,color: Color(0xFFF2F2F2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
           Container(
            width: ScreenUtil().setWidth(400),
            child: Text('车牌号: $truckLicenseNo',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
          ),
          Text(rightTitle,style: TextStyle( fontSize:  ScreenUtil().setSp(32),color: Color(0xFF8E8E8E)),)
        ],
      ),
    ); 
  }
  Widget centerContent(Map item){
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(400),
                child: Text(item['truckModelCode'] != null? configTruckModel[item['truckModelCode']] : '',style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
              ),
              Row(
                children: <Widget>[
                  Text('${item['truckLength'] != null? item['truckLength'].toString() + '米' : ''}' ,style: TextStyle(height: 1.2),),
                  Text('  ${item['regTonnage'] != null? item['regTonnage'].toString() + '吨' : ''}',style: TextStyle(height: 1.2),),
                ],
              ),
              
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(160),
          child: Text( item['certStatus'] != null ? configCertTruckStatus[item['certStatus']] : '',style: TextStyle(color: Theme.of(context).primaryColor),),
        )
      ]
    );
  }
  Widget bottomContent(Map item) {
    return Container(
      height: ScreenUtil().setHeight(100),
      padding: EdgeInsets.only(top: 10),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(
          width: 1,
          color: Color(0xFFF2F2F2)
        ))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Offstage(
            offstage: item['certStatus'] == 'authenticating'? false : true,
            child: minButton(context,'认证', true, (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return VehicleCertificationDetailPage(code: item['code'],);
              })).then((res){
                setState(() {
                 _loading = true; 
                });
                page =1;
                certTruckList = [];
                _getCertTruckList();
              });
            }),
          ),
          Offstage(
            offstage: item['certStatus'] == 'authenticated'? false : true,
            child: minButton(context,'打回', true, (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return VehicleCertificationDetailPage(code: item['code'],);
              })).then((res){
                setState(() {
                 _loading = true; 
                });
                page =1;
                certTruckList = [];
                _getCertTruckList();
              });
            }),
          ),
        ]
      ),
    );
  }
  _getCertTruckList() {//获取订单列表
    certStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size';
    if(certStatus != ''){
      stringParams += '&certStatus=$certStatus';
    }
    if(truckLicenseNo != ''){
      stringParams += '&truckLicenseNo=$truckLicenseNo';
    }
    getAjax('certTruckList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         certTruckList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           certTruckList = []; 
          });
        }
      }
    });
  }
  
}