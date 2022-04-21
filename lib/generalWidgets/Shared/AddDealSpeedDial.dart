import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/Pipeline/AddPipelineBloc.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/LoadingService/LoadingService.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/DropSelectionWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetRelationWidget.dart';
import 'package:mycrm/infrastructure/DateTimeHelper.dart';
import 'package:mycrm/infrastructure/TextHelper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

import '../loadingIndicator.dart';
import 'NoContactInfoGuideWidget.dart';

class AddDealSpeedDial extends StatefulWidget {
  final bool visible;
  final Function onTapCallBackSecond;
  final String heroTag;
  final PipelineListBloc pipelineListBloc;
  final AddPipelineBloc addPipelineBloc = AddPipelineBloc();

  // final Function onTapCallBackThird;
  AddDealSpeedDial(this.visible, this.onTapCallBackSecond, this.heroTag,
      this.pipelineListBloc);

  @override
  State<StatefulWidget> createState() {
    return AddDealSpeedDialState();
  }
}

class AddDealSpeedDialState extends State<AddDealSpeedDial> {
  SpeechRecognition _speech;
  bool autoValidate = false;
  bool _isAvailable = false;
  bool _isListening = false;
  String dealNameVoiceText;
  String dealAmountVoiceText;
  bool dealNameVoiceProcessed;
  bool dealAmountVoiceProcessed;
  DateTime selectedAttainDateTime;
  Timer timer;
  Pipeline pipeline = new Pipeline();
  Company company;
  People people;
  List<Stage> allStageList;
  Stage selectedStage;
  final _cogsAmountController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final _marginController = TextEditingController();
  final _estimatedGPController = TextEditingController();
  final _noteController = TextEditingController();

  var typeDropdownValue = 'Goods Sales';
  var cogsAndMarginDropdownValue = 'COGS Amount';
  @override
  void initState() {
    initSpeechRecognizer();
    dealAmountVoiceProcessed = false;
    dealNameVoiceProcessed = false;
    super.initState();
  }

