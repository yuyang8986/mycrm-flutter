import 'dart:async';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/Repos/Employee/EmployeeRepo.dart';
import 'package:mycrm/Http/Repos/Stage/StageRepo.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:rxdart/rxdart.dart';

class StageListPageBloc extends BlocBase {
  final stageRepo = StageRepo();
  final employeeRepo = ApplicationUserRepo();

  final _stageController = BehaviorSubject<List<Stage>>();
  final _employeeController = BehaviorSubject<List<ApplicationUser>>();

  StageListPageBloc() {
    getAllStages();
    if (HttpRequest.appUser.isManager) getAllEmployees();
  }

  Observable<List<Stage>> get allStages => _stageController.stream;
  Observable<List<ApplicationUser>> get allEmployees =>
      _employeeController.stream;

  Future addStage(Stage stage) async {
    await stageRepo.add(stage);
    await getAllStages();
  }

  Future getAllStages({String employeeId}) async {
    var response = await stageRepo.getAllStage(employeeId: employeeId);
    await handleEndResult(response, _stageController);
  }

  Future getAllEmployees() async {
    var response = await employeeRepo.getAllEmployees();
    await handleEndResult(response, _employeeController);
  }

  Future updateStage(Stage stage) async {
    await stageRepo.update(stage);
    await getAllStages();
  }

  Future deleteStage(int id) async {
    await stageRepo.delete(id);
    await getAllStages();
  }

  Future reOrder(int id, int displayIndex) async {
    var response = await stageRepo.reOrder(id, displayIndex);
    await Future.delayed(Duration(milliseconds: 1000));
    if (response.statusCode == 200) {
      await getAllStages();
    } else {
      throw Exception("Error Processing Reorder Request");
    }
  }

  @override
  void dispose() {
    //_stageController.close();
    //_employeeController.close();
  }
}
