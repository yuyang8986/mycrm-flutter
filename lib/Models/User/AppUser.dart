enum SubcriptionPlan { none, essential, advanced, premium }

class AppUser {
  String sub;
  bool emailConfirmed;
  String name;
  String firstName;
  String lastName;
  String phone;
  String email;
  String companyName;
  bool isManager;
  bool isAdmin;
  bool isFreeTrail;
  int eventNumbers;
  SubcriptionPlan subscriptionPlan;
  bool isSubExpired;
  //bool isFreeTrail;
  bool isSubAboutToExpire;
  String subId;

  AppUser(
      {this.companyName,
      this.email,
      this.emailConfirmed,
      this.name,
      this.firstName,
      this.lastName,
      this.phone,
      this.isManager,
      this.eventNumbers,
      this.isSubAboutToExpire,
      this.isSubExpired,
      this.isFreeTrail,
      this.subscriptionPlan,
      this.sub,
      this.subId,
      this.isAdmin});

  factory AppUser.fromJson(Map<String, dynamic> json) => new AppUser(
      email: json["email"],
      emailConfirmed: json["emailConfirmed"],
      name: json["name"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      phone: json["phone"],
      companyName: json["companyName"],
      isManager: json["isManager"],
      isFreeTrail: json["isFreeTrail"],
      eventNumbers: json["eventNumbers"],
      isAdmin: json["isAdmin"],
      sub: json["sub"],
      subscriptionPlan: SubcriptionPlan.values[(json["subscriptionPlan"])],
      // isFreeTrail: json["isFreeTrail"],
      isSubAboutToExpire: json["isSubAboutToExpire"],
      isSubExpired: json["isSubExpired"],
      subId: json["subId"]);

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
      };
}
