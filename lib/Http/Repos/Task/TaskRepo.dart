import 'package:dio/dio.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

class TaskRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllTasksUrl = HttpRequest.baseUrl + 'task';
  final String addTaskUrl = HttpRequest.baseUrl + 'task';

  Future<RepoResponse> getAll() async {
    print('init get all Task request');
    var response = await HttpRequest.get(getAllTasksUrl);

    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return Task.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Task>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(Task task) async {
    print('init add Task request');
    print('request body:' + task.toJson().toString());
    return await HttpRequest.post(addTaskUrl, task.toJson());
  }

  Future<Response> update(Task task) async {
    print('init put Task request');
    print('request body:' + task.toJson().toString());
    return await HttpRequest.put(addTaskUrl + "/${task.id}", task.toJson());
  }

  Future<Response> changeState(String taskId) async {
    print('init put Task request');
    //print('request body:' + appointment.toJson().toString());
    return await HttpRequest.put(addTaskUrl + "/changestate/$taskId", null);
  }

  Future<Response> delete(String id) async {
    print('init delete Task request');
    return await HttpRequest.delete(addTaskUrl + "/$id");
  }
}
