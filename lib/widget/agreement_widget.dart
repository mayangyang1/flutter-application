import 'package:flutter/material.dart';

Widget agreementWidget(BuildContext context,bool isAgree,String urlName , Function change, Function urlLaunch){
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
            value: isAgree,
            onChanged: change
          ),
          Text('同意'),
          InkWell(
            child: Text('<<$urlName>>',style:TextStyle(color: Theme.of(context).primaryColor)),
            onTap: urlLaunch,
          )
        ],
      ),
    );
  }