import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

text2(String title) {
  if(title != ''){
    return Text(
      title,
      style: TextStyle(height: 1.5,fontSize: ScreenUtil().setSp(28)),
    );
  }else{
    return Text('',style: TextStyle(height: 0),);
  }
  
}