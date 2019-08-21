import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

companyBlockWidget(BuildContext context, Widget startCompany, Widget endCompany) {
  return Container(
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(width: 1,color: Color(0xFFCCCCCC)),bottom: BorderSide(width: 1,color: Color(0xFFCCCCCC)))
    ),
    child: Stack(
      children: <Widget>[
        Positioned(
          top: 30,
          left: 25,
          child: Container(
            height: ScreenUtil().setHeight(240),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(width: 1,color: Color(0xFFF2F2F2)))
            ),
            child: Text(''),
          ),
        ),
        Column(
          children: <Widget>[
            startCompany,
            Padding(child: Divider(),padding: EdgeInsets.only(left: 40),),
            endCompany
          ],
        ),
        // Positioned(
        //   top: 10,
        //   right: 0,
        //   child: Image.asset('assets/images/r.png',width: ScreenUtil().setWidth(180),),
        // ),
      ],
    ),
  );
}
companyBlockItemWidget(BuildContext context, String imageUrl, List<Widget> widgetList) {
  return LimitedBox(
    child: Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 10),
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setHeight(240)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            child: Image.asset('assets/images/$imageUrl.png',width: ScreenUtil().setWidth(60),),
            padding: EdgeInsets.only(right: 5,top: 10)
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgetList
          )
        ],
      ),
    ),
  );
}