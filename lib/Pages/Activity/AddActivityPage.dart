import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Event/ScheduleListBloc.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Pages/Error/ErrorPage.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';
import 'package:mycrm/services/FutureBuilderDataHandler/FutureBuilderHandler.dart';

class AddActivityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddActivityState();
  }
}

class _AddActivityState extends State<AddActivityPage> {
  TextEditingController _activityNameController;
  TextEditingController _existingActivityNameController;
  bool _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //bool isloading = false;
  Activity newActivity;
  ScheduleListBloc _scheduleListBloc;
  final formKey = GlobalKey<FormState>();
  bool isInit = true;
  ActivityType activityType;
  var activityTypeName;

  @override
  void initState() {
    _activityNameController = TextEditingController();
    _existingActivityNameController = TextEditingController();
    super.initState();
  }

  // @override
  // void dispose() {
  //   //_scheduleListBloc?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    _scheduleListBloc =
        _scheduleListBloc ?? BlocProvider.of<ScheduleListBloc>(context);
    if (isInit) {
      // _scheduleListBloc.getAllActivities();
      activityType = ModalRoute.of(context).settings.arguments;
      switch (activityType) {
        case ActivityType.appointment:
          activityTypeName = "Appointment";
          break;
        case ActivityType.event:
          activityTypeName = "Event";
          break;
        case ActivityType.task:
          activityTypeName = "Task";
          break;
        default:
      }
    }
    isInit = false;
    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar('Manage $activityTypeName Type',
              '$activityTypeName', formKey, _scaffoldKey, confirmButtonCallback)
          .create(),
      body: newActivityContainer(),
    );
  }

  confirmButtonCallback() {
    _autoValidate = true;
    if (formKey.currentState.validate()) {
      postForm();
    } else {
      final SnackBar snackBar = new SnackBar(
        content: Text('Please fill in all information.'),
        duration: Duration(milliseconds: 3000),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void postForm() async {
    newActivity = new Activity();
    newActivity.name = _activityNameController.text;
    newActivity.activityType = activityType;

    try {
      //var result = await ActivityRepo().add(newActivity);
      //if (result.statusCode == 200 || result.statusCode == 201) {

      await _scheduleListBloc.addActivity(newActivity);
      Fluttertoast.showToast(msg: "Activity Added");
      // await ShowSnackBarAndGoBackHelper.go(
      //     _scaffoldKey, "Activity Added", context);
      //} else {
      //locator<ErrorService>().handleErrorResult(result, context);
      //}
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    } finally {}
  }

  Widget newActivityContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            activityNameRow,
            SizedBox(height: 10),
            activityList,
          ],
        ),
      ),
    );
  }

  Widget get activityList {
    //addPipelineBloc.getAllActivities();
    return CustomStreamBuilder(
      retryCallback: _scheduleListBloc.getAllActivities,
      stream: _scheduleListBloc.allActivities,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // if (snapshot.connectionState == ConnectionState.active &&
        //     snapshot.data == null) {
        //   return ErrorPage(() {
        //     _scheduleListBloc.getAllActivities();
        //   });
        // }
        // if (snapshot.hasError)
        //   return ErrorPage(() {
        //     _scheduleListBloc.getAllActivities();
        //   });
        return activityListContent(snapshot);
      },
    );
  }

  Widget activityListContent(AsyncSnapshot snapshot) {
    if (!snapshot.hasData) return LoadingIndicator();
    var activities = snapshot.data as List<Activity>;
    activities =
        activities.where((s) => s.activityType == activityType).toList();
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: activities?.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                color: Colors.grey[100],
                child: Slidable(
                    actionExtentRatio: 0.16,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        //caption: '',
                        color: Colors.blue[700],
                        icon: Icons.edit,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: new Text('Update Activity Name'),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text("Close"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    new FlatButton(
                                      child: Text("Confirm"),
                                      onPressed: () async {
                                        if (_existingActivityNameController
                                            .text.isEmpty) {
                                          DialogService().show(context,
                                              'Activity Name can not be Empty.');
                                          Navigator.pop(context);
                                          return;
                                        }
                                        activities[index].name =
                                            _existingActivityNameController
                                                .text;
                                        // var result = await ActivityRepo()
                                        //     .update(activities[index]);
                                        // if (result.statusCode == 200 ||
                                        //     result.statusCode == 204) {

                                        await _scheduleListBloc
                                            .updateActivity(activities[index]);

                                        Navigator.pop(context);
                                        //}
                                      },
                                    ),
                                  ],
                                  content: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: _existingActivityNameController,
                                  ),
                                );
                              });
                        },
                      ),
                      IconSlideAction(
                        //caption: '',
                        color: Colors.red[600],
                        icon: Icons.delete,
                        onTap: () async {
                          DialogService().showConfirm(
                              context, "Are you to delete this activity?",
                              () async {
                            // Response result =
                            //     await ActivityRepo().delete(activities[index]);
                            // if (result.statusCode == 200 ||
                            //     result.statusCode == 204) {

                            try {
                              await _scheduleListBloc
                                  .deleteActivityById(activities[index]);

                              //await page to refresh
                              Future.delayed(Duration(milliseconds: 150));
                              Navigator.pop(context);
                            } catch (e) {
                              ErrorService()
                                  .handlePageLevelException(e, context);
                            }
                            //} else {
                            //Navigator.pop(context);
                            //locator<ErrorService>()
                            //.handleErrorResult(result, context);
                            //}
                          });
                        },
                      ),
                    ],
                    actionPane: SlidableDrawerActionPane(),
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[Text(activities[index].name)],
                      ),
                    )));
          }),
    );
  }

  Widget get activityNameRow {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.event_available,
              size: 35,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: _activityNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Activity Name.';
                }
                if (value.length > 30) {
                  return 'Name length exceed max allowed.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Add A New Activity Name'),
            ),
          ),
        ],
      ),
    );
  }
}
