import 'package:flutter/material.dart';
import '../components/multiple_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget mulitipleSelectWidget(BuildContext context, List list,String value, Function success,){
   return InkWell(
      child: Container(
        padding: EdgeInsets.only(top: 10,bottom:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(value,maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.end,style: TextStyle(
                fontSize: ScreenUtil().setSp(30)
              ),),
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
        mulitiplePicker(context,list,value,success);
      }
    );
}