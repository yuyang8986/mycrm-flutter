
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';

class TargetTemplate {
  String name;
  String id;
  double q1;
  double q2;
  double q3;
  double q4;
  int organizationId;
  bool isArchive;

  List<ApplicationUser> employees;
  List<ApplicationUser> employeesNotInThisTemplate;

  TargetTemplate(
      {this.employees,
      this.id,
      this.name,
      this.q1,
      this.q2,
      this.q3,
      this.q4,
      this.isArchive,
      this.organizationId,
      this.employeesNotInThisTemplate});

  factory TargetTemplate.fromJson(Map<String, dynamic> json) =>
      new TargetTemplate(
        name: json["name"],
        id: json["id"],
        q1: json["q1"],
        q2: json["q2"],
        q3: json["q3"],
        q4: json["q4"],
        isArchive: json["isArchive"],
        organizationId: json["organizationId"],
        employees: json['employees'] == null
            ? null
            : new List<ApplicationUser>.from(
                json["employees"].map((x) => ApplicationUser.fromJson(x))),
        employeesNotInThisTemplate: json['employeesNotInThisTemplate'] == null
            ? null
            : new List<ApplicationUser>.from(json["employeesNotInThisTemplate"]
                .map((x) => ApplicationUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "q1": q1,
        "q2": q2,
        "q3": q3,
        "q4": q4,
        //"isArchive": isArchive,
        // "employeesNotInThisTemplate": employeesNotInThisTemplate == null
        //     ? null
        //     : new List<dynamic>.from(
        //         employeesNotInThisTemplate.map((x) => x.toJson())),
        //"employees": employees == null
           // ? null
            //: new List<dynamic>.from(employees.map((x) => x.toJson())),
      };

  bool operator ==(o) => o is TargetTemplate && o.name == name;
  int get hashCode => name.hashCode;
}
