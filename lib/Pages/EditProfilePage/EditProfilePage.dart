import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/httpRequest.dart' as prefix0;
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:mycrm/infrastructure/ShowSnackbarAndGoBackerHelper.dart';

import '../../main.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfilePage> {
  bool isInit;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isActive;
  bool isloading = false;
  bool _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppUser user;
  final formKey = GlobalKey<FormState>();
  ContactListPageBloc contactListPageBloc;
  final url = HttpRequest.baseUrl + 'user';
  @override
  void dispose() {
    // _firstNameController.dispose();
    // _lastNameController.dispose();
    // _emailController.dispose();
    // _workEmailController.dispose();
    _emailController.dispose();
    // _phoneController.dispose();
    // _workPhoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = HttpRequest.appUser;
    if (isInit) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      isInit = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      key: _scaffoldKey,
      body: selectedEmployeeContainer(),
    );
  }

  void postForm() async {
    try {
      user.firstName = _firstNameController.text;
      user.lastName = _lastNameController.text;
      user.phone = _phoneController.text;

      print('start put user profile');
      await HttpRequest.put(url, user.toJson());

      Fluttertoast.showToast(msg: "Profile Changed!");
      HttpRequest.appUser = await HttpRequest.fetchAppUserLiveData();
      Navigator.pop(context);
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
    //ErrorService().handlePageLevelException(e, context);
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
                        if (formKey.currentState.validate()) {
                          postForm();
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

  Widget selectedEmployeeContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            userFirstNameRow,
            userLastNameRow,
            SizedBox(height: 10),
            emailInputRow,
            SizedBox(height: 10),
            phoneInputRow,
            SizedBox(height: 10),
            finishBtn(context),
          ],
        ),
      ),
    );
  }

  Widget get phoneInputRow {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.phone,
              size: 35,
              color: Colors.green[600],
            ),
          ),
          Expanded(
            child: TextFormField(
              inputFormatters: <TextInputFormatter>[
                //WhitelistingTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.phone,
              validator: locator<FormValidateService>().validateMobile,
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
          )
        ],
      ),
    );
  }

  Widget get emailInputRow {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.local_post_office,
              size: 35,
              color: Colors.purple,
            ),
          ),
          Expanded(
            child: TextFormField(
              enabled: false,
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get userFirstNameRow {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.person_outline,
              size: 35,
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: _firstNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter First Name.';
                }
                if (value.length > 20) {
                  return 'Name length exceed max allowed.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'First name'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get userLastNameRow {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(right: 50), child: Container()),
          Expanded(
            child: TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: _lastNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Last Name.';
                }
                if (value.length > 20) {
                  return 'Name length exceed max allowed.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
          )
        ],
      ),
    );
  }
}
