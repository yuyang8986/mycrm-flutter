import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Dto/Auth/RegisterDto.dart';
import 'package:mycrm/Pages/WebViewPage/WebViewPage.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';

final registerEndpoint =
    Uri.parse("https://mycrmapi.azurewebsites.net/authentication/register");

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = new GlobalKey<FormState>();
  final lastNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final confirmEmailFocus = FocusNode();
  final phoneFocus = FocusNode();
  final companyNameFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  bool isloading = false;
  final firstNameInputController = TextEditingController();
  final lastNameInputController = TextEditingController();
  final emailInputController = TextEditingController();
  final confirmEmailInputController = TextEditingController();
  final phoneInputController = TextEditingController();
  final companyNameInputController = TextEditingController();
  final passwordConfirmInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  RegisterDto newRegister = new RegisterDto();
  final url = HttpRequest.baseUrl + 'authentication/Register';
  bool privacyCheck;
  bool termConditionsCheck;
  bool pwVisible;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _registerView,
    );
  }

  @override
  void initState() {
    privacyCheck = false;
    termConditionsCheck = false;
    pwVisible = false;
    super.initState();
  }

  Widget registerOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                enabled: !isloading,
                controller: firstNameInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(lastNameFocus);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter First Name';
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    labelText: "First Name *",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                textCapitalization: TextCapitalization.words,
                focusNode: lastNameFocus,
                textInputAction: TextInputAction.next,
                enabled: !isloading,
                controller: lastNameInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(emailFocus);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Last Name';
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    labelText: "Last Name *",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: emailFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                enabled: !isloading,
                //focusNode: focus,
                controller: emailInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(confirmEmailFocus);
                },
                validator: locator<FormValidateService>().validateEmailNotNull,
                decoration: new InputDecoration(
                    labelText: "Email *",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: confirmEmailFocus,
                enableInteractiveSelection: false,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                enabled: !isloading,
                //focusNode: focus,
                controller: confirmEmailInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(phoneFocus);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please confirm Email';
                  }

                  if (confirmEmailInputController.text.isNotEmpty) {
                    if (emailInputController.text != value) {
                      return 'Email does not match';
                    }
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    labelText: "Confirm Email *",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: phoneFocus,
                // focusNode: focus,
                textInputAction: TextInputAction.next,
                enabled: !isloading,
                keyboardType: TextInputType.phone,
                controller: phoneInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(companyNameFocus);
                },
                validator: locator<FormValidateService>().validateMobile,
                decoration: new InputDecoration(
                    labelText: "Phone",
                    labelStyle: TextStyle(color: Colors.grey)),
              ))
            ],
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: companyNameFocus,
                textCapitalization: TextCapitalization.words,
                // focusNode: focus,
                textInputAction: TextInputAction.next,
                enabled: !isloading,
                controller: companyNameInputController,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(passwordFocus);
                },
                // validator: (value) {
                //   if (value.isEmpty) {
                //     return 'Please enter Username';
                //   }
                //   return null;
                // },
                decoration: new InputDecoration(
                    labelText: "Company Name",
                    labelStyle: TextStyle(color: Colors.grey)),
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
                    //errorText: 'Your password need to: \ninclude both lower and upper case characters,\ninclude at least one number, \nat least 8 characters long.',
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
                    labelText: "Password *",
                    labelStyle: TextStyle(color: Colors.grey)),
                obscureText: !pwVisible,
              ))
            ],
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                focusNode: confirmPasswordFocus,
                enableInteractiveSelection: false,
                enabled: !isloading,
                controller: passwordConfirmInputController,
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
                    labelText: "Confirm Password *",
                    labelStyle: TextStyle(color: Colors.grey)),
                obscureText: !pwVisible,
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
          key: _registerFormKey,
          child: Stack(
            fit: StackFit.expand,
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
                                  right: ScreenUtil().setWidth(14),
                                  top: ScreenUtil().setWidth(18)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(20),
                                        top: ScreenUtil().setHeight(20)),
                                    child: Text("Register",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(60),
                                            letterSpacing: .6,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  registerOptions(context),
                                ],
                              ),
                            )),
                      ),
                      VEmptyView(10),
                      Container(
                        height: ScreenUtil().setHeight(100),
                        child: CheckboxListTile(
                          onChanged: (v) {
                            setState(() {
                              privacyCheck = v;
                            });
                          },
                          value: privacyCheck,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text("I have read the ",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32))),
                              InkWell(
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: ScreenUtil().setSp(32)),
                                ),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (ctx) {
                                    return WebViewPage(
                                        "https://www.dealo.app/privacy-policy");
                                  }));
                                },
                              ),
                              Text(" and agree.",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32))),
                            ],
                          ),
                        ),
                      ),
                      //loginBtn(context),
                      CheckboxListTile(
                        onChanged: (v) {
                          setState(() {
                            termConditionsCheck = v;
                          });
                        },
                        value: termConditionsCheck,
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("I have read the ",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32))),
                            InkWell(
                              child: Text(
                                "Terms & Conditions",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: ScreenUtil().setSp(32)),
                              ),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (ctx) {
                                  return WebViewPage(
                                      "https://www.dealo.app/terms-of-service");
                                }));
                              },
                            ),
                            Text(" and agree.",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32))),
                          ],
                        ),
                      ),

                      registerBtn(context),
                      VEmptyView(10),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget registerBtn(BuildContext context) {
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
                  gradient: LinearGradient(colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor
                  ]),
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
                        if (!privacyCheck) {
                          Fluttertoast.showToast(
                              msg:
                                  "Please agree to Privacy Policy before submit");
                          return;
                        }
                        if (!termConditionsCheck) {
                          Fluttertoast.showToast(
                              msg:
                                  "Please agree to Terms And Conditions before submit");
                          return;
                        }
                        if (_registerFormKey.currentState.validate()) {
                          startRegisterRequest();
                        }
                      },
                      child: Center(
                        child: Text(
                          'REGISTER',
                          style: TextStyle(
                              color: AppColors.normalTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(44)),
                        ),
                      ))),
          WEmptyView(30),
        ],
      ),
    );
  }

  void startRegisterRequest() async {
    newRegister.email = emailInputController.text;
    newRegister.firstName = firstNameInputController.text;
    newRegister.lastName = lastNameInputController.text;
    newRegister.phone = phoneInputController.text;
    newRegister.organizationName = companyNameInputController.text;
    newRegister.password = passwordInputController.text;
    newRegister.confirmPassword = passwordConfirmInputController.text;
    try {
      print('start register');
      await HttpRequest.postWithoutToken(url, newRegister);
      print("register complete");
      Navigator.pop(context);
      print("nav back");

      Fluttertoast.showToast(msg: "Registration Success!");
    } catch (e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: "${e.response.data.toString()}");
      } else {
        Fluttertoast.showToast(msg: "${e.toString()}");
      }
    }
  }
}
