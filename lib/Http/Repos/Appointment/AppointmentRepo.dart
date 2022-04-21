import 'package:dio/dio.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

class AppointmentRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final  String getAllAppointmentsUrl =
      HttpRequest.baseUrl + 'appointment';
  final String addAppointmentUrl = HttpRequest.baseUrl + 'appointment';
  final String putAppointmentUrl = HttpRequest.baseUrl + 'appointment';

  Future<RepoResponse> getAll() async {
    print('init get all appoitments request');
    var response = await HttpRequest.get(getAllAppointmentsUrl);


    var result = await handleResponse(response);
    if (result.success) {
      var data = result.model.map((s) {
        return Appointment.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Appointment>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<Response> add(Appointment appointment) async {
    print('init add appointment request');
    print('request body:' + appointment.toJson().toString());
    return await HttpRequest.post(addAppointmentUrl, appointment.toJson());
  }

  Future<Response> update(Appointment appointment) async {
    print('init put appointment request');
    print('request body:' + appointment.toJson().toString());
    return await HttpRequest.put(
        putAppointmentUrl + "/${appointment.id}", appointment.toJson());
  }

  Future<Response> changeState(String appointmentId) async {
    print('init put appointment request');
    //print('request body:' + appointment.toJson().toString());
    return await HttpRequest.put(
        putAppointmentUrl + "/changestate/$appointmentId", null);
  }

  Future<Response> delete(String id) async {
    print('init delete appointment request');
    return await HttpRequest.delete(addAppointmentUrl + "/$id");
  }
}
