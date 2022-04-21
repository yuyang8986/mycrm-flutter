import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Dto/FileItemDto.dart';
import 'package:mycrm/Pages/DownloadFile/FileDownloadPage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineEditPage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Pages/Schedule/AppointmentAddPage.dart';
import 'package:mycrm/Pages/Schedule/TaskAddPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/UrlSchemeService/UrlSchemeService.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/NoContactInfoGuideWidget.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:mycrm/infrastructure/DateTimeHelper.dart' as prefix0;
import 'package:share/share.dart';

class PipelineCard extends StatefulWidget {
  PipelineCard({
    Key key,
    @required this.pipeline,
    //@required this.filterPipelinesCallBack,
    @required this.pipelineListBloc,
    @required this.parentContext,
    this.changePipelineRefreshStageSummaryCallBack,
    //this.filterStrings,
  }) : super(key: key);

  final Function changePipelineRefreshStageSummaryCallBack;
  //final Function filterPipelinesCallBack;
  final Pipeline pipeline;
  final PipelineListBloc pipelineListBloc;
  final BuildContext parentContext;

  //final List<String> filterStrings;

  @override
  State<StatefulWidget> createState() => PipelineCardState();
}

class PipelineCardState extends State<PipelineCard> {
  Pipeline pipeline;
  PipelineListBloc pipelineListBloc;
  BuildContext parentContext;
  List<String> filterStrings;
  bool isStarUpdating;
  bool isInit;
  Function changePipelineRefreshStageSummaryCallBack;
  String filePath;
  // @override
  // void dispose() {
  //   //pipelineListBloc.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    // pipeline = widget.pipeline;
    isInit = true;
    pipelineListBloc = widget.pipelineListBloc;
    parentContext = widget.parentContext;
    //filterStrings = widget.filterStrings;
    changePipelineRefreshStageSummaryCallBack =
        widget.changePipelineRefreshStageSummaryCallBack;
    isStarUpdating = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pipeline = widget.pipeline;
    return Material(
        color: Colors.transparent,
        textStyle: TextStyle(color: Colors.white, fontFamily: "QuickSand"),
        child: Theme(
          data: ThemeData(
              textTheme: TextTheme(
                  body1:
                      TextStyle(color: Colors.black, fontFamily: "QuickSand"))),
          child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(50)),
              ),
              elevation: 2,
              margin: EdgeInsets.all(5),
              color: Colors.white,
              // color: Colors.red[300],
              // borderOnForeground: true,
              //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    pipelineRowLeftInfo(pipeline),
                    pipelineRowRightIconButtons(pipeline)
                  ],
                ),
                padding: EdgeInsets.all(5),
              )),
        ));
  }

  get starUpdatingWidget {
    return Container(
      // margin: EdgeInsets.all(13),
      height: ScreenUtil().setHeight(140),
      width: ScreenUtil().setWidth(140),
      child: Container(
        //margin: EdgeInsets.all(ScreenUtil().setWidth(50)),
        // width: ScreenUtil().setWidth(20),
        // height: ScreenUtil().setHeight(20),
        child: Container(),
      ),
    );
  }

  get starred {
    return Container(
      width: ScreenUtil().setWidth(140),
      height: ScreenUtil().setHeight(140),
      child: IconButton(
        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
        alignment: Alignment.center,
        icon: Icon(
          pipeline.isStarred ? Icons.star : FontAwesomeIcons.star,
          color: !isPipelineAssignedEmployeeSameAsCurrentUser
              ? Colors.grey
              : Colors.red,
          size: pipeline.isStarred
              ? ScreenUtil().setWidth(65)
              : ScreenUtil().setWidth(55),
        ),
        color: Colors.amber,
        onPressed: () async {
          if (!isPipelineAssignedEmployeeSameAsCurrentUser) return;
          setState(() {
            isStarUpdating = true;
          });
          pipeline.isStarred = !pipeline.isStarred;
          await pipelineListBloc.updatePipeline(pipeline);
          // if (filterStrings != null) {
          //   if (filterStrings.length > 0)
          //     widget.filterPipelinesCallBack();
          //     //pipelineListBloc.getFilteredPipelines(filterStrings);
          // }
          await Future.delayed(Duration(milliseconds: 300));
          setState(() {
            isStarUpdating = false;
          });
        },
      ),
    );
  }

  get uploadFileOptions {
    return Container(
      width: ScreenUtil().setWidth(140),
      height: ScreenUtil().setHeight(140),
      child: IconButton(
        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
        alignment: Alignment.center,
        icon: Icon(
          Icons.attach_file,
        ),
        color: Colors.black,
        onPressed: () async {
          _upLoadOptionsDialogBox();
        },
      ),
    );
  }

  Future<void> _upLoadOptionsDialogBox() {
    // Navigator.of(context).pop();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: new Container(
                        width: ScreenUtil().setWidth(300),
                        height: ScreenUtil().setHeight(80),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.attach_file),
                            WEmptyView(20),
                            Text('Attach a file'),
                          ],
                        )),
                    onTap: () async {
                      try {
                        var filePath =
                            await FilePicker.getFilePath(type: FileType.ANY);
                        var file = await MultipartFile.fromFile(filePath);
                        FormData formData = FormData.fromMap({"file": file});
                        await HttpRequest.post(
                            HttpRequest.baseUrl + "uploadfile/" + pipeline.id,
                            formData);
                        Fluttertoast.showToast(msg: "File has been uploaded.");
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg: "Upload Failed:" + e.toString());
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Container(
                        width: ScreenUtil().setWidth(300),
                        height: ScreenUtil().setHeight(80),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.insert_drive_file),
                            WEmptyView(20),
                            Text('List of attached files'),
                          ],
                        )),
                    onTap: () async {
                      var fileList;
                      var result = await HttpRequest.get(
                          HttpRequest.baseUrl + "uploadfile/" + pipeline.id);
                      if (result.data == null) {
                        fileList = new List<FileItemDto>();
                      } else {
                        fileList =
                            new List<FileItemDto>.from(result.data.map((r) {
                          return FileItemDto.fromJson(r);
                        }));
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  FileDownloadPage(
                                    files: fileList,
                                    pipeline: pipeline,
                                    pipelineListBloc: pipelineListBloc,
                                  )));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  get contactOptions {
    return Container(
      width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setHeight(120),
      child: PopupMenuButton(
        enabled: pipeline.people != null,
        onSelected: (value) async {
          switch (value) {
            case PipelineCardContactMenu.sms:
              if (pipeline.people?.phone?.isEmpty ?? true) {
                DialogService().show(parentContext, 'No Phone number');
                return;
              }
              UrlSchemeService().sendSMS(pipeline.people.phone);
              break;
            case PipelineCardContactMenu.call:
              if (pipeline.people?.phone?.isEmpty ?? true) {
                DialogService().show(parentContext, 'No Phone number');
                return;
              }
              UrlSchemeService().makePhoneCall(pipeline.people.phone);
              break;
            case PipelineCardContactMenu.email:
              if (pipeline.people?.email?.isEmpty ?? true) {
                DialogService().show(parentContext, 'No Email');
                return;
              }
              UrlSchemeService().sendEmail(pipeline.people.email);
              break;

            default:
          }
        },
        padding: EdgeInsets.all(0),
        icon: Icon(
          Icons.message,
          color: pipeline.people != null ? Colors.green : Colors.grey,
        ),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              child: Center(
                child: Icon(Icons.sms),
              ),
              value: PipelineCardContactMenu.sms,
            ),
            PopupMenuItem(
              child: Center(
                child: Icon(Icons.call),
              ),
              value: PipelineCardContactMenu.call,
            ),
            PopupMenuItem(
              child: Center(
                child: Icon(Icons.email),
              ),
              value: PipelineCardContactMenu.email,
            ),
          ];
        },
      ),
    );
  }

  get dotsOptions {
    return Container(
      width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setHeight(120),
      child: PopupMenuButton(
        onSelected: (value) async {
          switch (value) {
            case PipelineCardDotsMenu.details:
              _getDealDetails();
              PipelineListPageState.isInit = true;
              if (changePipelineRefreshStageSummaryCallBack != null) {
                changePipelineRefreshStageSummaryCallBack();
              }
              break;
            case PipelineCardDotsMenu.setToWon:
              await pipelineListBloc.setWonLostClose(
                  pipeline.id, 'Won', pipeline);
              PipelineListPageState.isInit = true;
              if (changePipelineRefreshStageSummaryCallBack != null) {
                changePipelineRefreshStageSummaryCallBack();
              }
              break;
            case PipelineCardDotsMenu.setToLost:
              await pipelineListBloc.setWonLostClose(
                  pipeline.id, 'Lost', pipeline);
              PipelineListPageState.isInit = true;
              if (changePipelineRefreshStageSummaryCallBack != null) {
                changePipelineRefreshStageSummaryCallBack();
              }
              break;
            case PipelineCardDotsMenu.setToClose:
              await pipelineListBloc.setWonLostClose(
                  pipeline.id, 'Closed', pipeline);
              PipelineListPageState.isInit = true;
              if (changePipelineRefreshStageSummaryCallBack != null) {
                changePipelineRefreshStageSummaryCallBack();
              }
              break;
            case PipelineCardDotsMenu.editLead:
              Navigator.of(parentContext).push(MaterialPageRoute(
                  builder: (BuildContext context) {
                    return BlocProvider<PipelineListBloc>(
                      bloc: pipelineListBloc,
                      child: PipelineEditPage(),
                    );
                  },
                  settings: RouteSettings(arguments: pipeline)));
              break;
            case PipelineCardDotsMenu.changeAssignment:
              if (!HttpRequest.appUser.isManager) return;
              //pipelineListBloc.getAllEmployees();
              await showModalBottomSheet(
                  builder: (context) {
                    return CustomStreamBuilder(
                      retryCallback: pipelineListBloc.getAllEmployees,
                      stream: pipelineListBloc.allEmployeesStream,
                      builder: (ctx, snapshot) {
                        // if (!snapshot.hasData) return LoadingIndicator();
                        // if (snapshot.hasError)
                        //   return ErrorPage(() {
                        //     pipelineListBloc.getAllEmployees();
                        //   });
                        List<ApplicationUser> employees =
                            snapshot.data as List<ApplicationUser>;

                        // employees.removeWhere((s) => s.isAdmin);
                        return Container(
                          child: ListView.builder(
                            itemCount: employees?.length,
                            itemBuilder: (ctx, index) {
                              return ListTile(
                                onTap: () async {
                                  pipeline.applicationUserId =
                                      employees[index].id;
                                  await pipelineListBloc
                                      .updatePipeline(pipeline);
                                  PipelineListPageState.isInit = true;
                                  Navigator.of(context).pop();
                                },
                                leading: Text(employees[index].name),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  context: context,
                  isScrollControlled: false);
              break;
            case PipelineCardDotsMenu.deleteLead:
              try {
                DialogService().showConfirm(parentContext,
                    'Are you sure to delete this deal? All the appointment and tasks related will be deleted as well!',
                    () async {
                  await pipelineListBloc.deletePipelineById(pipeline.id);
                  PipelineListPageState.isInit = true;
                  Navigator.pop(parentContext);
                  if (changePipelineRefreshStageSummaryCallBack != null) {
                    changePipelineRefreshStageSummaryCallBack();
                  }
                });
              } catch (e) {
                Navigator.pop(parentContext);
              }
              break;
            default:
          }
        },
        padding: EdgeInsets.all(0),
        icon: Icon(
          FontAwesomeIcons.ellipsisV,
          color: Colors.blue,
          size: ScreenUtil().setWidth(50),
        ),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
                enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
                child: Text(
                  'Details',
                  style: TextStyle(fontFamily: "QuickSand"),
                ),
                value: PipelineCardDotsMenu.details),
            PopupMenuItem(
              enabled: pipeline.people != null &&
                  isPipelineAssignedEmployeeSameAsCurrentUser,
              child: Text(
                'Set to WON',
                style: TextStyle(fontFamily: "QuickSand"),
              ),
              value: PipelineCardDotsMenu.setToWon,
            ),
            PopupMenuItem(
              enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
              child: Text(
                'Set to LOST',
                style: TextStyle(fontFamily: "QuickSand"),
              ),
              value: PipelineCardDotsMenu.setToLost,
            ),
            PopupMenuItem(
              enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
              child: Text(
                'Set to CLOSED',
                style: TextStyle(fontFamily: "QuickSand"),
              ),
              value: PipelineCardDotsMenu.setToClose,
            ),
            PopupMenuItem(
              enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
              child: Text(
                'Edit Deal',
                style: TextStyle(fontFamily: "QuickSand"),
              ),
              value: PipelineCardDotsMenu.editLead,
            ),
            PopupMenuItem(
              enabled: HttpRequest.appUser.isManager,
              child: Text(
                'Change Assignment',
                style: TextStyle(fontFamily: "QuickSand"),
              ),
              value: PipelineCardDotsMenu.changeAssignment,
            ),
            PopupMenuItem(
              enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
              child: Text(
                'Delete',
                style: TextStyle(fontFamily: "QuickSand"),
              ),
              value: PipelineCardDotsMenu.deleteLead,
            )
          ];
        },
      ),
    );
  }

  Widget pipelineRowRightIconButtons(Pipeline pipeline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        starred,
        isPipelineAssignedEmployeeSameAsCurrentUser
            ? contactOptions
            : Container(),
        dotsOptions, // IconButton(
        //   icon: Icon(
        //     Icons.attach_file,
        //     color: Colors.grey,
        //   ),
        //   onPressed: () {},
        // ),
        shareOptions,
        uploadFileOptions
      ],
    );
  }

  get shareOptions {
    return Container(
      width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setHeight(120),
      child: PopupMenuButton(
        onSelected: (value) async {
          switch (value) {
            case ShareOptionDotsMenu.email:
              final Email email = Email(
                body: 'Deal Details:\n\nDeal Name: ${pipeline.dealName}\nDeal Amount: ${pipeline.dealAmount.toString()}' +
                    ' \nContact Person: ${pipeline.people?.name ?? ''}\nCompany: ${pipeline.people != null ? pipeline.people.company.name : pipeline.company.name}' +
                    '\nContact Number: ${pipeline.people?.phone ?? ""}\nStage: ${pipeline.stage?.name ?? ""}\n\nImported From Dealo',
                subject: 'Deal Summary - ${pipeline.dealName}',
                //recipients: ['example@example.com'],
                //cc: ['cc@example.com'],
                //bcc: ['bcc@example.com'],
                //attachmentPath: '/path/to/attachment.zip',
                isHTML: false,
              );

              await FlutterEmailSender.send(email);
              break;
            case ShareOptionDotsMenu.sms:
              String _result = await sendSMS(
                  message: 'Deal Details:\n\nDeal Name: ${pipeline.dealName}\nDeal Amount: ${pipeline.dealAmount.toString()}' +
                      ' \nContact Person: ${pipeline.people?.name ?? ''}\nCompany: ${pipeline.people != null ? pipeline.people.company.name : pipeline.company.name}' +
                      '\nContact Number: ${pipeline.people?.phone ?? ""}\nStage: ${pipeline.stage?.name ?? ""}\n\nImported From Dealo',
                  recipients: [""]).catchError((onError) {
                print(onError);
              });
              // SmsSender sender = new SmsSender();
              // await sender.sendSms(new SmsMessage(
              //     "0430490668",
              //     'Deal Details:\n\nDeal Name: ${pipeline.dealName}\nDeal Amount: ${pipeline.dealAmount.toString()}' +
              //         ' \nContact Person: ${pipeline.people?.name ?? ''}\nCompany: ${pipeline.people != null ? pipeline.people.company.name : pipeline.company.name}' +
              //         '\nContact Number: ${pipeline.people?.phone ?? ""}\nStage: ${pipeline.stage?.name ?? ""}\n\nImported From Dealo'));
              break;
            case ShareOptionDotsMenu.other:
              Share.share('Deal Details:\n\nDeal Name: ${pipeline.dealName}\nDeal Amount: ${pipeline.dealAmount.toString()}' +
                  ' \nContact Person: ${pipeline.people?.name ?? ''}\nCompany: ${pipeline.people != null ? pipeline.people.company.name : pipeline.company.name}' +
                  '\nContact Number: ${pipeline.people?.phone ?? ""}\nStage: ${pipeline.stage?.name ?? ""}\n\nImported From Dealo');
              break;

            default:
          }
        },
        icon: Icon(
          FontAwesomeIcons.share,
          size: ScreenUtil().setWidth(50),
          color: Colors.brown,
        ),
        itemBuilder: (BuildContext context) {
          return Platform.isIOS
              ? [
                  PopupMenuItem(
                    //enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
                    child: Text(
                      'Share to apps',
                      style: TextStyle(fontFamily: "QuickSand"),
                    ),
                    value: ShareOptionDotsMenu.other,
                  ),
                ]
              : [
                  PopupMenuItem(
                    // enabled: pipeline.people != null &&
                    //     isPipelineAssignedEmployeeSameAsCurrentUser,
                    child: Text(
                      'Share with Email',
                      style: TextStyle(fontFamily: "QuickSand"),
                    ),
                    value: ShareOptionDotsMenu.email,
                  ),
                  PopupMenuItem(
                    //enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
                    child: Text(
                      'Share with SMS',
                      style: TextStyle(fontFamily: "QuickSand"),
                    ),
                    value: ShareOptionDotsMenu.sms,
                  ),
                  PopupMenuItem(
                    //enabled: isPipelineAssignedEmployeeSameAsCurrentUser,
                    child: Text(
                      'Share to apps',
                      style: TextStyle(fontFamily: "QuickSand"),
                    ),
                    value: ShareOptionDotsMenu.other,
                  ),
                ];
        },
      ),
    );
  }

  Widget followUpInfo() {
    // var appointments = pipeline.appointments;
    // appointments.sort((a, b) {
    //   return a.eventStartDateTime.compareTo(b.eventStartDateTime);
    // });
    // Appointment appointment;
    // if (appointments.length > 0) {
    //   appointment = appointments.first;
    // } else {}

    return pipeline.nextActivity?.name == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              VEmptyView(20),
              Text("Next Activity: " + pipeline.nextActivity.name),
              Text("Time: " +
                  DateTimeHelper.parseDateTimeToDateHHMM(
                      pipeline.nextActivity.startTime))
            ],
          );
  }

  bool get isPipelineAssignedEmployeeSameAsCurrentUser {
    return HttpRequest.appUser.name == pipeline.applicationUser?.name;
  }

  Widget get addAppointmentOrTaskWidget {
    return isPipelineAssignedEmployeeSameAsCurrentUser
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: Colors.grey, blurRadius: 1),
                  BoxShadow(color: Colors.grey, blurRadius: 1)
                ]),
                child: RaisedButton(
                  onPressed: () async {
                    if (pipeline.people == null) {
                      DialogService()
                          .show(context, "Please add contact person first");
                      return;
                    }
                    await showModalBottomSheet(
                        isScrollControlled: true,
                        builder: (context) {
                          return BlocProvider(
                            bloc: pipelineListBloc,
                            child: AppointmentAddPage(
                              pipeline: pipeline,
                            ),
                          );
                        },
                        context: context);
                  },
                  child: Text('Add Appointment',
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: Colors.grey, blurRadius: 1),
                  BoxShadow(color: Colors.grey, blurRadius: 1)
                ]),
                child: RaisedButton(
                  onPressed: () async {
                    if (pipeline.people == null) {
                      DialogService()
                          .show(context, "Please add contact person first");
                      return;
                    }
                    await showModalBottomSheet(
                        isScrollControlled: true,
                        builder: (context) {
                          return BlocProvider(
                            bloc: pipelineListBloc,
                            child: TaskAddPage(
                              pipeline: pipeline,
                            ),
                          );
                        },
                        context: context);
                  },
                  child: Text('Add Task',
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          )
        : Container();
  }

  Widget selectPeopleModalList(List<People> peoples) {
    return Container(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemBuilder: (ctx, index) {
            return InkWell(
              onTap: () async {
                PipelineListPageState.isInit = true;
                await pipelineListBloc.linkPerson(
                    peoples[index].id, pipeline.id);
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Person Name: " + peoples[index].name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(40),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Company: " + peoples[index].company?.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(40),
                        fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: Colors.grey,
                  )
                ],
              ),
            );
          },
          itemCount: peoples.length,
        ));
  }

  Future _getDealDetails() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: new Text(
                      "Deal Details:",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w700),
                    )),
                  ),
                  Container(
                      margin: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 20.0),
                      child: Column(
                        children: <Widget>[
                          new Table(
                            border: TableBorder(bottom: BorderSide(width: 1)),
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Name: "),
                                    ),
                                  ),
                                  new TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: new Text(pipeline.dealName),
                                  )),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Amount: "),
                                    ),
                                  ),
                                  new TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: new Text(
                                        "\$" + pipeline.dealAmount.toString()),
                                  )),
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Company Name: "),
                                    ),
                                  ),
                                  new TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: new Text(
                                      (pipeline.people != null
                                          ? (pipeline.people?.company?.name ??
                                                  "") +
                                              (pipeline.people?.company
                                                          ?.isDeleted ??
                                                      false
                                                  ? " (former)"
                                                  : "")
                                          : (pipeline.company?.name ?? "") +
                                              (pipeline.company?.isDeleted ??
                                                      false
                                                  ? " (former)"
                                                  : "")),
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                          new Table(
                            border: TableBorder(bottom: BorderSide(width: 1)),
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Contact Details: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Container(),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Name: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.people != null
                                            ? Text(pipeline.people.name)
                                            : Text('TBD')),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Email: "),
                                    ),
                                  ),
                                  new TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: pipeline.people != null
                                              ? Text(pipeline.people.email)
                                              : Text('TBD')))
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Phone: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.people != null
                                            ? Text(pipeline.people.phone)
                                            : Text('TBD')),
                                  )
                                ],
                              ),
                            ],
                          ),
                          new Table(
                            border: TableBorder(bottom: BorderSide(width: 1)),
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Type: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.type != null
                                            ? Text(pipeline.type)
                                            : Text("TBD")),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Cost Model: "),
                                    ),
                                  ),
                                  new TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: pipeline.cogsAmount != null
                                              ? Text(
                                                  "COGS (\$${pipeline.cogsAmount})")
                                              : Text(
                                                  "Cost Margin% (${(pipeline.margin ?? 0) * 100})")))
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("GP: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.cogsAmount != null
                                            ? Text("\$" +
                                                (pipeline.dealAmount -
                                                        pipeline.cogsAmount)
                                                    .toStringAsFixed(2))
                                            : Text("\$" +
                                                (pipeline.dealAmount *
                                                        (1 -
                                                            (pipeline.margin ??
                                                                0)))
                                                    .toStringAsFixed(2))),
                                  )
                                ],
                              ),
                            ],
                          ),
                          new Table(
                            border: TableBorder(bottom: BorderSide(width: 1)),
                            children: <TableRow>[
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Assigned to: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.applicationUser != null
                                            ? Text(
                                                pipeline.applicationUser.name)
                                            : Text('TBD')),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Deal Creation Date: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.applicationUser != null
                                            ? Text(DateTimeHelper
                                                    .parseDateTimeToDate(
                                                        pipeline.createdDate)
                                                .toString())
                                            : Text('TBD')),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child:
                                          new Text("Targeted Date To Attain: "),
                                    ),
                                  ),
                                  new TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: pipeline.attainDate != null
                                              ? Text(DateTimeHelper
                                                      .parseDateTimeToDate(
                                                          pipeline.attainDate)
                                                  .toString())
                                              : Text("TBD")))
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Stage: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Text(pipeline.stage.name)),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Days on this stage: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Text(
                                            pipeline.stayedTime.toString())),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Next Activity: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.nextActivity != null
                                            ? Text(pipeline.nextActivity.name)
                                            : Text('TBD')),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text(
                                          "Next Activity Start Time: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.nextActivity != null
                                            ? Text(DateTimeHelper
                                                    .parseDateTimeToDateHHMM(
                                                        pipeline.nextActivity
                                                            .startTime)
                                                .toString())
                                            : Text('TBD')),
                                  )
                                ],
                              ),
                              new TableRow(
                                children: <Widget>[
                                  new TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: new Text("Note: "),
                                    ),
                                  ),
                                  new TableCell(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: pipeline.note != null
                                            ? Text(pipeline.note)
                                            : Text("TBD")),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
          ));
        });
  }

  Color stageColor(String stage) {
    Color color = Colors.blue;
    switch (stage) {
      case 'Won':
        color = Colors.green;
        break;
      case 'Lost':
        color = Colors.red;
        break;
      case 'Closed':
        color = Colors.grey;
        break;
    }
    return color;
  }

  Widget getStage(Pipeline pipeline) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        //width: ScreenUtil().setWidth(300),
        height: ScreenUtil().setHeight(60),
        decoration: BoxDecoration(
          color: stageColor(pipeline.stage.name),
          // borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(pipeline.stage.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: "QuickSand",
                  fontSize: ScreenUtil().setSp(40))),
        ));
  }

  Widget pipelineRowLeftInfo(Pipeline pipeline) {
    //bool nextFollowUpDateDue = false;
    //if (pipeline.appointment != null) nextFollowUpDateDue = pipeline.isOverdue;
    //pipeline.appointment.eventStartDateTime.difference(DateTime.now()).inHours < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
                constraints: BoxConstraints(
                  maxWidth: ScreenUtil().setWidth(700),
                ),
                child: InkWell(
                  onTap: () {
                    _getDealDetails();
                  },
                  child: Text(pipeline.dealName,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "QuickSand",
                          fontSize: ScreenUtil().setSp(50))),
                )),
          ],
        ),
        Container(
          constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(600)),
          child: Text(
            "\$${pipeline.dealAmount.toStringAsFixed(2)}",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(45)),
          ),
        ),
        Container(
          constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(600)),
          child: Text(
            (pipeline.people != null
                ? (pipeline.people?.company?.name ?? "") +
                    (pipeline.people?.company?.isDeleted ?? false
                        ? " (former)"
                        : "")
                : (pipeline.company?.name ?? "") +
                    (pipeline.company?.isDeleted ?? false ? " (former)" : "")),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(45)),
          ),
        ),
        VEmptyView(20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            getStage(pipeline),
            WEmptyView(10),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: ScreenUtil().setHeight(60),
                //width: ScreenUtil().setWidth(300),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  child: Center(
                    child: Text("Show Details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "QuickSand",
                            fontSize: ScreenUtil().setSp(40))),
                  ),
                  onTap: () {
                    _getDealDetails();
                  },
                )),
          ],
        ),

        VEmptyView(40),
        Container(
          width: ScreenUtil().setWidth(850),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
        ),
        VEmptyView(20),
        Text(
          "Contact Details:",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(45)),
        ),
        VEmptyView(20),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            pipeline.people == null
                ? Container(
                    height: ScreenUtil().setHeight(60),
                    // width: ScreenUtil().setWidth(300),
                    child: RaisedButton(
                      color: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text("Link Person",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "QuickSand",
                              fontSize: ScreenUtil().setSp(40))),
                      onPressed: () async {
                        if (isInit) {
                          if (pipeline.companyId != null)
                            await pipelineListBloc
                                .getAllPeoplesWithinCompany(pipeline.companyId);
                          isInit = false;
                        }
                        await showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              // pipelineListBloc.getAllPeoplesWithinCompany(
                              //     pipeline.companyId);
                              return CustomStreamBuilder(
                                retryCallback:
                                    pipelineListBloc.getAllPeoplesWithinCompany,
                                stream:
                                    pipelineListBloc.allPeoplesWithingCompany,
                                builder: (ctx, asyncdata) {
                                  // if (!asyncdata.hasData) {
                                  //   return LoadingIndicator();
                                  // }

                                  //RepoResponse response = asyncdata.data;
                                  List<People> peoples =
                                      asyncdata.data as List<People>;
                                  if (peoples == null || peoples?.length == 0) {
                                    return NoContactInfoGuideWidget(1);
                                  }

                                  return selectPeopleModalList(asyncdata.data);
                                },
                              );
                            });
                      },
                    ),
                  )
                : TextHelper.checkTextIfNullOrEmptyReturnTitleWithRedTBDRow(
                    'Name ',
                    pipeline.people.name +
                        (pipeline.people?.isDeleted ?? false
                            ? "(former)"
                            : "")),
          ],
        ),
        //VEmptyView(20),
        pipeline.people == null
            ? Container()
            : TextHelper.checkTextIfNullOrEmptyReturnTitleWithRedTBDRow(
                'Email', pipeline.people?.email),
        pipeline.people == null
            ? Container()
            : TextHelper.checkTextIfNullOrEmptyReturnTitleWithRedTBDRow(
                'Phone', pipeline.people?.phone),

        followUpInfo()
      ],
    );
  }
}
