// To parse this JSON data, do
//
//     final Company = CompanyFromJson(jsonString);

import 'dart:convert';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';

import '../../../Models/Core/contact/People.dart';
import '../Pipeline/Pipeline.dart';

Company companyFromJson(String str) => Company.fromJson(json.decode(str));

String companyToJson( data) => json.encode(data.toJson());

class Company {
    String applicationUserId;   
    ApplicationUser applicationUser;
    int id;
     List<Pipeline> pipelines;
    String name;
    String location;
    String phone;
    String email;
    String secondaryEmail;
    String secondaryPhone;     
    List<People> peoples;
    bool isDeleted;

    Company({
        this.applicationUserId,   
        this.applicationUser,
        this.pipelines,
        this.id,
        this.name,
        this.location,
        this.email,
        this.phone,    
        this.peoples,
        this.secondaryEmail,
        this.secondaryPhone,
        this.isDeleted
    });

    factory Company.fromJson(Map<String, dynamic> json) => new Company(
        applicationUserId: json["applicationUserId"],     
        applicationUser: json["applicationUser"] == null?null:ApplicationUser.fromJson(json["applicationUser"]),
        pipelines: json['pipelines'] == null? null:  new List<Pipeline>.from(json["pipelines"].map((x) => Pipeline.fromJson(x))),
        id: json["id"],
        name: json["name"],
        location: json['location'],
        email: json['email'],
        phone: json['phone'],
        secondaryEmail: json['secondaryEmail'],
        secondaryPhone: json['secondaryPhone'],
        isDeleted: json['isDeleted'],
        peoples: json['peoples'] == null?null: new List<People>.from(json["peoples"].map((x) => People.fromJson(x))),   
    );

    Map<String, dynamic> toJson() => {
        "applicationUserId": applicationUserId,  
         "pipelines": pipelines == null? null: new List<dynamic>.from(pipelines.map((x) => x.toJson())), 
        "id": id,
        "name": name,
        'location':location,
        'email':email,
        'phone': phone,    
        "peoples": peoples == null? null: new List<dynamic>.from(peoples.map((x) => x.toJson())),
        "secondaryPhone":secondaryPhone,
        "secondaryEmail": secondaryEmail,
    };
}