import 'dart:async';

import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/Repos/Activity/ActivityRepo.dart';
import 'package:mycrm/Http/Repos/Appointment/AppointmentRepo.dart';
import 'package:mycrm/Http/Repos/Employee/EmployeeRepo.dart';
import 'package:mycrm/Http/Repos/People/PeopleRepo.dart';
import 'package:mycrm/Http/Repos/Pipeline/PipelineRepo.dart';
import 'package:mycrm/Http/Repos/Task/TaskRepo.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Schedule/Appointment.dart';
import 'package:mycrm/Models/Core/Schedule/Task.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class PipelineListBloc extends BlocBase {
  final _pipelineRepo = PipelineRepo();
  final _peopleRepo = PeopleRepo();
  final _activityRepo = ActivityRepo();
  final _appointmentRepo = AppointmentRepo();
  final _employeeRepo = ApplicationUserRepo();
  final _taskRepo = TaskRepo();

  List<People> allPeoplesList = new List<People>();
  List<Pipeline> allPipelinesList = new List<Pipeline>();
  PipelineListBloc() {
    getAllPipelines();
    getAllActivities();
    if (HttpRequest.appUser.isManager) getAllEmployees();
    getAllPeoples();
  }

  final _allPipelineController = BehaviorSubject<List<Pipeline>>();

  // final _allPipelineOnDateController =
  //     StreamController<List<Pipeline>>.broadcast();

  final _allActivitiesController = BehaviorSubject<List<Activity>>();

  final _allEmployeesController = BehaviorSubject<List<ApplicationUser>>();

  final _allPeoplesController = BehaviorSubject<List<People>>();

  final _allPeoplesWithinCompanyController = BehaviorSubject<List<People>>();

  //StreamSink<List<Pipeline>> _allPipelineOnDateSink;

  Observable<List<Pipeline>> get allPipelines => _allPipelineController.stream;
  Observable<List<People>> get allPeoples => _allPeoplesController.stream;
  Observable<List<People>> get allPeoplesWithingCompany =>
      _allPeoplesWithinCompanyController.stream;

  Observable<List<ApplicationUser>> get allEmployeesStream =>
      _allEmployeesController.stream;

  // Stream<List<Pipeline>> get allPipelinesOnDate =>
  //     _allPipelineOnDateController.stream;
  Observable<List<Activity>> get allActivities =>
      _allActivitiesController.stream;

  DateTime selectedDateTime;

  //List<Pipeline> allPipelineData;

  Future addTask(Task task) async {
    await _taskRepo.add(task);
    await getAllPipelines();
  }

  Future getAllEmployees() async {
    var response = await _employeeRepo.getAllEmployees();
    await handleEndResult(response, _allEmployeesController);
  }

  Future getAllPeoples() async {
    var response = await _peopleRepo.getAllPeoplesForCurrentEmployee();
    allPeoplesList = response?.model;
    await handleEndResult(response, _allPeoplesController);
  }

  Future getAllPeoplesWithinCompany(int companyId) async {
    // var response = await _peopleRepo.getAllPeoples();
    if (allPeoplesList == null) {
      _allPeoplesWithinCompanyController.sink.addError(null);
    } else {
      var peoplesWithinCompany = allPeoplesList.where((s) {
        return s.company.id == companyId;
      }).toList();
      _allPeoplesWithinCompanyController.sink.add(peoplesWithinCompany);
    }
  }

  // getPipelinesByStage(Stage stage) async {
  //   _allPipelineController.sink
  //       .add(await _pipelineRepo.getPipelinesByStage(stage.name));
  // }

  Future getAllActivities() async {
    var response = await _activityRepo.getAllActivity();
    await handleEndResult(response, _allActivitiesController);
  }

  Future addAppointment(Appointment appointment) async {
    await _appointmentRepo.add(appointment);
    await getAllPipelines();
  }

  Future linkPerson(int personId, String pipelineId) async {
    await _pipelineRepo.linkPerson(personId, pipelineId);
    await getAllPipelines();
  }

  // getStarredPipelines() async {
  //   _allPipelineController.sink.add(await _pipelineRepo.getStarredPipelines());
  // }

  // getOverduePipelines() async {
  //   _allPipelineController.sink.add(await _pipelineRepo.getOverduePipelines());
  // }

