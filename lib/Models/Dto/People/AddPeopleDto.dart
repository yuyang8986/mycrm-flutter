// To parse this JSON data, do
//
//     final people = peopleFromJson(jsonString);


class AddPeopleDto {
  bool isCustomer;
  int id;
  String firstName;
  String lastName;
  String workEmail;
  String email;
  String workPhone;
  String phone;
  String companyName;
  AddPeopleDto({
    this.isCustomer,
    this.id,
    this.workEmail,
    this.email,
    this.workPhone,
    this.phone,
    this.firstName,
    this.companyName,
    this.lastName,
  });

  Map<String, dynamic> toJson() => {
        "isCustomer": isCustomer,
        "id": id,
        "workEmail": workEmail,
        "email": email,
        "workPhone": workPhone,
        "phone": phone,
        "companyName": companyName,
        "firstName": firstName,
        "lastName": lastName,
      };
}
