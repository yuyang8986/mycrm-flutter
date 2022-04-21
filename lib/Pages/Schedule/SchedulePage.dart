import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Event/ScheduleListBloc.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/Models/Core/Schedule/Event.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:mycrm/Pages/Activity/AddActivityPage.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/Schedule/AppointmentAddPage.dart';
import 'package:mycrm/Pages/Schedule/AppointmentEditPage.dart';
import 'package:mycrm/Pages/Schedule/EventAddPage.dart';
import 'package:mycrm/Pages/Schedule/EventEditPage.dart';
import 'package:mycrm/Pages/Schedule/TaskAddPage.dart';
import 'package:mycrm/Pages/Schedule/TaskEditPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/NotificationService/NotificationService.dart';
import 'package:mycrm/Styles/BoxDecorations.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/ExpandableListWithNestedListView.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/TopRightNumberNotifier.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:mycrm/table_calendar/table_calendar.dart';

DateTime now = DateTime.now();

class ScheduleListPage extends StatefulWidget {
  ScheduleListPage({Key key}) : super(key: key);

  ScheduleListPageState createState() => ScheduleListPageState();
}

class ScheduleListPageState extends State<ScheduleListPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  CalendarController _calendarController;
  Completer<GoogleMapController> _controller;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  bool isInit;

  final ScheduleListBloc schedulePageBloc = ScheduleListBloc();
  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;
    }
    return Scaffold(body: calendarWithEventsView);
  }

  // @override
  // void dispose() {
  //   //schedulePageBloc.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    isInit = true;
    print("init schedule page");
    _calendarController = CalendarController();
    _controller = Completer();
    super.initState();
  }

  Widget get calendarWithEventsView {
    int eventsHash = 0;
    schedulePageBloc.allEvents.listen((data) {
      if (data != null && data.hashCode != eventsHash) {
        print("on data");
        setState(() {
          _calendarController.setEvents(data);
        });
      }
    }, onDone: () {
      print("on done");
    });
    return CustomStreamBuilder(
      retryCallback: schedulePageBloc.getEvents,
      stream: schedulePageBloc.allEvents,
      builder: (BuildContext context, AsyncSnapshot allEventSnapshot) {
        // if (allEventSnapshot.connectionState == ConnectionState.active &&
        //     allEventSnapshot.data == null) {
        //   return ErrorPage(() {
        //     schedulePageBloc.getEvents();
        //   });
        // }
        // if (allEventSnapshot.hasError)
        //   return ErrorPage(() {
        //     schedulePageBloc.getEvents();
        //   });
        // if (!allEventSnapshot.hasData)
        //   return Center(
        //     heightFactor: 7,
        //     child: LoadingIndicator(),
        //   );
        //initData(snapshot);
        // schedulePageBloc
        //     .getSelectedDayEvent(schedulePageBloc.selectedScheduleDateTime);
        eventsHash = allEventSnapshot.data.hashCode;
        // schedulePageBloc
        //     .getSelectedDayEvent(schedulePageBloc.selectedScheduleDateTime);
        return Column(
          children: <Widget>[
            _buildTableCalendarWithBuilders(allEventSnapshot.data),
            Expanded(
                child: RefreshIndicator(
              child: CustomStreamBuilder(
                retryCallback: schedulePageBloc.getSelectedDayEvent,
                stream: schedulePageBloc.selectedDayEvents,
                builder: (ctx, selectDayEventsSnapshot) {
                  // schedulePageBloc.getSelectedDayEvent(
                  //     schedulePageBloc.selectedScheduleDateTime);
                  // if (!selectDayEventsSnapshot.hasData ||
                  //     selectDayEventsSnapshot.connectionState ==
                  //             ConnectionState.active &&
                  //         selectDayEventsSnapshot.data == null) {
                  //   return LoadingIndicator();
                  // }
                  // if (selectDayEventsSnapshot.hasError)
                  //   return ErrorPage(() {
                  //     schedulePageBloc.getEvents();
                  //   });

                  return SingleChildScrollView(
                    child: Column(
                      //shrinkWrap: true,
                      children: <Widget>[
                        appointmentsList(selectDayEventsSnapshot.data),
                        SizedBox(
                          height: 2,
                        ),
                        eventsList(selectDayEventsSnapshot.data),
                        SizedBox(
                          height: 2,
                        ),
                        tasksList(selectDayEventsSnapshot.data)
                      ],
                    ),
                  );
                },
              ),
              onRefresh: _refreshSchedule,
            ))
          ],
        );
      },
    );
  }

  Future<void> _refreshSchedule() async {
    HttpRequest.forceRefresh = true;
    await schedulePageBloc.getAllActivities();
    HttpRequest.forceRefresh = true;
    await schedulePageBloc.getEvents();
  }

  Widget appointmentsList(List<ScheduleEvent> events) {
    events = events.where((s) => s.appointment != null).toList();
    return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ExpandableListWithNestListView(
            appointmentHeader(events), appointmentRowContent(events)));
  }

  Widget appointmentHeader(events) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TopRightNumberNotifier(
            events.length,
            Container(
              margin: EdgeInsets.all(4),
              child: Text(
                'Appointments',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          HttpRequest.appUser.isManager
              ? PopupMenuButton(
                  onSelected: (v) {
                    if (v == "Appointment") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlocProvider<ScheduleListBloc>(
                          bloc: schedulePageBloc,
                          child: AppointmentAddPage(),
                        );
                      }));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                return BlocProvider<ScheduleListBloc>(
                                  bloc: schedulePageBloc,
                                  child: AddActivityPage(),
                                );
                              },
                              settings: RouteSettings(
                                  arguments: ActivityType.appointment)));
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text("Add Appointment"),
                        value: "Appointment",
                      ),
                      PopupMenuItem(
                        child: Text("Manage Appointment Type"),
                        value: "AppointmentType",
                      )
                    ];
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BlocProvider<ScheduleListBloc>(
                        bloc: schedulePageBloc,
                        child: AppointmentAddPage(),
                      );
                    }));
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                )
        ],
      ),
    );
  }

  Widget appointmentRowContent(List<ScheduleEvent> events) {
    var date = schedulePageBloc.selectedScheduleDateTime;
    return events.length == 0
        ? NoDataWidget(
            "No appointment on ${DateTimeHelper.parseDateTimeToDate(date)}, please add appointment or navigate to another date")
        : Container(
            // constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(300)),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: events?.length,
              itemBuilder: (context, index) {
                if (events == null || events.length == 0) return Container();
                return appointmentRow(
                    events.map((e) => e.appointment).toList()[index]);
              },
            ),
          );
  }

  Widget eventsList(List<ScheduleEvent> events) {
    events = events.where((s) => s.event != null).toList();
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpandableListWithNestListView(
        eventHeader(events),
        eventRowContent(events),
      ),
    );
  }

  Widget eventHeader(events) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TopRightNumberNotifier(
            events.length,
            Container(
              margin: EdgeInsets.all(4),
              child: Text(
                'Events',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          HttpRequest.appUser.isManager
              ? PopupMenuButton(
                  onSelected: (v) {
                    if (v == "Event") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlocProvider<ScheduleListBloc>(
                          bloc: schedulePageBloc,
                          child: EventAddPage(),
                        );
                      }));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                return BlocProvider<ScheduleListBloc>(
                                  bloc: schedulePageBloc,
                                  child: AddActivityPage(),
                                );
                              },
                              settings: RouteSettings(
                                  arguments: ActivityType.event)));
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text("Add Event"),
                        value: "Event",
                      ),
                      PopupMenuItem(
                        child: Text("Manage Event Type"),
                        value: "EventType",
                      )
                    ];
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BlocProvider<ScheduleListBloc>(
                        bloc: schedulePageBloc,
                        child: EventAddPage(),
                      );
                    }));
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                )
        ],
      ),
    );
  }

  Widget eventRowContent(List<ScheduleEvent> events) {
    var date = schedulePageBloc.selectedScheduleDateTime;
    return events.length == 0
        ? NoDataWidget(
            "No Event on ${DateTimeHelper.parseDateTimeToDate(date)}, please add event or navigate to another date")
        : Container(
            // constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(500)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: events?.length,
              itemBuilder: (context, index) {
                if (events == null || events.length == 0) return Container();
                return eventRow(events.map((e) => e.event).toList()[index]);
              },
            ),
          );
  }

  Widget tasksList(List<ScheduleEvent> events) {
    events = events.where((s) => s.task != null).toList();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ExpandableListWithNestListView(
        taskHeader(events),
        taskRowContent(events),
      ),
    );
  }

  Widget taskHeader(events) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TopRightNumberNotifier(
            events.length,
            Container(
              margin: EdgeInsets.all(4),
              child: Text(
                'Tasks',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          HttpRequest.appUser.isManager
              ? PopupMenuButton(
                  onSelected: (v) {
                    if (v == "Task") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlocProvider<ScheduleListBloc>(
                          bloc: schedulePageBloc,
                          child: TaskAddPage(),
                        );
                      }));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                return BlocProvider<ScheduleListBloc>(
                                  bloc: schedulePageBloc,
                                  child: AddActivityPage(),
                                );
                              },
                              settings:
                                  RouteSettings(arguments: ActivityType.task)));
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text("Add Task"),
                        value: "Task",
                      ),
                      PopupMenuItem(
                        child: Text("Manage Task Type"),
                        value: "TaskType",
                      )
                    ];
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BlocProvider<ScheduleListBloc>(
                        bloc: schedulePageBloc,
                        child: TaskAddPage(),
                      );
                    }));
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
        ],
      ),
    );
  }

  Widget taskRowContent(List<ScheduleEvent> events) {
    var date = schedulePageBloc.selectedScheduleDateTime;

    return events.length == 0
        ? NoDataWidget(
            "No Task on ${DateTimeHelper.parseDateTimeToDate(date)}, please add task or navigate to another date")
        : Container(
            // constraints: BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: events?.length,
              itemBuilder: (context, index) {
                if (events == null || events.length == 0) return Container();
                return taskRow(events.map((e) => e.task).toList()[index]);
              },
            ),
          );
  }

  Widget appointmentRow(Appointment appointment) {
    //bool expired = appointment.eventStartDateTime.isBefore(now);
    return Card(
        elevation: 5,
        child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.12,
            actions: <Widget>[
              IconSlideAction(
                //caption: '',
                color:
                    appointment.isCompleted ? Colors.grey : Colors.green[700],
                icon: Icons.check,
                onTap: () async {
                  if (appointment.isCompleted) return;
                  await schedulePageBloc.changeAppointmentState(appointment.id);
                },
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                //caption: '',
                color: Colors.yellow[700],
                icon: Icons.alarm,
                onTap: () async {
                  DialogService().showConfirm(
                      context,
                      "Turn alarm " +
                          (appointment.isReminderOn ? "Off?" : "On?"),
                      () async {
                    appointment.isReminderOn = !appointment.isReminderOn;
                    await schedulePageBloc.updateAppointment(appointment);
                    if (appointment.isReminderOn)
                      await NotificationService.scheduleNotifications(
                          new ScheduleEvent(
                              appointment: appointment,
                              eventDateTime: appointment.eventStartDateTime,
                              eventType: "appointment"));
                    Navigator.pop(context);
                  });
                },
              ),
              IconSlideAction(
                //caption: '',
                color: Colors.blue[700],
                icon: Icons.edit,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return BlocProvider<ScheduleListBloc>(
                              bloc: schedulePageBloc,
                              child: AppointmentEditPage(),
                            );
                          },
                          settings: RouteSettings(arguments: appointment)));
                },
              ),
              IconSlideAction(
                //caption: '',
                color: Colors.red[700],
                icon: Icons.delete,
                onTap: () async {
                  DialogService().showConfirm(context,
                      "Are you sure to delete this Appointment? This can not be reversed!",
                      () async {
                    await schedulePageBloc
                        .deleteAppointmentById(appointment.id);
                    setState(() {});
                    Navigator.pop(context);
                  });
                },
              ),
            ],
            child: appointmentRowText(appointment)));
  }

  Widget appointmentRowText(Appointment appointment) {
    return Material(
        child: Container(
      //elevation: 5,
      child: InkWell(
        onTap: () async {
          Future cameraPostionFuture = _getLatlng(appointment.location);
          await showModalBottomSheet(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Container(
                    //padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: new Text(
                            "Appointment Details:",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          )),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
                          child: new Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {1: FractionColumnWidth(.6)},
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Summary: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(appointment.summary),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Type: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            appointment.activity?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Location: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            appointment.location)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Name: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            appointment.pipeline?.dealName)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Amount:"),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            appointment.pipeline?.dealAmount
                                                .toStringAsFixed(2))),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Contact Person: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            appointment
                                                .pipeline?.people?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Date: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            DateTimeHelper.parseDateTimeToDate(
                                                appointment
                                                    .eventStartDateTime))),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Company: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            appointment.pipeline?.people != null
                                                ? appointment.pipeline?.people
                                                    ?.company?.name
                                                : appointment
                                                    .pipeline?.company?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Reminder:"),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(appointment.isReminderOn
                                        ? "On"
                                        : "Off"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: cameraPostionFuture,
                          builder: (ctx, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            CameraPosition cameraPosition =
                                snapshot.data as CameraPosition;

                            return _googleMapView(cameraPosition,
                                appointment.id, appointment.summary);
                          },
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
            margin: EdgeInsets.only(left: 15, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Type: ' +
                        TextHelper.checkTextIfNullReturnEmpty(
                            appointment.activity?.name)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Deal Name: ' + appointment.pipeline.dealName),
                    Row(
                      children: <Widget>[
                        Text(appointment.pipeline?.people == null
                            ? "Company: " +
                                TextHelper.checkTextIfNullReturnTBD(
                                    appointment.pipeline?.company?.name)
                            : "Company: " +
                                TextHelper.checkTextIfNullReturnTBD(appointment
                                    .pipeline?.people?.company?.name)),
                                    WEmptyView(30),
                        appointment.isReminderOn
                            ? Icon(
                                Icons.alarm,
                                color: Colors.green,
                              )
                            : Container()
                      ],
                    ),
                    Text('Contact Person: ' +
                        TextHelper.checkTextIfNullReturnTBD(
                            appointment.pipeline?.people?.name)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Time: ' +
                        TextHelper.checkTextIfNullReturnEmpty(
                            DateTimeHelper.parseDateTimeToHHMMOnly(
                                    appointment.eventStartDateTime) +
                                "-" +
                                TextHelper.checkTextIfNullReturnEmpty(
                                    DateTimeHelper.parseDateTimeToHHMMOnly(
                                        appointment.eventStartDateTime.add(
                                            Duration(
                                                minutes: appointment
                                                    .durationMinutes)))))),
                    VEmptyView(30),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: ScreenUtil().setHeight(50),
                      width: ScreenUtil().setWidth(280),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text("Show Details",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "QuickSand",
                                fontSize: ScreenUtil().setSp(35))),
                      ),
                    ),
                    VEmptyView(30),
                    Divider(
                      height: 2,
                      color: Colors.blue,
                    )
                  ],
                ),
                appointment.isCompleted
                    ? Icon(
                        Icons.check_box,
                        color: Colors.green,
                      )
                    : Container()
              ],
            )),
      ),
    ));
  }

  Widget eventRow(Event event) {
    // bool expired = event.eventStartDateTime.isBefore(now);
    return Card(
        elevation: 5,
        child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.12,
            secondaryActions: <Widget>[
              IconSlideAction(
                //caption: '',
                color: Colors.yellow[700],
                icon: Icons.alarm,
                onTap: () {
                  DialogService().showConfirm(context,
                      "Turn alarm " + (event.isReminderOn ? "Off?" : "On?"),
                      () async {
                    event.isReminderOn = !event.isReminderOn;
                    await schedulePageBloc.updateEvent(event);
                    if (event.isReminderOn)
                      await NotificationService.scheduleNotifications(
                          new ScheduleEvent(
                              event: event,
                              eventDateTime: event.eventStartDateTime,
                              eventType: "event"));
                    Navigator.pop(context);
                  });
                },
              ),
              IconSlideAction(
                //caption: '',
                color: Colors.blue[700],
                icon: Icons.edit,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return BlocProvider<ScheduleListBloc>(
                              bloc: schedulePageBloc,
                              child: EventEditPage(),
                            );
                          },
                          settings: RouteSettings(arguments: event)));
                },
              ),
              IconSlideAction(
                //caption: '',
                color: Colors.red[700],
                icon: Icons.delete,
                onTap: () {
                  DialogService().showConfirm(context,
                      "Are you sure to delete this event? This can not be reversed!",
                      () async {
                    await schedulePageBloc.deleteEventById(event.id);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
            child: eventRowText(event)));
  }

  Widget eventRowText(Event event) {
    return Material(
        child: Container(
      // elevation: 5,
      child: InkWell(
        onTap: () async {
          Future cameraPostionFuture = _getLatlng(event.location);
          await showModalBottomSheet(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Container(
                    //padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: Text(
                            "Event Details:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
                          child: new Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {1: FractionColumnWidth(.6)},
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Summary: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(event.summary),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Type: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            event.activity?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Location: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            event.location)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Date: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            DateTimeHelper.parseDateTimeToDate(
                                                event.eventStartDateTime))),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Company: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            event.company?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Reminder:"),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        event.isReminderOn ? "On" : "Off"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: cameraPostionFuture,
                          builder: (ctx, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            CameraPosition cameraPosition =
                                snapshot.data as CameraPosition;

                            return _googleMapView(
                                cameraPosition, event.id, event.summary);
                          },
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
          margin: EdgeInsets.only(left: 15, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Type: ' +
                      TextHelper.checkTextIfNullReturnEmpty(
                          event.activity.name)),
                          WEmptyView(30),
                  event.isReminderOn
                      ? Icon(
                          Icons.alarm,
                          color: Colors.green,
                        )
                      : Container()
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text("Company: " +
                  TextHelper.checkTextIfNullReturnTBD(event.company.name)),
              SizedBox(
                height: 5,
              ),
              Text('Time: ' +
                  TextHelper.checkTextIfNullReturnEmpty(DateTimeHelper
                          .parseDateTimeToHHMMOnly(event.eventStartDateTime) +
                      "-" +
                      TextHelper.checkTextIfNullReturnEmpty(
                          DateTimeHelper.parseDateTimeToHHMMOnly(
                              event.eventStartDateTime.add(
                                  Duration(minutes: event.durationMinutes)))))),
              VEmptyView(30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: ScreenUtil().setHeight(50),
                width: ScreenUtil().setWidth(280),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text("Show Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "QuickSand",
                          fontSize: ScreenUtil().setSp(35))),
                ),
              ),
              VEmptyView(30),
              Divider(
                height: 2,
                color: Colors.blue,
              )
            ],
          ),
        ),
      ),
    ));
  }

  Widget taskRow(Task task) {
    //bool expired = task.eventStartDateTime.isBefore(now);
    return Card(
        elevation: 5,
        child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.12,
            actions: <Widget>[
              IconSlideAction(
                //caption: '',
                color: task.isCompleted ? Colors.grey : Colors.green[700],
                icon: Icons.check,
                onTap: () async {
                  if (task.isCompleted) return;
                  await schedulePageBloc.changeTaskState(task.id);
                },
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                //caption: '',
                color: Colors.yellow[700],
                icon: Icons.alarm,
                onTap: () {
                  DialogService().showConfirm(context,
                      "Turn alarm " + (task.isReminderOn ? "Off?" : "On?"),
                      () async {
                    task.isReminderOn = !task.isReminderOn;
                    await schedulePageBloc.updateTask(task);
                    if (task.isReminderOn)
                      await NotificationService.scheduleNotifications(
                          new ScheduleEvent(
                              task: task,
                              eventDateTime: task.eventStartDateTime,
                              eventType: "task"));
                    Navigator.pop(context);
                  });
                },
              ),
              IconSlideAction(
                //caption: '',
                color: Colors.blue[700],
                icon: Icons.edit,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return BlocProvider<ScheduleListBloc>(
                              bloc: schedulePageBloc,
                              child: TaskEditPage(),
                            );
                          },
                          settings: RouteSettings(arguments: task)));
                },
              ),
              IconSlideAction(
                //caption: '',
                color: Colors.red[700],
                icon: Icons.delete,
                onTap: () {
                  DialogService().showConfirm(context,
                      "Are you sure to delete this task? This can not be reversed!",
                      () async {
                    await schedulePageBloc.deleteTaskById(task.id);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
            child: taskRowText(task)));
  }

  Widget taskRowText(Task task) {
    return Material(
        child: Container(
      //elevation: 5,
      child: InkWell(
        onTap: () async {
          Future cameraPostionFuture = _getLatlng(task.location);
          await showModalBottomSheet(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    //padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: Text(
                            "Task Details:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
                          child: new Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {1: FractionColumnWidth(.6)},
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Summary: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(task.summary),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Type: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            task.activity?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Location: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            task.location)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Name: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            task.pipeline?.dealName)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Amount:"),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(task
                                            .pipeline?.dealAmount
                                            .toStringAsFixed(2))),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Contact Person: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            task.pipeline?.people?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Date: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            DateTimeHelper.parseDateTimeToDate(
                                                task.eventStartDateTime))),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Company: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        TextHelper.checkTextIfNullReturnTBD(
                                            task.pipeline?.people != null
                                                ? task.pipeline?.people?.company
                                                    ?.name
                                                : task
                                                    .pipeline?.company?.name)),
                                  ),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Reminder:"),
                                    ),
                                  ),
                                  new TableCell(
                                    child: new Text(
                                        task.isReminderOn ? "On" : "Off"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: cameraPostionFuture,
                          builder: (ctx, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            CameraPosition cameraPosition =
                                snapshot.data as CameraPosition;

                            return _googleMapView(
                                cameraPosition, task.id, task.summary);
                          },
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
            margin: EdgeInsets.only(left: 15, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('Type: ' +
                            TextHelper.checkTextIfNullReturnEmpty(
                                task.activity?.name)),
                                WEmptyView(30),
                        task.isReminderOn
                            ? Icon(
                                Icons.alarm,
                                color: Colors.green,
                              )
                            : Container()
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Text('Deal Name: ' +
                            TextHelper.checkTextIfNullReturnEmpty(
                                task.pipeline?.dealName))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(task.pipeline?.people == null
                        ? 'Company: ' +
                            TextHelper.checkTextIfNullReturnTBD(
                                task.pipeline?.company?.name)
                        : 'Company: ' +
                            TextHelper.checkTextIfNullReturnEmpty(
                                task.pipeline?.people?.company?.name)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Contact Person: ' +
                        TextHelper.checkTextIfNullReturnEmpty(
                            task.pipeline?.people?.name)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Time: ' +
                        TextHelper.checkTextIfNullReturnEmpty(
                            DateTimeHelper.parseDateTimeToHHMMOnly(
                                    task.eventStartDateTime) +
                                "-" +
                                TextHelper.checkTextIfNullReturnEmpty(
                                    DateTimeHelper.parseDateTimeToHHMMOnly(
                                        task.eventStartDateTime.add(Duration(
                                            minutes: task.durationMinutes)))))),
                    VEmptyView(30),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: ScreenUtil().setHeight(50),
                      width: ScreenUtil().setWidth(280),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text("Show Details",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "QuickSand",
                                fontSize: ScreenUtil().setSp(35))),
                      ),
                    ),
                    VEmptyView(30),
                    Divider(
                      height: 2,
                      color: Colors.blue,
                    )
                  ],
                ),
                task.isCompleted
                    ? Icon(
                        Icons.check_box,
                        color: Colors.green,
                      )
                    : Container()
              ],
            )),
      ),
    ));
  }

  // Widget topBar() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 15),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         Center(
  //           child: Text(
  //             DateTimeHelper.parseDateTimeToYYMM(DateTime.now()),
  //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         Material(
  //           color: Colors.grey,
  //           borderRadius: BorderRadius.circular(5),
  //           child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   // schedulePageBloc.selectedScheduleDateTime = DateTime.now();
  //                   _calendarController.setSelectedDay(DateTime.now());
  //                 });
  //               },
  //               child: Padding(
  //                 padding: EdgeInsets.all(3),
  //                 child: Text(
  //                   "Today",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //               )),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEventsMarker(DateTime date, List events) {
    return
        //AnimatedContainer(
        // duration: const Duration(milliseconds: 100),
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   color: _calendarController.isSelected(date)
        //       ? Colors.brown[500]
        //       : _calendarController.isToday(date)
        //           ? Colors.brown[300]
        //           : Colors.blue[400],
        // ),
        // width: 16.0,
        // height: 16.0,
        //child:
        Center(
      child: Text(
        '*',
        //'${events.length}',
        style: TextStyle().copyWith(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
    );
    //);
  }

  void _onDaySelected(DateTime day, List events) async {
    schedulePageBloc.selectedScheduleDateTime = day;
    await schedulePageBloc.getSelectedDayEvent(day);
  }

  Widget _buildTableCalendarWithBuilders(
      Map<DateTime, List<ScheduleEvent>> allscheduleEventsMap) {
    return Container(
      //elevation: 5,
      color: Colors.grey[600],
      child: TableCalendar(
        rowHeight: 65,
        headerVisible: true,
        //startDay: DateTime.now(),
        calendarController: _calendarController,
        events: allscheduleEventsMap,
        initialCalendarFormat: CalendarFormat.week,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        calendarStyle: CalendarStyle(
          markersColor: Colors.purple[500],
          canEventMarkersOverflow: true,
          outsideDaysVisible: false,
          weekendStyle: TextStyle().copyWith(color: Colors.white),
          holidayStyle: TextStyle().copyWith(color: Colors.white),
          weekdayStyle: TextStyle().copyWith(color: Colors.white),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.white),
          weekdayStyle: TextStyle().copyWith(color: Colors.white),
        ),
        headerStyle: HeaderStyle(
            leftChevronIcon: Icon(
              FontAwesomeIcons.arrowAltCircleLeft,
              color: Colors.white,
            ),
            rightChevronIcon: Icon(
              FontAwesomeIcons.arrowAltCircleRight,
              color: Colors.white,
            ),
            centerHeaderTitle: true,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            formatButtonVisible: false,
            formatButtonTextStyle: TextStyles.whiteText,
            formatButtonDecoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(5))),
        // builders: CalendarBuilders(
        //   // selectedDayBuilder: (context, date, _) {
        //   //   return Container(
        //   //     margin: const EdgeInsets.all(4.0),
        //   //     padding: const EdgeInsets.only(top: 5.0, left: 6.0),
        //   //     color: Colors.deepOrange[300],
        //   //     width: 100,
        //   //     height: 100,
        //   //     child: Text(
        //   //       '${date.day}',
        //   //       style: TextStyle().copyWith(fontSize: 16.0),
        //   //     ),
        //   //   );
        //   // // },
        //   // todayDayBuilder: (context, date, _) {
        //   //   return Container(
        //   //     margin: const EdgeInsets.all(4.0),
        //   //     padding: const EdgeInsets.only(top: 5.0, left: 6.0),
        //   //     color: Colors.amber[400],
        //   //     width: 100,
        //   //     height: 100,
        //   //     child: Text(
        //   //       '${date.day}',
        //   //       style: TextStyle().copyWith(fontSize: 16.0),
        //   //     ),
        //   //   );
        //   // },
        //   markersBuilder: (context, date, allscheduleEventsMap, holidays) {
        //     final children = <Widget>[];

        //     if (allscheduleEventsMap.isNotEmpty) {
        //       children.add(
        //         Positioned(
        //           right: 1,
        //           bottom: 1,
        //           child:
        //               _buildEventsMarker(date, allscheduleEventsMap.toList()),
        //         ),
        //       );
        //     }

        //     // if (holidays.isNotEmpty) {
        //     //   children.add(
        //     //     Positioned(
        //     //       right: -2,
        //     //       top: -2,
        //     //       child: _buildHolidaysMarker(),
        //     //     ),
        //     //   );
        //     // }

        //     return children;
        //   },
        // ),

        onDaySelected: (date, events) {
          _onDaySelected(date, events);
        },
        onVisibleDaysChanged: (d, dd, f) {},
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  // @override
  // bool get wantKeepAlive => false;

  Widget _googleMapView(CameraPosition cameraPosition, String id, String name) {
    print("init map");
    return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 40),
        height: 200,
        child: GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            markers: {
              Marker(
                  markerId: MarkerId(id),
                  position: LatLng(cameraPosition.target.latitude,
                      cameraPosition.target.longitude),
                  infoWindow: InfoWindow(title: name)),
            }));
  }

  Future<dynamic> _getLatlng(String location) async {
    print("get Latlng for" + location);
    var initPostion;
    PermissionStatus permissionawait =
        await LocationPermissions().requestPermissions();
    if (permissionawait == PermissionStatus.granted) {
      if (location != null) {
        var address = await Geocoder.local.findAddressesFromQuery(location);
        var latlng = address.first;
        initPostion = CameraPosition(
            target: LatLng(
                latlng.coordinates.latitude, latlng.coordinates.longitude),
            zoom: 15);
      } else {
        //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        initPostion = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15);
      }
    }
    return await Future.value(initPostion);
  }
}
