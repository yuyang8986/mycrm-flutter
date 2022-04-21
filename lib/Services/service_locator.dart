import 'package:get_it/get_it.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';
import 'NavigationService/NavigationService.dart';
GetIt locator = GetIt();
void setupLocator() {
  locator.registerLazySingleton(()=>NavigationService());
  locator.registerLazySingleton(()=>DialogService());
  locator.registerLazySingleton(()=>ErrorService());
  locator.registerLazySingleton(()=>FormValidateService());

}
