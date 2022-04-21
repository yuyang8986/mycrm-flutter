import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Pipeline/AddPipelineBloc.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/GeneralWidgets/RemoveBinIconButton.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/DropSelectionWidget.dart';
import 'package:mycrm/generalWidgets/Shared/EventTimeSelectionWidget.dart';
import 'package:mycrm/generalWidgets/Shared/NoContactInfoGuideWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetRelationWidget.dart';
import 'package:mycrm/infrastructure/DateTimeHelper.dart';
import 'package:mycrm/infrastructure/TextHelper.dart';
import '../../Models/Core/Pipeline/Pipeline.dart';
import '../../Models/Core/Stage/Stage.dart';
import '../../Models/Core/contact/People.dart';

class PipelineAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PipelineAddState();
  }
}

class _PipelineAddState extends State<PipelineAddPage> {
  final AddPipelineBloc addPipelineBloc = AddPipelineBloc();

  final _dealNameController = TextEditingController();
  final _dealAmountController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final _cogsAmountController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final _marginController = TextEditingController();
  final _estimatedGPController = TextEditingController();
  final _noteController = TextEditingController();

//purpose to declare future for futurebuilder here is to let futurebuilder use the same instance of future, so it will not keep calling REST API
  //Future<List<Company>> allCompanyFuture = CompanyRepo().getAllCompanies();
  //Future<List<People>> allPeopleFuture = PeopleRepo().getAllPeoples();
  // Future<List<Activity>> allActivitiesFuture = ActivityRepo().getAllActivity();
  // Future<List<Stage>> allStagesFuture = StageRepo().getAllStage();

  List<Stage> allStageList = new List<Stage>();
  //List<Activity> allActivitiesList = new List<Activity>();

  Company selectedCompany;
  //Activity selectedActivity;
  People selectedPeople;
  ApplicationUser assignedEmployee;
  Pipeline newPipline;
  Stage selectedStage;
  //DateTime selectedFollowUpDateTime;
  bool _autoValidate;
  //bool isloading;
  DateTime selectedAttainDateTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  PipelineListBloc _pipeListBloc;

  var typeDropdownValue = 'Goods Sales';
  var cogsAndMarginDropdownValue = 'COGS Amount';