//Reason why we fetch filtered from DB is we can have multiple users manipulate same record and need to
//ensure data is up to date
  // getFilteredPipelines(List<Pipeline> pipelines, List<String> filters) async {
  //   _allPipelineController.sink.add(filterPipes(pipelines, filters)
  //       //_pipelineRepo.getFilteredPipelines(filters)

  //       );

  //   //getAllPipelinesOnDate();
  // }

  // List<Pipeline> filterPipes(List<Pipeline> pipelines, List<String> filters) {
  //   if (filters.contains("starred")) {
  //     if (pipelines != null)
  //       pipelines = pipelines.where((s) => s.isStarred).toList();
  //   }

  //   if (filters.contains("overdue")) {
  //     if (pipelines != null)
  //       pipelines = pipelines.where((s) => s.isOverdue).toList();
  //   }

  //   // if (filters.contains("todayOnly")) {
  //   //   if (pipelines != null)
  //   //     pipelines = pipelines
  //   //         .where((s) => DateTimeHelper.compareDatesIsSameDate(
  //   //             s.appointment?.eventStartDateTime, DateTime.now()))
  //   //         .toList();
  //   // }
  //   return pipelines;
  // }

  // Future searchPipelines(searchText) async {
  //   var searched = allPipelinesList
  //       .where((s) =>
  //           (s.company?.name
  //                   ?.toLowerCase()
  //                   ?.contains(searchText.toString().toLowerCase()) ??
  //               false) ||
  //           (s.people?.company?.name
  //                   ?.toLowerCase()
  //                   ?.contains(searchText.toString().toLowerCase()) ??
  //               false) ||
  //           (s.applicationUser?.name
  //                   ?.toLowerCase()
  //                   ?.contains(searchText.toString().toLowerCase()) ??
  //               false))
  //       .toList();

  //   _allPipelineController.sink.add(searched);
  // }

//   getAllPipelinesOnDate() async {
//     //Reason why we fetch filtered from DB is we can have multiple users manipulate same record and need to
// //ensure data is up to date
//     //getAllPipelines();
//     //_allPipelineOnDateSink.add(await handleAllPipelinesOnDateSink());
//   }

  // Future<List<Pipeline>> handleAllPipelinesOnDateSink() async {
  //   var pipelines = await allPipelines.firstWhere((s) => true);

  //   pipelines = pipelines
  //       .where((s) => DateTimeHelper.compareDatesIsSameDate(
  //           s.appointment.eventStartDateTime, selectedDateTime))
  //       .toList();
  //   return pipelines;
  // }

  Future getAllPipelines() async {
    // var pipelines =
    var response = await _pipelineRepo.getAllPipelines();
    if (response.success) {
      allPipelinesList = response.model;
      if(HttpRequest.appUser?.isManager??false) await getAllEmployees();
    }
    await handleEndResult(response, _allPipelineController);
  }

  Future addPipeline(Pipeline pipeline) async {
    await _pipelineRepo.add(pipeline);
    await getAllPipelines();
  }

   Future<Pipeline> addPipelineReturnNewPipeline(Pipeline pipeline) async {
    var result =  await _pipelineRepo. add(pipeline);
    await getAllPipelines();
    return result.model;
  }

  Future updatePipeline(Pipeline pipeline) async {
    await _pipelineRepo.update(pipeline);
    await getAllPipelines();
  }

  Future deletePipelineById(String id) async {
    await _pipelineRepo.delete(id);
    await getAllPipelines();
  }

  Future setWonLostClose(String id, String stageName, Pipeline pipeline) async {
    await _pipelineRepo.setWonLostClosed(id, stageName, pipeline);
    await getAllPipelines();
  }

  @override
  void dispose() {
    // _allPipelineController.close();
    // _allActivitiesController.close();
    // _allEmployeesController.close();
    // _allPeoplesController.close();
    // _allPeoplesWithinCompanyController.close();
  }
}
