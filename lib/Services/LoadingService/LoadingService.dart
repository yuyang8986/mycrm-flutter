import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';

class LoadingService {
  static bool isLoading = false;

  static void showLoading(BuildContext context) {
    if (!isLoading) {
      isLoading = true;
      showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return Align(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.black54,
                  child: LoadingIndicator(),
                ),
              ),
            );
          }).then((v) {
        // 消失的时候把状态置为 false
        isLoading = false;
      });
    }
  }

  static void showAnalysingLoading(BuildContext context, bool isAI) {
    if (!isLoading) {
      isLoading = true;
      showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return Align(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setHeight(200),
                  color: Colors.black54,
                  child: Column(
                    children: <Widget>[
                      Text(isAI? "Advanced AI Analysing...":"Analysing...", style: TextStyle(fontSize: ScreenUtil().setSp(40), color: Colors.white),)
                    ],
                  ),
                ),
              ),
            );
          }).then((v) {
        // 消失的时候把状态置为 false
        isLoading = false;
      });
    }
  }

  static void hideLoading(BuildContext context) async {
    if (isLoading) {
      //await Future.delayed(Duration(milliseconds: 100));
      Navigator.of(context).pop();
    }
  }
}
