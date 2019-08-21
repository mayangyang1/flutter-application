import 'package:flutter/material.dart';
import '../../widget/input.dart';
class TruckListSearchBarPage extends StatefulWidget {
 final Function success;

  TruckListSearchBarPage({Key key, this.success}) : super(key: key);
  _TruckListSearchBarPageState createState() => _TruckListSearchBarPageState();
}

class _TruckListSearchBarPageState extends State<TruckListSearchBarPage> {
  TextEditingController truckLicenseNoController = TextEditingController();
  TextEditingController driverFullNameController = TextEditingController();
  String truckLicenseNo = '';
  String driverFullName = '';
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
            input(driverFullNameController, '请输入司机姓名', true,(val){
              setState(() {
               driverFullName = val; 
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
                Map result = { 'truckLicenseNo':truckLicenseNo,'driverFullName': driverFullName};
                widget.success(result);
              },
            )
          ],
        )
      ),
    );
  }
}