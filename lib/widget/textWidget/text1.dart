import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

text1(String title) {
  return Text(
    title,
    style: TextStyle(height: 1.7,fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(32)),
  );
}