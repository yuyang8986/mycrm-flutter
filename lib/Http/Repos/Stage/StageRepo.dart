import 'package:dio/dio.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

import '../../../Models/Constants/Constants.dart';
import '../../../Models/Core/Stage/Stage.dart';

class StageRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllStagesUrl = HttpRequest.baseUrl + 'stage';
  final String addStagesUrl = HttpRequest.baseUrl + 'stage';

  Future<RepoResponse> getAllStage({String employeeId}) async {
    print('init get all stages request');
    String url;
    if (employeeId == null) {
      url = getAllStagesUrl;
    } else {
      url = getAllStagesUrl + "/$employeeId";
    }
    var response = await HttpRequest.get(url);
    var result = await handleResponse(response);

     if (result.success) {
      var data = result.model.map((s) {
        return Stage.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Stage>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(Stage stage) async {
    print('init add stage request');
    print('request body:' + stage.toJson().toString());
    return await HttpRequest.post(addStagesUrl, stage.toJson());
  }

  Future<Response> update(Stage stage) async {
    print('init put stage request');
    print('request body:' + stage.toJson().toString());
    return await HttpRequest.put(addStagesUrl + "/${stage.id}", stage.toJson());
  }

  Future<Response> reOrder(int id, int displayIndex) async {
    print('init reorder stage request');
    return await HttpRequest.put(
        HttpRequest.baseUrl +
            'stage/reorder?id=${id.toString()}&displayIndex=${displayIndex.toString()}',
        null);
  }

  Future<Response> delete(int id) async {
    print('init delete stage request');
    return await HttpRequest.delete(HttpRequest.baseUrl + '/stage/$id');
  }
}
