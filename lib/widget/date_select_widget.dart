import 'package:flutter/material.dart';
import '../components/date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget dateSelectWidget(String title,BuildContext context, Function change,){
   return InkWell(
      child: Container(
        padding: EdgeInsets.only(top: 10,bottom:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(title,overflow: TextOverflow.ellipsis,textAlign: TextAlign.end,style: TextStyle(
                fontSize: ScreenUtil().setSp(32)
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
       datePicker(context,title, change);
      }
    );
}