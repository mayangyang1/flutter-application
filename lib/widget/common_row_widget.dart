import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

commonRowWidget(BuildContext context,bool isNeed, String title, Widget widgetModel,{num height, num width} ) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(left: 10, right:10),
    margin: EdgeInsets.only(top: 6),
    height: height!= null? ScreenUtil().setHeight(height) : ScreenUtil().setHeight(100),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[ 
        Container(
          width: width != null ?ScreenUtil().setWidth(width) : ScreenUtil().setWidth(200),
          child:Row(
            children: <Widget>[
              Offstage(
                child: Text('*',style: TextStyle(color: Theme.of(context).primaryColor),),
                offstage: !isNeed,
              ),
              Expanded(
                child: Text(title, style: TextStyle(
                  fontSize: ScreenUtil().setSp(30)
                ),softWrap: true,),
                flex: 1,
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: widgetModel,
        )
      ],
    ),
  );
}