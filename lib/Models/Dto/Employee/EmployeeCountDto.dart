class EmployeeCountDto{
    int activeEmployeeCount;
    int totalEmployeeCount;
    EmployeeCountDto({
      this.activeEmployeeCount,
      this.totalEmployeeCount,
    });
    factory EmployeeCountDto.fromJson(Map<String,dynamic> json) => new EmployeeCountDto(
      activeEmployeeCount: json["activeEmployeeCount"],
      totalEmployeeCount: json["totalEmployeeCount"],
    );
}