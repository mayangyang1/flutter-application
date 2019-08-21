 
 import 'package:flutter/material.dart';
 import 'package:flutter_screenutil/flutter_screenutil.dart';
 
 Widget previewImageList(String title, List imageList, Function previewImage) {
  return Container(
    height: ScreenUtil().setHeight(120),
    child: Row(
      children: <Widget>[
        Container(child: Text('$title:',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF888888)),),width: ScreenUtil().setWidth(200)),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: imageList.length > 0
            ? imageList.map((item){
                return InkWell(
                  child: Container(
                    padding: EdgeInsets.only(right: 20),
                    child: Image.network(item,width:ScreenUtil().setWidth(100),height: ScreenUtil().setHeight(80),fit: BoxFit.fill,),
                  ),
                  onTap: (){
                    previewImage(item);
                  },
                );  
              }).toList()
            : <Widget>[
              
            ],
          ),
        )
      ],
    ),
  );
}