  initSpeechRecognizer() {
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(
        (bool result) => setState(() => _isAvailable = result));
    _speech.setRecognitionStartedHandler(
        () => setState(() => _isListening = true));

    _speech.setRecognitionResultHandler((String text) {
      print("speech complete: $text");
      // if (dealNameVoiceText == null) {
      //   dealNameVoiceText = text;
      // } else if (dealNameVoiceText != null &&
      //     dealAmountVoiceText == null &&
      //     dealNameVoiceProcessed) {
      //   dealAmountVoiceText = text;
      // }
      if (text.isEmpty && !_isListening) {
        // Fluttertoast.showToast(
        //     msg: "Can not recognize the speech, please try again");
        return;
      }
      if (!_isListening && !dealNameVoiceProcessed) {
        dealNameVoiceText = text;
        onDealNameVoiceComplete();
        dealNameVoiceProcessed = true;
      } else if (dealNameVoiceProcessed &&
          !_isListening &&
          !dealAmountVoiceProcessed) {
        dealAmountVoiceText = text;
        onDealAmountVoiceComplete();
        dealAmountVoiceProcessed = true;
      }
    });

    _speech.setRecognitionCompleteHandler(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      // both default to 16
      marginRight: ScreenUtil().setWidth(500),
      // marginBottom: ScreenUtil().setWidth(400),
      animatedIcon: AnimatedIcons.view_list,
      animatedIconTheme: IconThemeData(size: 22.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      visible: widget.visible,
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: widget.heroTag,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(
              Icons.keyboard_voice,
              color: Colors.white,
            ),
            backgroundColor:
                HttpRequest.appUser.subscriptionPlan != SubcriptionPlan.premium
                    ? Colors.grey
                    : Colors.amber,
            label: 'Speak To Add',
            labelStyle: TextStyle(fontSize: ScreenUtil().setWidth(32)),
            onTap: () async {
              if (HttpRequest.appUser.subscriptionPlan !=
                  SubcriptionPlan.premium) {
                Fluttertoast.showToast(
                    msg:
                        "Please upgrade Subscription Plan to Premium to enable this feature");
                return;
              }
              dealNameVoiceProcessed = false;
              dealAmountVoiceProcessed = false;
              // print("scan business card started");
              PermissionStatus permission = await PermissionHandler()
                  .checkPermissionStatus(PermissionGroup.microphone);
              if (permission != PermissionStatus.granted) {
                Map<PermissionGroup, PermissionStatus> permissions =
                    await PermissionHandler()
                        .requestPermissions([PermissionGroup.microphone]);

                if (permissions[PermissionGroup.microphone] ==
                    PermissionStatus.granted) {
                  await _optionsDialogBox();
                }
              } else {
                await _optionsDialogBox();
              }
            }),
        SpeedDialChild(
          child: Icon(Icons.brush),
          backgroundColor: Colors.blue,
          label: 'Input New Deal',
          labelStyle: TextStyle(fontSize: ScreenUtil().setWidth(32)),
          onTap: widget.onTapCallBackSecond,
        ),
      ],
    );
  }

  double matchWordToNumber(String text) {
    try {
      List<String> pieces = text.toLowerCase().split(' ');

      double total = 0;
      int indexOfMillion = 0;
      int indexOfThousand = 0;
      int indexOfHundred = 0;

      for (var millionString in NumbersInWords.million.values) {
        if (pieces.contains(millionString)) {
          indexOfMillion = pieces.indexOf(millionString);
          String numberOfMillionInWord = pieces[indexOfMillion - 1];

          double numberOfM = 0;

          if (NumbersInWords.ones.values.contains(numberOfMillionInWord)) {
            numberOfM = NumbersInWords.ones.keys.firstWhere(
                (k) => NumbersInWords.ones[k] == numberOfMillionInWord,
                orElse: () => null);
          } else if (NumbersInWords.teens.values
              .contains(numberOfMillionInWord)) {
            numberOfM = NumbersInWords.teens.keys.firstWhere(
                (k) => NumbersInWords.teens[k] == numberOfMillionInWord,
                orElse: () => null);
          } else if (NumbersInWords.tens.values
              .contains(numberOfMillionInWord)) {
            numberOfM = NumbersInWords.tens.keys.firstWhere(
                (k) => NumbersInWords.tens[k] == numberOfMillionInWord,
                orElse: () => null);
          } else if (NumbersInWords.hundred.values
              .contains(numberOfMillionInWord)) {
            numberOfM = NumbersInWords.hundred.keys.firstWhere(
                (k) => NumbersInWords.hundred[k] == numberOfMillionInWord,
                orElse: () => null);
          }

          total += numberOfM * 1000000;
        }
      }

      for (var thousandString in NumbersInWords.thousand.values) {
        if (pieces.contains(thousandString)) {
          indexOfThousand = pieces.indexOf(thousandString);
          String numberInWord = pieces[indexOfThousand - 1];

          double number = 0;

          if (NumbersInWords.ones.values.contains(numberInWord)) {
            number = NumbersInWords.ones.keys.firstWhere(
                (k) => NumbersInWords.ones[k] == numberInWord,
                orElse: () => null);
          } else if (NumbersInWords.teens.values.contains(numberInWord)) {
            number = NumbersInWords.teens.keys.firstWhere(
                (k) => NumbersInWords.teens[k] == numberInWord,
                orElse: () => null);
          } else if (NumbersInWords.tens.values.contains(numberInWord)) {
            number = NumbersInWords.tens.keys.firstWhere(
                (k) => NumbersInWords.tens[k] == numberInWord,
                orElse: () => null);
          } else if (NumbersInWords.hundred.values.contains(numberInWord)) {
            number = NumbersInWords.hundred.keys.firstWhere(
                (k) => NumbersInWords.hundred[k] == numberInWord,
                orElse: () => null);
          }

          total += number * 1000;
        }
      }

      for (var hundredString in NumbersInWords.hundred.values) {
        if (pieces.contains(hundredString)) {
          indexOfHundred = pieces.lastIndexOf(hundredString);
          String numberInWord = pieces[indexOfHundred - 1];

          double number = 0;

          if (NumbersInWords.ones.values.contains(numberInWord)) {
            number = NumbersInWords.ones.keys.firstWhere(
                (k) => NumbersInWords.ones[k] == numberInWord,
                orElse: () => null);
          }
          // else if (NumbersInWords.teens.values.contains(numberInWord)) {
          //   number = NumbersInWords.teens.keys.firstWhere(
          //       (k) => NumbersInWords.teens[k] == numberInWord,
          //       orElse: () => null);
          // } else if (NumbersInWords.tens.values.contains(numberInWord)) {
          //   number = NumbersInWords.tens.keys.firstWhere(
          //       (k) => NumbersInWords.tens[k] == numberInWord,
          //       orElse: () => null);
          // } else if (NumbersInWords.hundred.values.contains(numberInWord)) {
          //   number = NumbersInWords.hundred.keys.firstWhere(
          //       (k) => NumbersInWords.hundred[k] == numberInWord,
          //       orElse: () => null);
          // }

          total += number * 100;
        }
      }

      for (var tensString in NumbersInWords.tens.values) {
        if (pieces.contains(tensString)) {
          int index = pieces.lastIndexOf(tensString);
          String numberInWord = pieces[index];

          double number = 0;

          if (NumbersInWords.tens.values.contains(numberInWord)) {
            number = NumbersInWords.tens.keys.firstWhere(
                (k) => NumbersInWords.tens[k] == numberInWord,
                orElse: () => null);
          }
          // else if (NumbersInWords.teens.values.contains(numberInWord)) {
          //   number = NumbersInWords.teens.keys.firstWhere(
          //       (k) => NumbersInWords.teens[k] == numberInWord,
          //       orElse: () => null);
          // } else if (NumbersInWords.tens.values.contains(numberInWord)) {
          //   number = NumbersInWords.tens.keys.firstWhere(
          //       (k) => NumbersInWords.tens[k] == numberInWord,
          //       orElse: () => null);
          // } else if (NumbersInWords.hundred.values.contains(numberInWord)) {
          //   number = NumbersInWords.hundred.keys.firstWhere(
          //       (k) => NumbersInWords.hundred[k] == numberInWord,
          //       orElse: () => null);
          // }

          total += number;
        }
      }

      for (var onesString in NumbersInWords.ones.values) {
        if (pieces.contains(onesString)) {
          int index = pieces.lastIndexOf(onesString);

          if (index <= indexOfHundred ||
              index <= indexOfThousand ||
              index <= indexOfMillion) continue;
          String numberInWord = pieces[index];

          double number = 0;

          if (NumbersInWords.ones.values.contains(numberInWord)) {
            number = NumbersInWords.ones.keys.firstWhere(
                (k) => NumbersInWords.ones[k] == numberInWord,
                orElse: () => null);
          }
          // else if (NumbersInWords.teens.values.contains(numberInWord)) {
          //   number = NumbersInWords.teens.keys.firstWhere(
          //       (k) => NumbersInWords.teens[k] == numberInWord,
          //       orElse: () => null);
          // } else if (NumbersInWords.tens.values.contains(numberInWord)) {
          //   number = NumbersInWords.tens.keys.firstWhere(
          //       (k) => NumbersInWords.tens[k] == numberInWord,
          //       orElse: () => null);
          // } else if (NumbersInWords.hundred.values.contains(numberInWord)) {
          //   number = NumbersInWords.hundred.keys.firstWhere(
          //       (k) => NumbersInWords.hundred[k] == numberInWord,
          //       orElse: () => null);
          // }

          total += number;
        }
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  processDealNameVoice(speechResult) {
    try {
      //LoadingService.showLoading(context);

      dealNameVoiceText = speechResult;
      dealNameVoiceProcessed = true;

      DialogService().showTextInput(
          context, "Confirm the Deal Name, edit it if required", "Confirm",
          (v) {
        pipeline.dealName = v;
        Navigator.pop(context);

        Future.delayed(Duration(milliseconds: 500), () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  content: new SingleChildScrollView(
                    child: new ListBody(
                      children: <Widget>[
                        GestureDetector(
                          child: new Container(
                              width: ScreenUtil().setWidth(1000),
                              // height: ScreenUtil().setHeight(200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Touch "),
                                      Icon(_isListening
                                          ? Icons.voicemail
                                          : Icons.record_voice_over),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('then tell Dealo the deal amount'),
                                    ],
                                  )
                                ],
                              )),
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 500), () {
                              _speech.activate().then((res) {
                                if (_isAvailable && !_isListening) {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          content: Container(
                                            height: ScreenUtil().setHeight(350),
                                            constraints: BoxConstraints(
                                                maxWidth:
                                                    ScreenUtil().setWidth(500)),
                                            child: Column(
                                              children: <Widget>[
                                                LoadingIndicator(),
                                                VEmptyView(40),
                                                Text(
                                                  'Speak a deal amount and Dealo is listening',
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(45)),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });

                                  _speech.listen(locale: "en_AU");
                                  //Navigator.pop(context);
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Dealo is not ready for your speech, pleast try again.");
                                  Navigator.pop(context);
                                }
                              });
                            });

                            //_speech.cancel();

                            // _speech.stop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
      }, () {
        Navigator.pop(context);
        Navigator.pop(context);
      }, initialValue: dealNameVoiceText);

      //LoadingService.hideLoading(context);

      final formKey = GlobalKey<FormState>();
    } catch (e) {
      DialogService().show(context, "Voice Input Failed");
      LoadingService.hideLoading(context);
    }
  }

  processDealAmountVoice(speechResult) {
    try {
      //LoadingService.showLoading(context);

      //double dealAmount = matchWordToNumber(speechResult);
      double dealAmount = double.tryParse(speechResult);
      if (dealAmount == null) {
        DialogService().show(
            context, "Can not recognize the deal amount, please try again");
        return;
      }
      DialogService().showTextInput(
          context, "Confirm the Deal amount, edit it if required", "Confirm",
          (v) {
        double dealAmountFinal = double.parse(v);
        pipeline.dealAmount = dealAmountFinal;
        reviewDeal();
      }, () {
        Navigator.pop(context);
      }, initialValue: dealAmount.toStringAsFixed(2));

      //LoadingService.hideLoading(context);

    } catch (e) {
      DialogService().show(context, "Voice Input Failed");
      LoadingService.hideLoading(context);
    }
  }

  reviewDeal() {
    final formKey = GlobalKey<FormState>();

    Future.delayed(Duration(milliseconds: 500), () {
      showModalBottomSheet(
        isScrollControlled: true,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setModelState) {
              return Container(
                constraints:
                    BoxConstraints(maxHeight: ScreenUtil().setHeight(1500)),
                margin: EdgeInsets.all(ScreenUtil().setWidth(40)),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    body: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Please Review And Complete Details",
                            style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                          ),
                        ),
                        VEmptyView(10),
                        Container(
                          child: Text("You can edit on the results"),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              autovalidate: autoValidate,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TextFormField(
                                    initialValue: pipeline.dealName ?? "",
                                    decoration: InputDecoration(
                                      labelText: "Deal Name",
                                    ),
                                    validator: (v) {
                                      if (v.isEmpty) {
                                        return "Deal Name can not be empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    initialValue:
                                        pipeline.dealAmount.toString() ?? "",
                                    decoration: InputDecoration(
                                      labelText: "Deal Amount",
                                    ),
                                    validator: (v) {
                                      if (v.isEmpty) {
                                        return "Deal Amount can not be empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  // TextFormField(
                                  //   decoration: InputDecoration(
                                  //     labelText: "Company Name",
                                  //   ),
                                  //   validator: (v) {
                                  //     if (v.isEmpty) {
                                  //       return "Company Name can not be empty";
                                  //     }
                                  //     return null;
                                  //   },
                                  // ),
                                  VEmptyView(100),
                                  people == null
                                      ? Container(
                                          constraints: BoxConstraints(
                                              maxWidth:
                                                  ScreenUtil().setWidth(800)),
                                          child: SetRelationWidget(
                                              SetRelationOption.company, (c) {
                                            setModelState(() {
                                              company = c;
                                            });
                                          }, () {
                                            setModelState(() {
                                              company = null;
                                            });
                                          },
                                              noDataDisplay:
                                                  NoContactInfoGuideWidget(2)),
                                        )
                                      : Container(),
                                  VEmptyView(50),
                                  company == null
                                      ? Container(
                                          constraints: BoxConstraints(
                                              maxWidth:
                                                  ScreenUtil().setWidth(800)),
                                          child: SetRelationWidget(
                                              SetRelationOption.people, (p) {
                                            setModelState(() {
                                              people = p;
                                            });
                                          }, () {
                                            setModelState(() {
                                              people = null;
                                            });
                                          },
                                              noDataDisplay:
                                                  NoContactInfoGuideWidget(2)),
                                        )
                                      : Container(),
                                  VEmptyView(40),
                                  getTypeDropdown(setModelState),
                                  VEmptyView(40),
                                  estimatedCostRow,
                                  VEmptyView(20),
                                  estimatedGPRow,
                                  VEmptyView(50),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Set Stage:",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(42),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600]),
                                      )
                                    ],
                                  ),
                                  VEmptyView(20),
                                  allStageDropdown(setModelState),
                                  VEmptyView(40),

                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Targeted Date to Attain:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(42),
                                            color: Colors.grey[600]),
                                      )
                                    ],
                                  ),
                                  VEmptyView(20),
                                  attainDateTimeCallBackRow(setModelState),
                                  noteRow,
                                  VEmptyView(50),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      RaisedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      WEmptyView(20),
                                      RaisedButton(
                                        child: Text(
                                          "Add Deal",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          if (company == null &&
                                              people == null) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Please set Company or Person");
                                            return;
                                          }
                                          if (formKey.currentState.validate()) {
                                            pipeline.companyId = company?.id;
                                            pipeline.peopleId = people?.id;
                                            pipeline.stageId = selectedStage.id;
                                            if (cogsAndMarginDropdownValue ==
                                                'COGS Amount') {
                                              pipeline.cogsAmount =
                                                  double.parse(
                                                      _cogsAmountController.text
                                                          .replaceAll(",", ""));
                                            }
                                            if (cogsAndMarginDropdownValue ==
                                                'Cost Margin%') {
                                              pipeline.margin = double.parse(
                                                      _marginController.text) /
                                                  100;
                                            }

                                            pipeline.type = typeDropdownValue;
                                            pipeline.attainDate =
                                                selectedAttainDateTime;
                                            pipeline.note =
                                                _noteController.text;
                                            await widget.pipelineListBloc
                                                .addPipeline(pipeline);
                                            PipelineListPageState.isInit = true;
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                                msg: "Deal Added");
                                          } else {
                                            await Fluttertoast.showToast(
                                                msg:
                                                    "Please ensure all information are correct");
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        context: context,
      );
    });
  }

  Widget getTypeDropdown(Function setModelState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
          child: Text(
            "Type:",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(42),
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
        ),
        VEmptyView(20),
        Container(
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
            height: ScreenUtil().setHeight(50),
            width: ScreenUtil().setWidth(500),
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.white, width: 0),
              color: Theme.of(context).primaryColor,
            ),
            constraints: BoxConstraints(
                // maxWidth: ScreenUtil().setWidth(650),
                minHeight: ScreenUtil().setHeight(120)),
            child: Theme(
                data: ThemeData(canvasColor: Theme.of(context).primaryColor),
                child: DropdownButton<String>(
                  value: typeDropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      typeDropdownValue = newValue;
                    });
                    setModelState(() {
                      typeDropdownValue = newValue;
                    });
                  },
                  isDense: true,
                  isExpanded: false,
                  underline: Container(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(48),
                      fontWeight: FontWeight.bold),
                  items: <String>['Goods Sales', 'Services']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                          ),
                          width: ScreenUtil().setWidth(380),
                        ));
                  }).toList(),
                ))),
        VEmptyView(40),
        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
          child: Text(
            "Cost Model:",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(42),
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
        ),
        VEmptyView(20),
        Container(
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
            height: ScreenUtil().setHeight(50),
            width: ScreenUtil().setWidth(500),
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.white, width: 0),
              color: Theme.of(context).primaryColor,
            ),
            constraints: BoxConstraints(
                // maxWidth: ScreenUtil().setWidth(650),
                minHeight: ScreenUtil().setHeight(120)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Theme(
                    data:
                        ThemeData(canvasColor: Theme.of(context).primaryColor),
                    child: DropdownButton<String>(
                      value: cogsAndMarginDropdownValue,
                      isDense: true,
                      isExpanded: false,
                      onChanged: (String newValue) {
                        setState(() {
                          cogsAndMarginDropdownValue = newValue;
                          _cogsAmountController.text = "0.00";
                          _marginController.text = "";
                          _estimatedGPController.text = "";
                        });
                        setModelState(() {
                          cogsAndMarginDropdownValue = newValue;
                          _cogsAmountController.text = "0.00";
                          _marginController.text = "";
                          _estimatedGPController.text = "";
                        });
                      },
                      underline: Container(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(48),
                          fontWeight: FontWeight.bold),
                      items: <String>['COGS Amount', 'Cost Margin%']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                              ),
                              width: ScreenUtil().setWidth(380),
                            ));
                      }).toList(),
                    ))
              ],
            ))
      ],
    );
  }

  Widget get estimatedCostRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: getEstimatedTextField()),
          SizedBox(width: ScreenUtil().setSp(600))
        ],
      ),
    );
  }

  getEstimatedTextField() {
    if (cogsAndMarginDropdownValue == 'COGS Amount') {
      return TextFormField(
        onChanged: (value) {
          Timer timer = new Timer(new Duration(seconds: 3), () {
            var gp = double.parse(dealAmountVoiceText.replaceAll(",", "")) -
                double.parse(_cogsAmountController.text.replaceAll(",", ""));
            setState(() {
              _estimatedGPController.text = gp.toStringAsFixed(2);
            });
          });
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        enabled: company != null || people != null,
        controller: _cogsAmountController,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(labelText: 'COGS Amount:'),
      );
    } else {
      return TextFormField(
        onChanged: (value) {
          Timer timer = new Timer(new Duration(seconds: 3), () {
            var gp = double.parse(dealAmountVoiceText.replaceAll(",", "")) *
                (1 -
                    double.parse(_marginController.text.replaceAll(",", "")) /
                        100);

            setState(() {
              _estimatedGPController.text = gp.toStringAsFixed(2);
            });
          });
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        enabled: company != null || people != null,
        controller: _marginController,
        maxLength: 2,
        maxLengthEnforced: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Cost Margin%'),
      );
    }
  }

  Widget get estimatedGPRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              style: TextStyle(fontWeight: FontWeight.bold),
              enabled: false,
              controller: _estimatedGPController,
              decoration: InputDecoration(labelText: 'Gross Profit:'),
            ),
          ),
          SizedBox(width: ScreenUtil().setSp(600))
        ],
      ),
    );
  }

  Widget allStageDropdown(Function setModelState) {
    //addPipelineBloc.getAllStages();
    return CustomStreamBuilder(
        retryCallback: widget.addPipelineBloc.getAllStages,
        stream: widget.addPipelineBloc.allStages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          allStageList = snapshot.data as List<Stage>;
          if (selectedStage == null) {
            selectedStage =
                allStageList.length == 0 ? null : allStageList.first;
          }
          return CustomDropdownSelection(
            "",
            allStageList,
            selectedStage,
            (value) {
              setState(() {
                selectedStage = value;
              });
              setModelState(() {
                selectedStage = value;
              });
            },
            createCallBack: createStageCallBack,
          );
        });
  }

  createStageCallBack() {
    DialogService().showTextInput(context, "Create A New Stage", "Create",
        (name) async {
      var newStage = Stage(name: name);
      await widget.addPipelineBloc.addStage(newStage);
    }, () {
      Navigator.pop(context);
    });
  }

  onDealNameVoiceComplete() {
    print("said:" + dealNameVoiceText);
    //Navigator.pop(context);
    if (dealNameVoiceText != null) processDealNameVoice(dealNameVoiceText);
  }

  onDealAmountVoiceComplete() {
    print("said:" + dealAmountVoiceText);
    Navigator.pop(context);
    if (dealAmountVoiceText != null)
      processDealAmountVoice(dealAmountVoiceText);
  }

  Future<void> _optionsDialogBox() async {
    // Navigator.of(context).pop();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(ScreenUtil().setWidth(20)),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                      child: new Container(
                          width: ScreenUtil().setWidth(1000),
                          // height: ScreenUtil().setHeight(80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Touch "),
                                  Icon(_isListening
                                      ? Icons.voicemail
                                      : Icons.record_voice_over),
                                ],
                              ),
                              Text('then tell Dealo a deal name'),
                            ],
                          )),
                      onTap: () async {
                        await _speech.activate().then(
                          (res) async {
                            _isAvailable = res;
                            // if (!_isAvailable) {
                            //   Navigator.pop(context);
                            //   return;
                            // }
                            Navigator.pop(context);
                            if (_isAvailable && !_isListening) {
                              _speech.listen(locale: "en_AU");
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      content: Container(
                                        height: ScreenUtil().setHeight(350),
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                ScreenUtil().setWidth(500)),
                                        child: Column(
                                          children: <Widget>[
                                            LoadingIndicator(),
                                            VEmptyView(20),
                                            Text(
                                              'Speak a deal name',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(45)),
                                            ),
                                            Text(
                                              'and Dealo is listening',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(45)),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            } else {
                              await Fluttertoast.showToast(
                                  msg:
                                      "Dealo is not ready for your speech, pleast try again.");
                              Navigator.pop(context);
                            }

                            //_speech.cancel();

                            // _speech.stop();
                          },
                        );
                      }),
                ],
              ),
            ),
          );
        });
  }

  Widget attainDateTimeCallBackRow(Function setModelState) {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 50),
      padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(55), 0, ScreenUtil().setWidth(485), 0),
      width: ScreenUtil().setWidth(200),
      height: ScreenUtil().setHeight(110),
      child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          colorBrightness: Brightness.light,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            DatePicker.showDatePicker(context, showTitleActions: true,
                // minTime: DateTime.now().add(-Duration(days: 365)),
                // maxTime: DateTime.now().add(Duration(days: 365)),
                onConfirm: (date) {
              selectedAttainDateTimeCallBack(date, setModelState);
            },
                currentTime: DateTime.now().add(Duration(days: 1)),
                locale: LocaleType.en);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              selectedAttainDateTime != null
                  ? selectEventStartDateTimeText
                  : Text(
                      'Date',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
              // Icon(
              //   Icons.timer,
              //   color: Theme.of(context).primaryColor,
              // )
            ],
          )),
    );
  }

  selectedAttainDateTimeCallBack(date, Function setModelState) {
    setState(() {
      selectedAttainDateTime = date;
    });
    setModelState(() {
      selectedAttainDateTime = date;
    });
  }

  Widget get selectEventStartDateTimeText {
    return Container(
      width: ScreenUtil().setWidth(300),
      child: Text(
          TextHelper.checkTextIfNullReturnEmpty(
              DateTimeHelper.parseDateTimeToDate(selectedAttainDateTime)),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(44),
              color: Colors.white)),
    );
  }

  Widget get noteRow {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              enabled: company != null || people != null,
              style: TextStyle(fontWeight: FontWeight.bold),
              keyboardType: TextInputType.multiline,
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Note:'),
              maxLines: null,
            ),
          )
        ],
      ),
    );
  }
}
