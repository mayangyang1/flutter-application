import 'package:flutter/material.dart';
import '../../components/city_picker.dart';
import '../../widget/input.dart';
class WaybillSearchBarPage extends StatefulWidget {
 final Function success;

  WaybillSearchBarPage({Key key, this.success}) : super(key: key);
  _WaybillSearchBarPageState createState() => _WaybillSearchBarPageState();
}

class _WaybillSearchBarPageState extends State<WaybillSearchBarPage> {
  TextEditingController startAdressController = TextEditingController();
  TextEditingController endAdressController = TextEditingController();
  TextEditingController goodsNameController = TextEditingController();
  TextEditingController trucklincenseNoController = TextEditingController();
  String startAdress;
  String endAdress;
  String waybillNo = '';
  String truckLicenseNo = '';
  Map<String, String> startCodeMap;
  Map<String, String> endCodeMap;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索'),),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              input(goodsNameController, '请输入运单号', true,(val){
                setState(() {
                waybillNo = val; 
                });
              }),
              input(trucklincenseNoController, '请输入车牌号', true,(val){
                setState(() {
                truckLicenseNo = val; 
                });
              }),
              
              InkWell(
                child: input(startAdressController, '请选择发货地', false,(val){}),
                onTap: (){
                  showPicker(context, (res){
                    setState(() {
                      startAdress = res['textValue'];
                      startAdressController.text = startAdress; 
                      startCodeMap = res;
                    });
                    print(startCodeMap);
                  },true);
                },
              ),
              InkWell(
                child: input(endAdressController, '请选择收货地', false,(val){}),
                onTap: (){
                  showPicker(context, (res){
                    setState(() {
                      endAdress = res['textValue'];
                      endAdressController.text = endAdress; 
                      endCodeMap = res;
                    });
                  }, true);
                },
              ),
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
                  Map result = {'startCodeMap': startCodeMap, 'endCodeMap': endCodeMap, 'waybillNo':waybillNo, 'truckLicenseNo': truckLicenseNo};
                  widget.success(result);
                },
              )
            ],
          )
        )
      ),
    );
  }
}