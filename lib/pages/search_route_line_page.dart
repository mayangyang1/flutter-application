import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../common/service_method.dart';
import '../components/componentsModel.dart';
import '../widget/searchPageWidget/searchBar_widget.dart';
import '../widget/searchPageWidget/bottomButtomWidget.dart';
import '../widget/searchPageWidget/common_refresh_list_widget.dart';


class SearchRouteLinePage extends StatefulWidget {
  @override
  _SearchRouteLinePageState createState() => _SearchRouteLinePageState();
}

class _SearchRouteLinePageState extends State<SearchRouteLinePage> {
  TextEditingController searchController = TextEditingController();
   GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  List comList = [];
  int page = 1;
  int groupValue = -1;
  Map routeLineInfo = {};
  String routeName = '';
  bool _loading = false;
  @override
  void initState() { 
    super.initState();
    _loading = true;
    _getRouteLineList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索线路'),),
      body: ProgressDialog(
        loading: _loading,
        msg: '加载中...',
        child: Container(
          color: Color(0xFFF2F2F2),
          child: Column(
            children: <Widget>[
              searchBar(searchController, '请输入线路名称',(res){
                routeName = res;
                groupValue = -1;
                page = 1;
                comList = [];
                _getRouteLineList();
              }),
              commonList(
                commonRereshListWidget(comList, _headerKey, _footerKey, '暂无线路',(){
                    page++;
                    _getRouteLineList();
                  },(){
                    groupValue = -1;
                    page = 1;
                    comList = [];
                    _getRouteLineList();
                  },
                  commonItem
                ),
                bottomButtomWidget(context, (){
                  if(groupValue >= 0){
                    routeLineInfo = comList[groupValue];
                    Navigator.of(context).pop(routeLineInfo);
                  }else{
                    return Toast.toast(context, '请选择线路');
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
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 6,bottom:6),
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
              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(item['routeName']?? '', style: TextStyle(fontSize: ScreenUtil().setSp(34),),softWrap: true,),
                      Padding(child: null,padding: EdgeInsets.only(top: 6),),
                      Text('发货单位: ${item['loadingOrgName']?? ''}', style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF666666)),softWrap: true,),
                      Padding(child: null,padding: EdgeInsets.only(top: 6),),
                      Text('收货单位: ${item['unloadingOrgName']?? ''}', style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF666666)),softWrap: true,),
                    ],
                  ),
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
  _getRouteLineList() {//获取线路列表
    var stringParams = '?size=20&page=$page';
    if(routeName != ''){
      stringParams +='&routeName=$routeName';
    }
    getAjax('routeLineList', stringParams, context).then((res){
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