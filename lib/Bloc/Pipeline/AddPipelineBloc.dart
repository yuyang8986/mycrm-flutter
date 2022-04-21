import 'dart:async';

import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/Repos/Stage/StageRepo.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:rxdart/rxdart.dart';

class AddPipelineBloc extends BlocBase {
  //final _activityRepo = ActivityRepo();
  final _stageRepo = StageRepo();

  AddPipelineBloc() {   
    getAllStages();
  }

  //final _allActivitiesController = StreamController<List<Activity>>.broadcast();
  final _allStagesController = BehaviorSubject<List<Stage>>();

  //get allActivities => _allActivitiesController.stream;
  Observable<List<Stage>> get allStages => _allStagesController.stream;



  Future getAllStages() async {
    var response = await _stageRepo.getAllStage();
    await handleEndResult(response, _allStagesController);
  }

  Future getAllTypes() async {
    var response = await _stageRepo.getAllStage();
    await handleEndResult(response, _allStagesController);
  }

  Future addActivity(Activity activity) async {
    //await _activityRepo.add(activity);
    //getAllActivities();
  }

  Future addStage(Stage stage) async {
    await _stageRepo.add(stage);
    await getAllStages();
  }

  Future updateActivity(Activity activity) async {
    //await _activityRepo.update(activity);
    //getAllActivities();
  }

  Future updateStage(Stage stage) async {
    await _stageRepo.update(stage);
    await getAllStages();
  }

  Future deleteActivityById(Activity activity) async {
    // await _activityRepo.delete(activity);
    //getAllActivities();
  }

  Future deleteStageById(int id) async {
    await _stageRepo.delete(id);
    await getAllStages();
  }

  dispose() {
    //_allActivitiesController?.close();
    //_allStagesController.close();
  }
}
