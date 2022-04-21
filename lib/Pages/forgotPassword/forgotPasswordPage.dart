import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Dto/Auth/ForgotPasswordDto.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import '../forgotPassword/resetPasswordPage.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _forgetPasswordFormKey =
      new GlobalKey<FormState>();
  String email;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final focus = FocusNode();
  bool isloading = false;
  final emailInputController = TextEditingController();
  ForgotPasswordDto dto = new ForgotPasswordDto();
  final url = HttpRequest.baseUrl + 'authentication/ForgotPassword';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _forgotPasswordView,
    );
  }

  Widget forgotPasswordOptions(BuildContext context) {
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
                  controller: emailInputController,
                  validator:
                      locator<FormValidateService>().validateEmailNotNull,
                  decoration: new InputDecoration(
                    labelText: "Email: *",
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

  Widget get _forgotPasswordView {
    return SafeArea(
        child: Form(
      key: _forgetPasswordFormKey,
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Image.asset(
                  //       "assets/logo/logo.png",
                  //       width: ScreenUtil().setWidth(520),
                  //       height: ScreenUtil().setHeight(450),
                  //       filterQuality: FilterQuality.high,
                  //     )
                  //   ],
                  // ),
                  // VEmptyView(100),
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
                                child: Text("Forgot Password",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(60),
                                        letterSpacing: .6,
                                        fontWeight: FontWeight.bold)),
                              ),
                              forgotPasswordOptions(context),
                            ],
                          ),
                        )),
                  ),
                  VEmptyView(20),
                  //loginBtn(context),
                  sendCodeBtn(context)
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }

  Widget sendCodeBtn(BuildContext context) {
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
                        if (_forgetPasswordFormKey.currentState.validate()) {
                          starForgotPasswordRequest();
                        }
                        setState(() {
                          isloading = false;
                        });
                      },
                      child: Center(
                        child: Text(
                          'SEND CODE',
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

  void starForgotPasswordRequest() async {
    dto.email = emailInputController.text;
    email = emailInputController.text;
    try {
      print("start ForgotPassword");
      await HttpRequest.postWithoutToken(url, dto);
      Fluttertoast.showToast(msg: "Code sent, Please check your email");

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  ResetPasswordPage(email: email)));
    } catch (e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: "${e.response.data.toString()}");
      } else {
        Fluttertoast.showToast(msg: "${e.toString()}");
      }
    }
  }
}
