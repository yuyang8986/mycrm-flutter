import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Dto/Auth/ResetPasswordDto.dart';
import 'package:mycrm/Pages/Login/LoginPage.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  ResetPasswordPage({this.email});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ResetPasswordState();
  }
}

class ResetPasswordState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _resetPasswordFormKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final verifyCodeFocus = FocusNode();
  bool isloading = false;
  var emailInputController = TextEditingController();
  final passwordConfirmInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final verifyCodeInputController = TextEditingController();
  ResetPasswordDto resetPasswordDto = new ResetPasswordDto();
  final url = HttpRequest.baseUrl + 'authentication/ResetPassword';
  bool pwVisible;
  @override
  void initState() {
    emailInputController.text = widget.email;
    pwVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _registerView,
    );
  }

  Widget resetPasswordOptions(BuildContext context) {
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
                //focusNode: focus,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(passwordFocus);
                },
                controller: emailInputController,
                validator: locator<FormValidateService>().validateEmailNotNull,
                decoration: new InputDecoration(
                    labelText: "Email *",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
          // VEmptyView(50),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: passwordFocus,
                enabled: !isloading,
                controller: passwordInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(confirmPasswordFocus);
                },
                validator: (value) {
                  Pattern pattern =
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[^]{8,16}$';
                  RegExp regExp = new RegExp(pattern);
                  if (value.isEmpty) {
                    return 'Password is required';
                  }
                  if (!regExp.hasMatch(value)) {
                    return 'Your password need to: \ninclude both lower and upper case characters,\ninclude at least one number, \nat least 8 characters long.';
                  }

                  if (passwordConfirmInputController.text.isNotEmpty) {
                    if (passwordConfirmInputController.text != value) {
                      return 'Password does not match';
                    }
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            pwVisible = !pwVisible;
                          });
                        },
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          pwVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        )),
                    labelText: "New Password *",
                    labelStyle: TextStyle(color: Colors.grey)),
                obscureText: !pwVisible,
              ))
            ],
          ),
          // new Row(
          //   children: <Widget>[
          //     Text(
          //       'Your password need to: \ninclude both lower and upper case characters,\ninclude at least one number, \nat least 8 characters long.',
          //       style: TextStyle(color: Colors.red),
          //     )
          //   ],
          // ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: confirmPasswordFocus,
                enableInteractiveSelection: false,
                enabled: !isloading,
                controller: passwordConfirmInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(verifyCodeFocus);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please confirm Password';
                  }

                  if (passwordConfirmInputController.text.isNotEmpty) {
                    if (passwordInputController.text != value) {
                      return 'Password does not match';
                    }
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            pwVisible = !pwVisible;
                          });
                        },
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          pwVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        )),
                    labelText: "Confirm New Password *",
                    labelStyle: TextStyle(color: Colors.grey)),
                obscureText: !pwVisible,
              ))
            ],
          ),

          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                autofocus: false,
                textInputAction: TextInputAction.next,
                enabled: !isloading,
                focusNode: verifyCodeFocus,
                controller: verifyCodeInputController,
                // onFieldSubmitted: (v) {
                // FocusScope.of(context).requestFocus(focus);
                //},
                decoration: new InputDecoration(
                    labelText: "Verify Code",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget get _registerView {
    return SafeArea(
        child: Form(
      key: _resetPasswordFormKey,
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
                    alignment: Alignment.center,
                    width: double.infinity,
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
                                child: Text("Reset Password",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(60),
                                        letterSpacing: .6,
                                        fontWeight: FontWeight.bold)),
                              ),
                              resetPasswordOptions(context),
                            ],
                          ),
                        )),
                  ),
                  VEmptyView(20),
                  //loginBtn(context),
                  finishBtn(context)
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }

  Widget finishBtn(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor
                  ]),
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
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back',
                  style: TextStyle(
                      color: AppColors.normalTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(44)),
                ),
              )),
          WEmptyView(40),
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor
                  ]),
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
                        if (_resetPasswordFormKey.currentState.validate()) {
                          startResetPasswordRequest();
                        }
                      },
                      child: Center(
                        child: Text(
                          'Finish',
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

  void startResetPasswordRequest() async {
    resetPasswordDto.email = emailInputController.text;
    resetPasswordDto.password = passwordInputController.text;
    resetPasswordDto.confirmPassword = passwordConfirmInputController.text;
    resetPasswordDto.verifyCode = verifyCodeInputController.text;
    try {
      print('start register');
      await HttpRequest.postWithoutToken(url, resetPasswordDto);

      Fluttertoast.showToast(msg: "Password Reset!");

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
