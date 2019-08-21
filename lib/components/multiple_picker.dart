import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
mulitiplePicker(BuildContext context, List truckLengthRequireList,String value, Function success) {
  showDialog(
    context: context,
    builder: (BuildContext context){
      return MultiplePickerDialog(list:truckLengthRequireList,value:value,success: success,);
    }
  );
}
class MultiplePickerDialog extends StatefulWidget{
  final List list;
  final String value;
  final Function success;
  MultiplePickerDialog({Key key, this.list,this.value, this.success}) : super(key: key);
  @override
  _MultiplePickerDialogState createState() => _MultiplePickerDialogState();
}

class _MultiplePickerDialogState extends State<MultiplePickerDialog> {
  List commonList;
  @override
  void initState() { 
    super.initState();
    commonList = widget.list;
    _getCheckedItem();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(bottom: 14),
                color: Colors.white,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        height: ScreenUtil().setHeight(100),
                        alignment: Alignment.centerLeft,
                        color: Theme.of(context).primaryColor,
                        child: Text('选择车长',style: TextStyle(color: Colors.white),),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: Color(0xFFCCCCCC)
                            )
                          )
                        ),
                        child: Wrap(
                          children: commonList.length > 0
                          ? commonList.map((item){
                            return itemModel(context,item);
                          }).toList()
                          : [Text('')]
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            child: Container(
                              width: ScreenUtil().setWidth(200),
                              height: ScreenUtil().setHeight(100),
                              margin: EdgeInsets.only(left:10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xFFCCCCCC)
                                ),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(
                                child: Text('取消',style: TextStyle(
                                  color: Color(0xFF666666)
                                ),),
                              ),
                            ),
                            onTap: (){
                              Navigator.of(context).pop('cancel');
                            },
                          ),
                          InkWell(
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              width: ScreenUtil().setWidth(200),
                              height: ScreenUtil().setHeight(100),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Center(
                                child: Text('确认',style: TextStyle(
                                  color: Colors.white
                                ),),
                              ),
                            ),
                            onTap: (){
                              Navigator.of(context).pop('confirm');
                              _selectItem();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget itemModel( BuildContext context, Map item,){
    return InkWell(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        width: MediaQuery.of(context).size.width/3-20,
        height: ScreenUtil().setHeight(100),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Color(0xFFCCCCCC)
          ),
          borderRadius: BorderRadius.circular(5),
          color: item['check']? Theme.of(context).primaryColor : Colors.white
        ),
        child: Center(
          child: Text(item['value'],style: TextStyle(
            color: item['check']? Colors.white : Color(0xFF454545)
          ),),
        ),
      ),
      onTap: (){
        setState((){
          item['check'] = !item['check'];
        });
      },
    );
  }
  _getCheckedItem() {
    if(widget.value == '' || widget.value == '请选择'){
      return;
    }
    List checkList = widget.value.split(',');
    commonList.forEach((items){
      items['check'] = false;
    });
    commonList.forEach((items){
      checkList.forEach((item){
        if(item == items['value']){
          setState(() {
           items['check'] = true; 
          });
        }
      });
    });
  }
  _selectItem() {
    List list = [];
    String checkValue = '';
    commonList.forEach((item){
      if(item['check']){
        list.add(item['value']);
      }
    });
    checkValue = list.join(',');
    widget.success(checkValue);
  }
  @override
  void dispose() {
    super.dispose();
    commonList = [];
  }
}
