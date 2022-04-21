// To parse this JSON data, do
//
//     final Pipeline = PipelineFromJson(jsonString);

import 'dart:convert';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Views/NextActivity.dart';

Pipeline pipelineFromJson(String str) => Pipeline.fromJson(json.decode(str));

String pipelineToJson(Pipeline data) => json.encode(data.toJson());

class Pipeline {
  String applicationUserId;
  Stage stage;
  int stageId;
  int peopleId;
  People people;
  People personForDisplayInPipeline;
  Company company;
  int companyId;
  String id;
  String dealName;
  double dealAmount;
  String note;
  ApplicationUser applicationUser;
  bool isStarred;
  List<Appointment> appointments;
  String appointmentId;
  Task task;
  String taskId;
  bool isOverdue;
  NextActivity nextActivity;
  int stayedTime;
  String type;
  double cogsAmount;
  double margin;
  DateTime attainDate;
  DateTime createdDate;

  Pipeline(
      {this.applicationUserId,
      this.stage,
      this.stageId,
      this.peopleId,
      this.company,
      this.companyId,
      this.id,
      this.dealName,
      this.dealAmount,
      this.note,
      this.people,
      this.personForDisplayInPipeline,
      this.applicationUser,
      this.isStarred,
      this.appointments,
      this.appointmentId,
      this.task,
      this.taskId,
      this.nextActivity,
      this.stayedTime,
      this.attainDate,
      this.cogsAmount,
      this.margin,
      this.type,
      this.isOverdue,
      this.createdDate});

  factory Pipeline.fromJson(Map<String, dynamic> json) => new Pipeline(
      applicationUserId: json["applicationUserId"],
      stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
      stageId: json["stageId"],
      peopleId: json["peopleId"],
      people: json["people"] == null ? null : People.fromJson(json["people"]),
      personForDisplayInPipeline: json["personForDisplayInPipeline"] == null
          ? null
          : People.fromJson(json["personForDisplayInPipeline"]),
      company:
          json["company"] == null ? null : Company.fromJson(json["company"]),
      nextActivity: json["nextActivity"] == null
          ? null
          : NextActivity.fromJson(json["nextActivity"]),
      companyId: json["companyId"],
      id: json["id"],
      dealName: json["dealName"],
      dealAmount: json["dealAmount"],
      note: json["note"],
      applicationUser: json["applicationUser"] == null
          ? null
          : ApplicationUser.fromJson(json["applicationUser"]),
      appointments: json['appointments'] == null
          ? null
          : new List<Appointment>.from(
              json["appointments"].map((x) => Appointment.fromJson(x))),
      appointmentId: json["appointmentId"],
      task: json["task"] == null ? null : Task.fromJson(json["task"]),
      taskId: json["taskId"],
      isOverdue: json["isOverdue"],
      cogsAmount: json["cogsAmount"],
      margin: json["margin"],
      type: json["type"],
      attainDate: DateTimeHelper.parseDotNetDateTimeToDart(json["attainDate"]),
      stayedTime: json["stayedTime"],
      isStarred: json["isStarred"],
      createdDate :DateTimeHelper.parseDotNetDateTimeToDart(json["createdDate"]),
      );

  Map<String, dynamic> toJson() => {
        "applicationUserId": applicationUserId,
        "stage": stage == null ? null : stage.toJson(),
        "stageId": stageId,
        "peopleId": peopleId,
        "company": company == null ? null : company.toJson(),
        "people": people == null ? null : people.toJson(),
        "companyId": companyId,
        "id": id,
        "dealName": dealName,
        "dealAmount": dealAmount,
        "note": note,
        // "employee": applicationUser == null ? null : applicationUser.toJson(),
        "appointment": appointments == null
            ? null
            : new List<dynamic>.from(appointments.map((x) => x.toJson())),
        "appointmentId": appointmentId,
        "task": task == null ? null : task.toJson(),
        "taskId": taskId,
        "isStarred": isStarred,
        "isOverdue": isOverdue,
        "cogsAmount":cogsAmount,
        "margin":margin,
        "type":type,
        "attainDate":attainDate?.toIso8601String(),
      };
}
