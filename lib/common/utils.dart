import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

getCookieAndSaveInStorage (res){
  String cookies;
  var  cookiestr = res.headers['set-cookie'].join(';');
  List  cookiesarr = cookiestr.split(';');
  print('cookiestr');
  print(cookiesarr);
  cookiesarr.forEach((item){
    if(item.indexOf('JSESSIONID') != -1){
      var itemar = item.split('=');
      cookies = itemar[itemar.length - 1];
    }
  });
  return cookies;
}

checkedPermission (value) async{//权限校验
 bool  _values = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.getString('roleInfo') != null){
    var roleInfo = json.decode(prefs.getString('roleInfo'));
    List permissionList = roleInfo['permissionCodeList'] ?? [];
    permissionList.forEach((item){
      if(item == value){
        _values = true;
      }
    });
  }
  return _values;
}

Map configLicensePlate = {
  '01': '大型汽车号牌',
  '02': '小型汽车号牌',
  '99': '其他号牌'
};
Map configTruckModel = {
  'H01': '普通货车',
  'H02': '厢式货车',
  'H04': '罐式货车',
  'Q00': '牵引车',
  'G01': '普通挂车',
  'G03': '罐式挂车',
  'G05': '集装箱挂车',
  'H09': '仓栅式货车',
  'H03': '封闭货车',
  'H05': '平板货车',
  'H06': '集装箱车',
  'H07': '自卸货车',
  'H08': '特殊结构货车',
  'Z00': '专项作业车',
  'G02': '厢式挂车',
  'G07': '仓栅式挂车',
  'G04': '平板挂车',
  'G06': '自卸挂车',
  'G09': '专项作业挂车',
  'X91': '车辆运输车',
  'X92': '车辆运输车（单排）'
};

Map configGender = {
  'male': '男',
  'female': '女'
};
Map configFreightStatus = {
  'pushling': '发布中',
  'received': '已接单',
  'finished': '已结束'
};
Map driverAcceptStatus = {
  'undispatched': '待派车',
  'dispatched': '已派车',
  'ignored': '已忽略'
};
Map configSettleMethod = {
  'loadingweight': '按发货货量',
  'unloadingweight': '按收货货量',
  'smaller': '发货与收货两者取小',
  'bigger': '发货与收货两者取大',
  'trucknumber': '按车次'
};
Map configPayStatus = {
  'uncreated': '待支付',
  'pend': '待支付',
  'paid': '已支付',
  'failed': '支付失败'
};
Map configPayChannel = {
  'offline': '线下支付',
  'ljs': '炼金师支付',
  'icbc': '工商银行支付',
  'bsb': '包商银行支付',
};
Map configWaybillStatus = {
  'unloading': '待装货',
  'going': '运输中',
  'finish': '运输完成',
  'cancel': '运单取消'
};
Map configLogisticsStatus = {
  'todo': '待执行',
  'doing': '执行中',
  'finish': '订单完成'
};
Map configBusinessTypeCode = {
  '1002996': '干线普货运输',
  '1003997': '城市配送',
  '1003998': '农村配送',
  '1002998': '集装箱运输',
  '1003999': '其他',
};
Map configCertTruckStatus = {
  'authenticating': '待认证',
  'unauthenticated': '未提交',
  'authenticated': '认证通过',
  'failed': '认证不通过',
};
Map configResourceTruckStatus = {
  'authenticating': '认证中',
  'unauthenticated': '未认证',
  'authenticated': '已认证',
  'failed': '认证失败',
};
Map configMeterageType = {
  'ton' : '吨',
  'cube' : '方',
  'item' : '件',
};
Map<String,String> configPowerTypeMap = {
  'gas': '气车',
  'oil': '油车'
};
Map configGoodsType = {
  '90': '电子产品',
  '92': '商品汽车',
  '93': '冷藏货物',
  '94': '大宗货物',
  '95': '快速消费品',
  '96': '农产品',
  '999': '其他',
};
Map configGoodsLossMethod = {
  'goods.loss.ration': '按系数',
  'goods.loss': '按量'
};
Map configGoodsLossUnitCode = {
  'percent': '‰',
  'ton': '吨/车',
  'cube': '方/车',
  'item': '件/车'
};
Map<String, Map> unit = {
  'cube': {
    'carrier.price': {
      'yuanpersquare': '元/方',
      'yuanpertruck': '元/车',
    },
    'driver.prices': {
      'yuanpercube': '元/方',
      'yuanpertruck': '元/车'
    },
    'driver.price': [
      { 'name': '元/方', 'id': 'yuanpercube' },
      { 'name': '元/车', 'id':'yuanpertruck'}
    ],
    'goods.loss': {
      'cube': '方/车'
    },
    'goods.price': {
      'name': '元/方',
      'id': 'yuanpercube'
    },
    'goods.volume': {
      'cube': '方'
    },
    'settle.volume.unit': {
      'cube': '方'
    },
    'truck.cubage': {
      'cube': '方'
    }
  },
  'day': {
    'route.duration': {
      'day': '天'
    }
  },
  'hour': {
    'route.duration': {
      'hour': '小时'
    }
  },
  'item': {
    'carrier.price': {
      'yuanperitem': '元/件',
      'yuanpertruck': '元/车'
    },
    'driver.prices': {
      'yuanperitem': '元/件',
      'yuanpertruck': '元/车'
    },
    'driver.price': [
      { 'name': '元/件', 'id': 'yuanperitem' },
      { 'name': '元/车', 'id': 'yuanpertruck'}
    ],
    'goods.loss': {
      'item': '件/车'
    },
    'goods.number': {
      'item': '件'
    },
    'goods.price': {
      'name': '元/件',
      'id': 'yuanperitem'
    },
    'settle.volume.unit': {
      'item': '件'
    }
  },
  'km': {
    'mileage.number': {
      'km': '公里'
    },
    'standard.distance': {
      'km': '公里'
    }
  },
  'liang': {
    'truckqty.number': {
      'liang': '辆'
    }
  },
  'meter': {
    'truck.size': {
      'meter': '米'
    }
  },
  'millimetre': {
    'truck.size': {
      'millimetre': '毫米'
    }
  },
  'mm': {
    'tyrewrinkles.number': {
      'mm': '毫米'
    }
  },
  'percent': {
    'goods.loss.ration': {
      'percent': '%'
    }
  },
  'ton': {
    'carrier.price': {
      'yuanperton': '元/吨',
      'yuanpertruck': '元/车'
    },
    'driver.prices': {
      'yuanperton': '元/吨',
      'yuanpertruck': '元/车'
    },
    'driver.price': [
      { 'name': '元/吨', 'id': 'yuanperton' },
      { 'name': '元/车', 'id': 'yuanpertruck'}
    ],
    'goods.loss': {
      'ton': '吨/车'
    },
    'goods.price': {
      'name': '元/吨',
      'id': 'yuanperton'
    },
    'goods.weight': {
      'ton': '吨'
    },
    'settle.volume.unit': {
      'ton': '吨'
    },
    'truck.carry': {
      'ton': '吨'
    },
  },
  'yuan': {
    'price.unit': {
      'yuan': '元'
    }
  }
};

