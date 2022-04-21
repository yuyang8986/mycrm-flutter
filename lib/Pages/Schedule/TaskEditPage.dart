import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Event/ScheduleListBloc.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/ReminderSwitch.dart';
import 'package:mycrm/generalWidgets/Shared/DropSelectionWidget.dart';
import 'package:mycrm/generalWidgets/Shared/EventTimeSelectionWidget.dart';
import 'package:mycrm/generalWidgets/Shared/NoContactInfoGuideWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetLocationWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetRelationWidget.dart';
import 'package:mycrm/generalWidgets/Shared/TItleInputText.dart';
import '../../Models/Core/Activitty/Activity.dart';

class TaskEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TaskEditState();
  }
}

class _TaskEditState extends State<TaskEditPage> {
//purpose to declare future for futurebuilder here is to let futurebuilder use the same instance of future, so it will not keep calling REST API
  // Future<List<Company>> allCompanyFuture = CompanyRepo().getAllCompanies();
  // Future<List<People>> allPeopleFuture = PeopleRepo().getAllPeoples();
  // Future<List<Activity>> allActivitiesFuture = ActivityRepo().getAllActivity();
  List<Activity> allActivitiesList = new List<Activity>();
  //Future<List<Pipeline>> allPipelinesFuture = PipelineRepo().getAllPipelines();
  final geocoding = new GoogleMapsGeocoding(apiKey: Constants.googleAPI);
  Future<GeocodingResponse> googleMapSearchFuture;
  GeocodingResponse addressResponse;
  var _noteController = TextEditingController();
  var _nameController = TextEditingController();
  var addressSearchTerm;
  //Company selectedCompany;
  Activity selectedActivity;
  //People selectedPeople;
  Pipeline selectedPipeline;
  Task selectedTask;
  //DateTime selectedTaskStartDateTime;
  //int durationMinutes;
  bool _autoValidate;
 // bool isReminderOn;
  String location;
  bool isInit;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  ScheduleListBloc _scheduleListBloc;

  // @override
  // void dispose() {
  //   //_scheduleListBloc.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    _autoValidate = false;
    //isReminderOn = false;
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleListBloc =
        _scheduleListBloc ?? BlocProvider.of<ScheduleListBloc>(context);
    selectedTask = ModalRoute.of(context).settings.arguments;
    if (isInit) {
      _nameController.text = selectedTask.summary;
      selectedPipeline = selectedTask.pipeline;
      location = selectedTask.location;
      selectedActivity = selectedTask.activity;
      //selectedTaskStartDateTime = selectedTask.eventStartDateTime;
      //durationMinutes = selectedTask.durationMinutes;
      //isReminderOn = selectedTask.isReminderOn;
      _noteController.text = selectedTask.note;
      isInit = false;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar(
              'Edit Task', 'Task', formKey, _scaffoldKey, confirmButtonCallback)
          .create(),
      body: newTaskContainer(),
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
    // if (selectedTaskStartDateTime == null) {
    //   DialogService().show(context, "Please set Task Start Time!");
    //   return;
    // }
    // if (durationMinutes == null) {
    //   DialogService().show(context, "Please set Task Duration!");
    //   return;
    // }

    if (selectedActivity == null) {
      DialogService().show(context, "Please set Task Type!");
      return;
    }

    // if (selectedPipeline.appointment != null || selectedPipeline.task != null) {
    //   DialogService().show(context,
    //       'Sorry, only one Appointment/Task is allowed at a time for a deal.');
    //   return;
    // }
    selectedTask.summary = _nameController.text;
   // selectedTask.eventStartDateTime = selectedTaskStartDateTime;
    //selectedTask.durationMinutes = durationMinutes;
    //selectedTask.isReminderOn = isReminderOn;
    selectedTask.location = location;
    selectedTask.note = _noteController.text;
    selectedTask.activityId = selectedActivity.id;
    selectedTask.pipelineId = selectedPipeline.id;
    try {
      print('begin http request');

      await _scheduleListBloc.updateTask(selectedTask);
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Task Updated", context);
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    } finally {
      // setState(() {
      //   isloading = false;
      // });
    }
  }

