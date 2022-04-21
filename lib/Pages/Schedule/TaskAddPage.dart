import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Event/ScheduleListBloc.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/NotificationService/NotificationService.dart';
import 'package:mycrm/Styles/AppColors.dart';
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
import 'package:mycrm/pages/Pipeline/PipelineAddPage.dart';
import '../../Models/Core/Activitty/Activity.dart';

class TaskAddPage extends StatefulWidget {
  final Pipeline pipeline;
  TaskAddPage({this.pipeline});
  @override
  State<StatefulWidget> createState() {
    return _TaskAddState();
  }
}

class _TaskAddState extends State<TaskAddPage> {
//purpose to declare future for futurebuilder here is to let futurebuilder use the same instance of future, so it will not keep calling REST API
  // Future<List<Company>> allCompanyFuture = CompanyRepo().getAllCompanies();
  // Future<List<People>> allPeopleFuture = PeopleRepo().getAllPeoples();
  // Future<List<Activity>> allActivitiesFuture = ActivityRepo().getAllActivity();
  List<Activity> allActivitiesList = new List<Activity>();
  //Future<List<Pipeline>> allPipelinesFuture = PipelineRepo().getAllPipelines();
  final geocoding = new GoogleMapsGeocoding(apiKey: Constants.googleAPI);
  Future<GeocodingResponse> googleMapSearchFuture;
  GeocodingResponse addressResponse;
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  var addressSearchTerm;
  //Company selectedCompany;
  Activity selectedActivity;
  //People selectedPeople;
  Pipeline selectedPipeline;
  Task newTask;
  DateTime selectedTaskStartDateTime;
  int durationMinutes;
  bool _autoValidate;
  bool isReminderOn;
  String location;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  ScheduleListBloc _scheduleListBloc;
  PipelineListBloc _pipelineListBloc;
  final PipelineListBloc _pipelineListBlocForAdd = new PipelineListBloc();

  // @override
  // void dispose() {
  //   //_scheduleListBloc.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    selectedPipeline = widget.pipeline ?? selectedPipeline;
    _autoValidate = false;
    isReminderOn = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleListBloc =
        _scheduleListBloc ?? BlocProvider.of<ScheduleListBloc>(context);

    _pipelineListBloc =
        _pipelineListBloc ?? BlocProvider.of<PipelineListBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar(
              'Add Task', 'Task', formKey, _scaffoldKey, confirmButtonCallback)
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
    newTask = new Task();
    if (selectedTaskStartDateTime == null) {
      DialogService().show(context, "Please set Task Start Time!");
      return;
    }
    if (durationMinutes == null) {
      DialogService().show(context, "Please set Task Duration!");
      return;
    }

    if (selectedActivity == null) {
      DialogService().show(context, "Please set Task Type!");
      return;
    }

