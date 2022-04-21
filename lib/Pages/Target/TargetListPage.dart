import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Dashboard/DashboardPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/TargetTemplate/TargetTemplate.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/AppFloatingActionButton.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';

class TargetListPage extends StatefulWidget {
  @override
  _TargetListPageState createState() => _TargetListPageState();
}

class _TargetListPageState extends State<TargetListPage>
    with AutomaticKeepAliveClientMixin {
  DashboardPageBloc dashboardPageBloc;
  bool isInit;

  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      dashboardPageBloc = BlocProvider.of<DashboardPageBloc>(context);
      //dashboardPageBloc.getAllTargetTemplates();
      isInit = false;
    }

    return Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Target"),
        ),
        floatingActionButton: _addNewTargetTemplateButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: targetListContainer);
  }

  Widget get header {
    return Card(
      elevation: 5,
      child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: <Widget>[
              Text("\$ to Win: Quarter Target",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )),
    );
  }

  Widget get targetListContainer {
    return Column(
      children: <Widget>[
        header,
        // Divider(
        //   height: 5,
        //   color: Colors.black,
        // ),
        templateWithEmployeesExpandablePanel
      ],
    );
  }

  Widget get templateWithEmployeesExpandablePanel {
    return CustomStreamBuilder(
      retryCallback: dashboardPageBloc.getAllTargetTemplates,
      stream: dashboardPageBloc.allTargetTemplatesStream,
      builder: (ctx, snapshot) {
        // if (!snapshot.hasData) return LoadingIndicator();
        // if (snapshot.connectionState == ConnectionState.active &&
        //     snapshot.data == null) {
        //   return ErrorPage(() {
        //     dashboardPageBloc.getAllTargetTemplates();
        //   });
        // }
        // if (snapshot.hasError)
        //   return ErrorPage(() {
        //     dashboardPageBloc.getAllTargetTemplates();a
        //   });
        List<TargetTemplate> targetTemplates =
            snapshot.data as List<TargetTemplate>;
        return RefreshIndicator(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              TargetTemplate template = targetTemplates[index];
              return expandableTemplateItem(template);
            },
            itemCount: targetTemplates.length,
          ),
          onRefresh: _refreshTargetTempletes,
        );
      },
    );
  }

  Future<void> _refreshTargetTempletes() async {
    HttpRequest.forceRefresh = true;
    await dashboardPageBloc.getAllTargetTemplates();
  }

  Widget expandableTemplateItem(TargetTemplate template) {
    return Slidable(
        actionExtentRatio: .1,
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            icon: template.isArchive ? Icons.check : Icons.delete,
            color: Colors.red,
            onTap: () async {
              if (template.isArchive) {
                DialogService().showConfirm(
                    context, "Are you to enable this template?", () async {
                  await dashboardPageBloc.enableTemplate(template.id);
                  Navigator.pop(context);
                });
              } else {
                DialogService().showConfirm(
                    context, "Are you to archive this template?", () async {
                  await dashboardPageBloc.archiveTemplate(template.id);
                  Navigator.pop(context);
                });
              }
            },
          )
        ],
        child: Card(
          elevation: 5,
          child: ExpandablePanel(
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        "Q1: \$${template.q1}     Q2: \$${template.q2}   \nQ3: \$${template.q3}     Q4: \$${template.q4}",
                        style: TextStyle(fontSize: 16)),
                  ),
                  // Divider(
                  //   thickness: 1.7,
                  //   color: Colors.black38,
                  // ),
                  template.employees != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: template.employees?.length,
                          itemBuilder: (ctx, index) {
                            if (template.employees == null ||
                                template.employees?.length == 0) {
                              return Container();
                            }
                            ApplicationUser employee =
                                template.employees[index];
                            return slidableEmployee(employee);
                          },
                        )
                      : Container(),
                ],
              ),
              header: expandHeader(template)),
        ));
  }

  Widget slidableEmployee(ApplicationUser employee) {
    return Column(
      children: <Widget>[
        Slidable(
          actionExtentRatio: .1,
          actionPane: SlidableDrawerActionPane(),
          child: Column(
            children: <Widget>[
              Card(
                elevation: 3,
                color: Colors.white70,
                child: Container(
                  height: 35,
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: <Widget>[Text(employee.name)],
                  ),
                ),
              )
            ],
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              iconWidget: Icon(Icons.delete, color: Colors.red),
              onTap: () async {
                await dashboardPageBloc.removeEmployeeFromTemplate(employee.id);
              },
            )
          ],
        ),
        // Divider(
        //   thickness: 1.5,
        // )
      ],
    );
  }

  Widget expandHeader(TargetTemplate template) {
    final templateNameController = TextEditingController(text: template.name);
    final TextEditingController q1Update = MoneyMaskedTextController(
        initialValue: template.q1,
        decimalSeparator: '.',
        thousandSeparator: ',');
    // q1Update.text = template.q1.toString();
    final TextEditingController q2Update = MoneyMaskedTextController(
        initialValue: template.q2,
        decimalSeparator: '.',
        thousandSeparator: ',');
    // q2Update.text = template.q2.toString();
    final TextEditingController q3Update = MoneyMaskedTextController(
        initialValue: template.q3,
        decimalSeparator: '.',
        thousandSeparator: ',');
    // q3Update.text = template.q3.toString();
    final TextEditingController q4Update = MoneyMaskedTextController(
        initialValue: template.q4,
        decimalSeparator: '.',
        thousandSeparator: ',');
    // q4Update.text = template.q4.toString();
    return Container(
      padding: EdgeInsets.only(left: 10),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(template.name + (template.isArchive ? " (Archived)" : ""),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.green,
                ),
                onPressed: () async {
                  if (template.isArchive) {
                    DialogService().show(
                        context, "Please enable template to add employee.");
                    return;
                  }
                  await showModalBottomSheet(
                      builder: (ctx) {
                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                "Add Employee - ${template.name}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            template.employeesNotInThisTemplate.length > 0
                                ? Expanded(
                                    child: ListView.builder(
                                      itemBuilder: (ctx, index) {
                                        ApplicationUser employee = template
                                            .employeesNotInThisTemplate[index];
                                        return ListTile(
                                          onTap: () async {
                                            await dashboardPageBloc
                                                .addEmployeeToTemplate(
                                                    template.id, employee.id);

                                            Navigator.pop(context);
                                          },
                                          leading: Text(employee.name),
                                        );
                                      },
                                      itemCount: template
                                          .employeesNotInThisTemplate.length,
                                    ),
                                  )
                                : Center(
                                    child: Text("No Employees to be add"),
                                  ),
                          ],
                        );
                      },
                      context: context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  if (template.isArchive) {
                    DialogService()
                        .show(context, "Please enable template to edit.");
                    return;
                  }
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        return Scaffold(
                          resizeToAvoidBottomInset: true,
                          body: Container(
                            // constraints: BoxConstraints(maxHeight: 500),
                            padding: EdgeInsets.only(top: 40),
                            child: Column(
                              children: <Widget>[
                                Text("Edit Template Data"),
                                Center(
                                  child: Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(5),
                                      // color: Colors.grey[200],
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        controller: templateNameController,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        maxLength: 30,
                                        maxLengthEnforced: true,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Q1: \$'),
                                    WEmptyView(20),
                                    Container(
                                      width: ScreenUtil().setWidth(300),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: q1Update,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Q2: \$'),
                                    WEmptyView(20),
                                    Container(
                                      width: ScreenUtil().setWidth(300),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: q2Update,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Q3: \$'),
                                    WEmptyView(20),
                                    Container(
                                      width: ScreenUtil().setWidth(300),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: q3Update,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Q4: \$'),
                                    WEmptyView(20),
                                    Container(
                                      width: ScreenUtil().setWidth(300),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: q4Update,
                                      ),
                                    )
                                  ],
                                ),
                                VEmptyView(5),
                                RaisedButton.icon(
                                  icon: Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (q1Update.text.isEmpty ||
                                        q2Update.text.isEmpty ||
                                        q3Update.text.isEmpty ||
                                        q4Update.text.isEmpty) {
                                      DialogService().show(context,
                                          "Please Input All Quarter Data!");
                                      return;
                                    }

                                    template.q1 = double.parse(
                                        q1Update.text.replaceAll(",", ""));
                                    template.q2 = double.parse(
                                        q2Update.text.replaceAll(",", ""));
                                    template.q3 = double.parse(
                                        q3Update.text.replaceAll(",", ""));
                                    template.q4 = double.parse(
                                        q4Update.text.replaceAll(",", ""));
                                    template.name = templateNameController.text;

                                    await dashboardPageBloc
                                        .updateTemplate(template);
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget get _addNewTargetTemplateButton {
    final TextEditingController q1Add = MoneyMaskedTextController(
        decimalSeparator: '.', thousandSeparator: ',');
    final TextEditingController q2Add = MoneyMaskedTextController(
        decimalSeparator: '.', thousandSeparator: ',');
    final TextEditingController q3Add = MoneyMaskedTextController(
        decimalSeparator: '.', thousandSeparator: ',');
    final TextEditingController q4Add = MoneyMaskedTextController(
        decimalSeparator: '.', thousandSeparator: ',');
    final TextEditingController nameController = TextEditingController();
    return AppFloatingActionButton(() async {
      await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Container(
                  constraints: BoxConstraints(maxHeight: 550),
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                             VEmptyView(20),
                      Text(
                        "Add Template", style: TextStyle(fontSize: ScreenUtil().setSp(60), fontWeight: FontWeight.bold),
                      ),
                      VEmptyView(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: ScreenUtil().setWidth(550),
                              height: ScreenUtil().setHeight(180),
                              child: TextField(
                                textAlign: TextAlign.center,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 30,
                                maxLengthEnforced: true,
                                controller: nameController,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                    hintText: "Template Name",
                                    hintStyle: TextStyle(
                                        textBaseline: TextBaseline.alphabetic)),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Q1: \$'),
                          WEmptyView(20),
                          Container(
                            width: ScreenUtil().setWidth(300),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: q1Add,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Q2: \$'),
                          WEmptyView(20),
                          Container(
                            width: ScreenUtil().setWidth(300),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: q2Add,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Q3: \$'),
                          WEmptyView(20),
                          Container(
                            width: ScreenUtil().setWidth(300),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: q3Add,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Q4: \$'),
                          WEmptyView(20),
                          Container(
                            width: ScreenUtil().setWidth(300),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: q4Add,
                            ),
                          )
                        ],
                      ),
                      VEmptyView(20),
                      RaisedButton.icon(
                        icon: Icon(
                          FontAwesomeIcons.check,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          try {
                            if (q1Add.text.isEmpty ||
                                q2Add.text.isEmpty ||
                                q3Add.text.isEmpty ||
                                q4Add.text.isEmpty) {
                              DialogService().show(
                                  context, "Please Input All Quarter Data!");
                              return;
                            }

                            TargetTemplate template = new TargetTemplate();
                            template.name = nameController.text;
                            template.q1 =
                                double.parse(q1Add.text.replaceAll(",", ""));
                            template.q2 =
                                double.parse(q2Add.text.replaceAll(",", ""));
                            template.q3 =
                                double.parse(q3Add.text.replaceAll(",", ""));
                            template.q4 =
                                double.parse(q4Add.text.replaceAll(",", ""));

                            await dashboardPageBloc.addTemplate(template);
                            Navigator.pop(context);
                          } catch (e) {
                            ErrorService().handlePageLevelException(e, context);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    }, "AddTarget");
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
