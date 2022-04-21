import 'dart:async';
import 'package:collection/collection.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/Repos/Activity/ActivityRepo.dart';
import 'package:mycrm/Http/Repos/Appointment/AppointmentRepo.dart';
import 'package:mycrm/Http/Repos/Event/EventRepo.dart';
import 'package:mycrm/Http/Repos/Schedule/ScheduleRepo.dart';
import 'package:mycrm/Http/Repos/Task/TaskRepo.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/Models/Core/Schedule/Event.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class ScheduleListBloc extends BlocBase {
  final ScheduleRepo _scheduleRepo = ScheduleRepo();
  final ActivityRepo _activityRepo = ActivityRepo();
  final AppointmentRepo _appointmentRepo = AppointmentRepo();
  final EventRepo _eventRepo = EventRepo();
  final TaskRepo _taskRepo = TaskRepo();
  List<ScheduleEvent> scheduleEvents;

  ScheduleListBloc() {
    selectedScheduleDateTime = DateTime.now();
    getEvents();
    getAllActivities();
    //getSelectedDayEvent(selectedScheduleDateTime);
  }
  final _allEventsController =
      BehaviorSubject<Map<DateTime, List<ScheduleEvent>>>();

  final _selectedEventsController = BehaviorSubject<List<ScheduleEvent>>();
  final _allActivitiesController = BehaviorSubject<List<Activity>>();

  Observable<Map<DateTime, List<ScheduleEvent>>> get allEvents =>
      _allEventsController.stream;
  Observable<List<Activity>> get allActivities =>
      _allActivitiesController.stream;
  Observable<List<ScheduleEvent>> get selectedDayEvents =>
      _selectedEventsController.stream;

  DateTime selectedScheduleDateTime;
  // List<ScheduleEvent> selectedScheduleEvents;
  // Map<DateTime, List<ScheduleEvent>> allscheduleEventsMap;

  Future getSelectedDayEvent(selectedScheduleDateTime) async {
    // var response = await _scheduleRepo.getAllEvents();
    // if (!response.success) {
    //   _selectedEventsController.sink.addError(null);
    // }

    var selectedScheduleEvents = scheduleEvents.where((s) {
      switch (s.eventType.toLowerCase()) {
        case "appointment":
          return DateTimeHelper.compareDatesIsSameDate(
              s.appointment.eventStartDateTime, selectedScheduleDateTime);
          break;
        case "event":
          return DateTimeHelper.compareDatesIsSameDate(
              s.event.eventStartDateTime, selectedScheduleDateTime);
          break;
        case "task":
          return DateTimeHelper.compareDatesIsSameDate(
              s.task.eventStartDateTime, selectedScheduleDateTime);
          break;
        default:
          return null;
      }
    }).toList();

    _selectedEventsController.sink.add(selectedScheduleEvents);
  }

  Future getAllActivities() async {
    var model = await _activityRepo.getAllActivity();
    await handleEndResult(model, _allActivitiesController);
  }

  Future getEvents() async {
    var response = await _scheduleRepo.getAllEvents();
    if (!response.success) {
      _allEventsController.sink.addError(null);
    } else {
      scheduleEvents = response.model;
      _allEventsController.sink.add(groupEventsByDate(response.model));
    }

    await getSelectedDayEvent(selectedScheduleDateTime);
    //getSelectedDayEvent(selectedScheduleDateTime);
  }

  Map<DateTime, List<ScheduleEvent>> groupEventsByDate(
      List<ScheduleEvent> scheduleEvents) {
    var groupByDateList;
    var allscheduleEventsMap = Map<DateTime, List<ScheduleEvent>>();
    groupByDateList = groupBy(
        scheduleEvents,
        (ScheduleEvent s) =>
            DateTimeHelper.parseDateTimeToDateIgnoreHHMMSS(s.eventDateTime));

    if (groupByDateList != null && groupByDateList.length > 0) {
      groupByDateList.forEach((p, x) {
        allscheduleEventsMap[p] = x;
      });
    } else {
      allscheduleEventsMap = {};
    }

    return allscheduleEventsMap;
  }

  Future addActivity(Activity activity) async {
    await _activityRepo.add(activity);
    await getAllActivities();
  }

  Future addAppointment(Appointment appointment) async {
    await _appointmentRepo.add(appointment);
    await getEvents();
  }

  Future updateActivity(Activity activity) async {
    await _activityRepo.update(activity);
    await getAllActivities();
  }

  Future updateAppointment(Appointment appointment) async {
    await _appointmentRepo.update(appointment);
    await getEvents();
  }

  Future changeAppointmentState(String appointmentId) async {
    await _appointmentRepo.changeState(appointmentId);
    await getEvents();
  }

  Future deleteActivityById(Activity activity) async {
    await _activityRepo.delete(activity);
    await getAllActivities();
  }

  Future deleteAppointmentById(String id) async {
    await _appointmentRepo.delete(id);
    await getEvents();
  }

  Future addEvent(Event event) async {
    await _eventRepo.add(event);
    await getEvents();
  }

  Future updateEvent(Event event) async {
    await _eventRepo.update(event);
    await getEvents();
  }

  Future deleteEventById(String id) async {
    await _eventRepo.delete(id);
    await getEvents();
  }

  Future addTask(Task task) async {
    await _taskRepo.add(task);
    await getEvents();
  }

  Future updateTask(Task task) async {
    await _taskRepo.update(task);
    await getEvents();
  }

  Future changeTaskState(String taskId) async {
    await _taskRepo.changeState(taskId);
    await getEvents();
  }

  Future deleteTaskById(String id) async {
    await _taskRepo.delete(id);
    await getEvents();
  }

  @override
  void dispose() {
    //_allEventsController.close();
    //_allActivitiesController.close();
    //_selectedEventsController.close();
  }
}
