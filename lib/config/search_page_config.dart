import '../pages/condition_search_page/condition_search_model.dart';
searchPageConfig(String type, Function success){
  switch (type) {
    case 'logisticsSearchPage':
      return LogisticsSearchBarPage(success: success,);
      break;
    case 'resourceSearchPage':
      return ResourceSearchBarPage(success: success,);
      break;
    case 'waybillSearchBarPage':
      return WaybillSearchBarPage(success: success,);
      break;
    case 'certTruckList':
      return CertTruckSearchBarPage(success: success,);
      break;
    case 'certDriverList':
      return CertDriverSearchBarPage(success: success,);
      break;
    case 'truckListPage':
      return TruckListSearchBarPage(success: success,);
      break;
    case 'driverListPage':
      return DriverListSearchBarPage(success: success,);
      break;
    default:
  }
}