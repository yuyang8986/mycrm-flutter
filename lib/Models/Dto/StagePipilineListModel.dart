import 'package:mycrm/Models/Core/Stage/Stage.dart';

class StagePipelineListModel {
  StagePipelineListModel(this.stage, {this.applicationUserId});

  final Stage stage;
  final String applicationUserId;
}
