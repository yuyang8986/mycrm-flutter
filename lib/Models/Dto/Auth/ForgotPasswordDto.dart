class  ForgotPasswordDto {
  String email;

  ForgotPasswordDto({
    this.email,
  });
  Map<String,dynamic> toJson() =>{
    "email":email,
  };
}