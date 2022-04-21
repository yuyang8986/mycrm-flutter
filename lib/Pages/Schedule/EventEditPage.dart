import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Event/ScheduleListBloc.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Schedule/Event.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/DropSelectionWidget.dart';
import 'package:mycrm/generalWidgets/Shared/NoContactInfoGuideWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetLocationWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetRelationWidget.dart';
import 'package:mycrm/generalWidgets/Shared/TItleInputText.dart';
import '../../Models/Core/Activitty/Activity.dart';

class EventEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventEditState();
  }
}

class _EventEditState extends State<EventEditPage> {
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
  Company selectedCompany;
  Activity selectedActivity;
  Event selectedEvent;
  //DateTime selectedEventStartDateTime;
  //int durationMinutes;
  bool _autoValidate;
  //bool isReminderOn;
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
    selectedEvent = ModalRoute.of(context).settings.arguments;
    if (isInit) {
      selectedActivity = selectedEvent.activity;
      selectedCompany = selectedEvent.company;
      _nameController.text = selectedEvent.summary;
      location = selectedEvent.location;
      //selectedEventStartDateTime = selectedEvent.eventStartDateTime;
      //durationMinutes = selectedEvent.durationMinutes;
      //isReminderOn = selectedEvent.isReminderOn;
      _noteController.text = selectedEvent.note;
      isInit = false;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar('Edit Event', 'Event', formKey, _scaffoldKey,
              confirmButtonCallback)
          .create(),
      body: newEventContainer(),
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
    // if (selectedEventStartDateTime == null) {
    //   DialogService().show(context, "Please set Event Start Time!");
    //   return;
    // }
    // if (durationMinutes == null) {
    //   DialogService().show(context, "Please set Event Duration!");
    //   return;
    // }

    if (selectedActivity == null) {
      DialogService().show(context, "Please set Event Type!");
      return;
    }

    selectedEvent.summary = _nameController.text;
    //selectedEvent.eventStartDateTime = selectedEventStartDateTime;
    //selectedEvent.durationMinutes = durationMinutes;
   // selectedEvent.isReminderOn = isReminderOn;
    selectedEvent.location = location;
    selectedEvent.note = _noteController.text;
    selectedEvent.activityId = selectedActivity.id;
    selectedEvent.companyId = selectedCompany.id;

    try {
      print('begin http request');

      await _scheduleListBloc.updateEvent(selectedEvent);
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Event Updated", context);
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    } finally {
      // setState(() {
      //   isloading = false;
      // });
    }
  }

  Widget newEventContainer() {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 5, right: 5),
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          children: <Widget>[
            //linkPersonRow,
            nameRow,
            linkCompanyRow,
            //linkDealRow(),
            VEmptyView(40),
            locationRow,
            VEmptyView(40),

            allActivityDropdown,
            VEmptyView(40),

            // EventTimeSelectionWidget(
            //     selectedEventStartDateTime,
            //     durationMinutes,
            //     selectStartTimeCallBack,
            //     selectDurationTimeCallBack),
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

  Widget get nameRow {
    return TitleInputText(_nameController, "Event Summary");
  }

  Widget get linkCompanyRow {
    return SetRelationWidget(SetRelationOption.company, (company) {
      setState(() {
        selectedCompany = company;
      });
    }, () {
      selectedCompany = null;
    }, selectedCompany: selectedCompany,noDataDisplay: NoContactInfoGuideWidget(2));
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
  //     selectedEventStartDateTime = date;
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
            .where((s) => s.activityType == ActivityType.event)
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
      },
    );
  }

  createActivityCallBack() {
    DialogService().showTextInput(context, "Create A Activity", "Create",
        (name) async {
      var activity = Activity(name: name, activityType: ActivityType.event);
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
