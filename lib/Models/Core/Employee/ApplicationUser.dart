import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';

class ApplicationUser {
  int organizationId;
  List<People> peoples;
  List<Company> companies;
  List<Pipeline> pipeLineFlows;
  //List<Pipeline> pipelinesForDisplayInEmployee;
  String id;
  String name;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  bool isActive;
  bool isManager;
  List<String> roleStrings;

  ApplicationUser(
      {this.isActive,
      this.organizationId,
      this.peoples,
      this.companies,
      this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.isManager,
      this.firstName,
      this.roleStrings,
      this.pipeLineFlows,
      //this.pipelinesForDisplayInEmployee,
      this.lastName});

  factory ApplicationUser.fromJson(Map<String, dynamic> json) =>
      new ApplicationUser(
          organizationId: json["organizationId"],
          peoples: json['peoples'] == null
              ? null
              : new List<People>.from(
                  json["peoples"].map((x) => People.fromJson(x))),
          companies: json['companies'] == null
              ? null
              : new List<Company>.from(
                  json["companies"].map((x) => Company.fromJson(x))),
          pipeLineFlows: json['pipeLineFlows'] == null
              ? null
              : new List<Pipeline>.from(
                  json["pipeLineFlows"].map((x) => Pipeline.fromJson(x))),
          // pipelinesForDisplayInEmployee:
          //     json['pipelinesForDisplayInEmployee'] == null
          //         ? new List<Pipeline>()
          //         : new List<Pipeline>.from(
          //             json["pipelinesForDisplayInEmployee"]
          //                 .map((x) => Pipeline.fromJson(x))),
          id: json["id"],
          name: json["name"],
          firstName: json['firstName'],
          email: json["email"],
          phoneNumber: json["phoneNumber"],
          isActive: json["isActive"],
          roleStrings: json['roleStrings'] == null
              ? null
              : new List<String>.from(json["roleStrings"].map((x) => (x))),
          lastName: json['lastName']);

  Map<String, dynamic> toJson() => {
        "organizationId": organizationId,
        // "pipelinesForDisplayInEmployee": pipelinesForDisplayInEmployee == null
        //     ? null
        //     : new List<dynamic>.from(
        //         pipelinesForDisplayInEmployee.map((x) => x.toJson())),
        "pipeLineFlows": pipeLineFlows == null
            ? null
            : new List<dynamic>.from(pipeLineFlows.map((x) => x.toJson())),
        "peoples": peoples == null
            ? null
            : new List<dynamic>.from(peoples.map((x) => x.toJson())),
        "companies": companies == null
            ? null
            : new List<dynamic>.from(companies.map((x) => x.toJson())),
        "id": id,
        "name": name,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNumber": phoneNumber,
        "isActive": isActive,
        "isManager": isManager
        //"roleStrings":roleStrings
      };

  bool operator ==(o) => o is ApplicationUser && o.id == id;
  int get hashCode => id.hashCode;

  get isAdmin => roleStrings.contains("admin");
  get isManagerFromRoles => roleStrings.contains("manager");
}
