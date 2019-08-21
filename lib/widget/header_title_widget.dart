import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

headerTitleWidget(String title) {
  return Container(
    padding: EdgeInsets.only(left: 10),
    height: ScreenUtil().setHeight(100),
    width: double.infinity,
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Color(0xFFF2F2F2)
    ),
    child: Text(title,style: TextStyle(
      fontSize: ScreenUtil().setSp(34),
      color: Color(0xFF777777)
    ),),
  );
}