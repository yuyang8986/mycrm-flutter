// To parse this JSON data, do
//
//     final people = peopleFromJson(jsonString);


class ScanPeopleDto {
  String firstName;
  String lastName;
  String address;
  String email;
  String phone;
  String workPhone;
  String company;

  ScanPeopleDto(
      {this.email,
      this.workPhone,
      this.phone,
      this.firstName,
      this.company,
      this.lastName,
      this.address});

  factory ScanPeopleDto.fromJson(Map<String, dynamic> json) =>
      new ScanPeopleDto(
        email: json["email"],
        workPhone: json["workPhone"],
        phone: json["phone"],
        firstName: json['firstName'],
        lastName: json['lastName'],
        company: json["company"],
        address: json["address"]
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "workPhone": workPhone,
        "phone": phone,
        "company": company,
        "firstName": firstName,
        "lastName": lastName,
        "address":address
      };
}
