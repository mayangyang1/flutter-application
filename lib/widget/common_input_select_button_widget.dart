import 'package:flutter/material.dart';
import './input_widget.dart';
import '../components/select_button.dart';

Widget commonInputSelectButtonWidget(TextEditingController controller, String hintText, Function change,List list, String selectValue, Function result,{bool offstage}){
    return Container(
      child:Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          offstage != null && offstage == false
          ? Padding(
            child: null,
            padding: EdgeInsets.only(left: 0),
          )
          :Expanded(
              child: inputWidget(controller, hintText, change),
              flex: 1,
           ) ,
          Padding(
            child: null,
            padding: EdgeInsets.only(left: 6),
          ),
          selectButton(list, selectValue, result,)
        ]
      ),
    );
  }