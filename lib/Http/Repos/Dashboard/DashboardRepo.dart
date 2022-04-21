import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Models/Core/Dashboard/DashboardModel.dart';

class DashboardRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getDashboardUrl = HttpRequest.baseUrl + 'dashboard';

  Future<RepoResponse> getDashboard() async {
    print('init get dashboard request');
    var response = await HttpRequest.get(getDashboardUrl);

    var result = await handleResponse(response);

    if (result.success) {
      return RepoResponse(true, DashboardModel.fromJson(result.model));
    }

    return RepoResponse(false, null);
  }


    Future<RepoResponse> getDashboardByAppUserId(String id) async {
    print('init get dashboard by id request');
    var response = await HttpRequest.get(getDashboardUrl + "/$id");

    var result = await handleResponse(response);

    if (result.success) {
      return RepoResponse(true, DashboardModel.fromJson(result.model));
    }

    return RepoResponse(false, null);
  }
}
