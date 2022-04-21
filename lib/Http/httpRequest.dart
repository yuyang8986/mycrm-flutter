import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/LoadingService/LoadingService.dart';
import 'package:mycrm/dioCacheManager/src/builder_dio.dart';
import 'package:mycrm/dioCacheManager/src/core/config.dart';
import 'package:mycrm/dioCacheManager/src/core/manager.dart';
import 'package:mycrm/dioCacheManager/src/manager_dio.dart';
import 'package:mycrm/env.dart';
import 'package:mycrm/main.dart';
import 'package:oauth2/oauth2.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  bool success;
  String msg;

  LoginResult(this.msg, this.success);
}

class HttpRequest {
  //Client is only for OAuth2 login and store token
  static Client client;
  //static List<Function> pendingOfflineHttpRequests = new List<Function>();
  static String token;

  static final baseUrl = environment["baseUrl"];
  static final tokenEndpoint = environment["tokenEndpoint"];
  //Dio is for all CRUD http request
  static Dio dio = new Dio();
  static DioCacheManager dioCacheManager = new DioCacheManager(CacheConfig(
      baseUrl: HttpRequest.baseUrl,
      databaseName: "dealo",
      skipMemoryCache: true));

  static CacheManager cacheManager =
      new CacheManager(CacheConfig(baseUrl: HttpRequest.baseUrl));
  static AppUser appUser;
  static bool forceRefresh;
  static SharedPreferences prefs;

  Future<LoginResult> initClient(String userName, String password) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //await ensureNetwork();

      //offline mode
      if (MyApp.isOfflineMode) {
        //still need to ensure token is valid from local
        if (prefs.containsKey("token")) {
          //   token = prefs.getString("token");
          //   if (token?.isEmpty ?? true) {
          //     throw Exception("Sign In Expired");
          //   }
          //   if (prefs.containsKey("tokenExpiration")) {
          //     DateTime tokenExpiration =
          //         DateTime.parse(prefs.getString("tokenExpiration"));
          //     if (tokenExpiration.isAfter(DateTime.now())) {
          //       throw Exception("Sign In Expired");
          //     }
          //   } else {
          //     throw Exception("Sign In Expired");
          //   }
          // } else {
          //   throw Exception("Sign In Expired");
          // }

          // //if username keyed in is different to username saved on local for offline mode, thennot allow sign in
          // String usernameSaved = prefs.getString("username");
          // if (usernameSaved == userName) {
          //   appUser = new AppUser();
          //   appUser.companyName = prefs.getString("companyName");
          //   appUser.name = prefs.getString("name");
          //   appUser.email = prefs.getString("email");
          //   appUser.isAdmin = prefs.getBool("isAdmin");
          //   appUser.isManager = prefs.getBool("isManager");
          //   appUser.eventNumbers = prefs.getInt("eventNumbers");
          //   //appUser.isFreeTrail = prefs.getBool("isFreeTrail");
          //   appUser.isSubAboutToExpire = prefs.getBool("isSubAboutToExpire");
          //   appUser.isSubExpired = prefs.getBool("isSubExpired");
          // } else {
          //   //await dioCacheManager.clearAll();
          //   throw Exception("Sign In Expired");
        }
      }

