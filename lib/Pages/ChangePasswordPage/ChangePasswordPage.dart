import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Dto/Auth/ChangePasswordDto.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:mycrm/main.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _changePasswordFormKey =
      new GlobalKey<FormState>();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  bool isloading = false;
  final oldPasswordInputController = TextEditingController();
  final passwordConfirmInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  ChangePasswordDto changePasswordDto = new ChangePasswordDto();
  final url = HttpRequest.baseUrl + 'authentication/ChangePassword';
  bool pwVisible;
  @override
  void initState() {
    super.initState();
    pwVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _changePasswordView,
    );
  }

  Widget changePasswordOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                enabled: !isloading,
                controller: oldPasswordInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(passwordFocus);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Old Password is required';
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
                    labelText: "Old Password",
                    labelStyle: TextStyle(color: Colors.grey)),
                obscureText: !pwVisible,
              ))
            ],
          ),
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
                validator: (value) {
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
        ],
      ),
    );
  }

  Widget get _changePasswordView {
    return SafeArea(
      child: Form(
          key: _changePasswordFormKey,
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
                          alignment: Alignment.center,
                          width: double.infinity,
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
                                      child: Text("Change Password",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(60),
                                              letterSpacing: .6,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    changePasswordOptions(context),
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
            ),
          )),
    );
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
                  color: Theme.of(context).primaryColor,
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
                        if (_changePasswordFormKey.currentState.validate()) {
                          await startChangePasswordRequest();
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

  Future startChangePasswordRequest() async {
    changePasswordDto.oldPassword = oldPasswordInputController.text;
    changePasswordDto.password = passwordInputController.text;
    changePasswordDto.confirmPassword = passwordInputController.text;
    try {
      print('start changePassword');

      await HttpRequest.post(url, changePasswordDto);

      Fluttertoast.showToast(msg: "Password Changed, please login again");
      var token = sp.getString("token");
      var tokenLocalAuth = sp.getString("tokenLocalAuth");
      if (token != null) {
        sp.remove("token");
      }

      if (tokenLocalAuth != null) {
        sp.remove("tokenLocalAuth");
      }

      // Navigator.pushReplacement(context,
      // MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      Navigator.pop(context);
      Navigator.pop(context);
      MainPage.mainPageState.logOurAndMoveToLoginPage();
    } catch (e) {
      if (e is DioError) {
        Fluttertoast.showToast(
            msg: "${e.response.data.toString()}",
            toastLength: Toast.LENGTH_LONG);
      } else {
        Fluttertoast.showToast(
            msg: "${e.toString()}", toastLength: Toast.LENGTH_LONG);
      }
    }
  }
}
