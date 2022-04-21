// import 'package:flutter/material.dart';
// import 'package:mycrm/Bloc/BlocBase.dart';
// import 'package:mycrm/Bloc/Pipeline/AddPipelineBloc.dart';
// import 'package:mycrm/Bloc/Stage/StageListPageBloc.dart';
// import 'package:mycrm/Http/Repos/Stage/StageRepo.dart';
// import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
// import 'package:mycrm/Models/Core/Stage/Stage.dart';
// import 'package:mycrm/Models/Views/StageViewModel.dart';
// import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
// import 'package:mycrm/Services/ErrorService/ErrorService.dart';
// import 'package:mycrm/Styles/BoxDecorations.dart';
// import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
// import 'package:mycrm/generalWidgets/RoundedRaiseButton.dart';

// class AddStagePage extends StatefulWidget {
//   @override
//   AddStagePageState createState() => AddStagePageState();
// }

// class AddStagePageState extends State<AddStagePage> {
//   var newStagePositionSelectOption;
//   var showAllStagesDropDown;
//   var selectedStagePositionToInsertAfter;
//   var formKey;
//   var newStageNameTextFieldController;
//   List<StagesDropdownSelection> stageSelectionList;
//   var primarySummaryNameSelection;
//   var secondSummaryNameSelection;
//   var thirdSummaryNameSelection;
//   var showSecondSummaryDropdown;
//   var showThirdSummaryDropdown;
//   Stage stageNew;
//   bool isloading;
//   bool _autoValidate;
//   List<Stage> stageList;
//   int selectedIconDataIndex;
//   final scaffHoldKey = GlobalKey<ScaffoldState>();

//   StageListPageBloc stageListBloc;
//   AddPipelineBloc addPipelineBloc;

//   @override
//   void initState() {
//     initAddStagePageState();
//     initStages();
//     super.initState();
//   }

//   // @override
//   // void dispose() {
//   //   newStageNameTextFieldController?.dispose();
//   //   //stageListBloc?.dispose();
//   //   //addPipelineBloc?.dispose();
//   //   super.dispose();
//   // }

//   void initAddStagePageState() {
//     //stageNew = new Stage();
//     _autoValidate = false;
//     isloading = false;
//     showAllStagesDropDown = false;
//     selectedStagePositionToInsertAfter = 1;
//     newStagePositionSelectOption = radioButtonSelections.none;
//     formKey = new GlobalKey<FormState>();
//     newStageNameTextFieldController = new TextEditingController();
//     stageSelectionList = new List<StagesDropdownSelection>();
//     showSecondSummaryDropdown = false;
//     showThirdSummaryDropdown = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     stageListBloc = BlocProvider.of<StageListPageBloc>(context);
//     addPipelineBloc = BlocProvider.of<AddPipelineBloc>(context);

//     return Scaffold(
//       key: scaffHoldKey,
//       resizeToAvoidBottomPadding: false,
//       appBar: GeneralAppBar(
//               'Add Stage', 'Stage', formKey, scaffHoldKey, confirmButtonAction)
//           .create(),
//       body: Form(
//         autovalidate: _autoValidate,
//         key: formKey,
//         child: isloading
//             ? LoadingIndicator()
//             : ListView(
//                 children: <Widget>[
//                   _newStageNameTextField,
//                   //_selectStageIcon,
//                  // _summaryOptions,
//                  SizedBox(height: 30,),
//                   _newStagePositionSelectionRadioGroup
//                 ],
//               ),
//       ),
//     );
//   }

//   void confirmButtonAction() {
//     _autoValidate = true;
//     setState(() {
//       isloading = true;
//     });
//     print('start add stage request');
//     //send post request to add stage
//     stageNew = new Stage(
//         name: newStageNameTextFieldController.text,
//         // primarySummaryName: primarySummaryNameSelection,
//         // secondarySummaryName: secondSummaryNameSelection,
//         // thirdSummaryName: thirdSummaryNameSelection,
//         //iconIndex: selectedIconDataIndex
//         );

//     if (formKey.currentState.validate()) {
//       postForm();
//     }
//   }

//   void postForm() async {
//     if (newStagePositionSelectOption == radioButtonSelections.none) {
//       final snackBar = SnackBar(content: Text('New Stage Position Required'));
//       scaffHoldKey.currentState.showSnackBar(snackBar);
//       setState(() {
//         isloading = false;
//       });
//       return;
//     } else if (newStagePositionSelectOption == radioButtonSelections.first) {
//       stageNew.displayIndex = 1;
//     } else if (newStagePositionSelectOption == radioButtonSelections.last) {
//       stageNew.displayIndex = stageList.length;
//     } else if (newStagePositionSelectOption == radioButtonSelections.manual) {
//       stageNew.displayIndex = selectedStagePositionToInsertAfter + 1;
//     }

