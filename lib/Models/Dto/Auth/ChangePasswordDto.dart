class ChangePasswordDto {
  String oldPassword;
  String password;
  String confirmPassword;
  
  ChangePasswordDto({
    this.oldPassword,
    this.password,
    this.confirmPassword,
  });
  Map<String, dynamic> toJson()=>{
    "oldPassword":oldPassword,
    "password":password,
    "confirmPassword":confirmPassword,
  };
  
}