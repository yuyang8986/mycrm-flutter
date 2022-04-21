import 'package:dio/dio.dart';
import 'package:mycrm/Models/Core/TargetTemplate/TargetTemplate.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

import '../../../Models/Constants/Constants.dart';

class TargetTemplateRepo extends RepoBase {
  // final HttpRequest httpRequest = new HttpRequest();
  final String getAllTargetTemplatesUrl =
      HttpRequest.baseUrl + 'targetTemplate';
  final String addTargetTemplatesUrl =
      HttpRequest.baseUrl + 'targetTemplate';

  Future<RepoResponse> getAllTargetTemplate() async {
    print('init get all TargetTemplates request');
    var response = await HttpRequest.get(getAllTargetTemplatesUrl);
    var result = await handleResponse(response);

         if (result.success) {
      var data = result.model.map((s) {
        return TargetTemplate.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<TargetTemplate>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(TargetTemplate targetTemplate) async {
    print('init add TargetTemplate request');
    print('request body:' + targetTemplate.toJson().toString());
    return await HttpRequest.post(
        addTargetTemplatesUrl, targetTemplate.toJson());
  }

  Future<Response> update(TargetTemplate targetTemplate) async {
    print('init put TargetTemplate request');
    print('request body:' + targetTemplate.toJson().toString());
    return await HttpRequest.put(
        addTargetTemplatesUrl + "/${targetTemplate.id}",
        targetTemplate.toJson());
  }

  Future<Response> delete(String id) async {
    print('init delete TargetTemplate request');
    return await HttpRequest.delete(
        HttpRequest.baseUrl + '/targetTemplate/$id');
  }

  Future<Response> enable(String id) async {
    print('init enable TargetTemplate request');
    return await HttpRequest.get(
        HttpRequest.baseUrl + '/targetTemplate/recover/$id');
  }
}
