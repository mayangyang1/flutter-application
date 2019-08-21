const serviceUrl = 'https://rltx2-yfb-gateway.rltx.com';

const servicePath = {
  'apiFreightlist' : '$serviceUrl/freight/freight/list', //货源列表
  'accountLogin' : '$serviceUrl/account/login', //账户登录
  'selfInfo' : '$serviceUrl/person/person/self/info', //用户信息
  'editeSelfInfo' : '$serviceUrl/person/person/self/edit', //编辑用户信息
  'loginOut' : '$serviceUrl/account/logout', //退出登录
  'verifyCode' : '$serviceUrl/account/account/send/verify_code', //获取验证码
  'modifyAccount' : '$serviceUrl/account/account/modify_login_account',//修改手机号
  'modifyPassword' : '$serviceUrl/account/account/modify_password', //修改密码
  'partnerList' : '$serviceUrl/org/partner/list', //伙伴列表
  'transportList' : '$serviceUrl/transport/transport/list', //获取主车列表
  'trailerList' : '$serviceUrl/truck/trailer/list', //获取挂车列表
  'driverList' : '$serviceUrl/person/person/driver/list', //获取司机列表
  'routeLineList' : '$serviceUrl/resource/resource/route/list',//获取线路列表
  'provinceList' : '$serviceUrl/org-config/org-config/province/list', //省列表
  'cityList' : '$serviceUrl/org-config/org-config/city/list', //市列表
  'countyList' : '$serviceUrl/org-config/org-config/county/list', //区列表
  'otherConfig' : '$serviceUrl/platform/platform/core/config/other', //获取登录用户配置信息
  'areaInfo' : '$serviceUrl/person/area/map/get',//获取省市区数据
  'freightAdd' : '$serviceUrl/freight/freight/add',//发布货源
  'orgSelf' : '$serviceUrl/org/org/self', //获取用户信息
  'driverGet' : '$serviceUrl/person/person/driver/null/get',//获取司机信息
  'waybillAdd' : '$serviceUrl/waybill/waybill/add',//新建运单
  'logisticsList' : '$serviceUrl/logistics/logistics/list',//获取订单列表
  'freightList' : '$serviceUrl/freight/freight/list',//获取货源列表
  'waybillList' : '$serviceUrl/waybill/waybill/list',// 货物运单列表
  'updateImage' : '$serviceUrl/waybill/fw/image/update',//上传运单附件
  'freigthAcceptRecord' : '$serviceUrl/freight/freight_accept_record/list',//货源接货记录
  'certTruckList' : '$serviceUrl/platform/cert_truck/list',//认证车辆列表
  'certDriverList' : '$serviceUrl//platform/cert_person/list',//认证司机列表
  'truckList' : '$serviceUrl/transport/transport/list',//资源库车辆列表
  'certTruckApprove' : '$serviceUrl/platform/cert_truck/approve',//车辆认证
  'certDriverApprove' : '$serviceUrl/platform/cert_person/approve',//司机认证

};