import 'dart:async';

import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/Repos/Dashboard/DashboardRepo.dart';
import 'package:mycrm/Http/Repos/Employee/EmployeeRepo.dart';
import 'package:mycrm/Http/Repos/TargetTemplate/TargetRepo.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Dashboard/DashboardModel.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/TargetTemplate/TargetTemplate.dart';
import 'package:rxdart/rxdart.dart';

class DashboardPageBloc extends BlocBase {
  DashboardPageBloc() {
    if (HttpRequest.appUser.isManager) {
      getAllTargetTemplates();
      getEmployees();
    }
    getDashboardById(HttpRequest.appUser.sub);
  }
  final TargetTemplateRepo targetTemplateRepo = TargetTemplateRepo();
  final ApplicationUserRepo employeeRepo = ApplicationUserRepo();
  final DashboardRepo dashboardRepo = DashboardRepo();

  BehaviorSubject<List<TargetTemplate>> allTargetTemplatesController =
      BehaviorSubject<List<TargetTemplate>>();

  BehaviorSubject<List<ApplicationUser>> allEmployeesController =
      BehaviorSubject<List<ApplicationUser>>();

  BehaviorSubject<DashboardModel> dashboardDataStreamController =
      BehaviorSubject<DashboardModel>();

  Observable<DashboardModel> get dashBoardDataStream =>
      dashboardDataStreamController.stream;
  Observable<List<TargetTemplate>> get allTargetTemplatesStream =>
      allTargetTemplatesController.stream;

  Observable<List<ApplicationUser>> get allEmployeesStream =>
      allEmployeesController.stream;
  //get allEmployees => allEmployeesController.stream;

  Future getAllTargetTemplates() async {
    var result = await targetTemplateRepo.getAllTargetTemplate();
    await handleEndResult(result, allTargetTemplatesController);
  }

  Future getEmployees() async {
    var result = await employeeRepo.getAllEmployees();
    await handleEndResult(result, allEmployeesController);
  }

  Future getDashboard() async {
    var result = await dashboardRepo.getDashboard();
    await handleEndResult(result, dashboardDataStreamController);
  }

  Future getDashboardById(String employeeId) async {
    var result = await dashboardRepo.getDashboardByAppUserId(employeeId);
    await handleEndResult(result, dashboardDataStreamController);
  }

  Future getDashboardByApplicationUserId(String id) async {
    var result = await dashboardRepo.getDashboardByAppUserId(id);
    await handleEndResult(result, dashboardDataStreamController);
  }

  // getAllEmployees() async {
  //   allEmployeesController.sink.add(await employeeRepo.getAllEmployees());
  // }

  Future addEmployeeToTemplate(String templateId, String employeeId) async {
    await employeeRepo.addEmployeeToTemplate(templateId, employeeId);
    await getAllTargetTemplates();
  }

  Future updateTemplate(TargetTemplate targetTemplate) async {
    await targetTemplateRepo.update(targetTemplate);
    await getAllTargetTemplates();
  }

  Future addTemplate(TargetTemplate targetTemplate) async {
    await targetTemplateRepo.add(targetTemplate);
    await getAllTargetTemplates();
  }

  Future removeEmployeeFromTemplate(String employeeId) async {
    await employeeRepo.removeEmployeeFromTemplate(employeeId);
    await getAllTargetTemplates();
  }

  Future archiveTemplate(String id) async {
    await targetTemplateRepo.delete(id);
    await getAllTargetTemplates();
  }

  Future enableTemplate(String id) async {
    await targetTemplateRepo.enable(id);
    await getAllTargetTemplates();
  }

  @override
  void dispose() {
    //allTargetTemplatesController.close();
    //allEmployeesController.close();
  }
}
