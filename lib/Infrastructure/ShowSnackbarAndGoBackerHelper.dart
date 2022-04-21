import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowSnackBarAndGoBackHelper {
  static go(GlobalKey<ScaffoldState> scaffoldKey, String message,
      BuildContext context, {dynamic data}) async {
    Fluttertoast.showToast(msg: message);
    //await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context, data);
  }
}