//     print('begin http request');
//     try {
//       if (stageListBloc !=null) {
//         //var result = await StageRepo().add(stageNew);
//         //if (result.statusCode == 200 || result.statusCode == 201) {
//           //force refresh all stages to get the new stage
//           //initStages();
//           await stageListBloc.addStage(stageNew);
//           await ShowSnackBarAndGoBackHelper.go(scaffHoldKey, "Stage Added", context);
//         //} else {
//           //locator<ErrorService>().handleErrorResult(result, context);
//        // }
//       } else if (addPipelineBloc !=null) {
//         await addPipelineBloc.addStage(stageNew);
//         await ShowSnackBarAndGoBackHelper.go(scaffHoldKey, "Stage Added", context);
//       }
//     } catch (e) {
//       //ErrorService().handlePageLevelException(e, context);
//     } finally {
//       setState(() {
//         isloading = false;
//       });
//     }
//   }

//   // Widget get _summaryOptions {
//   //   return Container(
//   //       margin: EdgeInsets.all(20),
//   //       child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //           children: <Widget>[
//   //             Container(
//   //               margin: EdgeInsets.only(bottom: 20),
//   //               child: Text(
//   //                 'Optional',
//   //                 style: TextStyles.onlyBoldTextStyle,
//   //               ),
//   //             ),
//   //             Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: <Widget>[
//   //                 Text('Choose First Summary for this Stage'),
//   //                 SizedBox(height: 10),
//   //                 _firstSummaryDropdown
//   //               ],
//   //             ),
//   //             showSecondSummaryDropdown
//   //                 ? Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: <Widget>[
//   //                       SizedBox(height: 10),
//   //                       Text('Choose Second Summary for this Stage'),
//   //                       _secondSummaryDropdown
//   //                     ],
//   //                   )
//   //                 : Container(),
//   //             showThirdSummaryDropdown
//   //                 ? Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: <Widget>[
//   //                       SizedBox(height: 5),
//   //                       Text('Choose Third Summary for this Stage'),
//   //                       _thirdSummaryDropdown
//   //                     ],
//   //                   )
//   //                 : Container()
//   //           ]));
//   // }

//   Widget get _thirdSummaryDropdown {
//     return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
//       DropdownButton<String>(
//         items: Stage.defaultStageSummaries.map((String summary) {
//           return DropdownMenuItem<String>(value: summary, child: Text(summary));
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             thirdSummaryNameSelection = value;
//           });
//         },
//         value: thirdSummaryNameSelection,
//       ),
//       SizedBox(width: 100),
//     ]);
//   }

//   Widget get _secondSummaryDropdown {
//     return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
//       DropdownButton<String>(
//         items: Stage.defaultStageSummaries.map((String summary) {
//           return DropdownMenuItem<String>(value: summary, child: Text(summary));
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             secondSummaryNameSelection = value;
//           });
//         },
//         value: secondSummaryNameSelection,
//       ),
//       SizedBox(width: 10),
//       RoundedRaisedButton(() {
//         setState(() {
//           showThirdSummaryDropdown = !showThirdSummaryDropdown;
//         });
//       }, 
      
//       Text(  !showThirdSummaryDropdown? 'Add Summary':"Hide", style: TextStyle(color: Colors.white, fontSize: 12),))
//     ]);
//   }

//   Widget get _firstSummaryDropdown {
//     return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
//       DropdownButton<String>(
//         items: Stage.defaultStageSummaries.map((String summary) {
//           return DropdownMenuItem<String>(value: summary, child: Text(summary));
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             primarySummaryNameSelection = value;
//           });
//         },
//         value: primarySummaryNameSelection,
//       ),
//       SizedBox(width: 10),
//       RoundedRaisedButton(() {
//         setState(
//           () {
//             showSecondSummaryDropdown = !showSecondSummaryDropdown;
//           },
//         );
//       }, Text( !showSecondSummaryDropdown? 'Add Summary':"Hide", style: TextStyle(color: Colors.white, fontSize: 12)))
//     ]);
//   }

