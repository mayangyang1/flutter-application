import 'package:flutter/material.dart';
import './input_widget.dart';

Widget commonInputWidget(TextEditingController controller, String hintText, Function change,{String title,bool enabled}){
    return Container(
      child:Row(
        children: <Widget>[
          Expanded(
            child: inputWidget(controller, hintText, change,enabled: enabled),
            flex: 1,
          ),
          title !=null?
          Padding(child: Text(title),padding: EdgeInsets.only(left: 8))
          : Text(''),
        ]
      ),
    );
  }