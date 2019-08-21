import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


Widget bottomButtomWidget( BuildContext context ,Function beSure){
  return Container(
    width: MediaQuery.of(context).size.width,
    height: ScreenUtil().setHeight(120),
    padding: EdgeInsets.only(left: 10,right:10),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 1,color: Color(0xFFCCCCCC)),
        
      ),
      color: Colors.white
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          child: Text('取消',style: TextStyle(
            fontSize: ScreenUtil().setSp(34)
          ),),
          onTap: (){
            Navigator.of(context).pop();
          },
        ),
        InkWell(
          child: Container(
            width: ScreenUtil().setWidth(160),
            height: ScreenUtil().setHeight(80),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5)
            ),
            child: Center(
              child: Text('确认',style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(34)
              ),),
            ),
          ),
          onTap: beSure
        )
      ],
    ),
  );
}