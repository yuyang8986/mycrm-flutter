import 'package:dio/dio.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

class CompanyRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllCompaniesUrl = HttpRequest.baseUrl + 'company';
  final String addCompanyUrl = HttpRequest.baseUrl + 'company';
  final String getCompanyByIdUrl = HttpRequest.baseUrl + 'company';
  final String deleteCompanyUrl = HttpRequest.baseUrl + 'company';

  Future<RepoResponse> getAllCompanies() async {
    print('init get all company request');
    var response = await HttpRequest.get(getAllCompaniesUrl);

    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return Company.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Company>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<RepoResponse> getAllCompaniesForCurrentEmployee() async {
    print('init get all company for employee request');
    var response = await HttpRequest.get(getAllCompaniesUrl + "/employee");

    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return Company.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Company>.from(data));
    }

    return RepoResponse(false, null);
  }

  // Future<Company> getCompanyById(int id) async {
  //   var result = await httpRequest.get(getCompanyByIdUrl + '/$id');

  //   try {
  //     if (result.statusCode == 204) return null;
  //     return Company.fromJson(result.data);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  Future<RepoResponse> add(Company company) async {
    print('init add company request');
    print('request body:' + company.toJson().toString());
    var response = await HttpRequest.post(addCompanyUrl, company.toJson());
    var result = await handleResponse(response);
    if (result.success) {
      return RepoResponse(true, Company.fromJson(result.model));
    }
    return  RepoResponse(false, null);
  }

  Future<Response> update(Company company) async {
    print('init put company request');
    print('request body:' + company.toJson().toString());
    return await HttpRequest.put(
        addCompanyUrl + "/${company.id}", company.toJson());
  }

  Future<Response> delete(dynamic id) async {
    print('init delete company request');
    return await HttpRequest.delete(deleteCompanyUrl + "/$id");
  }
}
