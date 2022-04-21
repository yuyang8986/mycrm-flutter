import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/Models/Core/Schedule/Event.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';

class ScheduleEvent {
  //a task, or a appointment, or a event, if the prop is null means it is not that type

  Appointment appointment;
  Event event;
  Task task;
  String eventType;
  DateTime eventDateTime;


  ScheduleEvent({this.appointment, this.event, this.task, this.eventType, this.eventDateTime});

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) =>
      new ScheduleEvent(
        appointment: json['appointment'] == null
            ? null
            : new Appointment.fromJson(json['appointment']),
        event: json['event'] == null ? null : new Event.fromJson(json['event']),
        task: json['task'] == null ? null : new Task.fromJson(json['task']),
        eventType: json['eventType'],
        eventDateTime: json["eventDateTime"] == null?null: DateTimeHelper.parseDotNetDateTimeToDart(json["eventDateTime"])
      );
}
