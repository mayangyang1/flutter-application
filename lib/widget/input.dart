import 'package:flutter/material.dart';

Widget input(TextEditingController controller, String hintText, bool enabled, Function change){
  return Container(
    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
    padding: EdgeInsets.only(left: 5.0),
    decoration: BoxDecoration(
      border: Border.all(width: 1.0, color: Color(0XFFCCCCCC)),
      borderRadius: BorderRadius.circular(5.0)
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        disabledBorder: InputBorder.none,
        enabledBorder:InputBorder.none,
        focusedBorder:InputBorder.none,
        hintStyle: TextStyle(color: Color(0xFF8e8e8e))
      ),
      cursorColor: Colors.black,
      enabled: enabled,
      onChanged: (text){
        return change(text);
      },
    ),
  );
}