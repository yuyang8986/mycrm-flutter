// To parse this JSON data, do
//
//     final stage = stageFromJson(jsonString);

import 'dart:convert';

import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';

Stage stageFromJson(String str) => Stage.fromJson(json.decode(str));

String stageToJson(Stage data) => json.encode(data.toJson());

class Stage {
  int id;
  String name;
  int displayIndex;
  int iconIndex;
  int thisMonthNumber;
  int thisQuarterNumber;
  int companyId;
  bool isDeleted;
  List<Pipeline> pipelines;
  static List<String> get defaultStageSummaries => [
        'Started',
        'Follow Up',
        'Achieved',
        'UnAchieved',
        'High',
        'Low',
        'New',
        'OnHand',
        'This Month',
        'This Week',
        'This Quarter',
        'Total',
        'Upcoming',
        'Review',
        'Completed',
        'Expired',
        'In Progress',
        'Waiting',
        'Sent',
        'Unsuccess',
        'Made',
        'Success'
      ];

  Stage(
      {this.id,
      this.name,
      this.displayIndex,
      this.thisMonthNumber,
      this.thisQuarterNumber,
      this.companyId,
      this.iconIndex,
      this.isDeleted,
      this.pipelines});

  factory Stage.fromJson(Map<String, dynamic> json) => new Stage(
        id: json["id"],
        name: json["name"],
        displayIndex: json["displayIndex"],
        thisMonthNumber: json["thisMonthNumber"],
        thisQuarterNumber: json["thisQuarterNumber"],
        companyId: json["companyId"],
        iconIndex: json["iconIndex"],
        isDeleted: json["isDeleted"],
        pipelines: json['pipelines'] == null
            ? null
            : new List<Pipeline>.from(
                json["pipelines"].map((x) => Pipeline.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "displayIndex": displayIndex,
        "companyId": companyId,
        "iconIndex": iconIndex,
        "isDeleted": isDeleted,
        "pipelines": pipelines == null
            ? null
            : new List<dynamic>.from(pipelines.map((x) => x.toJson())),
      };

  bool operator ==(o) => o is Stage && o.name == name;
  int get hashCode => name.hashCode;

  get isEditable =>
      name != 'Lead In' &&
      name != "Appointment" &&
      name != "Proposal" &&
      name != "Quotation" &&
      name != "Won" &&
      name != "Lost" &&
      name != "Closed";
}
