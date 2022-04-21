import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Schedule/EventBase.dart';

class Appointment implements EventBase {
  //Employee employee;
  Activity activity;
  String activityId;
  Pipeline pipeline;
  String pipelineId;
  bool isReminderOn;
  String location;
  DateTime eventStartDateTime;

  @override
  DateTime completeTime;

  @override
  DateTime createTime;

  @override
  String id;

  @override
  bool isCompleted;

  @override
  String summary;

  @override
  String note;

  @override
  int durationMinutes;

  Appointment(
      {this.id,
      this.summary,
      this.note,
      this.createTime,
      this.isCompleted,
      this.completeTime,
      this.isReminderOn,
      this.location,
      this.eventStartDateTime,
      this.activity,
    //  this.employee,   
      this.pipeline,
      this.activityId,  
      this.pipelineId,
      this.durationMinutes});

  factory Appointment.fromJson(Map<String, dynamic> json) => new Appointment(
      activity:
          json["activity"] == null ? null : Activity.fromJson(json["activity"]),     
      id: json["id"],
      summary: json["summary"],
      note: json["note"],
      createTime: DateTimeHelper.parseDotNetDateTimeToDart(json["createdTime"]),
      isCompleted: json["isCompleted"],
      completeTime:
          DateTimeHelper.parseDotNetDateTimeToDart(json["completeTime"]),
      isReminderOn: json["isReminderOn"],
      location: json["location"],
      //employee:
        //  json["employee"] == null ? null : Employee.fromJson(json["employee"]),
      pipeline:
          json["pipeline"] == null ? null : Pipeline.fromJson(json["pipeline"]),
      eventStartDateTime:
          DateTimeHelper.parseDotNetDateTimeToDart(json["eventStartDateTime"]),
      activityId: json["activityId"],  
      pipelineId: json["pipelineId"],
      durationMinutes: json["durationMinutes"]);

  Map<String, dynamic> toJson() => {   
        //"id": id,
        "summary": summary,
        "note": note,
        //"createdTime": createTime?.toIso8601String(),
        //"isCompleted": isCompleted,
        //"completeTime": completeTime?.toIso8601String(),
        "isReminderOn": isReminderOn,
        "location": location,
        //"activity": activity == null ? null : activity.toJson(),
        //"employee": employee == null ? null : employee.toJson(),
        //"pipeline": pipeline == null ? null : pipeline.toJson(),
        "eventStartDateTime": eventStartDateTime?.toIso8601String(),
        "pipelineId": pipelineId,     
        "activityId": activityId,        
        "durationMinutes": durationMinutes
      };
}
