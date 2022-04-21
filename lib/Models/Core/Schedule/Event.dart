import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Schedule/EventBase.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';

class Event implements EventBase {
  @override
  DateTime completeTime;

  @override
  DateTime createTime;

  @override
  DateTime eventStartDateTime;

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
  int durationMinutes;

  Activity activity;
  String activityId;
  Company company;
  int companyId;
  int organizationId;

  Event(
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
      this.activityId,
      this.companyId,
      this.company,
      this.organizationId,
      this.durationMinutes});

  factory Event.fromJson(Map<String, dynamic> json) => new Event(
        id: json["id"],
        summary: json["summary"],
        note: json["note"],
        createTime:
            DateTimeHelper.parseDotNetDateTimeToDart(json["createdTime"]),
        isCompleted: json["isCompleted"],
        completeTime:
            DateTimeHelper.parseDotNetDateTimeToDart(json["completeTime"]),
        isReminderOn: json["isReminderOn"],
        location: json["location"],
        eventStartDateTime: DateTimeHelper.parseDotNetDateTimeToDart(
            json["eventStartDateTime"]),
        activity: json["activity"] == null
            ? null
            : Activity.fromJson(json["activity"]),
        activityId: json["activityId"],
        company:
            json["company"] == null ? null : Company.fromJson(json["company"]),
        companyId: json["companyId"],
        durationMinutes: json["durationMinutes"],
        organizationId: json["organizationId"]
      );

  Map<String, dynamic> toJson() => {
        //"id": id,
        "summary": summary,
        "note": note,
        "createdTime": createTime?.toIso8601String(),
        "isCompleted": isCompleted,
        "completeTime": completeTime?.toIso8601String(),
        "isReminderOn": isReminderOn,
        "location": location,
        "eventStartDateTime": eventStartDateTime?.toIso8601String(),
        //"activity": activity == null ? null : activity.toJson(),
        //"company": company == null ? null : company.toJson(),
        "activityId": activityId,
        "durationMinutes": durationMinutes,
        "companyId": companyId,
        "organizationId":organizationId
      };
}
