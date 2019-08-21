import 'package:flutter/material.dart';
import '../../widget/input.dart';
class CertDriverSearchBarPage extends StatefulWidget {
 final Function success;

  CertDriverSearchBarPage({Key key, this.success}) : super(key: key);
  _CertDriverSearchBarPageState createState() => _CertDriverSearchBarPageState();
}

class _CertDriverSearchBarPageState extends State<CertDriverSearchBarPage> {
  TextEditingController fullNameController = TextEditingController();
  String fullName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索'),),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            input(fullNameController, '请输入司机姓名', true,(val){
              setState(() {
               fullName = val; 
              });
            }),
            InkWell(
              child: Container(
                width: 200.0,
                height: 50.0,
                margin: EdgeInsets.only(top: 20.0),
               decoration: BoxDecoration(
                 color: Theme.of(context).primaryColor,
                 borderRadius: BorderRadius.circular(5.0)
               ),
                child: Center(
                  child: Text('搜索',style: TextStyle(color: Colors.white,fontSize: 16.0),),
                )
              ),
              onTap: (){
                Navigator.of(context).pop();
                Map result = { 'fullName':fullName};
                widget.success(result);
              },
            )
          ],
        )
      ),
    );
  }
}