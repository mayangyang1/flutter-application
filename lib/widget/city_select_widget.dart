import 'package:flutter/material.dart';
import '../components/city_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget citySelectWidget(String title,BuildContext context, Function change, bool showArea){
   return InkWell(
      child: Container(
        padding: EdgeInsets.only(top: 10,bottom:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(title,overflow: TextOverflow.ellipsis,textAlign: TextAlign.end,style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                
              ),),
              flex: 1,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Color(0xFF454545),
            )
          ],
        ),
      ),
      onTap: (){
        showPicker(context, change, showArea,);
      }
    );
}