  Widget newTaskContainer() {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 5, right: 5),
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          children: <Widget>[
            //linkPersonRow,
            //linkCompanyRow,
            nameRow,
            linkDealRow(),
            VEmptyView(40),
            locationRow,
            VEmptyView(40),
            allActivityDropdown,
            VEmptyView(40),
            // EventTimeSelectionWidget(selectedTaskStartDateTime, durationMinutes,
            //     selectStartTimeCallBack, selectDurationTimeCallBack),
            // VEmptyView(40),

            // ReminderSwitch(isReminderOn, (v) {
            //   setState(() {
            //     isReminderOn = v;
            //   });
            // }),
            // Center(
            //   child: Text('Note'),
            // ),
            // noteRow,
          ],
        ),
      ),
    );
  }

  // Widget get selectTaskEndDateTimeText {
  //   return Container(
  //     child: Text(
  //         TextHelper.checkTextIfNullReturnEmpty(
  //             DateTimeHelper.parseDateTimeToDateHHMM(
  //                 selectedTaskStartDateTime)),
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //   );
  // }

  // Widget get linkCompanyRow {
  //   return Container(
  //     height: 50,
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           margin: const EdgeInsets.only(right: 15),
  //           child: Icon(
  //             Icons.home,
  //             size: 35,
  //             color: Colors.lightBlue,
  //           ),
  //         ),
  //         //linkCompanyInkWell,
  //         //if linked a company and no person linked, show icon
  //         //if linked a person and person has associated company, hide icon
  //         selectedCompanyInfo,
  //         removeSelectedCompanyButton
  //       ],
  //     ),
  //   );
  // }

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

  // Widget get removeSelectedCompanyButton {
  //   if (selectedCompany != null &&
  //       (selectedPeople?.company == null && selectedPeople == null)) {
  //     return RemoveBinIconButton(() {
  //       setState(() {
  //         selectedCompany = null;
  //       });
  //     });
  //   }
  //   return Container(
  //     width: 50,
  //   );
  // }

  // Widget get selectedCompanyInfo {
  //   if (selectedPeople?.company != null) {
  //     return MultilineFixedWidthWidget([
  //       Text(selectedPeople?.company?.name),
  //       TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //           selectedPeople?.company?.location)
  //     ]);
  //   } else if (selectedCompany != null)
  //     return MultilineFixedWidthWidget([
  //       Text(selectedCompany?.name),
  //       TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //           selectedCompany?.location)
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

  // Widget get linkPersonRow {
  //   return Container(
  //     // height: 50,
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           margin: const EdgeInsets.only(right: 15),
  //           child: Icon(
  //             Icons.person,
  //             size: 35,
  //             color: Colors.orange,
  //           ),
  //         ),
  //         //linkPersonInkWell,
  //         selectedPersonInfo,
  //         selectedPeople != null
  //             ? RemoveBinIconButton(() {
  //                 setState(() {
  //                   selectedPeople = null;
  //                   selectedCompany = null;
  //                 });
  //               })
  //             : Container(),
  //       ],
  //     ),
  //   );
  // }

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

  Widget linkDealRow() {
    return SetRelationWidget(
      SetRelationOption.pipeline,
      pipelineOnSelectCallBack,
      removeSelectedPipelineCallBack,
      selectedPipeline: selectedPipeline,
      noDataDisplay: NoContactInfoGuideWidget(2)
    );
  }

  removeSelectedPipelineCallBack() {
    setState(() {
      selectedPipeline = null;
      // selectedCompany = null;
      // selectedPeople = null;
    });
  }

  pipelineOnSelectCallBack(Pipeline pipeline) {
    setState(() {
      selectedPipeline = pipeline;

      // selectedPeople = pipeline.people;
      // selectedCompany = pipeline.people.company;
    });
  }

  setGeoSearchFutureCallback(addressController) {
    setState(() {
      googleMapSearchFuture = geocoding.searchByAddress(addressController.text,
          components: [new Component(Component.country, "au")]);
    });
  }

  manualSetLocation(addressController) {
    setState(() {
      location = addressController.text;
    });
  }

  setLocationFromResultCallBack(addressResponse, index) {
    setState(() {
      location = addressResponse.results[index].formattedAddress;
    });
  }

  removeSelectedLocationCallBack() {
    setState(() {
      location = null;
    });
  }

  // selectStartTimeCallBack(date) {
  //   setState(() {
  //     selectedTaskStartDateTime = date;
  //   });
  // }

  // selectDurationTimeCallBack(int minutes) {
  //   setState(() {
  //     durationMinutes = minutes;
  //   });
  // }

  Widget get locationRow {
    return SetLocationWidget(
        location,
        googleMapSearchFuture,
        setLocationFromResultCallBack,
        manualSetLocation,
        setGeoSearchFutureCallback,
        removeSelectedLocationCallBack);
  }

  Widget get nameRow {
    return TitleInputText(_nameController, "Task Summary");
  }

  Widget get allActivityDropdown {
    // if (allActivitiesList == null || allActivitiesList?.length == 0) {
    //   _scheduleListBloc.getAllActivities();
    // }
    return CustomStreamBuilder(
      retryCallback: _scheduleListBloc.getAllActivities,
      stream: _scheduleListBloc.allActivities,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // if (snapshot.connectionState == ConnectionState.active &&
        //     snapshot.data == null) {
        //   return ErrorPage(() {
        //     _scheduleListBloc.getAllActivities();
        //   });
        // }
        // if (snapshot.hasError)
        //   return ErrorPage(() {
        //     _scheduleListBloc.getAllActivities();
        //   });
        // if (!snapshot.hasData &&
        //     (allActivitiesList == null || allActivitiesList.length == 0))
        //   return LoadingIndicator();
        allActivitiesList = snapshot.data as List<Activity>;
        allActivitiesList = allActivitiesList
            .where((s) => s.activityType == ActivityType.task)
            .toList();
        // selectedActivity =
        //     allActivitiesList?.length == 0 ? null : allActivitiesList?.first;

        return CustomDropdownSelection(
          "Set Type",
          allActivitiesList,
          selectedActivity,
          (value) {
            setState(() {
              selectedActivity = value;
            });
          },
          createCallBack: createActivityCallBack,
        );
        // Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Text('Task Type',
        //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        //       SizedBox(
        //         width: 20,
        //       ),
        //       Container(
        //           constraints: BoxConstraints(maxWidth: 250),
        //           height: 40,
        //           color: Colors.grey[200],
        //           child: DropdownButton<Activity>(
        //             isDense: false,
        //             isExpanded: true,
        //             hint: Text('No Task Type Available.'),
        //             items: allActivitiesList.map((Activity selection) {
        //               return DropdownMenuItem<Activity>(
        //                   value: selection,
        //                   child: Center(
        //                     child: Text(selection?.name),
        //                   ));
        //             }).toList(),
        //             onChanged: (value) {
        //               setState(() {
        //                 selectedActivity = value;
        //               });
        //             },
        //             value: selectedActivity,
        //           )),
        //     ]);
      },
    );
  }

  createActivityCallBack() {
    DialogService().showTextInput(context, "Create A Activity", "Create",
        (name) async {
      var activity = Activity(name: name, activityType: ActivityType.task);
      await _scheduleListBloc.addActivity(activity);
    }, () {
      Navigator.pop(context);
    });
  }

  Widget get noteRow {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextFormField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: _noteController,
            ),
          )
        ],
      ),
    );
  }
}
