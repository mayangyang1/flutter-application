import 'package:flutter/material.dart';
import '../../components/city_picker.dart';
import '../../widget/input.dart';
class ResourceSearchBarPage extends StatefulWidget {
 final Function success;

  ResourceSearchBarPage({Key key, this.success}) : super(key: key);
  _ResourceSearchBarPageState createState() => _ResourceSearchBarPageState();
}

class _ResourceSearchBarPageState extends State<ResourceSearchBarPage> {
  TextEditingController startAdressController = TextEditingController();
  TextEditingController endAdressController = TextEditingController();
  TextEditingController goodsNameController = TextEditingController();
  String startAdress;
  String endAdress;
  String freightNo = '';
  Map<String, String> startCodeMap;
  Map<String, String> endCodeMap;
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
            input(goodsNameController, '请输入货源号', true,(val){
              setState(() {
               freightNo = val; 
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
                Map result = {'startCodeMap': startCodeMap, 'endCodeMap': endCodeMap, 'freightNo':freightNo};
                widget.success(result);
              },
            )
          ],
        )
      ),
    );
  }
}