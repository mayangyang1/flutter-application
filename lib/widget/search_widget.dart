import 'package:flutter/material.dart';

 searchWidget( BuildContext context,String title, Widget navigatorPage, Function result){
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(top: 10,bottom:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(title,softWrap: true,textAlign: TextAlign.end,),
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
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return navigatorPage;
        })).then(result);
      }
    );
  }