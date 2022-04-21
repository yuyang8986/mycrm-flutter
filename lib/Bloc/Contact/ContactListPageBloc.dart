import 'dart:async';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/Repos/Company/CompanyRepo.dart';
import 'package:mycrm/Http/Repos/Employee/EmployeeRepo.dart';
import 'package:mycrm/Http/Repos/People/PeopleRepo.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Dto/Employee/EmployeeCountDto.dart';
import 'package:mycrm/Models/Dto/People/ImportPeopleDto.dart';
import 'package:mycrm/Models/Dto/People/ScanPeopleDto.dart';
import 'package:rxdart/rxdart.dart';

class ContactListPageBloc extends BlocBase {
  // ContactListPageBloc() {
  //   getAllCompanies();
  //   if (HttpRequest.appUser?.isAdmin ?? false) getEmployeeCount();
  //   if (HttpRequest.appUser?.isManager ?? false) getAllEmployees();
  //   getAllPeoples();
  // }
  final CompanyRepo companyRepo = CompanyRepo();
  final PeopleRepo peopleRepo = PeopleRepo();
  final ApplicationUserRepo employeeRepo = ApplicationUserRepo();

  final BehaviorSubject<List<Company>> allCompaniesController =
      BehaviorSubject<List<Company>>();
  final BehaviorSubject<List<People>> allPeoplesController =
      BehaviorSubject<List<People>>();
  final BehaviorSubject<List<ApplicationUser>> allEmployeesController =
      BehaviorSubject<List<ApplicationUser>>();
  final BehaviorSubject<EmployeeCountDto> employeeCountController =
      BehaviorSubject<EmployeeCountDto>();
  final BehaviorSubject<Company> companyAddController =
      BehaviorSubject<Company>();
  Observable<List<Company>> get allCompaniesStream =>
      allCompaniesController.stream;
  Observable<List<People>> get allPeoplesStream => allPeoplesController.stream;
  Observable<List<ApplicationUser>> get allEmployeesStream =>
      allEmployeesController.stream;
  Observable<EmployeeCountDto> get employeeCountStream =>
      employeeCountController.stream;
  Observable<Company> get companyAddStream => companyAddController.stream;
  Future getAllCompanies() async {
    var result = await companyRepo.getAllCompanies();
    //to refresh another tab data
    //var peopleResult = await peopleRepo.getAllPeoples();
    await handleEndResult(result, allCompaniesController);
    //await handleEndResult(peopleResult, allPeoplesController);
  }

  Future getAllPeoples() async {
    var result = await peopleRepo.getAllPeoples();
    //to refresh another tab data
    //var companyResult = await companyRepo.getAllCompanies();
    await handleEndResult(result, allPeoplesController);
    //await handleEndResult(companyResult, allCompaniesController);
  }

  Future getEmployeeCount() async {
    var result = await employeeRepo.getEmployeeCount();
    await handleEndResult(result, employeeCountController);
  }

  Future getAllEmployees() async {
    var result = await employeeRepo.getAllEmployees();
    await handleEndResult(result, allEmployeesController);
  }

  Future addCompany(Company company) async {
    await companyRepo.add(company);
    await getAllCompanies();
  }

   Future<Company> addCompanyReturnNewCompany(Company company) async {
    var result = await companyRepo.add(company);
    await getAllCompanies();
    return result.model;
  }

  Future scan(ScanPeopleDto scanPeopleDto) async {
    await peopleRepo.scan(scanPeopleDto);
    await getAllPeoples();
  }

  Future addPeople(People people) async {
    await peopleRepo.add(people);
    await getAllPeoples();
  }

  Future addRange(ImportPeopleDto dto) async {
    await peopleRepo.addRange(dto);
    await getAllPeoples();
  }

  Future addEmployee(ApplicationUser employee) async {
    await employeeRepo.add(employee);
    await getAllEmployees();
    await getEmployeeCount();
  }

  Future updateCompany(Company company) async {
    await companyRepo.update(company);
    await getAllCompanies();
  }

  Future updatePeople(People people) async {
    await peopleRepo.update(people);
    await getAllPeoples();
  }

  Future updateEmployee(ApplicationUser employee) async {
    await employeeRepo.update(employee);
    await getAllEmployees();
    await getEmployeeCount();
  }

  Future deleteCompany(int id) async {
    await companyRepo.delete(id);
    await getAllCompanies();
  }

  Future deletePeople(int id) async {
    await peopleRepo.delete(id);
    await getAllPeoples();
  }

  Future deleteEmployee(int id) async {
    await employeeRepo.delete(id);
    await getAllEmployees();
    await getEmployeeCount();
  }

  @override
  void dispose() {
    //allCompaniesController.close();
    //allEmployeesController.close();
    //allPeoplesController.close();
  }
}
