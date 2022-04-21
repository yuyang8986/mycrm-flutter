import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/NavigationService/NavigationService.dart';

import '../service_locator.dart';

class ErrorService {
  void handleErrorResult(Response response, BuildContext context) {
    if (response.statusCode == 401) {
      locator<DialogService>().show(context, Constants.httpNotAuthorized);
    } else if (response.statusCode == 403) {
      locator<NavigationService>().navigateTo(Routes.loginPage);
    } else if (response.statusCode == 404) {
      locator<DialogService>().show(context, Constants.httpNotFound);
    }
  }

  void handlePageLevelException(dynamic e, BuildContext context) {
    print(e.toString());
    if (e is DioError) {
      if (e.response.statusCode == 401 || e.response.statusCode == 403) {
        DialogService().show(context, Constants.httpNotAuthorized);
      } else if (e.response.statusCode == 404) {
        DialogService().show(context, e.response.data.toString());
      } else {
        DialogService().show(context, e.response.data.toString());
      }
    } else {
      DialogService().show(context, e.toString());
    }

    //Navigator.pop(context);
  }
}
