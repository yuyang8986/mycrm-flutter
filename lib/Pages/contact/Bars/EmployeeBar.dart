import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/contact/Employee/EmployeeAddPage.dart';
import 'package:mycrm/Pages/contact/Employee/EmployeeEditPage.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Shared/AppFloatingActionButton.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';
import 'package:mycrm/services/UrlSchemeService/UrlSchemeService.dart';
import '../../../Models/Constants/Constants.dart';

class EmployeeTabBarPage extends StatefulWidget {
  final ContactListPageBloc contactListPageBloc;

  EmployeeTabBarPage(this.contactListPageBloc);
  @override
  State<StatefulWidget> createState() {
    return EmployeeTabBarPageState();
  }
}

class EmployeeTabBarPageState extends State<EmployeeTabBarPage> {
  ContactListPageBloc contactListPageBloc;
  bool isInit;

  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      contactListPageBloc = widget.contactListPageBloc;
      contactListPageBloc.getAllEmployees();
      isInit = false;
    }

    return Scaffold(
      floatingActionButton: _addEmployeeButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
          child: CustomStreamBuilder(
              retryCallback: contactListPageBloc.getAllEmployees,
              stream: contactListPageBloc.allEmployeesStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // if (snapshot.hasError) return ErrorPage((){

                // });
                // if (!snapshot.hasData) return LoadingIndicator();
                var employeeList = snapshot.data as List<ApplicationUser>;
                return employeeListTileRow(employeeList);
              })),
    );
  }

  Widget get _addEmployeeButton {
    return AppFloatingActionButton(() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return BlocProvider<ContactListPageBloc>(
          bloc: contactListPageBloc,
          child: AddEmployeePage(),
        );
      }));
    }, "AddEmployee");
  }

  Widget employeeListTileRow(List<ApplicationUser> employeeList) {
    return RefreshIndicator(
      child: employeeList.length == 0
          ? NoDataWidget("No employees, please add new employee")
          : ListView.builder(
            padding: EdgeInsets.only(bottom: 90),
              itemCount: employeeList?.length,
              itemBuilder: (BuildContext context, int index) {
                return employeeListTileItem(employeeList[index]);
              },
            ),
      onRefresh: () async {
        HttpRequest.forceRefresh = true;
        await contactListPageBloc.getAllEmployees();
      },
    );
  }

  Widget employeeListTile(ApplicationUser employee) {
    return
        //ExpandablePanel(
        //header:
        Container(
      alignment: Alignment.center,
      child: ListTile(
        dense: true,
        onTap: () {
          Navigator.pushNamed(context, Routes.employeeDetailPage,
              arguments: employee);
        },
        leading: CircleAvatar(
        backgroundColor: Colors.lightBlue,
          child: Text(
            employee.name.substring(0, 1),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(employee.name +
            (isCurrentUserManagerHimself(employee)
                ? " (Me)"
                : "" +    (employee.isManagerFromRoles?" (Manager) ":"") +    (employee.isActive ? "" : " (Disabled)")), style: TextStyle(fontSize: ScreenUtil().setSp(45)),),
        //subtitle: Text('Location: ' +
        //TextHelper.checkTextIfNullReturnEmpty(Employee.location)),
      ),
    );
    // collapsed:
    // expanded: employee.peoples?.length == 0 || employee.peoples == null
    //     ? Center(
    //         child: Text('No person linked to this Employee'),
    //       )
    //     : Container(
    //         constraints: BoxConstraints(
    //             maxHeight:
    //                 ScreenUtil().setHeight(employee.peoples.length * 150)),
    //         child: ListView.builder(
    //           shrinkWrap: false,
    //           itemCount: employee.peoples.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return Card(
    //                 color: Colors.grey[200],
    //                 child: ListTile(
    //                   dense: true,
    //                   // onTap: () {
    //                   //   Navigator.pushNamed(context, Routes.peopleDetailPage,
    //                   //       arguments: employee.peoples[index]);
    //                   // },
    //                   leading: Text(employee.peoples[index].name),
    //                   title: Text(TextHelper.checkTextIfNullReturnEmpty(
    //                       employee.peoples[index].phone)),
    //                   trailing: Text(TextHelper.checkTextIfNullReturnEmpty(
    //                       employee.peoples[index].company?.name)),
    //                 ));
    //           },
    //         )),

    //tapHeaderToExpand: false,
    //hasIcon: true,
    //);
  }

  bool isCurrentUserManagerHimself(ApplicationUser employee) {
    return HttpRequest.appUser.isManager &&
        HttpRequest.appUser.name == employee.name;
  }

  Widget employeeListTileItem(ApplicationUser employee) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(210)),
      color: Colors.grey[200],
      child: Card(
        child: Slidable(
          actionExtentRatio: 0.16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () {}, child: employeeListTile(employee)),
          ),
          actionPane: SlidableDrawerActionPane(),
          actions: isCurrentUserManagerHimself(employee)
              ? <Widget>[]
              : <Widget>[
                  IconSlideAction(
                    //caption: '',
                    color: Colors.green,
                    icon: Icons.phone,
                    onTap: () async {
                      if (employee.phoneNumber.isEmpty ?? true) {
                        DialogService()
                            .show(context, 'No Phone Number avaliable');
                      } else {
                        UrlSchemeService().makePhoneCall(employee.phoneNumber);
                      }
                    },
                  ),
                  IconSlideAction(
                    //caption: '',
                    color: Colors.purple,
                    icon: Icons.email,
                    onTap: () async {
                      if (employee.email?.isEmpty ?? true) {
                        DialogService()
                            .show(context, 'No Email Address avaliable');
                      } else {
                        UrlSchemeService().sendEmail(employee.email);
                      }
                    },
                  ),
                ],
          secondaryActions: isCurrentUserManagerHimself(employee)
              ? <Widget>[]
              : <Widget>[
                  IconSlideAction(
                    //caption: '',
                            color: Colors.blue[700],
                    icon: Icons.edit,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) {
                            return BlocProvider<ContactListPageBloc>(
                              bloc: contactListPageBloc,
                              child: EditEmployeePage(),
                            );
                          },
                          settings: RouteSettings(arguments: employee)));
                    },
                  ),
                  // IconSlideAction(
                  //   //caption: '',
                  //   color: Colors.red[600],
                  //   icon: Icons.delete,
                  //   onTap: () async {
                  //     DialogService().showConfirm(
                  //         context, "Are you to delete this Employee?",
                  //         () async {
                  //       await contactListPageBloc.deleteEmployee(employee.id);
                  //     });
                  //   },
                  // ),
                ],
        ),
      ),
    );
  }
}
