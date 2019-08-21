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
import './driver_certification_detail_page.dart';

class DriverCertificationPage extends StatefulWidget {
  @override
  _DriverCertificationPageState createState() => _DriverCertificationPageState();
}

class _DriverCertificationPageState extends State<DriverCertificationPage> {
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  bool _loading = false;
  int page = 1;
  int size = 10;
  List certDriverList = [];
  String fullName = '';
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
    _getCertDriverList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('司机认证'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Column(
          children: <Widget>[
            searchBar(
              context,
              'certDriverList',
              singlePickerList,
              _index,
              (val){//搜索框
                print(val);
                setState(() {
                  fullName = val['fullName'] ?? '';
                  _loading = true;
                });
                page = 1;
                certDriverList = [];
                _getCertDriverList();
              },
              (val){//切换货源
                print(val);
                if(val['key'] == 'confirm'){
                  setState(() {
                    _index = val['value']; 
                    _loading =true;
                  });
                  page = 1;
                  certDriverList = [];
                  _getCertDriverList();
                }
              }
            ),
            Expanded(
              child: commonRereshListWidget(certDriverList, _headerKey, _footerKey, '暂无车辆', (){
                page ++;
                _getCertDriverList();
              }, (){
                page = 1;
                certDriverList = [];
                _getCertDriverList();
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
            topContent(context,item['fullName'] ?? '', item['requestTime'].toString().substring(0,16)),
            centerContent(item),
            bottomContent(item),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return DriverCertificationDetailPage(code: item['code'],);
        })).then((res){
          setState(() {
            _loading = true; 
          });
          page = 1;
          certDriverList = [];
          _getCertDriverList();
        });
      },
    );
  }

  Widget topContent(BuildContext context, String fullName, String rightTitle) {
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
            child: Text('司机姓名: $fullName',style: TextStyle(color:Color(0xFF454545),fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30),height: 1.2),overflow: TextOverflow.ellipsis,),
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
                child: Text(item['requestOrgFullname'] ?? '',style: TextStyle(fontSize: ScreenUtil().setSp(30),height: 1.1),maxLines: 1,overflow: TextOverflow.ellipsis,)
              ),
              Row(
                children: <Widget>[
                  Text('${item['userStatus'] != 'activated'? '已激活' : '未激活'}' ,style: TextStyle(height: 1.2),),
                  Text('  ${item['phone'] ?? ''}',style: TextStyle(height: 1.2),),
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
                return DriverCertificationDetailPage(code: item['code'],);
              })).then((res){
                setState(() {
                 _loading = true; 
                });
                page = 1;
                certDriverList = [];
                _getCertDriverList();
              });
            }),
          ),
          Offstage(
            offstage: item['certStatus'] == 'authenticated'? false : true,
            child: minButton(context,'打回', true, (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return DriverCertificationDetailPage(code: item['code'],);
              })).then((res){
                setState(() {
                 _loading = true; 
                });
                page = 1;
                certDriverList = [];
                _getCertDriverList();
              });
            }),
          ),
        ]
      ),
    );
  }
  _getCertDriverList() {//获取司机认证列表
    certStatus = singlePickerList[_index]['id'];
    String stringParams = '?page=$page&size=$size';
    if(certStatus != ''){
      stringParams += '&certStatus=$certStatus';
    }
    if(fullName != '') {
      stringParams += '&fullName=$fullName';
    }
    getAjax('certDriverList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res != null && res['code'] == 200 && res['content'].length > 0) {
        setState(() {
         certDriverList.addAll(res['content']); 
        });
      }else{
        if(page == 1 && res['code'] == 200 && res['content'].length == 0){
          setState(() {
           certDriverList = []; 
          });
        }
      }
    });
  }
  
}