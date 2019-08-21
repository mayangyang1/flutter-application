import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget commonBtnWidget(BuildContext context, String title, Function onTap,{bool mainColor}) {
  return InkWell(
    child: Container(
      // width: double.infinity,
      height: ScreenUtil().setHeight(100),
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(20) , left: ScreenUtil().setHeight(20),right: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
        color: mainColor == null || mainColor == true ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: mainColor == null || mainColor == true ? Border.all(width: 1,color: Colors.transparent) : Border.all(width: 1,color: Color(0xFFCCCCCC)),
        boxShadow: [
          BoxShadow(
            offset: Offset(2, 2),
            color: Color(0xFFCCCCCC)
          )
        ]
      ),
      child: Center(
        child: Text(title, style:TextStyle(
          fontSize: ScreenUtil().setSp(36),
          color: mainColor == null || mainColor == true ? Colors.white : Color(0xFF454545))
        ),
      ),
    ),
    onTap: onTap,
  );
}