//   Widget get _newStageNameTextField {
//     return Container(
//         decoration: BoxDecorations.addStagePageStageNameBackgroundDecoration,
//         child: Container(
//           margin: EdgeInsets.all(5),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   Container(
//                     child: Expanded(
//                         child: Container(
//                       decoration: BoxDecoration(color: Colors.white),
//                       child: Theme(
//                           data: new ThemeData(primaryColor: Colors.white),
//                           child: TextFormField(
//                             controller: newStageNameTextFieldController,
//                             decoration: new InputDecoration(
//                                 enabledBorder: OutlineInputBorder(
//                                     borderSide:
//                                         BorderSide(color: Colors.white)),
//                                 border: OutlineInputBorder(
//                                     borderSide: BorderSide(
//                                         color: Colors.white,
//                                         width: 10.0,
//                                         style: BorderStyle.solid)),
//                                 labelText: "Enter new stage name",
//                                 labelStyle: TextStyle(color: Colors.black)),
//                             validator: (value) {
//                               if (value.isEmpty) {
//                                 return 'Please enter Stage Name';
//                               }
//                               return null;
//                             },
//                           )),
//                     )),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget get _newStagePositionSelectionRadioGroup {
//     return Container(
//       margin: EdgeInsets.only(left:20),
//         child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Container(
//             child: Text(
//           'Position of the new stage',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         )),
//         _firstStageRadioButton,
//         _lastStageRadioButton,
//         _addThisStageAfterRadioButton,
//         showAllStagesDropDown ? _allStageDropdown : Container(),
//       ],
//     ));
//   }

//   Widget get _firstStageRadioButton {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         Radio(
//           groupValue: newStagePositionSelectOption,
//           value: radioButtonSelections.first,
//           onChanged: (value) {
//             setState(() {
//               newStagePositionSelectOption = value;
//               showAllStagesDropDown = false;
//             });
//           },
//         ),
//         Text('This is the first stage'),
//         SizedBox(width: 20)
//       ],
//     );
//   }

//   Widget get _lastStageRadioButton {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         Radio(
//           groupValue: newStagePositionSelectOption,
//           value: radioButtonSelections.last,
//           onChanged: (value) {
//             setState(() {
//               newStagePositionSelectOption = value;
//               showAllStagesDropDown = false;
//             });
//           },
//         ),
//         Text('This is the last stage'),
//         SizedBox(width: 20)
//       ],
//     );
//   }

//   Widget get _addThisStageAfterRadioButton {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         Radio(
//           groupValue: newStagePositionSelectOption,
//           onChanged: (value) {
//             setState(() {
//               newStagePositionSelectOption = value;
//               showAllStagesDropDown = true;
//             });
//           },
//           value: radioButtonSelections.manual,
//         ),
//         Text('Add this stage after:'),
//         SizedBox(width: 20)
//       ],
//     );
//   }

//   Widget get _allStageDropdown {
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
//       DropdownButton<int>(
//         hint: Text(stageSelectionList.first.displayText),
//         items: stageSelectionList.map((StagesDropdownSelection selection) {
//           return DropdownMenuItem<int>(
//               value: selection.displayIndex,
//               child: Text(selection.displayText.toString()));
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             selectedStagePositionToInsertAfter = value;
//           });
//         },
//         value: selectedStagePositionToInsertAfter,
//       )
//     ]);
//   }

//   // Widget get _selectStageIcon {
//   //   return Container(
//   //     margin: EdgeInsets.only(top: 10, left: 150, right: 150),
//   //     height: 50,
//   //     child: RaisedButton(
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   //       onPressed: () {
//   //         //icons gridview modal
//   //         showModalBottomSheet(
//   //             builder: (BuildContext context) {
//   //               return DraggableScrollableSheet(
//   //                 initialChildSize: 1,
//   //                 minChildSize: 0.5,
//   //                 maxChildSize: 1,
//   //                 builder: (BuildContext context,
//   //                     ScrollController scrollController) {
//   //                   return Container(
//   //                       child: GridView.count(
//   //                     crossAxisCount: 5,
//   //                     children:
//   //                         List.generate(GeneralIcons.allIcons.length, (index) {
//   //                       return Center(
//   //                         child: IconButton(
//   //                           icon: Icon(GeneralIcons.allIcons[index]),
//   //                           onPressed: () {
//   //                             setState(() {
//   //                               selectedIconDataIndex = index;
//   //                             });
//   //                             Navigator.pop(context);
//   //                           },
//   //                         ),
//   //                       );
//   //                     }),
//   //                   ));
//   //                 },
//   //               );
//   //             },
//   //             context: context);
//   //       },
//   //       child: selectedIconDataIndex == null
//   //           ? Text(
//   //               'Select Icon',
//   //               style:
//   //                   TextStyle(color: AppColors.normalTextColor, fontSize: 15),
//   //             )
//   //           : Icon(
//   //               GeneralIcons.allIcons[selectedIconDataIndex],
//   //               color: Colors.white,
//   //               size: 30,
//   //             ),
//   //     ),
//   //   );
//   // }

//   void initStages() async {
//     stageList = await StageRepo().getAllStage();

//     stageSelectionList = stageList.map((s) {
//       return new StagesDropdownSelection(s.displayIndex, s.name);
//     }).toList();
//   }
// }

// enum radioButtonSelections { none, first, last, manual }
