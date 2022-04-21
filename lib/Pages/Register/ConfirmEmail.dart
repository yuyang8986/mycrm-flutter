import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';

class ConfirmEmailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ConfirmEmailState();
  }
}

class ConfirmEmailState extends State<ConfirmEmailPage> {
  final GlobalKey<FormState> _confirmEmailFormKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isloading = false;
  final codeInputController = TextEditingController();

  final url = HttpRequest.baseUrl + 'authentication/ConfirmEmail/';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _confirmEmailView,
    );
  }

  Widget confirmEmailOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  enabled: !isloading,
                  controller: codeInputController,
                  decoration: new InputDecoration(
                    labelText: "Verify Code:*",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _confirmEmailView {
    return SafeArea(
        child: Form(
      key: _confirmEmailFormKey,
      child: Center(
          child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    // height: ScreenUtil().setHeight(1500),
                    child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(30)),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.0, 15.0),
                                  blurRadius: 15),
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.0, -10.0),
                                  blurRadius: 10)
                            ]),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(14),
                              right: ScreenUtil().setWidth(14),
                              top: ScreenUtil().setWidth(18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(20),
                                    top: ScreenUtil().setHeight(20)),
                                child: Text(
                                    "Please check your email and enter verify code",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(60),
                                        letterSpacing: .6,
                                        fontWeight: FontWeight.bold)),
                              ),
                              confirmEmailOptions(context),
                            ],
                          ),
                        )),
                  ),
                  VEmptyView(20),
                  //loginBtn(context),
                  confirmBtn(context)
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }

  Widget confirmBtn(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  // gradient: LinearGradient(colors: [
                  //   Colors.red[200],
                  //   Theme.of(context).primaryColor
                  // ]),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFF6078ea).withOpacity(.3),
                        offset: Offset(0.0, 8.0),
                        blurRadius: 8.0),
                  ]),
              // margin: EdgeInsets.only(top: 15),
              width: ScreenUtil().setWidth(350),
              height: ScreenUtil().setHeight(150),
              alignment: Alignment.center,
              child: isloading
                  ? LoadingIndicator()
                  : InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Text(
                          'BACK',
                          style: TextStyle(
                              color: AppColors.normalTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(44)),
                        ),
                      ))),
          WEmptyView(30),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  // gradient: LinearGradient(colors: [
                  //   Colors.red[200],
                  //   Theme.of(context).primaryColor
                  // ]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFF6078ea).withOpacity(.3),
                        offset: Offset(0.0, 8.0),
                        blurRadius: 8.0),
                  ]),
              // margin: EdgeInsets.only(top: 15),
              width: ScreenUtil().setWidth(350),
              height: ScreenUtil().setHeight(150),
              alignment: Alignment.center,
              child: isloading
                  ? LoadingIndicator()
                  : InkWell(
                      onTap: () async {
                        setState(() {
                          isloading = true;
                        });
                        if (_confirmEmailFormKey.currentState.validate()) {
                          startConfirmEmailRequest();
                        }
                        setState(() {
                          isloading = false;
                        });
                      },
                      child: Center(
                        child: Text(
                          'CONFIRM',
                          style: TextStyle(
                              color: AppColors.normalTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(44)),
                        ),
                      ))),
        ],
      ),
    );
  }

  void startConfirmEmailRequest() async {
    try {
      print("start ForgotPassword");
      String confirmUrl = url + codeInputController.text;
      await HttpRequest.post(confirmUrl, null);
      Fluttertoast.showToast(msg: "Email confirmed");
      HttpRequest.appUser = await HttpRequest.fetchAppUserLiveData();
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: "${e.response.data.toString()}");
      } else {
        Fluttertoast.showToast(msg: "${e.toString()}");
      }
    }
  }
}
