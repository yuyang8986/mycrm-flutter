import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Dto/Employee/EmployeeCountDto.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';

class AddEmployeePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddEmployeeState();
  }
}

class _AddEmployeeState extends State<AddEmployeePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ApplicationUser newEmployee = new ApplicationUser();
  bool isManager;
  final formKey = GlobalKey<FormState>();
  EmployeeCountDto employeeCountDto = new EmployeeCountDto();
  ContactListPageBloc contactListPageBloc;

  // @override
  // void dispose() {
  //   // _firstNameController.dispose();
  //   // _lastNameController.dispose();
  //   // _emailController.dispose();
  //   // _workEmailController.dispose();
  //   // _emailController.dispose();
  //   // _phoneController.dispose();
  //   // _workPhoneController.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    isManager = false;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        contactListPageBloc.getEmployeeCount();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    contactListPageBloc =
        contactListPageBloc ?? BlocProvider.of<ContactListPageBloc>(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: GeneralAppBar('Add Employee', 'Contact', formKey, _scaffoldKey,
                confirmButtonCallback)
            .create(),
        body: Container(
            child: CustomStreamBuilder(
                retryCallback: contactListPageBloc.getEmployeeCount,
                stream: contactListPageBloc.employeeCountStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  employeeCountDto = snapshot.data;
                  return newEmployeeContainer();
                })));
  }

  confirmButtonCallback() {
    _autoValidate = true;
    if (employeeCountDto.activeEmployeeCount >=
        employeeCountDto.totalEmployeeCount) {
      DialogService().show(context,
          "You have reach the max accounts availability. Please alter your subscription plan.");
      return;
    }
    if (formKey.currentState.validate()) {
      try {
        postForm();
      } catch (e) {
        locator<ErrorService>().handlePageLevelException(e, context);
      }
    } else {
      final SnackBar snackBar = new SnackBar(
        content: Text('Please fill in all information.'),
        duration: Duration(milliseconds: 3000),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void postForm() async {
    try {
      newEmployee.firstName = _firstNameController.text;
      newEmployee.lastName = _lastNameController.text;
      newEmployee.email = _emailController.text;
      newEmployee.phoneNumber = _phoneController.text;
      newEmployee.isManager = isManager;

      print('begin http request');

      await contactListPageBloc.addEmployee(newEmployee);
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey,
          "Employee Added, dealo has sent a temporary password to employee's email",
          context);
    } catch (e) {
      //Fluttertoast.showToast(msg: "Employee Creation Failed, ${e.toString()}");
      ErrorService().handlePageLevelException(e, context);
    }
  }

  Widget newEmployeeContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            employeeFirstNameRow,
            employeeLastNameRow,
            SizedBox(height: 10),
            emailInputRow,
            SizedBox(height: 10),
            phoneInputRow,
            SizedBox(height: 10),
            setManager,
            showCount,
          ],
        ),
      ),
    );
  }

  Widget get setManager {
    return !HttpRequest.appUser.isAdmin
        ? Container()
        : Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Manager'),
                Checkbox(
                  onChanged: (v) {
                    setState(() {
                      isManager = !isManager;
                    });
                  },
                  value: isManager,
                )
              ],
            ),
          );
  }

  Widget get showCount {
    return !HttpRequest.appUser.isAdmin
        ? Container()
        : Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Account availability: " +
                    employeeCountDto.activeEmployeeCount.toString() +
                    " / " +
                    employeeCountDto.totalEmployeeCount.toString())
              ],
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
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: locator<FormValidateService>().validateEmailNotNull,
              decoration: InputDecoration(labelText: 'Email (Login ID)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get employeeFirstNameRow {
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
              keyboardType: TextInputType.text,
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

  Widget get employeeLastNameRow {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(right: 50), child: Container()),
          Expanded(
            child: TextFormField(
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
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
