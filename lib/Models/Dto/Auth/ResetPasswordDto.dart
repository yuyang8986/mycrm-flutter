class ResetPasswordDto {
  String email;
  String password;
  String confirmPassword;
  String verifyCode;
  
  ResetPasswordDto({
    this.email,
    this.password,
    this.confirmPassword,
    this.verifyCode,
  });
  Map<String, dynamic> toJson()=>{
    "email":email,
    "password":password,
    "confirmPassword":confirmPassword,
    "verifyCode":verifyCode,
  };
  
}