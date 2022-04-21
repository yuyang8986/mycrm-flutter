class RegisterDto{
  String firstName;
  String lastName;
  String email;
  String phone;
  String organizationName;
  String password;
  String confirmPassword;
  
  RegisterDto({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.organizationName,
    this.password,
    this.confirmPassword,
  });
  Map<String, dynamic> toJson()=>{
    "firstName":firstName,
    "lastName":lastName,
    "email":email,
    "phone":phone,
    "organizationName":organizationName,
    "password":password,
    "confirmPassword":confirmPassword,

  };
}