List carTypes = ["请选择","A1", "A2", "A3", "B1", "B2", "C1", "C2"];

const List attachList = ['cardFront', 'cardAfter', 'driverOne', 'driverTwo', 'qualificationCertificateResourceCodeOne', 'qualificationCertificateResourceCodeTwo'];
Map<String, Map> attachments = {
  'cardFront': { 'name': '身份证正面', 'value': 'assets/images/pic.png', 'status': 'hidden', 'resourceCode': '' },
  'cardAfter': { 'name': '身份证反面', 'value': 'assets/images/pic.png', 'status': 'hidden', 'resourceCode': '' },
  'driverOne': { 'name': '驾驶证第一联照片', 'value': 'assets/images/pic.png', 'status': 'hidden', 'resourceCode': '' },
  'driverTwo': { 'name': '驾驶证第二联照片', 'value': 'assets/images/pic.png', 'status': 'hidden', 'resourceCode': '' },
  'qualificationCertificateResourceCodeOne': { 'name': '从业资格证照片一', 'value': 'assets/images/pic.png', 'status': 'hidden', 'resourceCode': '' },
  'qualificationCertificateResourceCodeTwo': { 'name': '从业资格证照片二', 'value': 'assets/images/pic.png', 'status': 'hidden', 'resourceCode': '' },
};

// --------常用正则---start ------------------//
  //手机号 RegExp mobile = new RegExp(r"1[0-9]\d{9}$");
  //登录密码：6~16位数字和字符组合 RegExp mobile = new RegExp(r"(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$");
  //登录密码：6位数字验证码 RegExp mobile = new RegExp(r"\d{6}$");
  // 忽略特殊字符 const _regExp=r"^[\u4E00-\u9FA5A-Za-z0-9_]+$";
  // 只能输数字和小写字母 const _regExp=r"^[Za-z0-9_]+$";
  // 只能输数字和字母 const _regExp=r"^[ZA-ZZa-z0-9_]+$";
  //可以带最多四位小数的数字 RegExp = _number = new RegExp(r"^[0-9]+(.[0-9]{0,4})?$");

// --------常用正则---end ------------------//
