import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Bloc/Event/ScheduleListBloc.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
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

class AppointmentAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppointmentAddState();
  }

  final Pipeline pipeline;
  AppointmentAddPage({this.pipeline});
}

class _AppointmentAddState extends State<AppointmentAddPage> {
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
  Appointment newAppointment;
  DateTime selectedEventStartDateTime;
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
      appBar: GeneralAppBar('Add Appointment', 'Appointment', formKey,
              _scaffoldKey, confirmButtonCallback)
          .create(),
      body: newAppointmentContainer(),
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
    newAppointment = new Appointment();
    if (selectedEventStartDateTime == null) {
      DialogService().show(context, "Please set Event Start Time!");
      return;
    }
    if (durationMinutes == null) {
      DialogService().show(context, "Please set Event Duration!");
      return;
    }

    if (selectedActivity == null) {
      DialogService().show(context, "Please set Appointment Type!");
      return;
    }

    if (selectedPipeline == null) {
      DialogService().show(context, "Please set Deal!");
      return;
    }

    // if (selectedPipeline?.appointment != null ||
    //     selectedPipeline.task != null) {
    //   DialogService().show(context,
    //       'Sorry, only one appointment/task is allowed at a time for a deal.');
    //   return;
    // }
    newAppointment.summary = _nameController.text;
    newAppointment.eventStartDateTime = selectedEventStartDateTime;
    newAppointment.durationMinutes = durationMinutes;
    newAppointment.isReminderOn = isReminderOn;
    newAppointment.location = location;
    newAppointment.note = _noteController.text;
    newAppointment.activityId = selectedActivity.id;
    newAppointment.pipelineId = selectedPipeline.id;
    try {
      //LoadingService.showLoading(context);
      print('begin http request');
      if (_pipelineListBloc != null) {
        await _pipelineListBloc.addAppointment(newAppointment);
        PipelineListPageState.isInit = true;
        if (isReminderOn)
          await NotificationService.scheduleNotifications(new ScheduleEvent(
              appointment: newAppointment,
              eventDateTime: newAppointment.eventStartDateTime,
              eventType: "appointment"));
      } else {
        await _scheduleListBloc.addAppointment(newAppointment);
        if (isReminderOn)
          await NotificationService.scheduleNotifications(new ScheduleEvent(
              appointment: newAppointment,
              eventDateTime: newAppointment.eventStartDateTime,
              eventType: "appointment"));
        //setState(() {});
      }

      //LoadingService.hideLoading(context);
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Appointment Added", context,);
    } catch (e) {
      ErrorService().handlePageLevelException(e, context);
    } finally {
      // setState(() {
      //   isloading = false;
      // });
    }
  }

  Widget newAppointmentContainer() {
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
            VEmptyView(40),
            linkDealRow(),
            VEmptyView(20),
            selectedPipeline == null ? addDealRow : Container(),
            VEmptyView(40),
            selectedPipeline != null ? allActivityDropdown : Container(),

            VEmptyView(40),
            selectedPipeline != null
                ? EventTimeSelectionWidget(
                    selectedEventStartDateTime,
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
            // Center(
            //   child: Text('Note'),
            // ),
            // noteRow,
          ],
        ),
      ),
    );
  }

  // Widget get selectEventEndDateTimeText {
  //   return Container(
  //     child: Text(
  //         TextHelper.checkTextIfNullReturnEmpty(
  //             DateTimeHelper.parseDateTimeToDateHHMM(
  //                 selectedEventStartDateTime)),
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
      noDataDisplay: NoContactInfoGuideWidget(2),
    );
  }

  Widget get addDealRow {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("or",style: TextStyle(fontSize: ScreenUtil().setSp(50),fontWeight: FontWeight.bold),),
        VEmptyView(ScreenUtil().setHeight(40)),
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
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
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

  selectStartTimeCallBack(date) {
    setState(() {
      selectedEventStartDateTime = date;
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

  Widget get allActivityDropdown {
    // if (_pipelineListBloc != null) {
    //   _pipelineListBloc.getAllActivities();
    // } else {
    //   _scheduleListBloc.getAllActivities();
    // }

    return CustomStreamBuilder(
      retryCallback: _pipelineListBloc != null
          ? _pipelineListBloc.getAllActivities
          : _scheduleListBloc.getAllActivities,
      stream: _pipelineListBloc != null
          ? _pipelineListBloc.allActivities
          : _scheduleListBloc.allActivities,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // if (snapshot.connectionState == ConnectionState.active &&
        //     snapshot.data == null) {
        //   return ErrorPage(() {
        //     _pipelineListBloc != null
        //         ? _pipelineListBloc.getAllActivities()
        //         : _scheduleListBloc.getAllActivities();
        //   });
        // }
        // if (snapshot.hasError)
        //   return ErrorPage(_pipelineListBloc != null
        //       ? _pipelineListBloc.getAllActivities()
        //       : _scheduleListBloc.getAllActivities());
        //if (!snapshot.hasData) return LoadingIndicator();
        allActivitiesList = snapshot.data as List<Activity>;
        allActivitiesList = allActivitiesList
            .where((s) => s.activityType == ActivityType.appointment)
            .toList();
        selectedActivity = allActivitiesList?.length == 0
            ? null
            : selectedActivity ?? allActivitiesList?.first;

        return CustomDropdownSelection(
          "Set Type",
          allActivitiesList,
          selectedActivity,
          (v) {
            setState(() {
              selectedActivity = v;
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
      var activity =
          Activity(name: name, activityType: ActivityType.appointment);
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

  Widget get nameRow {
    return TitleInputText(_nameController, "Appointment Summary");
  }
}
