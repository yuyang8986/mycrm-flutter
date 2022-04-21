import 'package:flutter/material.dart';
import 'package:mycrm/generalWidgets/subAppBar.dart';

class GeneralAppBar extends AppBar {
  final Function confirmButtonCallback;
  final String titleText;
  final String bottomTitle;
  final GlobalKey<FormState> formKey;

  final GlobalKey<ScaffoldState> scaffholdKey;
  GeneralAppBar(this.bottomTitle, this.titleText, this.formKey, this.scaffholdKey,
      this.confirmButtonCallback);

  Widget create() {
    return AppBar(
      // backgroundColor: Colors.green,
      bottom: confirmButtonCallback == null
          ? null
          : _bottomBarWithConfirmButton(bottomTitle, formKey, scaffholdKey),
      title: Text(titleText),
      centerTitle: true,
      automaticallyImplyLeading: confirmButtonCallback == null?true:false,
    );
  }

  Widget _bottomBarWithConfirmButton(String bottomTitle,
      GlobalKey<FormState> formKey, GlobalKey<ScaffoldState> scaffholdKey) {
    return CustmizedAppBarBottom(bottomTitle, () async {
      confirmButtonCallback();
    });
  }
}