  // @override
  // void dispose() {
  //   _dealNameController?.dispose();
  //   _dealAmountController?.dispose();
  //   //_pipeListBloc?.dispose();
  //   addPipelineBloc.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    _autoValidate = false;
    //isloading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _pipeListBloc = BlocProvider.of<PipelineListBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar(
              'Add Deal', 'Deal', formKey, _scaffoldKey, confirmButtonCallback)
          .create(),
      body: newPipelineContainer(),
    );
  }

  confirmButtonCallback() {
    _autoValidate = true;
    if (formKey.currentState.validate()) {
      postForm();
    } else {
      final SnackBar snackBar = new SnackBar(
        content: Text('Please fill in all information.'),
        duration: Duration(milliseconds: 3000),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void postForm() async {
    newPipline = new Pipeline();
    // if(selectedFollowUpDateTime == null)
    // {
    //   DialogService().show(context, "Please set next Follow Up Date!");
    //   return;
    // }
    //newPipline.nextFollowUpDate = selectedFollowUpDateTime;
    newPipline.peopleId = selectedPeople?.id;
    newPipline.companyId = selectedCompany?.id;
    newPipline.stageId = selectedStage.id;
    //newPipline.activityId = selectedActivity?.id;
    newPipline.applicationUserId = assignedEmployee?.id;
    newPipline.dealName = _dealNameController.text;
    newPipline.dealAmount =
        double.parse(_dealAmountController.text.replaceAll(",", ""));
    if (cogsAndMarginDropdownValue == 'COGS Amount') {
      newPipline.cogsAmount =
          double.parse(_cogsAmountController.text.replaceAll(",", ""));
    }
    if (cogsAndMarginDropdownValue == 'Cost Margin%') {
      newPipline.margin = double.parse(_marginController.text) / 100;
    }

    newPipline.type = typeDropdownValue;
    newPipline.attainDate = selectedAttainDateTime;
    newPipline.note = _noteController.text;

    try {
      print('begin http request');
      // setState(() {
      //   isloading = true;
      // });
      //var result = await PipelineRepo().add(newPipline);
      //if (result.statusCode == 200 || result.statusCode == 201) {
      var result = await _pipeListBloc.addPipelineReturnNewPipeline(newPipline);
      PipelineListPageState.isInit = true;
      await ShowSnackBarAndGoBackHelper.go(_scaffoldKey, "Deal Added", context,data: result);
      //} else {
      //locator<ErrorService>().handleErrorResult(result, context);
      //}
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    } finally {
      // setState(() {
      //   isloading = false;
      // });
    }
  }

  Widget newPipelineContainer() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          children: <Widget>[
            selectedPeople == null ? linkCompanyRow : Container(),
            VEmptyView(20),
            selectedPeople == null && selectedCompany == null
                ? Center(
                    child: Text(
                      'Or',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
            VEmptyView(20),
            selectedCompany == null ? linkPersonRow : Container(),

            dealNameRow,
            // VEmptyView(20),
            dealAmountRow,
            VEmptyView(40),
            selectedCompany != null || selectedPeople != null
                ? typeDropdown
                : Container(),
            VEmptyView(40),
            estimatedCostRow,
            VEmptyView(20),
            estimatedGPRow,
            VEmptyView(40),
            selectedCompany != null || selectedPeople != null
                ? Row(
                    children: <Widget>[
                      Text(
                        "Set Stage:",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(42),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600]),
                      )
                    ],
                  )
                : Container(),
            VEmptyView(20),
            selectedCompany != null || selectedPeople != null
                ? allStageDropdown
                : Container(),
            VEmptyView(40),
            selectedCompany != null || selectedPeople != null
                ? Row(
                    children: <Widget>[
                      Text(
                        "Targeted Date to Attain:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(42),
                            color: Colors.grey[600]),
                      )
                    ],
                  )
                : Container(),
            VEmptyView(20),
            selectedCompany != null || selectedPeople != null
                ? attainDateTimeCallBackRow
                : Container(),
            noteRow,
            // SizedBox(height: 10),
            // Text('Select Next Activity To Follow Up'),
            // allActivityDropdown,
            // SizedBox(height: 10),
            // nextFollowUpDateTimeRow,
          ],
        ),
      ),
    );
  }

  // Widget get selectNextFollowUpDateTimeText {
  //   return Container(
  //     child: Text(
  //         TextHelper.checkTextIfNullReturnEmpty(
  //             DateTimeHelper.parseDateTimeToDateHHMM(selectedFollowUpDateTime)),
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  //   );
  // }

  Widget get linkCompanyRow {
    return SetRelationWidget(
      SetRelationOption.company,
      onSelectCompanyCallBack,
      removeSelectedCompanyCallBack,
      noDataDisplay: NoContactInfoGuideWidget(2),
    );
    // return Container(
    //   height: 50,
    //   child: Row(
    //     children: <Widget>[
    //       Container(
    //         margin: const EdgeInsets.only(right: 15),
    //         child: Icon(
    //           Icons.home,
    //           size: 35,
    //           color: Colors.lightBlue,
    //         ),
    //       ),
    //       linkCompanyInkWell,
    //       //if linked a company and no person linked, show icon
    //       //if linked a person and person has associated company, hide icon
    //       selectedCompanyInfo,
    //       removeSelectedCompanyButton
    //     ],
    //   ),
    // );
  }

  onSelectCompanyCallBack(company) {
    setState(() {
      selectedCompany = company;
      selectedPeople = null;
    });
  }

  Widget get attainDateTimeCallBackRow {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 50),
      padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(55), 0, ScreenUtil().setWidth(485), 0),
      width: ScreenUtil().setWidth(200),
      height: ScreenUtil().setHeight(110),
      child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          colorBrightness: Brightness.light,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            DatePicker.showDatePicker(context, showTitleActions: true,
                // minTime: DateTime.now().add(-Duration(days: 365)),
                // maxTime: DateTime.now().add(Duration(days: 365)),
                onConfirm: (date) {
              selectedAttainDateTimeCallBack(date);
            },
                currentTime: DateTime.now().add(Duration(days: 1)),
                locale: LocaleType.en);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              selectedAttainDateTime != null
                  ? selectEventStartDateTimeText
                  : Text(
                      'Date',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
              // Icon(
              //   Icons.timer,
              //   color: Theme.of(context).primaryColor,
              // )
            ],
          )),
    );
  }

  Widget get selectEventStartDateTimeText {
    return Container(
      width: ScreenUtil().setWidth(300),
      child: Text(
          TextHelper.checkTextIfNullReturnEmpty(
              DateTimeHelper.parseDateTimeToDate(selectedAttainDateTime)),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(44),
              color: Colors.white)),
    );
  }

  selectedAttainDateTimeCallBack(date) {
    setState(() {
      selectedAttainDateTime = date;
    });
  }

  removeSelectedCompanyCallBack() {
    setState(() {
      selectedCompany = null;
    });
  }

  // Widget get linkCompanyInkWell {
  //   return Expanded(
  //       child: InkWell(
  //     child: selectedPeople?.company == null
  //         ? Text(
  //             'LINK A COMPANY',
  //             style: TextStyle(color: Colors.blue[600]),
  //           )
  //         : Text('Company'),
  //     onTap: () async {
  //       //not to show modal if selected people has a related company and showing already
  //       if (selectedPeople?.company != null) return;
  //       ModalBottomSheetListViewBuilder(allCompanyFuture, context,
  //           (Company company) {
  //         setState(() {
  //           selectedCompany = company;
  //         });
  //       }).showModal();
  //     },
  //   ));
  // }

  Widget get removeSelectedCompanyButton {
    if (selectedCompany != null) {
      return RemoveBinIconButton(() {
        setState(() {
          selectedCompany = null;
        });
      });
    }
    return Container(
      width: 50,
    );
  }

  // Widget get selectedCompanyInfo {
  //   if (selectedPeople?.company != null) {
  //     return MultilineFixedWidthWidget([
  //       Text(selectedPeople.company.name),
  //       TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //           selectedPeople.company?.location)
  //     ]);
  //   } else if (selectedCompany != null)
  //     return MultilineFixedWidthWidget([
  //       Text(selectedCompany.name),
  //       TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //           selectedCompany.location)
  //     ]);
  //   return Container();
  // }

  // Widget linkCompanyContent(List<Company> companys) {
  //   return ListView.builder(
  //       itemCount: companys?.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Column(
  //           children: <Widget>[
  //             ListTile(
  //               dense: true,
  //               leading: Text(companys[index].name),
  //               title: Container(
  //                 constraints: BoxConstraints(
  //                     maxWidth: Constants.companyLocationTextMaxWidth),
  //                 child: Text(TextHelper.checkTextIfNullReturnEmpty(
  //                     companys[index].location)),
  //               ),
  //               onTap: () {
  //                 //select the company and close bottomsheet and show the name on form
  //                 setState(() {
  //                   selectedCompany = companys[index];
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             BottomModalDivider()
  //           ],
  //         );
  //       });
  // }

  Widget get linkPersonRow {
    return SetRelationWidget(
      SetRelationOption.people,
      onPeopleSelectCallBack,
      removeSelectedPeopleCallBack,
      noDataDisplay: NoContactInfoGuideWidget(2),
    );
    // return Container(
    //   // height: 50,
    //   child: Row(
    //     children: <Widget>[
    //       Container(
    //         margin: const EdgeInsets.only(right: 15),
    //         child: Icon(
    //           Icons.person,
    //           size: 35,
    //           color: Colors.orange,
    //         ),
    //       ),
    //       linkPersonInkWell,
    //       selectedPersonInfo,
    //       selectedPeople != null
    //           ? RemoveBinIconButton(() {
    //               setState(() {
    //                 selectedPeople = null;
    //                 selectedCompany = null;
    //               });
    //             })
    //           : Container(),
    //     ],
    //   ),
    // );
  }

  onPeopleSelectCallBack(people) {
    setState(() {
      selectedPeople = people;
      selectedCompany = null;
    });
  }

  removeSelectedPeopleCallBack() {
    setState(() {
      selectedPeople = null;
      //selectedCompany = null;
    });
  }

  // Widget get selectedPersonInfo {
  //   if (selectedPeople != null) {
  //     return MultilineFixedWidthWidget([
  //       Text(selectedPeople.name),
  //       TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //           selectedPeople.company?.name),
  //       TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //           selectedPeople.phone)
  //     ]);
  //   }

  //   return Container();
  // }

  // Widget get linkPersonInkWell {
  //   return Expanded(
  //     child: InkWell(
  //       child: Text(
  //         'LINK A PERSON',
  //         style: TextStyle(color: Colors.blue[600]),
  //       ),
  //       onTap: () async {
  //         ModalBottomSheetListViewBuilder(allPeopleFuture, context,
  //             (People people) {
  //           setState(() {
  //             selectedPeople = people;
  //           });
  //         }).showModal();
  //       },
  //     ),
  //   );
  // }

  // Widget linkPeopleRowContent(List<People> peopleList) {
  //   return ListView.builder(
  //       itemCount: peopleList?.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return ListTile(
  //           dense: true,
  //           leading: Text(peopleList[index].name),
  //           title: Text(TextHelper.checkTextIfNullReturnEmpty(
  //               peopleList[index].company?.name)),
  //           trailing: Container(
  //             constraints: BoxConstraints(
  //                 maxWidth: Constants.companyLocationTextMaxWidth),
  //             child: Text(TextHelper.checkTextIfNullReturnEmpty(
  //                 peopleList[index].company?.location)),
  //           ),
  //           onTap: () {
  //             //select the company and close bottomsheet and show the name on form
  //             setState(() {
  //               selectedPeople = peopleList[index];
  //             });
  //             Navigator.pop(context);
  //           },
  //         );
  //       });
  // }

  // Widget get allActivityDropdown {
  //   return StreamBuilder(
  //     stream: addPipelineBloc.allActivities,
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       if (snapshot.hasData && snapshot.data != null) {
  //         allActivitiesList = snapshot.data as List<Activity>;
  //         selectedActivity =
  //             allActivitiesList.length == 0 ? null : allActivitiesList.first;

  //         return Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: <Widget>[
  //               Container(
  //                   height: 40,
  //                   color: Colors.grey[200],
  //                   width: 250,
  //                   child: DropdownButton<Activity>(
  //                     isDense: false,
  //                     isExpanded: true,
  //                     hint: Text('No Activities has been created.'),
  //                     items: allActivitiesList.map((Activity selection) {
  //                       return DropdownMenuItem<Activity>(
  //                           value: selection, child: Text(selection?.name));
  //                     }).toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         selectedActivity = value;
  //                       });
  //                     },
  //                     value: selectedActivity,
  //                   )),
  //               RaisedButton(
  //                   color: Theme.of(context).primaryColor,
  //                   child: Text(
  //                     'CREATE',
  //                     style: TextStyle(color: AppColors.normalTextColor),
  //                   ),
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(30)),
  //                   onPressed: () {
  //                     Navigator.of(context).push(
  //                         MaterialPageRoute(builder: (BuildContext context) {
  //                       return BlocProvider<AddPipelineBloc>(
  //                         bloc: addPipelineBloc,
  //                         child: AddActivityPage(),
  //                       );
  //                     }));
  //                   })
  //             ]);
  //       } else if (snapshot.hasError) {
  //         return ErrorPage();
  //       } else {
  //         return LoadingIndicator();
  //       }
  //     },
  //   );
  // }
  createStageCallBack() {
    DialogService().showTextInput(context, "Create A New Stage", "Create",
        (name) async {
      var newStage = Stage(name: name);
      await addPipelineBloc.addStage(newStage);
    }, () {
      Navigator.pop(context);
    });
  }

  Widget get typeDropdown {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
          child: Text(
            "Type:",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(42),
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
        ),
        VEmptyView(20),
        Container(
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
            height: ScreenUtil().setHeight(50),
            width: ScreenUtil().setWidth(480),
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.white, width: 0),
              color: Theme.of(context).primaryColor,
            ),
            constraints: BoxConstraints(
                // maxWidth: ScreenUtil().setWidth(650),
                minHeight: ScreenUtil().setHeight(120)),
            child: Theme(
                data: ThemeData(canvasColor: Theme.of(context).primaryColor),
                child: DropdownButton<String>(
                  value: typeDropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      typeDropdownValue = newValue;
                    });
                  },
                  isDense: true,
                  isExpanded: false,
                  underline: Container(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(48),
                      fontWeight: FontWeight.bold),
                  items: <String>['Goods Sales', 'Services']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                          ),
                          width: ScreenUtil().setWidth(380),
                        ));
                  }).toList(),
                ))),
        VEmptyView(40),
        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
          child: Text(
            "Cost Model:",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(42),
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
        ),
        VEmptyView(20),
        Container(
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
            height: ScreenUtil().setHeight(50),
            width: ScreenUtil().setWidth(480),
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.white, width: 0),
              color: Theme.of(context).primaryColor,
            ),
            constraints: BoxConstraints(
                // maxWidth: ScreenUtil().setWidth(650),
                minHeight: ScreenUtil().setHeight(120)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Theme(
                    data:
                        ThemeData(canvasColor: Theme.of(context).primaryColor),
                    child: DropdownButton<String>(
                      value: cogsAndMarginDropdownValue,
                      isDense: true,
                      isExpanded: false,
                      onChanged: (String newValue) {
                        setState(() {
                          cogsAndMarginDropdownValue = newValue;
                          _cogsAmountController.text = "0.00";
                          _marginController.text = "";
                          _estimatedGPController.text = "";
                        });
                      },
                      underline: Container(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(48),
                          fontWeight: FontWeight.bold),
                      items: <String>['COGS Amount', 'Cost Margin%']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                              ),
                              width: ScreenUtil().setWidth(380),
                            ));
                      }).toList(),
                    ))
              ],
            ))
      ],
    );
  }

  Widget get allStageDropdown {
    //addPipelineBloc.getAllStages();
    return CustomStreamBuilder(
        retryCallback: addPipelineBloc.getAllStages,
        stream: addPipelineBloc.allStages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (!snapshot.hasData) {
          //   a
          // }
          // if (snapshot.connectionState == ConnectionState.active &&
          //     snapshot.data == null) {
          //   return ErrorPage(() {
          //     addPipelineBloc.getAllStages();
          //   });
          // }
          // if (snapshot.hasError)
          //   return ErrorPage(() {
          //     addPipelineBloc.getAllStages();
          //   });
          if (snapshot.hasData && snapshot.data != null) {
            allStageList = snapshot.data as List<Stage>;
            if (selectedStage == null) {
              selectedStage =
                  allStageList.length == 0 ? null : allStageList.first;
            }
            return CustomDropdownSelection(
              "",
              allStageList,
              selectedStage,
              (value) {
                setState(() {
                  selectedStage = value;
                });
              },
              createCallBack: createStageCallBack,
            );

            //   Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: <Widget>[
            //         Text('Select A Stage'),
            //         Container(
            //           height: 40,
            //           color: Colors.grey[200],
            //           width: 250,
            //           child:
            //               //if stage name is same then will cause exception, same as activity
            //               DropdownButton<Stage>(
            //             elevation: 2,
            //             isDense: false,
            //             isExpanded: true,
            //             hint: Text('No Stages Has Been Created'),
            //             items: allStageList.map((Stage selection) {
            //               return DropdownMenuItem<Stage>(
            //                   value: selection, child: Text(selection.name));
            //             }).toList(),
            //             onChanged: (value) {
            //               setState(() {
            //                 selectedStage = value;
            //               });
            //             },
            //             value: selectedStage,
            //           ),
            //         ),
            //         // RaisedButton(
            //         //     color: Theme.of(context).primaryColor,
            //         //     child: Text('CREATE',
            //         //         style: TextStyle(color: AppColors.normalTextColor)),
            //         //     shape: RoundedRectangleBorder(
            //         //         borderRadius: BorderRadius.circular(30)),
            //         //     onPressed: () {
            //         //       Navigator.of(context).push(
            //         //           MaterialPageRoute(builder: (BuildContext context) {
            //         //         return BlocProvider<AddPipelineBloc>(
            //         //           bloc: addPipelineBloc,
            //         //           child: AddStagePage(),
            //         //         );
            //         //       }));
            //         //     })
            //       ]);
            // }
          }
        });
  }

  Widget get dealNameRow {
    return Container(
      // height: ScreenUtil().setHeight(220),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              style: TextStyle(fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.words,
              enabled: selectedCompany != null || selectedPeople != null,
              controller: _dealNameController,
              keyboardType: TextInputType.multiline,
              maxLength: 40,
              textInputAction: TextInputAction.done,
              maxLines: null,
              maxLengthEnforced: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Deal Name.';
                }

                return null;
              },
              decoration: InputDecoration(labelText: 'Deal Name *'),
            ),
          )
        ],
      ),
    );
  }

  // Widget get nextFollowUpDateTimeRow {
  //   return FlatButton(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //       colorBrightness: Brightness.light,
  //       color: Colors.blue[200],
  //       hoverColor: Colors.blue,
  //       onPressed: () {
  //         DatePicker.showDateTimePicker(context, showTitleActions: true,
  //             // minTime: DateTime.now().add(-Duration(days: 365)),
  //             // maxTime: DateTime.now().add(Duration(days: 365)),
  //             onConfirm: (date) {
  //           setState(() {
  //             selectedFollowUpDateTime = date;
  //           });
  //         }, currentTime: DateTime.now(), locale: LocaleType.en);
  //       },
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: <Widget>[
  //           Text(
  //             'Next Follow Update Time',
  //             style: TextStyle(color: Colors.black, fontSize: 12),
  //           ),
  //           selectedFollowUpDateTime != null
  //               ? selectNextFollowUpDateTimeText
  //               : Container(),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: <Widget>[
  //               Text('SET'),
  //               Icon(
  //                 Icons.timer,
  //                 color: Theme.of(context).primaryColor,
  //               )
  //             ],
  //           )
  //         ],
  //       ));
  // }

  Widget get dealAmountRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              onChanged: (value) {
                Timer timer = new Timer(new Duration(seconds: 3), () {
                  if (cogsAndMarginDropdownValue == 'COGS Amount') {
                    var gp = double.parse(
                            _dealAmountController.text.replaceAll(',', '')) -
                        double.parse(
                            _cogsAmountController.text.replaceAll(",", ""));
                    setState(() {
                      _estimatedGPController.text = gp.toStringAsFixed(2);
                    });
                  } else {
                    var gp = double.parse(
                            _dealAmountController.text.replaceAll(',', '')) *
                        (1 - double.parse(_marginController.text) / 100);
                    setState(() {
                      _estimatedGPController.text = gp.toStringAsFixed(2);
                    });
                  }
                });
              },
              style: TextStyle(fontWeight: FontWeight.bold),
              enabled: selectedCompany != null || selectedPeople != null,
              controller: _dealAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Deal Amount.';
                }
                if (double.parse(value.replaceAll(",", "")) < 0) {
                  return 'Must greater then zero.';
                }

                if (double.parse(value.replaceAll(",", "")) > 10000000) {
                  return 'Deal Amount is too large.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Deal Amount *'),
            ),
          )
        ],
      ),
    );
  }

  Widget get estimatedCostRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: getEstimatedTextField()),
          SizedBox(width: ScreenUtil().setSp(600))
        ],
      ),
    );
  }

  getEstimatedTextField() {
    if (cogsAndMarginDropdownValue == 'COGS Amount') {
      return TextFormField(
        onChanged: (value) {
          Timer timer = new Timer(new Duration(seconds: 3), () {
            var gp = double.parse(
                    _dealAmountController.text.replaceAll(",", "")) -
                double.parse(_cogsAmountController.text.replaceAll(",", ""));
            setState(() {
              _estimatedGPController.text = gp.toStringAsFixed(2);
            });
          });
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        enabled: selectedCompany != null || selectedPeople != null,
        controller: _cogsAmountController,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(labelText: 'COGS Amount:'),
      );
    } else {
      return TextFormField(
        onChanged: (value) {
          Timer timer = new Timer(new Duration(seconds: 3), () {
            var gp = double.parse(
                    _dealAmountController.text.replaceAll(",", "")) *
                (1 -
                    double.parse(_marginController.text.replaceAll(",", "")) /
                        100);

            setState(() {
              _estimatedGPController.text = gp.toStringAsFixed(2);
            });
          });
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        enabled: selectedCompany != null || selectedPeople != null,
        controller: _marginController,
        maxLength: 2,
        maxLengthEnforced: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Cost Margin%'),
      );
    }
  }

  Widget get estimatedGPRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              style: TextStyle(fontWeight: FontWeight.bold),
              enabled: false,
              controller: _estimatedGPController,
              decoration: InputDecoration(labelText: 'Gross Profit:'),
            ),
          ),
          SizedBox(width: ScreenUtil().setSp(600))
        ],
      ),
    );
  }

  Widget get noteRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              enabled: selectedCompany != null || selectedPeople != null,
              style: TextStyle(fontWeight: FontWeight.bold),
              keyboardType: TextInputType.multiline,
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Note:'),
              maxLines: null,
            ),
          )
        ],
      ),
    );
  }
}
