import 'package:dio/dio.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Schedule/Event.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

class EventRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllEventsUrl = HttpRequest.baseUrl + 'event';
  final String addEventUrl = HttpRequest.baseUrl + 'event';

  Future<RepoResponse> getAll() async {
    print('init get all event request');
    var response = await HttpRequest.get(getAllEventsUrl);

    var result = await handleResponse(response);

      if (result.success) {
      var data = result.model.map((s) {
        return Event.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Event>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(Event event) async {
    print('init add Event request');
    print('request body:' + event.toJson().toString());
    return await HttpRequest.post(addEventUrl, event.toJson());
  }

  Future<Response> update(Event event) async {
    print('init put event request');
    print('request body:' + event.toJson().toString());
    return await HttpRequest.put(addEventUrl + "/${event.id}", event.toJson());
  }

  Future<Response> delete(String id) async {
    print('init delete event request');
    return await HttpRequest.delete(addEventUrl + "/$id");
  }
}
