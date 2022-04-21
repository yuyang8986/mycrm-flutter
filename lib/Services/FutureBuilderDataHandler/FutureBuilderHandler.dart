import 'package:flutter/material.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/generalWidgets/Infrastructure/NetErrorWidget.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';

class FutureBuilderDataHandler {
  static Widget handle<T>(RepoResponse repoResponse,
      Widget onSuccessReturnWidget, Function onRreshCallBack,
      {Widget noDataDisplay}) {
    if (repoResponse.success) {
      if (repoResponse.model is List) {
        List<T> list = repoResponse.model as List<T>;
        if (list.length == 0) {
          return noDataDisplay ?? NoDataWidget("No Data");
        }
      }
      return onSuccessReturnWidget;
    } else {
      return NetErrorWidget(
        callback: onRreshCallBack,
      );
    }
  }
}
