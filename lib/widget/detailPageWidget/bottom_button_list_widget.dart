import 'package:flutter/material.dart';

bottomButtonListWidget(List<Widget> listWidget) {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    color: Color(0xFFF2F2F2),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: listWidget
    ),
  );
}