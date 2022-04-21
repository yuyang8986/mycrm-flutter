import 'package:dio/dio.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Dto/Employee/EmployeeCountDto.dart';

class ApplicationUserRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllEmployeesUrl = HttpRequest.baseUrl + 'employee';
  final String addEmployeeUrl = HttpRequest.baseUrl + 'employee';
  final String getEmployeeByIdUrl = HttpRequest.baseUrl + 'employee';
  final String deleteEmployeeUrl = HttpRequest.baseUrl + 'employee';
  final String getEmployeeCountUrl = HttpRequest.baseUrl + 'organization/employeecount';
  Future<RepoResponse> getAllEmployees() async {
    print('init get all Employee request');
    var response = await HttpRequest.get(getAllEmployeesUrl);

    var result = await handleResponse(response);

     if (result.success) {
      var data = result.model.map((s) {
        return ApplicationUser.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<ApplicationUser>.from(data));
    }

    return RepoResponse(false, null);
  }

 Future<RepoResponse> getEmployeeCount() async {
    print('init get Employee Count request');
    var response = await HttpRequest.get(getEmployeeCountUrl);

    var result = await handleResponse(response);

     if (result.success) {
      return RepoResponse(true, EmployeeCountDto.fromJson(result.model));
    }

    return RepoResponse(false, null);
  }

  // Future<ApplicationUser> getEmployeeById(int id) async {
  //   var result = await httpRequest.get(getEmployeeByIdUrl + '/$id');

  //   try {
  //     if (result.statusCode == 204) return null;
  //     return ApplicationUser.fromJson(result.data);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  Future<Response> add(ApplicationUser employee) async {
    print('init add Employee request');
    print('request body:' + employee.toJson().toString());
    return await HttpRequest.post(addEmployeeUrl, employee.toJson());
  }

  Future<Response> update(ApplicationUser employee) async {
    print('init put Employee request');
    print('request body:' + employee.toJson().toString());
    return await HttpRequest.put(addEmployeeUrl + "/${employee.id}", employee);
  }

  Future<Response> addEmployeeToTemplate(
      String templateId, String employeeId) async {
    print('init addEmployeeToTemplate request');
    return await HttpRequest.put(
        addEmployeeUrl + "/template/$employeeId?templateId=$templateId", null);
  }

  Future<Response> removeEmployeeFromTemplate(String employeeId) async {
    print('init removeEmployeeFromTemplate request');
    return await HttpRequest.delete(
        addEmployeeUrl + "/template/$employeeId");
  }

  Future<Response> delete(dynamic id) async {
    print('init delete Employee request');
    return await HttpRequest.delete(deleteEmployeeUrl + "/$id");
  }
}