    // if (selectedPipeline.appointment != null || selectedPipeline.task != null) {
    //   DialogService().show(context,
    //       'Sorry, only one Appointment/Task is allowed at a time for a deal.');
    //   return;
    // }
    newTask.summary = _nameController.text;
    newTask.eventStartDateTime = selectedTaskStartDateTime;
    newTask.durationMinutes = durationMinutes;
    newTask.isReminderOn = isReminderOn;
    newTask.location = location;
    newTask.note = _noteController.text;
    newTask.activityId = selectedActivity.id;
    newTask.pipelineId = selectedPipeline.id;
    try {
      print('begin http request');

      if (_pipelineListBloc != null) {
        await _pipelineListBloc.addTask(newTask);
        PipelineListPageState.isInit = true;
        if (isReminderOn)
          await NotificationService.scheduleNotifications(new ScheduleEvent(
              task: newTask,
              eventDateTime: newTask.eventStartDateTime,
              eventType: "task"));
      } else {
        await _scheduleListBloc.addTask(newTask);
        if (isReminderOn)
          await NotificationService.scheduleNotifications(new ScheduleEvent(
              task: newTask,
              eventDateTime: newTask.eventStartDateTime,
              eventType: "task"));
      }

      if (_pipelineListBloc != null) {
        await _pipelineListBloc.getAllPipelines();
      }
      await ShowSnackBarAndGoBackHelper.go(_scaffoldKey, "Task Added", context);
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
            VEmptyView(20),
            selectedPipeline == null ? addDealRow : Container(),
            VEmptyView(40),
            selectedPipeline != null ? allActivityDropdown : Container(),

            VEmptyView(40),
            selectedPipeline != null
                ? EventTimeSelectionWidget(
                    selectedTaskStartDateTime,
                    durationMinutes,
                    selectStartTimeCallBack,
                    selectDurationTimeCallBack)
                : Container(),

            VEmptyView(40),

            durationMinutes != null
                ? ReminderSwitch(isReminderOn, (v) {
                    setState(() {
                      isReminderOn = v;
                    });
                  })
                : Container(),
            VEmptyView(40),
            durationMinutes != null ? locationRow : Container(),
            // SizedBox(height: 30),
            // Center(
            //   child: Text('Note'),
            // ),
            // noteRow,
          ],
        ),
      ),
    );
  }

  Widget linkDealRow() {
    return SetRelationWidget(SetRelationOption.pipeline,
        pipelineOnSelectCallBack, removeSelectedPipelineCallBack,
        selectedPipeline: selectedPipeline,
        noDataDisplay: NoContactInfoGuideWidget(2));
  }

  Widget get addDealRow {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'or',
          style: TextStyle(
              fontSize: ScreenUtil().setSp(50), fontWeight: FontWeight.bold),
        ),
        VEmptyView(30),
        InkWell(
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return BlocProvider<PipelineListBloc>(
                  bloc: _pipelineListBlocForAdd,
                  child: PipelineAddPage(),
                );
              }),
            );
            setState(() {
              selectedPipeline = result;
            });
          },
          child: Container(
              height: ScreenUtil().setHeight(160),
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(10),
              ),
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
              constraints: BoxConstraints(
                minHeight: ScreenUtil().setHeight(140),
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColorNormal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Add Deal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(50),
                    ),
                  ),
                ],
              )),
        )
      ],
    );
  }

  removeSelectedPipelineCallBack() {
    setState(() {
      selectedPipeline = null;
    });
  }

  pipelineOnSelectCallBack(Pipeline pipeline) {
    setState(() {
      selectedPipeline = pipeline;
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

  selectStartTimeCallBack(date) {
    setState(() {
      selectedTaskStartDateTime = date;
    });
  }

  selectDurationTimeCallBack(int minutes) {
    setState(() {
      durationMinutes = minutes;
    });
  }

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
    //   if (_pipelineListBloc != null) {
    //     _pipelineListBloc.getAllActivities();
    //   } else {
    //     _scheduleListBloc.getAllActivities();
    //   }
    // }
    return CustomStreamBuilder(
        retryCallback: _pipelineListBloc != null
            ? _pipelineListBloc.getAllActivities
            : _scheduleListBloc.getAllActivities,
        stream: _pipelineListBloc != null
            ? _pipelineListBloc.allActivities
            : _scheduleListBloc.allActivities,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (!snapshot.hasData &&
          //     (allActivitiesList == null || allActivitiesList.length == 0))
          //   return LoadingIndicator();
          allActivitiesList = snapshot.data as List<Activity>;
          allActivitiesList = allActivitiesList
              .where((s) => s.activityType == ActivityType.task)
              .toList();
          selectedActivity = allActivitiesList?.length == 0
              ? null
              : selectedActivity ?? allActivitiesList?.first;

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
          //   Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         Text('Task Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          //         SizedBox(
          //           width: 20,
          //         ),
          //         Container(
          //             constraints: BoxConstraints(maxWidth: 250),
          //             height: 40,
          //             color: Colors.grey[200],
          //             child: DropdownButton<Activity>(
          //               isDense: false,
          //               isExpanded: true,
          //               hint: Text('No Task Type Available.'),
          //               items: allActivitiesList.map((Activity selection) {
          //                 return DropdownMenuItem<Activity>(
          //                     value: selection,
          //                     child: Center(
          //                       child: Text(selection?.name),
          //                     ));
          //               }).toList(),
          //               onChanged: (value) {
          //                 setState(() {
          //                   selectedActivity = value;
          //                 });
          //               },
          //               value: selectedActivity,
          //             )),
          //         // RaisedButton(
          //         //     color: Theme.of(context).primaryColor,
          //         //     child: Text(
          //         //       'CREATE',
          //         //       style: TextStyle(color: AppColors.normalTextColor),
          //         //     ),
          //         //     shape: RoundedRectangleBorder(
          //         //         borderRadius: BorderRadius.circular(30)),
          //         //     onPressed: () {
          //         //       Navigator.of(context).push(
          //         //           MaterialPageRoute(builder: (BuildContext context) {
          //         //         return BlocProvider<ScheduleListBloc>(
          //         //           bloc: _scheduleListBloc,
          //         //           child: AddActivityPage(),
          //         //         );
          //         //       }));
          //         //     })
          //       ]);
          // },
        });
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
