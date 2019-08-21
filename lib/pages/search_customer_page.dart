import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../common/service_method.dart';
import '../components/componentsModel.dart';
import '../widget/searchPageWidget/searchBar_widget.dart';
import '../widget/searchPageWidget/bottomButtomWidget.dart';
import '../widget/searchPageWidget/common_refresh_list_widget.dart';

class SearchCustomerPage extends StatefulWidget {
  @override
  _SearchCustomerPageState createState() => _SearchCustomerPageState();
}

class _SearchCustomerPageState extends State<SearchCustomerPage> {
  TextEditingController searchController = TextEditingController();
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  List comList = [];
  int page = 1;
  int groupValue = -1;
  Map customeInfo = {};
  String orgName = '';
  bool _loading = false;
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getCustomerList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索客户'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Container(
          color: Color(0xFFF2F2F2),
          child: Column(
            children: <Widget>[
              searchBar(searchController, '请输入客户名称',(res){
                orgName = res;
                groupValue = -1;
                page = 1;
                comList = [];
                _getCustomerList();
              }),
              commonList(
                commonRereshListWidget(comList, _headerKey, _footerKey, '暂无线路',(){
                    page++;
                    _getCustomerList();
                  },(){
                    groupValue = -1;
                    page = 1;
                    comList = [];
                    _getCustomerList();
                  },
                  commonItem
                ),
                bottomButtomWidget(context, (){
                  if(groupValue >= 0){
                    customeInfo = comList[groupValue];
                    Navigator.of(context).pop(customeInfo);
                  }else{
                    return Toast.toast(context, '请选择用户');
                  }
                })  
              ),
            ],
          )
        ),
      ),
    );
  }
  Widget commonList(commonRereshListWidget, bottomButtomWidget) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Padding(
          child:  commonRereshListWidget,
          padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(120)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: bottomButtomWidget,
          )
        ],
      )
    );
  }

  Widget commonItem( int index, Map item) {
    return Material(
      child: InkWell(
        child: Container(
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
              width: 1,
              color: Color(0xFFF2F2F2)
            )),
          ),
          child: Row(
            children: <Widget>[
              Radio(
                groupValue: groupValue,
                value: index,
                onChanged: (value){
                  setState(() {
                  groupValue = value; 
                  });
                },
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(item['orgFullName']?? '', style: TextStyle(fontSize: ScreenUtil().setSp(30)),),
                  ],
                ),
              )
            ],
          ),
        ),
        onTap: (){
          setState(() {
          groupValue = index; 
          });
        },
      ),
      color: Colors.white,
    );
  }
  _getCustomerList() {//获取客户列表
    var stringParams = '?size=20&page=$page';
    if(orgName != ''){
      stringParams +='&orgName=$orgName';
    }
    getAjax('partnerList', stringParams, context).then((res){
      setState(() {
       _loading = false; 
      });
      if(res['code'] == 200 && res['content'].length > 0){
        setState(() {
         comList.addAll(res['content']);
        });
      }else{
        if(res['code'] == 200 && page == 1 && res['content'].length == 0){
          setState(() {
           comList = []; 
          });
        }
      }
    });
  }
}