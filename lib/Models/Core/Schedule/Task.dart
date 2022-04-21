import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Schedule/EventBase.dart';

class Task implements EventBase {
  @override
  DateTime completeTime;

  @override
  DateTime createTime;

  @override
  String id;

  @override
  bool isCompleted;

  @override
  bool isReminderOn;

  @override
  String location;

  @override
  String summary;

  @override
  String note;

  @override
  DateTime eventStartDateTime;

  Pipeline pipeline;
  String pipelineId;
  //Employee employee;
  Activity activity;
  String activityId;
  Task(
      {this.id,
      this.summary,
      this.note,
      this.createTime,
      this.isCompleted,
      this.completeTime,
      this.isReminderOn,
      this.location, 
      this.pipeline,
      this.eventStartDateTime,
      this.activity,
      //this.employee,
      this.pipelineId,  
      this.activityId,
      this.durationMinutes});

  factory Task.fromJson(Map<String, dynamic> json) => new Task(    
      id: json["id"],
      summary: json["summary"],
      note: json["note"],
      createTime: DateTimeHelper.parseDotNetDateTimeToDart(json["createdTime"]),
      isCompleted: json["isCompleted"],
      completeTime:
          DateTimeHelper.parseDotNetDateTimeToDart(json["completeTime"]),
      isReminderOn: json["isReminderOn"],
      location: json["location"],
      pipeline:
          json["pipeline"] == null ? null : Pipeline.fromJson(json["pipeline"]),
      //employee:
          //json["employee"] == null ? null : Employee.fromJson(json["employee"]),
      eventStartDateTime:
          DateTimeHelper.parseDotNetDateTimeToDart(json["eventStartDateTime"]),
      activity:
          json["activity"] == null ? null : Activity.fromJson(json["activity"]),
      activityId: json["activityId"],
      pipelineId: json["pipelineId"],
      durationMinutes: json["durationMinutes"]);

  Map<String, dynamic> toJson() => {
        //"id": id,
        "summary": summary,
        "note": note,
        "createdTime": createTime?.toIso8601String(),
        "isCompleted": isCompleted,
        "completeTime": completeTime?.toIso8601String(),
        "isReminderOn": isReminderOn,
        "location": location,
        "pipeline": pipeline == null ? null : pipeline.toJson(),
        //"employee": employee == null ? null : employee.toJson(),
        "activity": activity == null ? null : activity.toJson(),
        "eventStartDateTime": eventStartDateTime?.toIso8601String(),
        "pipelineId": pipelineId,
        "activityId": activityId,
        "durationMinutes": durationMinutes
      };

  @override
  int durationMinutes;
}
