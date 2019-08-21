import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget imageTitle(String imgName, String title) {
  return Container(
    height: ScreenUtil().setHeight(100),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image.asset('assets/images/$imgName.png',width: ScreenUtil().setWidth(50),height: ScreenUtil().setHeight(50),),
        Padding(
          child: Text(title,style: TextStyle(
            fontSize: ScreenUtil().setSp(34)
          ),),
          padding: EdgeInsets.only(left:10),
        )
      ],
    ),
  );
}