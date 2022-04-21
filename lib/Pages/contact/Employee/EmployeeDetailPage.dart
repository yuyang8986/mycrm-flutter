import 'package:flutter/material.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/infrastructure/TextHelper.dart';

class EmployeeDetailPage extends StatefulWidget {
  @override
  _EmployeeDetailPageState createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  ApplicationUser employee;
  @override
  Widget build(BuildContext context) {
    employee = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: GeneralAppBar(null, 'Employee Info', null, null, null).create(),
      body: _employeeDetailContainer,
    );
  }

  Widget get _employeeDetailContainer {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.grey[350],
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: Text(
                  TextHelper.checkTextIfNullReturnEmpty(
                      '${employee.firstName.toUpperCase().substring(0, 1)}'),
                  style: TextStyle(
                      color: AppColors.normalTextColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(employee.name + (employee.isManagerFromRoles?" (Manager)":"")),
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Email Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(TextHelper.checkTextIfNullReturnTBD(employee.email)),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Contact Number:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(TextHelper.checkTextIfNullReturnTBD(employee.phoneNumber)),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Account Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(employee.isActive ? "Active" : "Disabled"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
