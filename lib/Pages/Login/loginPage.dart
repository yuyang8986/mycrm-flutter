import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Pages/PaymentPage/SubscriptionPurchasePage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/LoadingService/LoadingService.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:flutter/services.dart';
import 'package:mycrm/main.dart';
import 'package:oauth2/oauth2.dart';
import '../Register/RegisterPage.dart';
import '../forgotPassword/forgotPasswordPage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  bool _isSelected = false;
  bool pwVisible;
  final focus = FocusNode();
  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  bool isloading;
  final userNameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  // @override
  // void dispose() {
  //   userNameInputController.dispose();
  //   passwordInputController.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    pwVisible = false;
    super.initState();
    isloading = false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // await sp.clear();
      var enableBioAuth = sp.getBool("enableBioAuth");
      print(enableBioAuth);
      //if (enableBioAuth ?? false) return;

      if (!canCheckBiometrics) {
        //HttpRequest.appUser = null;
        return;
      }

      //var enableBioAuth = sp.getBool("enableBioAuth");
      if ((enableBioAuth ?? false)) {
        try {
          var localAuth = LocalAuthentication();
          var didAuth = await localAuth.authenticateWithBiometrics(
              localizedReason: 'Please authenticate to use Dealo');
          var tokenLocalAuth = sp.getString("tokenLocalAuth");
          if (didAuth && tokenLocalAuth != null) {
            HttpRequest.token = tokenLocalAuth;
            try {
              LoadingService.showLoading(context);
              HttpRequest.appUser = await HttpRequest.fetchAppUserLiveData();
              LoadingService.hideLoading(context);
              if (HttpRequest.appUser.isSubExpired) {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                  // DialogService().show(context,
                  //     "Your Subscription has expired, please renew to continue to use Dealo");
                  return SubscriptionPurchasePage();
                }));
              }
              MainPage.mainPageState.moveFromLoginToDashboard();
            } catch (e) {
              LoadingService.hideLoading(context);
              HttpRequest.appUser = null;
            }
          } else {
            if (didAuth && tokenLocalAuth == null) {
              Fluttertoast.showToast(
                  msg:
                      "Your have not logged in Dealo yet, ${Platform.isAndroid ? "Fingerprint" : "Touch ID"} is enable after you login once",
                  toastLength: Toast.LENGTH_LONG);
            } else if (tokenLocalAuth != null && didAuth) {
              Fluttertoast.showToast(
                  msg:
                      "${Platform.isAndroid ? "Fingerprint" : "Touch ID"} authentication error, please login manually",
                  toastLength: Toast.LENGTH_LONG);
            }
          }
        } on PlatformException catch (pe) {
          Fluttertoast.showToast(msg: "Error: ${pe.message}");
          HttpRequest.appUser = null;
        } catch (e) {
          HttpRequest.appUser = null;
        }
      } else {
        var showBioMessage = sp.getBool("showBioMessage");
        if (showBioMessage ?? false) return;
        var word = Platform.isAndroid ? "Fingerprint" : "Touch ID";
        DialogService().showConfirm(
            context, "Do you want to enable $word to login faster next time?",
            () {
          Navigator.pop(context);
          //Navigator.pop(context);
          sp.setBool("enableBioAuth", true);
          Fluttertoast.showToast(msg: "$word enabled");
        });
        sp.setBool("showBioMessage", true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: _loginView);
  }

  Widget radioButton(bool isSelected) {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(100),
      padding: EdgeInsets.all(2.0),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.black)),
      child: isSelected
          ? Container(
              width: double.infinity,
              height: double.infinity,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.black),
            )
          : Container(),
    );
  }

  Widget get _loginView {
    return Form(
        key: _loginFormKey,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            "assets/logo/logo.png",
                            width: ScreenUtil().setWidth(520),
                            height: ScreenUtil().setHeight(550),
                            filterQuality: FilterQuality.high,
                            alignment: Alignment.topCenter,
                          )
                        ],
                      ),
                      // VEmptyView(100),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil().setHeight(880),
                        child: Container(
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
                                // right: ScreenUtil().setWidth(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(22),
                                    ),
                                    child: Text("Login",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(60),
                                            letterSpacing: .6,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  loginOptions(context),
                                ],
                              ),
                            )),
                      ),
                      VEmptyView(20),

                      VEmptyView(40),

                      Container(
                        width: ScreenUtil().setWidth(400),
                        child: Divider(),
                      ),
                      VEmptyView(20),
                      registerBtn(context)
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget loginOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setHeight(26)),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                height: ScreenUtil().setHeight(220),
                child: TextFormField(
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isloading,
                  controller: userNameInputController,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter Email';
                    }
                    return null;
                  },
                  decoration: new InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
              ))
            ],
          ),
          // VEmptyView(50),
          new Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                height: ScreenUtil().setHeight(220),
                child: TextFormField(
                  focusNode: focus,
                  enabled: !isloading,
                  controller: passwordInputController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password is required';
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
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.grey)),
                  obscureText: !pwVisible,
                ),
              ))
            ],
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              loginBtn(context),
              new Container(
                  //padding: const EdgeInsets.only(top: 15),
                  child: forgotPasswordBtn(context)),
            ],
          )
        ],
      ),
    );
  }

  Widget loginBtn(BuildContext context) {
    return Container(
      width: double.infinity,
      // margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[
          //     GestureDetector(
          //       onTap: _radio,
          //       child: radioButton(_isSelected),
          //     ),
          //     Text(
          //       "Remember me?",
          //       style: TextStyle(color: Colors.black),
          //     ),
          //   ],
          // ),
          Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor
                ]),
                borderRadius: BorderRadius.circular(10),
                // boxShadow: [
                //   BoxShadow(
                //       color: Color(0xFF6078ea).withOpacity(.3),
                //       offset: Offset(0.0, 8.0),
                //       blurRadius: 8.0),
                // ]
              ),
              // margin: EdgeInsets.only(top: 15),
              width: ScreenUtil().setWidth(940),
              height: ScreenUtil().setHeight(150),
              alignment: Alignment.center,
              child: isloading
                  ? CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white))
                  : InkWell(
                      onTap: () async {
                        if (_loginFormKey.currentState.validate()) {
                          startLoginRequest();
                        }
                      },
                      child: Center(
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                              color: AppColors.normalTextColor,
                              fontSize: ScreenUtil().setSp(54),
                              fontWeight: FontWeight.bold),
                        ),
                      )))
        ],
      ),
    );
  }

  void startLoginRequest() async {
    try {
      setState(() {
        isloading = true;
      });

      print('start login');
      HttpRequest request = new HttpRequest();
      var loginResult = await request.initClient(
          userNameInputController.text, passwordInputController.text);

      if (loginResult.success) {
        //MainPage.mainPageState.moveFromLoginToDashboard();
        if (HttpRequest.appUser.isSubExpired) {
          Navigator.pushNamed(context, Routes.subscriptionPage);
          // DialogService().show(context,
          //     "Your Subscription has expired, please renew to continue using Dealo");
          return;
        } else {
          MainPage.mainPageState.moveFromLoginToDashboard();
        }
      } else {
        throw AuthorizationException("error", "login failed", null);
      }
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => MainPage()));
    } catch (e) {
      if (e is AuthorizationException) {
        if (e.error == "Subscription Expired") {
          Navigator.pushNamed(context, Routes.subscriptionPage,
              arguments: e.description);
          // DialogService().show(context,
          //     "Your Subscription has expired, please renew to continue using Dealo");
          return;
        }
        DialogService().show(context, "Wrong Email address or Password, please try again.");
      } else {
        print(e.toString());
        DialogService().show(context, "Login Failed");
      }
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Widget registerBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
                child: RaisedButton(
              color: Colors.grey,
              child: Text(
                'Start Free Trial',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(55),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => RegisterPage()));
              },
            )),
            Text(
              "No Credit Card is required",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        )
      ],
    );
  }

  Widget forgotPasswordBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
                child: FlatButton(
              color: Colors.white,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ForgotPasswordPage()));
              },
            )),
          ],
        )
      ],
    );
  }
}
