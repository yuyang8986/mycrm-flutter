// To parse this JSON data, do
//
//     final people = peopleFromJson(jsonString);

import 'dart:convert';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import '../Pipeline/Pipeline.dart';

People peopleFromJson(String str) => People.fromJson(json.decode(str));

String peopleToJson(People data) => json.encode(data.toJson());

class People {
  bool isCustomer;
  int id;
  String applicationUserId;
  ApplicationUser applicationUser;
  String name;
  String firstName;
  String lastName;
  String workEmail;
  String email;
  String workPhone;
  String phone;
  int companyId;
  bool isDeleted;

  List<Pipeline> pipelines;
  Company company;

  People(
      {this.isCustomer,
      this.id,
      this.applicationUserId,
      this.applicationUser,
      this.name,
      this.workEmail,
      this.email,
      this.workPhone,
      this.phone,
      this.companyId,
      this.firstName,
      this.company,
      this.lastName,
      this.pipelines,
      this.isDeleted});

  factory People.fromJson(Map<String, dynamic> json) => new People(
        isCustomer: json["isCustomer"],
        id: json["id"],
        applicationUserId: json["applicationUserId"],
        applicationUser: json["applicationUser"] == null
            ? null
            : ApplicationUser.fromJson(json["applicationUser"]),
        name: json["name"],
        workEmail: json["workEmail"],
        email: json["email"],
        workPhone: json["workPhone"],
        phone: json["phone"],
        companyId: json["companyId"],
        firstName: json['firstName'],
        lastName: json['lastName'],
        isDeleted: json["isDeleted"],
        company:
            json["company"] == null ? null : Company.fromJson(json["company"]),
        pipelines: json['pipelines'] == null
            ? null
            : new List<Pipeline>.from(
                json["pipelines"].map((x) => Pipeline.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isCustomer": isCustomer,
        "id": id,
        "applicationUserId": applicationUserId,
        "name": name,
        "workEmail": workEmail,
        "email": email,
        "workPhone": workPhone,
        "phone": phone,
        "companyId": companyId,
        "firstName": firstName,
        "lastName": lastName,
        "company": company == null ? null : company.toJson(),
        "pipelines": pipelines == null
            ? null
            : new List<dynamic>.from(pipelines.map((x) => x.toJson())),
      };
}
