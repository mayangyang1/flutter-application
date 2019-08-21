import 'package:flutter/material.dart';
import '../components/single_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget singleSelectWidget(String title, BuildContext context, List<Map> list, int index, result ){
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(top:10,bottom:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(title,overflow: TextOverflow.ellipsis,style: TextStyle(
              fontSize: ScreenUtil().setSp(30)
            ),),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Color(0xFF454545),
            )
          ],
        ),
      ),
      onTap: (){
        singlePicker(context, list, index, result);
      }
    );
  }