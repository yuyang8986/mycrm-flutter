import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Bloc/Stage/StageListPageBloc.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:mycrm/Models/Dto/StagePipilineListModel.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Styles/BoxDecorations.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Pipeline/PipelineCard.dart';

class StageDetailPage extends StatefulWidget {
  final StagePipelineListModel stagePipelineListModel;
  StageDetailPage({Key key, this.stagePipelineListModel}) : super(key: key);

  StageDetailPageState createState() => StageDetailPageState();
}

class StageDetailPageState extends State<StageDetailPage> {
  Stage stage;
  final PipelineListBloc _pipelineListBloc = PipelineListBloc();

  StageListPageBloc stageListPageBloc;
  String applicationUserId;
  bool isInit;
  // @override
  // void dispose() {
  //   //_pipelineListBloc.dispose();
  //   //stageListPageBloc.dispose();
  //   super.dispose();
  // }
  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;
    }
    var stagePipelineListModel =
        ModalRoute.of(context).settings.arguments as StagePipelineListModel;
    stage = stage ?? stagePipelineListModel.stage;
    applicationUserId =
        applicationUserId ?? stagePipelineListModel.applicationUserId;
    stageListPageBloc =
        stageListPageBloc ?? BlocProvider.of<StageListPageBloc>(context);
    return Scaffold(
      appBar: GeneralAppBar("Stage Detail", 'Stage', null, null, null).create(),
      body: _stageDetailContainer,
    );
  }

  Widget get _stageDetailContainer {
    return Container(
      //margin: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          _stageHeadSummaryListTile,
          CustomStreamBuilder(
            retryCallback: _pipelineListBloc.getAllPipelines,
            stream: _pipelineListBloc.allPipelines,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // if (snapshot.connectionState == ConnectionState.active &&
              //     snapshot.data == null) {
              //   return ErrorPage(() {
              //     _pipelineListBloc.getAllPipelines();
              //   });
              // }
              // if (snapshot.hasError)
              //   return ErrorPage(() {
              //     _pipelineListBloc.getAllPipelines();
              //   });
              // // var pipelines = snapshot as List<Pipeline>;
              return pipelineList(snapshot);
            },
          )
        ],
      ),
    );
  }

  Widget pipelineList(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      var pipelines;
      if (applicationUserId != null) {
        pipelines = (snapshot.data as List<Pipeline>)
            .where((p) =>
                p.stage?.name == stage.name &&
                p.applicationUserId == applicationUserId)
            .toList();
      } else {
        pipelines = (snapshot.data as List<Pipeline>)
            .where((p) => p.stage?.name == stage.name)
            .toList();
      }
      if (pipelines.length > 0) {
        return Expanded(
          child: ListView.builder(
            itemCount: pipelines?.length,
            itemBuilder: (BuildContext context, int index) {
              var pipeline = pipelines[index];
              return pipeline == null
                  ? NoDataWidget("No Pipeline")
                  : PipelineCard(
                      parentContext: context,
                      pipelineListBloc: _pipelineListBloc,
                      pipeline: pipeline,
                      changePipelineRefreshStageSummaryCallBack: () async {
                        await stageListPageBloc.getAllStages();
                      },
                    );
            },
          ),
        );
      }
      return Container(
        height: ScreenUtil().setHeight(500),
        child: NoDataWidget(
            "No Deals on this Stage. Pleasd set Deals to this Stage first or navigate to other stages."),
        alignment: Alignment.center,
      );
    }
    return Container(
      height: ScreenUtil().setHeight(500),
      child: NoDataWidget(
          "No Deals on this Stage. Pleasd set Deals to this Stage first or navigate to other stages."),
      alignment: Alignment.center,
    );
  }
  // Widget _pipelinesInThisStageCard(pipeline) {
  //   return Card(
  //     color: Colors.grey,
  //     margin: EdgeInsets.symmetric(vertical: 15),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //       decoration: BoxDecorations.stageDetailPagePipelinesCardDecoration,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: <Widget>[
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               _pipelineCardMainInfoSection(pipeline),
  //               pipelineRowRightIconButtons(pipeline)
  //             ],
  //           ),
  //           _pipelineCardBottomActionButtons(pipeline)
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _pipelineCardBottomActionButtons(Pipeline pipeline) {
  //   return Wrap(
  //     direction: Axis.horizontal,
  //     spacing: 0.8,
  //     children: <Widget>[
  //       RaisedButton.icon(
  //         color: Colors.white,
  //         icon: Icon(Icons.calendar_today, color: Colors.orange),
  //         onPressed: () {},
  //         label: Text('Schedule'),
  //       ),
  //       RaisedButton.icon(
  //         color: Colors.white,
  //         icon: Icon(
  //           Icons.sms,
  //           color: Colors.blue,
  //         ),
  //         onPressed: () {
  //           if (pipeline.people?.phone == null) {
  //             DialogService().show(context, 'No phone number');
  //             return;
  //           }
  //           UrlSchemeService().sendSMS(pipeline.people?.phone);
  //         },
  //         label: Text('Text'),
  //       ),
  //       RaisedButton.icon(
  //         color: Colors.white,
  //         icon: Icon(
  //           Icons.call,
  //           color: Colors.green,
  //         ),
  //         onPressed: () {
  //           if (pipeline.people?.phone == null) {
  //             DialogService().show(context, 'No phone number');
  //             return;
  //           }
  //           UrlSchemeService().makePhoneCall(pipeline.people?.phone);
  //         },
  //         label: Text('Call'),
  //       ),
  //       RaisedButton.icon(
  //         color: Colors.white,
  //         icon: Icon(
  //           Icons.email,
  //           color: Colors.purple,
  //         ),
  //         onPressed: () {
  //           if (pipeline.people?.email == null) {
  //             DialogService().show(context, 'No Email');
  //             return;
  //           }
  //           UrlSchemeService().sendEmail(pipeline.people?.email);
  //         },
  //         label: Text('Email'),
  //       ),
  //     ],
  //   );
  // }

  // Widget _pipelineCardMainInfoSection(Pipeline pipeline) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: <Widget>[
  //       Text(
  //         TextHelper.checkTextIfNullReturnEmpty(pipeline.company?.name),
  //         style: TextStyles.onlyBoldTextStyle,
  //       ),
  //       Text(
  //           TextHelper.checkTextIfNullReturnEmpty(
  //               pipeline.dealAmount.toString()),
  //           style: TextStyles.onlyBoldTextStyle),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       Text('Contact Name:' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.people?.name)),
  //       Text('Contact Email: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.people?.email)),
  //       Text('Contact Number: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.people?.phone)),
  //       //Text('Deal Stage: '+ TextHelper.checkTextIfNullReturnEmpty(pipeline.stage?.name)),
  //       Text('Task: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.activity?.name)),
  //       Text('Date & Time: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(
  //               DateTimeHelper.parseDateTimeToDateHHMM(
  //                   pipeline.nextFollowUpDate))),
  //       Text('Assigned To: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.employee?.name)),
  //       //Text('Notes:')
  //     ],
  //   );
  // }

  // Widget _pipelineCardRightActionButtons (pipeline) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: <Widget>[
  //       IconButton(
  //         icon: Icon(Icons.view_stream),
  //         onPressed: () {},
  //       ),
  //       IconButton(
  //         icon: Icon(
  //           Icons.star,
  //           color: Colors.red,
  //         ),
  //         onPressed: () {},
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.thumbs_up_down),
  //         onPressed: () {},
  //       )
  //     ],
  //   );
  // }

  // Widget pipelineRowRightIconButtons(Pipeline pipeline) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: <Widget>[
  //       PopupMenuButton(
  //         onSelected: (value) async {
  //           switch (value) {
  //             case PipelineCardDotsMenu.setToWon:
  //               await _pipelineListBloc.setWonLostClose(
  //                   pipeline.id, 'Won', pipeline);
  //               await stageListPageBloc.getAllStages();
  //               Navigator.pop(context);
  //               break;
  //             case PipelineCardDotsMenu.setToLost:
  //               await _pipelineListBloc.setWonLostClose(
  //                   pipeline.id, 'Lost', pipeline);
  //                   await stageListPageBloc.getAllStages();
  //               Navigator.pop(context);
  //               break;
  //             case PipelineCardDotsMenu.setToClose:
  //               await _pipelineListBloc.setWonLostClose(
  //                   pipeline.id, 'Closed', pipeline);
  //                   await stageListPageBloc.getAllStages();
  //               Navigator.pop(context);
  //               break;
  //             case PipelineCardDotsMenu.editLead:
  //               Navigator.of(context).push(MaterialPageRoute(
  //                   builder: (BuildContext context) {
  //                     return BlocProvider<PipelineListBloc>(
  //                       bloc: _pipelineListBloc,
  //                       child: PipelineEditPage(),
  //                     );
  //                   },
  //                   settings: RouteSettings(arguments: pipeline)));
  //               break;
  //             case PipelineCardDotsMenu.deleteLead:
  //               DialogService().showConfirm(
  //                   context, 'Are you sure to delete this lead?', () async {
  //                 await _pipelineListBloc.deletePipelineById(pipeline.id);
  //                 await stageListPageBloc.getAllStages();
  //                 Navigator.pop(context);
  //               });
  //               break;
  //             default:
  //           }
  //         },
  //         icon: Icon(
  //           FontAwesomeIcons.ellipsisV,
  //           color: Colors.lightBlue,
  //         ),
  //         itemBuilder: (BuildContext context) {
  //           return [
  //             PopupMenuItem(
  //               child: Text('Set to WON'),
  //               value: PipelineCardDotsMenu.setToWon,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Set to LOST'),
  //               value: PipelineCardDotsMenu.setToLost,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Set to CLOSED'),
  //               value: PipelineCardDotsMenu.setToClose,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Edit Lead'),
  //               value: PipelineCardDotsMenu.editLead,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Delete'),
  //               value: PipelineCardDotsMenu.deleteLead,
  //             )
  //           ];
  //         },
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.star),
  //         color: Colors.blue,
  //         onPressed: () {},
  //       ),
  //       IconButton(
  //         icon: Icon(
  //           Icons.attach_file,
  //           color: Colors.red,
  //         ),
  //         onPressed: () {},
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.message),
  //         color: Colors.green,
  //         onPressed: () {},
  //       )
  //     ],
  //   );
  // }

  Widget get _stageHeadSummaryListTile {
    return Container(
      height: ScreenUtil().setHeight(150),
      decoration: BoxDecorations.stageDetailPageHeaderDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListTile(
                // leading: stage.iconIndex != null
                //     ? Icon(
                //         GeneralIcons.allIcons[stage.iconIndex],
                //         color: Colors.white,
                //       )
                //     : Container(
                //         width: 10,
                //       ),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      stage.name,
                      style: TextStyles.stageDetailHeaderTitleTextStyle,
                    ),
                    applicationUserId != null
                        ? Text("Total: " + stage.pipelines.where((p)=>p.applicationUserId == applicationUserId).length.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(40)))
                        : Text("Total: " + stage.pipelines.length.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(40))),
                  ],
                ),
                trailing: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("This Month: " + stage.thisMonthNumber.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(40),
                          )),
                      Text(
                          "This Quarter: " + stage.thisQuarterNumber.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(40),
                          )),
                      // stage.primarySummaryName != null
                      //     ? Text(
                      //         stage.primarySummaryName +
                      //             ': ' +
                      //             stage.primarySummaryNumber?.toString(),
                      //         style:
                      //             TextStyle(color: AppColors.normalTextColor),
                      //       )
                      //     : Container(),
                      // stage.secondarySummaryName != null
                      //     ? Text(
                      //         stage.secondarySummaryName +
                      //             ': ' +
                      //             stage.secondarySummaryNumber?.toString(),
                      //         style:
                      //             TextStyle(color: AppColors.normalTextColor),
                      //       )
                      //     : Container(),
                      // stage.thirdSummaryName != null
                      //     ? Text(
                      //         stage.thirdSummaryName +
                      //             ': ' +
                      //             stage.thirdSummaryNumber?.toString(),
                      //         style:
                      //             TextStyle(color: AppColors.normalTextColor),
                      //       )
                      //     : Container()
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
