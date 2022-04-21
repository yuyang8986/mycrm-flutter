import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Stage/StageListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:mycrm/Models/Dto/StagePipilineListModel.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Pages/Stage/StageDetail.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Shared/AppFloatingActionButton.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';

class StageListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StageListPageState();
  }
}

class StageListPageState extends State<StageListPage>
    with AutomaticKeepAliveClientMixin {
  final colors = AppColors.stageListPageColors;
  StageListPageBloc stageListPageBloc = StageListPageBloc();
  Map<String, Color> stageColorMap;

  List<Stage> allStageList;
  List<ApplicationUser> allEmployees;
  ApplicationUser employSelection;
  final all = ApplicationUser(name: "All");
  bool isInit;
  // @override
  // void dispose() {
  //   //stageListPageBloc.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    isInit = true;
    print("init stage page");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;
    }
    return Scaffold(
        floatingActionButton: _addStageButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          margin: EdgeInsets.all(10),
          child: _stagelistView(context),
        ));
  }

  Widget get _addStageButton {
    if (!HttpRequest.appUser.isManager ||
        HttpRequest.appUser.subscriptionPlan == SubcriptionPlan.essential)
      return Container();
    return AppFloatingActionButton(addStage, "AddStage");
  }

  addStage() async {
    try {
      DialogService().showTextInput(context, "Create A New Stage", "Create",
          (input) async {
        var stage = new Stage();
        stage.name = input;
        stage.displayIndex = allStageList.length;
        await stageListPageBloc.addStage(stage);
        //Navigator.pop(context);
      }, () {
        Navigator.pop(context);
      });
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (BuildContext context) {
      //   return BlocProvider<StageListPageBloc>(
      //     bloc: stageListPageBloc,
      //     child: AddStagePage(),
      //   );
      // }));
    } catch (e) {}
  }

  Map dict(List<Stage> s) {
    final m = Map<String, Color>();
    if (s == null) {
      return null;
    }

    // int maxId = s.last.id;
    // int gap = maxId - 83 <0? 0 : maxId -83;
    s.forEach((e) {
      m[e.name] = colors[e.displayIndex];
    });
    return m;
  }

  Widget _stagelistView(BuildContext context) {
    return CustomStreamBuilder(
        retryCallback: stageListPageBloc.getAllStages,
        stream: stageListPageBloc.allStages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (snapshot.connectionState == ConnectionState.active &&
          //     snapshot.data == null) {
          //   return ErrorPage(() {
          //     stageListPageBloc.getAllStages();
          //   });
          // }
          // if (snapshot.hasError)
          //   return ErrorPage(() {
          //     stageListPageBloc.getAllStages();
          //   });
          allStageList = snapshot?.data as List<Stage>;
          stageColorMap = dict(allStageList);
          return stageListContent();
        });
  }

  Widget stageListContent() {
    // if (allEmployees?.isEmpty ?? true && HttpRequest.appUser.isManager)
    //   stageListPageBloc.getAllEmployees();
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        HttpRequest.appUser.isManager &&
                !(HttpRequest.appUser.subscriptionPlan ==
                    SubcriptionPlan.essential)
            ? CustomStreamBuilder(
                retryCallback: stageListPageBloc.getAllEmployees,
                stream: stageListPageBloc.allEmployees,
                builder: (ctx, snapshot) {
                  allEmployees = snapshot.data as List<ApplicationUser>;
                  if (!allEmployees.contains(all)) allEmployees.add(all);
                  return Container(
                    // margin: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                    alignment: Alignment.topCenter,
                    child: DropdownButton<ApplicationUser>(
                      // style: TextStyle(fontWeight: FontWeight.bold),
                      onChanged: (ApplicationUser e) async {
                        setState(() {
                          if (e.name == "All") {
                            employSelection = null;
                          } else {
                            employSelection = e;
                          }
                        });

                        if (e.name == "All") {
                          await stageListPageBloc.getAllStages();
                        } else {
                          await stageListPageBloc.getAllStages(
                              employeeId: e.id);
                        }
                      },
                      hint: Text(
                        "Select Employee",
                        style: TextStyle(fontFamily: "QuickSand"),
                      ),
                      value: employSelection,
                      items: allEmployees.map((e) {
                        return DropdownMenuItem(child: Text(e.name), value: e);
                      }).toList(),
                    ),
                  );
                },
              )
            : Container(),
        Expanded(
            child: RefreshIndicator(
          child: HttpRequest.appUser.isManager
              ? ReorderableListView(
                  children: allStageList == null || allStageList?.length == 0
                      ? List<Widget>()
                      : allStageList.map((stage) => _stageRow(stage)).toList(),
                  onReorder: (int oldIndex, int newIndex) async {
                    if (HttpRequest.appUser.subscriptionPlan ==
                        SubcriptionPlan.essential) {
                      Fluttertoast.showToast(
                          msg:
                              "Please upgrade Subscription Plan to enable Re-Order Stage feature");
                      return;
                    }
                    try {
                      print("oldIndex" + oldIndex.toString());
                      print("newIndex" + newIndex.toString());
                      var stage = allStageList
                          .where((s) => s.displayIndex == oldIndex + 1)
                          .first;
                      if (stage == null) return;
                      newIndex = newIndex < oldIndex ? newIndex + 1 : newIndex;
                      await stageListPageBloc.reOrder(stage.id, newIndex);

                      //StageRepo()
                      //.reOrder(stage.id, newIndex == 0 ? newIndex + 1 : newIndex);
                      // setState(() {
                      //   //force to refresh page
                      //   getAllStagesFuture = null;
                      // });
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                )
              : ListView(
                  children: allStageList == null || allStageList?.length == 0
                      ? List<Widget>()
                      : allStageList.map((stage) => _stageRow(stage)).toList(),
                ),
          onRefresh: _refreshStages,
        ))
      ],
    );
  }

  Future<void> _refreshStages() async {
    HttpRequest.forceRefresh = true;
    await stageListPageBloc.getAllStages();
    HttpRequest.forceRefresh = true;
    if (HttpRequest.appUser.isManager)
      await stageListPageBloc.getAllEmployees();
  }

  editStage(Stage stage) async {
    try {
      DialogService().showTextInput(context, "Stage Name", "Update",
          (input) async {
        stage.name = input;
        await stageListPageBloc.updateStage(stage);
        //Navigator.pop(context);
      }, () {
        Navigator.pop(context);
      });
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (BuildContext context) {
      //   return BlocProvider<StageListPageBloc>(
      //     bloc: stageListPageBloc,
      //     child: AddStagePage(),
      //   );
      // }));
    } catch (e) {}
  }

  Widget _stageRow(Stage stage) {
    return Card(
        elevation: 5,
        key: Key(stage.id.toString()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        color: stageColorMap[stage.name],
        child: Slidable(
            actionExtentRatio: 0.16,
            secondaryActions: stage.isEditable
                ? [
                    IconSlideAction(
                      //caption: '',
                      color: Colors.blue[700],
                      icon: Icons.edit,
                      onTap: () {
                        editStage(stage);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (BuildContext context) {
                        //       return BlocProvider<StageListPageBloc>(
                        //         bloc: stageListPageBloc,
                        //         child: EditStagePage(),
                        //       );
                        //     },
                        //     settings: RouteSettings(arguments: stage)));
                      },
                    ),
                    IconSlideAction(
                      //caption: '',
                      color: Colors.red[600],
                      icon: Icons.delete,
                      onTap: () async {
                        DialogService().showConfirm(
                            context, "Are you to delete this stage?", () async {
                          //Response result = await StageRepo().delete(stage.id);
                          //if (result.statusCode == 200 || result.statusCode == 204) {
                          await stageListPageBloc.deleteStage(stage.id);
                          Navigator.pop(context);
                          // setState(() {
                          //   //Force refresh
                          //   getAllStagesFuture = null;
                          // });
                          //} else {
                          //Navigator.pop(context);
                          //locator<ErrorService>().handleErrorResult(result, context);
                          //}
                        });
                      },
                    ),
                  ]
                : [],
            actionPane: SlidableDrawerActionPane(),
            child: Container(
              // elevation: 5,
              // shape:
              //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              // color: stageColorMap[stage.name],
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                          return BlocProvider<StageListPageBloc>(
                            bloc: stageListPageBloc,
                            child: StageDetailPage(),
                          );
                        },
                        settings: RouteSettings(
                            arguments: StagePipelineListModel(stage,
                                applicationUserId: employSelection?.id))));
                  },
                  child: Container(
                      // height: ScreenUtil().setHeight(140),
                      child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              !stage.isEditable
                                  ? Icon(
                                      FontAwesomeIcons.solidSnowflake,
                                      color: Colors.yellow[300],
                                      size: 12,
                                    )
                                  : Container(
                                      width: 12,
                                      height: 12,
                                    ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                // height: ScreenUtil().setHeight(140),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(stage?.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(50))),
                                    employSelection != null
                                        ? Text(
                                            "Total: " +
                                                stage.pipelines
                                                    .where((p) =>
                                                        p.applicationUserId ==
                                                        employSelection?.id)
                                                    .length
                                                    .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(40)))
                                        : Text(
                                            "Total: " +
                                                stage.pipelines.length
                                                    .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(40))),
                                  ],
                                ),
                              )
                            ],
                          ),
                          trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    "This Month: " +
                                        stage.thisMonthNumber.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(40),
                                    )),
                                Text(
                                    "This Quarter: " +
                                        stage.thisQuarterNumber.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(40),
                                    )),
                              ])))),
            )));
  }

  @override
  bool get wantKeepAlive => false;
}
