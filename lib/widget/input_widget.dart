import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget inputWidget(TextEditingController controller, String hintText, Function change, {String imgUrl,bool obscureText,bool enabled,String inputType,bool border, String align}) {
  return Container(
    padding: EdgeInsets.only(left: 5.0),
    decoration: BoxDecoration(
      border: border != null && !border? Border.all(color: Colors.transparent): Border.all(width: 1.0, color: Color(0xFFCCCCCC)),
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: Row(
      children: <Widget>[
        imgUrl != null
        ? Image.asset(imgUrl,width: ScreenUtil().setWidth(60),)
        : Container(child: null,),
        imgUrl != null
        ? Padding(child: null,padding: EdgeInsets.only(left: 10),)
        : Container(child: null,),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: align != null && align == 'center'? TextAlign.center : TextAlign.start,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.0),
                borderSide: BorderSide(color: Colors.transparent)
              ),
              disabledBorder: InputBorder.none,
              enabledBorder:InputBorder.none,
              focusedBorder:InputBorder.none
            ),
            cursorColor: Colors.black,
            obscureText: obscureText !=null? obscureText : false,
            enabled: enabled !=null? enabled : true,
            keyboardType: inputType != null && inputType == 'number'? TextInputType.number : TextInputType.text,
            onChanged: (text){
              return change(text);
            },
          ),
        )
      ],
    ),
  );
}