import 'package:flutter/material.dart';
import '../../widget/input.dart';
class CertTruckSearchBarPage extends StatefulWidget {
 final Function success;

  CertTruckSearchBarPage({Key key, this.success}) : super(key: key);
  _CertTruckSearchBarPageState createState() => _CertTruckSearchBarPageState();
}

class _CertTruckSearchBarPageState extends State<CertTruckSearchBarPage> {
  TextEditingController truckLicenseNoController = TextEditingController();
  String truckLicenseNo = '';

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
            input(truckLicenseNoController, '请输入车牌号', true,(val){
              setState(() {
               truckLicenseNo = val; 
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
                Map result = { 'truckLicenseNo':truckLicenseNo};
                widget.success(result);
              },
            )
          ],
        )
      ),
    );
  }
}