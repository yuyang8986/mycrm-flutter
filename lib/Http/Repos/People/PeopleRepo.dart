import 'package:dio/dio.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Dto/People/ImportPeopleDto.dart';
import 'package:mycrm/Models/Dto/People/ScanPeopleDto.dart';

class PeopleRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllPeoplesUrl = HttpRequest.baseUrl + 'people';
  final String addPeopleUrl = HttpRequest.baseUrl + 'people';
  final String scanPeopleUrl = HttpRequest.baseUrl + 'people/scan';  
  final String putPeopleUrl = HttpRequest.baseUrl + 'people';

  Future<RepoResponse> getAllPeoples() async {
    print('init get all people request');
    var response = await HttpRequest.get(getAllPeoplesUrl);

    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return People.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<People>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<RepoResponse> getAllPeoplesForCurrentEmployee() async {
    print('init get all people for employee request');
    Response response = await HttpRequest.get(getAllPeoplesUrl + "/employee");
    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return People.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<People>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(People people) async {
    print('init add people request');
    print('request body:' + people.toJson().toString());
    return await HttpRequest.post(addPeopleUrl, people.toJson());
  }

    Future<Response> addRange(ImportPeopleDto dto) async {
    print('init add peoples request');
    var json = dto.toJson();
    print(json);
    return await HttpRequest.post(addPeopleUrl+"/import", dto.toJson());
  }

  
  Future<Response> scan(ScanPeopleDto scanPeopleDto) async {
    print('init scan people request');
    print('request body:' + scanPeopleDto.toJson().toString());
    return await HttpRequest.post(scanPeopleUrl, scanPeopleDto.toJson());
  }

    // Future<Response> addRange(ImportPeopleDto dto) async {
    // print('init add peoples request');
    // var json = dto.toJson();
    // print(json);
    // return await HttpRequest.post(addPeopleUrl+"/import", dto.toJson());
  

  

  Future<Response> update(People people) async {
    print('init update stage request');
    print('request body:' + people.toJson().toString());
    return await HttpRequest.put(
        putPeopleUrl + "/${people.id}", people.toJson());
  }

  Future<Response> delete(dynamic id) async {
    print('init delete people request');
    return await HttpRequest.delete(putPeopleUrl + "/$id");
  }
}
