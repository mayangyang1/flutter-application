import 'package:flutter/material.dart';
import './single_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/search_page_config.dart';

Widget searchBar(BuildContext context, String type,  List singlePickerList, int index, Function searchChange, Function change,{bool disabledEditeStatus}) {
  return Container(
    height: ScreenUtil().setHeight(120),
    padding: EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(width: 1.0,color: Colors.black26)),
      color: Colors.black12,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: InkWell(
            child: Container(
              height: ScreenUtil().setHeight(75),
              padding: EdgeInsets.only(left: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.search),
                  Text('搜索',style: TextStyle(fontSize: ScreenUtil().setSp(28)),)
                ],
              ),
              
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                return searchPageConfig(type,(res){
                  searchChange(res);
                });
              }));
            },
          )
        ),
        Container(
          margin:EdgeInsets.only(left: 10.0),
          padding: EdgeInsets.only(left: 5),
          width: ScreenUtil().setWidth(190),
          height: ScreenUtil().setHeight(75),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Text(singlePickerList[index]['key'], style: TextStyle(fontSize: ScreenUtil().setSp(26)), overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                ),
                Offstage(
                  offstage: disabledEditeStatus != null && disabledEditeStatus == true ? true : false,
                  child: Icon(Icons.arrow_drop_down),
                )
                
              ],
            ),
            onTap: (){
              if(disabledEditeStatus != null && disabledEditeStatus == true){
                return;
              }
              singlePicker(context, singlePickerList, index,(res){
                if(res['key'] == 'confirm') {
                  change(res);
                }else if(res['key'] == 'cancel') {
                  change(res);
                }
              });
            },
          )
        )
        
      ],
    ),
  );
}
