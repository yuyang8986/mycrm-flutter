import 'package:dio/dio.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

class ActivityRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllActivityUrl = HttpRequest.baseUrl + 'activity';
  final String addActivityUrl = HttpRequest.baseUrl + 'activity';

  Future<RepoResponse> getAllActivity() async {
    print('init get all activity request');
    var response = await HttpRequest.get(getAllActivityUrl);

    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return Activity.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Activity>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(Activity activity) async {
    print('init add activity request');
    print('request body:' + activity.toJson().toString());
    return await HttpRequest.post(addActivityUrl, activity.toJson());
  }

  Future<Response> delete(Activity activity) async {
    print('init delete activity request');
    print('request body:' + activity.toJson().toString());
    return await HttpRequest.delete(addActivityUrl + "/${activity.id}");
  }

  Future<Response> update(Activity activity) async {
    print('init put activity request');
    print('request body:' + activity.toJson().toString());
    return await HttpRequest.put(
        addActivityUrl + "/${activity.id}", activity.toJson());
  }
}
