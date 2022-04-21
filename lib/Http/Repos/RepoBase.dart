import 'package:dio/dio.dart';
import 'package:oauth2/oauth2.dart';

class RepoResponse {
  bool success;
  dynamic model;

  RepoResponse(this.success, this.model);
}

class RepoBase {
  handleError(Exception e) {
    if (e is AuthorizationException) {
      throw e;
    } else {
      print(e.toString());
      throw e;
    }
  }

  Future<RepoResponse> handleResponse(Response response) async {
    if (response.statusCode == 200) {
      return RepoResponse(true, response.data);
    }

    if (response.statusCode == 204) {
      return RepoResponse(true, null);
    }

    if (response.statusCode == 400) {
      return RepoResponse(false, null);
    }

    if (response.statusCode == 404) {
      return RepoResponse(false, null);
    }

    if (response.statusCode == 500) {
      return RepoResponse(false, null);
    }

    if (response.statusCode == 502) {
      return RepoResponse(false, null);
    }

    return RepoResponse(false, null);
  }

  // ResponseDto validateReponse(Response response) {
  //   if (response.statusCode == 200) {

  //     //http requests rather than get will not contain data
  //     if(response.data == null && response.request.method != 'GET')
  //     {
  //       return ResponseDto(true, Constants.httpOk, null, null);
  //     }

  //     else
  //     {
  //        handleError(Exception());
  //     }

  //     return ResponseDto(true, Constants.httpOk, response.data, null);
  //   }

  //   else if (response.statusCode == 401 || response.statusCode == 403)
  //   {
  //     handleError(new AuthorizationException('Error', Constants.httpTokenExpired,null));
  //   }

  //   else
  //   {
  //     handleError(new Exception());
  //   }
  // }

  extractSingleData() {}

  extractListData() {}
}
