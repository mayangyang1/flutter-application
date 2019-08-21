import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget commonRereshListWidget(List comList, GlobalKey _headerKey, GlobalKey _footerKey, String title, Function loadMore, Function  onRefresh, Function commonItem) {
    return EasyRefresh(
      child: comList.length > 0
      ?ListView.builder(
          itemCount: comList.length,
          itemBuilder: (BuildContext context, int index) {
          return commonItem(index,comList[index]);
        },
      )
      : Center(child: Padding(child: Text(title,style: TextStyle(fontSize: ScreenUtil().setSp(40)),),padding: EdgeInsets.only(top: 200))),
      loadMore: loadMore,
      onRefresh: onRefresh,
      refreshFooter: ClassicsFooter(
        key: _footerKey,
        bgColor: Colors.white,
        textColor: Colors.black26,
        moreInfoColor: Colors.black26,
        showMore: false,
        noMoreText: '完成',
        moreInfo: ' ',
        loadText: '上拉加载',
        loadReadyText: '上拉加载',
        loadedText: '加载完成',
        loadingText: '加载中'
      ),
      refreshHeader: ClassicsHeader(
        key: _headerKey,
        bgColor: Colors.white,
        textColor: Colors.black26,
        moreInfoColor: Colors.black26,
        showMore: true,
        moreInfo: '加载中',
        refreshReadyText: '下拉刷新',
        refreshedText: '刷新完成',
      ),
    );
  }