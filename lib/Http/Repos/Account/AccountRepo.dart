// import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Dto/Payment/Payment.dart';

class AccountRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String renewUrl = HttpRequest.baseUrl + 'renew';
  final String accountInfoUrl = HttpRequest.baseUrl + 'payment';
  final String changeAccountNoUrl = HttpRequest.baseUrl + 'subscription';
  final String changePlanUrl = HttpRequest.baseUrl + "subscription";
  final String cancelPlanUrl = HttpRequest.baseUrl + "subscription/cancel";


  Future<RepoResponse> getRenewInfo(String subId) async {
    print('init get renew request');
    var response = await HttpRequest.getWithOutToken(renewUrl + "/$subId");

    var result = await handleResponse(response);

    if (result.success) {
      var data = AccountInfoDto.fromJson(result.model);
      return RepoResponse(true, data);
    }

    return RepoResponse(false, null);
  }

  Future<RepoResponse> getAccountInfo() async {
    print('init get account request');
    var response = await HttpRequest.get(accountInfoUrl);

    var result = await handleResponse(response);

    if (result.success) {
      var data = AccountInfoDto.fromJson(result.model);
      return RepoResponse(true, data);
    }

    return RepoResponse(false, null);
  }

  Future<Response> changeAccountsNo(int quantity) async {
    print('init change account no request');
    return await HttpRequest.get(changeAccountNoUrl + "/$quantity");
  }

  
  Future<Response> changePlan(String plan) async {
    print('init change account no request');
    return await HttpRequest.put(changePlanUrl + "/$plan", null);
  }

   Future<Response> cancelSub() async {
    print('init cancel account request');
    return await HttpRequest.put(cancelPlanUrl, null);
  }

  

  // Future<Response> add(Activity activity) async {
  //   print('init add activity request');
  //   print('request body:' + activity.toJson().toString());
  //   return await HttpRequest.post(addActivityUrl, activity.toJson());
  // }

  // Future<Response> delete(Activity activity) async {
  //   print('init delete activity request');
  //   print('request body:' + activity.toJson().toString());
  //   return await HttpRequest.delete(addActivityUrl + "/${activity.id}");
  // }

  // Future<Response> update(Activity activity) async {
  //   print('init put activity request');
  //   print('request body:' + activity.toJson().toString());
  //   return await HttpRequest.put(
  //       addActivityUrl + "/${activity.id}", activity.toJson());
  // }
}
