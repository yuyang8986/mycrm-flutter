import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';

class ScheduleRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllEventsUrl = HttpRequest.baseUrl + 'schedule';
  final String addEventUrl = HttpRequest.baseUrl + 'schedule';
  final String putEventUrl = HttpRequest.baseUrl + 'schedule';

  Future<RepoResponse> getAllEvents() async {
    print('init get all events request');
    var response = await HttpRequest.get(getAllEventsUrl);

    var result = await handleResponse(response);

       if (result.success) {
      var data = result.model.map((s) {
        return ScheduleEvent.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<ScheduleEvent>.from(data));
    }

    return RepoResponse(false, null);
  }
}
