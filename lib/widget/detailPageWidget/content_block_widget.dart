import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

contentBlockWidget(List<Widget> contentList,{bool borderTop, bool borderBottom}){
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        top: borderTop == null ? BorderSide(width: 1,color: Color(0xFFCCCCCC)) : BorderSide(width: 1,color: Colors.transparent),
        bottom: borderBottom == null ? BorderSide(width: 1,color: Color(0xFFCCCCCC)) : BorderSide(width: 1,color: Colors.transparent)
      ),

    ),
    child: Column(
      children: contentList,
    ),
  ); 
}
contentItemWidget( String title,  value) {
  if(value == ''){
    return Text('',style: TextStyle(height: 0),);
  }else{
    return Container(
      height: ScreenUtil().setHeight(50),
      child: Row(
        children: <Widget>[
          Container(child: Text(title,style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF888888)),),width: ScreenUtil().setWidth(200)),
          Text(value.toString(),style: TextStyle(fontSize: ScreenUtil().setSp(30)),)
        ],
      ),
    );
  }
  
}