      //online mode
      else {
        //await dioCacheManager.clearAll();
        print("requesting token from $tokenEndpoint");
        client = await resourceOwnerPasswordGrant(
            Uri.parse(tokenEndpoint), userName, password,
            identifier: Constants.identifier, secret: Constants.secret);

        if (client.credentials.accessToken.isNotEmpty) {
          if (prefs.containsKey("username")) {
            String savedUsername = prefs.getString("username");

            if (savedUsername != userName) {
              dioCacheManager.clearAll();
            }
          } else {
            dioCacheManager.clearAll();
          }

          if (prefs.containsKey("token")) {
            prefs.remove("token");
          }
          if (prefs.containsKey("tokenExpiration")) {
            prefs.remove("tokenExpiration");
          }
          await prefs.setString("token", client.credentials.accessToken);
          await prefs.setString(
              "tokenLocalAuth", client.credentials.accessToken);
          await prefs.setString("tokenExpiration",
              client.credentials.expiration.toIso8601String());
          token = client.credentials.accessToken;
          appUser = await fetchAppUserLiveData();

          await prefs.setString("sub", appUser.sub);
          await prefs.setString("username", userName);
          await prefs.setString("companyName", appUser.companyName);
          await prefs.setString("name", appUser.name);
          await prefs.setString("email", appUser.email);
          await prefs.setBool("isAdmin", appUser.isAdmin);
          await prefs.setBool("isManager", appUser.isManager);
          await prefs.setInt("eventNumbers", appUser.eventNumbers);
          return LoginResult("ok", true);
          //await fetchAllRestFul();
        } else {
          throw Exception("Login Failed, invalid Token Generation");
        }
      }
    } catch (e) {
      //client = null;
      // if (e is AuthorizationException) {
      //   if (e.error.toString() == "Subscription Expired") {
      //     //TODO set subId
      //     subId = e.description;
      //     return LoginResult(e.error, false);
      //   }
      // }
      throw e;
    }
  }

  static Future<AppUser> fetchAppUserLiveData() async {
    var result = await dio.get(baseUrl + "user",
        options: Options(
          contentType: "application/json",
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        ));
    print(result.data.toString());
    return AppUser.fromJson(result.data);
  }

  fetchAllRestFul() async {
    // await ActivityRepo().getAllActivity();
    // //await AppointmentRepo().getAll();
    // await CompanyRepo().getAllCompanies();
    // await CompanyRepo().getAllCompaniesForCurrentEmployee();
    // if (appUser.isManager) await ApplicationUserRepo().getAllEmployees();
    // //await EventRepo().getAll();
    // await PeopleRepo().getAllPeoples();
    // await StageRepo().getAllStage();
    // await PeopleRepo().getAllPeoplesForCurrentEmployee();
    // await PipelineRepo().getAllPipelines();
    // await PipelineRepo().getAllPipelinesForCurrentEmployee();
    // await ScheduleRepo().getAllEvents();
    // if (appUser.isManager) await TargetTemplateRepo().getAllTargetTemplate();
    //await TaskRepo().getAll();
  }

  static ensureNetwork() async {
    // try {
    //   var connection = await Connectivity().checkConnectivity();
    //   if (connection != ConnectivityResult.none) {
    //     print('connected');

    //     if (MyApp.isOfflineMode) {
    //       //once has network back, fetch all api calls from server and cache
    //       MyApp.isOfflineMode = false;
    //       //await dioCacheManager.clearAll();
    //       //await fetchAllRestFul();
    //     }
    //   } else {
    //     print('not connected');
    //     MyApp.isOfflineMode = true;
    //   }
    // } catch (e) {
    //   throw e;
    // }
  }

  static logout() async {
    client = null;
    token = null;
    appUser = null;
    //await dioCacheManager.clearAll();
  }

  static logoutLeepToken() async {
    client = null;
    appUser = null;
    //await dioCacheManager.clearAll();
  }

  // ensureValidToken(url) {
  //   // if (client.credentials.isExpired) {
  //   // //MyApp.navigatorKey.currentState.pushNamed(Routes.loginPage);
  //   // throw new AuthorizationException(
  //   // 'Token Error', Constants.httpTokenExpired, Uri.parse(url));
  //   // }
  // }

  static Future<Response> get(String url) async {
    try {
      await ensureNetwork();

      if (dio.interceptors == null || (dio.interceptors?.length ?? 0) == 0)
        dio.interceptors.add(dioCacheManager.interceptor);

      if (forceRefresh ?? false) {
        if (!MyApp.isOfflineMode) {
          await dioCacheManager.clearAll();
          forceRefresh = false;
        }
      }

      Response result = await dio.get(url,
          // options: Options(
          //   contentType: "application/json",
          //   headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
          // )
          // );
          options: buildCacheOptions(
            Duration(minutes: 15),
            options: Options(
                contentType: "application/json",
                headers: {HttpHeaders.authorizationHeader: 'Bearer $token'}),
          ));

      return result;
      //}
    } on SocketException catch (s) {
      print("Not Connected");
      MyApp.isOfflineMode = true;
      //LoadingService.hideLoading(context);
      throw s;
    } catch (e) {
      await dioCacheManager.clearAll();
      //LoadingService.hideLoading(context);
      return handleHttpGetError(e);
      throw e;
    } finally {
      //var canPop = Navigator.canPop(context);
      //if (canPop) {
      //LoadingService.hideLoading(context);
      //}
    }
  }

  static Future<Response> getWithOutToken(String url) async {
    try {
      await ensureNetwork();

      if (dio.interceptors == null || (dio.interceptors?.length ?? 0) == 0)
      dio.interceptors.add(dioCacheManager.interceptor);

      if (forceRefresh ?? false) {
        if (!MyApp.isOfflineMode) {
          await dioCacheManager.clearAll();
          forceRefresh = false;
        }
      }

      Response result = await dio.get(url,
          // options: Options(
          //   contentType: "application/json",
          //   // headers: {
          //   //   HttpHeaders.authorizationHeader:
          //   //       'Bearer ${client.credentials.accessToken}'
          //   // },
          // ));
      options: buildCacheOptions(
        Duration(minutes: 10),
        options: Options(
            contentType: "application/json",
            //headers: {HttpHeaders.authorizationHeader: 'Bearer $token'}
            ),
      ));

      return result;
      //}
    } on SocketException catch (s) {
      print("Not Connected");
      MyApp.isOfflineMode = true;
      //LoadingService.hideLoading(context);
      throw s;
    } catch (e) {
      await dioCacheManager.clearAll();
      //LoadingService.hideLoading(context);
      return handleHttpGetError(e);
      throw e;
    } finally {
      //var canPop = Navigator.canPop(context);
      //if (canPop) {
      //LoadingService.hideLoading(context);
      //}
    }
  }

  static Future<Response> handleHttpGetError(dynamic e) async {
    print('error:' + e.toString());
    print('error type is ' + e.runtimeType.toString());
    //Fluttertoast.showToast(msg: "Oops, something went wrong when loading page");
    if (e is DioError) {
      if (e.error is SocketException) {
        // DialogService().show(
        //     MainPageState.rootContext, "Error 502, Server is not avaliable");
        print("Server is down!!!"); //return;
        return Response(statusCode: 502, data: null);
      }
      if (e.response == null || e.response?.statusCode == null) {
        // DialogService()
        //     .show(MainPageState.rootContext, "Error, no response from server");
        print("Server is not returning response!!!");
        return Response(statusCode: 502, data: null);
      } else if (e.response.statusCode == 403 || e.response.statusCode == 401) {
        // DialogService().show(MainPageState.rootContext,
        //     "Error ${e.response.statusCode} Not Authorized");
        //logout();
        print("Not Authorized!!!");
        Fluttertoast.showToast(msg: "Authentication Expired");
        if (prefs.containsKey("token")) prefs.remove("token");
        if (prefs.containsKey("tokenLocalAuth")) prefs.remove("tokenLocalAuth");
        MainPage.mainPageState?.logOurAndMoveToLoginPage();
        //return;
      } else if (e.response.statusCode == 400) {
        // DialogService()
        //     .show(MainPageState.rootContext, "Error 400: Bad Request");
        print("Resource Not Found!!!");

        return Response(statusCode: 400, data: null);
        //return;
      } else if (e.response.statusCode == 404) {
        // DialogService().show(MainPageState.rootContext, "Error 404: Not Found");
        print("Resource Not Found!!!");

        return Response(statusCode: 404, data: null);
        //return;
      } else if (e.response.statusCode == 500) {
        // DialogService()
        //     .show(MainPageState.rootContext, "Error 500: Server Error");
        print("Server Error!!!");

        return Response(statusCode: 500, data: null);
        //return;
      } else if (e.response.statusCode == 502) {
        // DialogService()
        //     .show(MainPageState.rootContext, "Error 500: Server Error");
        print("Server Error!!!");
        return Response(statusCode: 502, data: null);

        //return;
      }

      //throw e;
      // return Response(
      //     statusCode: e.response.statusCode,
      //     statusMessage: Constants.httpUnexpected);
    } else {
      // final snackBar = SnackBar(
      //   content: Text("Unknown Error: ${e.runtimeType}"),
      // );
      // MyApp.scaffoldKey.currentState?.showSnackBar(snackBar);
      //return Response(statusCode: 500, statusMessage: Constants.httpUnexpected);
      // DialogService()
      //     .show(MainPageState.rootContext, "Error Unknown: Bad Request");
      print("Server Error!!!");
      return Response(statusCode: 500, data: null);
      throw e;
    }
    throw e;
    //throw e;
  }

  static Future<Response> handleHttPostPutError(dynamic e) async {
    print('error:' + e.toString());
    print('error type is ' + e.runtimeType.toString());
    if (e is DioError) {
      if (e.error is SocketException) {
        DialogService().show(MainPageState.rootContext,
            "Server is not avaliable, please try again");
        //return;
        return Response(statusCode: 502, data: e.response.data);
      }
      if (e.response == null || e.response?.statusCode == null) {
        DialogService().show(MainPageState.rootContext,
            "No response from server, please try again later");
        return Response(statusCode: 502, data: e.response.data);
      } else if (e.response.statusCode == 403 || e.response.statusCode == 401) {
        DialogService()
            .show(MainPageState.rootContext, "Operation Not Authorized");
        //logout();
        MainPage.mainPageState.logOurAndMoveToLoginPage();
        //return;
      } else if (e.response.statusCode == 400) {
        Fluttertoast.showToast(
            msg: e.response.data, toastLength: Toast.LENGTH_LONG);
        return Response(statusCode: 400, data: e.response.data);
        //return;
      } else if (e.response.statusCode == 404) {
        DialogService().show(MainPageState.rootContext,
            "Service requested is not found, please try again");
        return Response(statusCode: 404, data: e.response.data);
        //return;
      } else if (e.response.statusCode == 500) {
        DialogService().show(MainPageState.rootContext, "Server Error");
        return Response(statusCode: 500, data: e.response.data);
        //return;
      } else if (e.response.statusCode == 502) {
        DialogService().show(MainPageState.rootContext,
            "Server is not live, please try again later");
        return Response(statusCode: 502, data: e.response.data);

        //return;
      }

      throw e;
      // return Response(
      //     statusCode: e.response.statusCode,
      //     statusMessage: Constants.httpUnexpected);
    } else {
      // final snackBar = SnackBar(
      //   content: Text("Unknown Error: ${e.runtimeType}"),
      // );
      // MyApp.scaffoldKey.currentState?.showSnackBar(snackBar);
      //return Response(statusCode: 500, statusMessage: Constants.httpUnexpected);
      // DialogService()
      //     .show(MainPageState.rootContext, "Error Unknown: Bad Request");
      //return Response(statusCode: 500, data: null);
      Fluttertoast.showToast(msg: "Unknown Error");
      throw e;
    }
    throw e;
    //throw e;
  }

  static Future<Response> post(String url, dynamic data) async {
    try {
      LoadingService.showLoading(MainPageState.rootContext);
      print('http post fired');
      //ensureValidToken(url);
      print('request to ' + url);

      Function postRequest = () async {
        return await dio.post(
          url,
          data: data,
          options: new Options(
            contentType: "application/json",
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
            },
          ),
        );
      };
      if (!MyApp.isOfflineMode) {
        var result = await postRequest();
        LoadingService.hideLoading(MainPageState.rootContext);
        await dioCacheManager.clearAll();
        return result;
      } else {
        //TODO disable post for offline mode
        throw Exception("Offline Can not add item");
        // pendingOfflineHttpRequests.add(postRequest);
        // return Response(statusCode: 200);
      }
    } catch (e) {
      LoadingService.hideLoading(MainPageState.rootContext);
      handleHttPostPutError(e);
      throw e;
    }
  }

  static Future<Response> postWithoutToken(String url, dynamic data) async {
    try {
      LoadingService.showLoading(MainPageState.rootContext);
      print('http post fired');
      //ensureValidToken(url);
      print('request to ' + url);

      var result = await dio.post(
        url,
        data: data.toJson(),
        options: new Options(
          contentType: "application/json",
        ),
      );

      LoadingService.hideLoading(MainPageState.rootContext);
      return result;
    } catch (e) {
      LoadingService.hideLoading(MainPageState.rootContext);
      throw e;
    }
  }

  static Future<Response> put(String url, dynamic data) async {
    try {
      LoadingService.showLoading(MainPageState.rootContext);
      print('http put fired');
      //ensureValidToken(url);
      print('request to ' + url);
      await dioCacheManager.clearAll();

      Function putRequest = () async {
        return await dio.put(url,
            options: new Options(
              contentType: "application/json",
              headers: {
                HttpHeaders.authorizationHeader: 'Bearer $token',
              },
            ),
            data: data);
      };
      if (!MyApp.isOfflineMode) {
        var result = await putRequest();
        LoadingService.hideLoading(MainPageState.rootContext);
        //await dioCacheManager.clearAll();
        return result;
      } else {
        //TODO disable post for offline mode
        throw Exception("Offline Can not update item");
        // pendingOfflineHttpRequests.add(postRequest);
        // return Response(statusCode: 200);

        // pendingOfflineHttpRequests.add(putRequest);
        // return Response(statusCode: 200);
      }
    } catch (e) {
      LoadingService.hideLoading(MainPageState.rootContext);
      return handleHttPostPutError(e);
      throw e;
    }
  }

  static Future<Response> delete(String url) async {
    try {
      LoadingService.showLoading(MainPageState.rootContext);
      print('http delete fired');
      //ensureValidToken(url);
      print('request to ' + url);
      Function deleteRequest = () async {
        return await dio.delete(
          url,
          options: new Options(
            contentType: "application/json",
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
            },
          ),
        );
      };
      if (!MyApp.isOfflineMode) {
        //bool clearCachResult = await dioCacheManager.clearAll();
        //print('caching clearing - ' + (clearCachResult ? "success" : "failed"));
        var result = await deleteRequest();
        LoadingService.hideLoading(MainPageState.rootContext);
        await dioCacheManager.clearAll();
        return result;
      } else {
        //pendingOfflineHttpRequests.add(deleteRequest);
        return Response(statusCode: 200);
      }
    } catch (e) {
      LoadingService.hideLoading(MainPageState.rootContext);
      return handleHttPostPutError(e);
      throw e;
    }
  }

  static Future<Response> deleteWithOutToken(String url) async {
    try {
      LoadingService.showLoading(MainPageState.rootContext);
      print('http delete fired');
      //ensureValidToken(url);
      print('request to ' + url);
      Function deleteRequest = () async {
        return await dio.delete(
          url,
          options: new Options(
            contentType: "application/json",
          ),
        );
      };
      if (!MyApp.isOfflineMode) {
        //bool clearCachResult = await dioCacheManager.clearAll();
        //print('caching clearing - ' + (clearCachResult ? "success" : "failed"));
        var result = await deleteRequest();
        LoadingService.hideLoading(MainPageState.rootContext);
        await dioCacheManager.clearAll();
        return result;
      } else {
        //pendingOfflineHttpRequests.add(deleteRequest);
        return Response(statusCode: 200);
      }
    } catch (e) {
      LoadingService.hideLoading(MainPageState.rootContext);
      return handleHttPostPutError(e);
      throw e;
    }
  }
}
