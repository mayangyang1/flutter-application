import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/input_widget.dart';
Widget searchBar(TextEditingController searchController,String title, Function result) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(140),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFCCCCCC)))
      ),
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(40)
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search),
            Expanded(
              child: inputWidget(searchController, title, result, border: false),
              flex: 1,
            )
          ],
        ),
      ),
    );
  }