// import 'package:flutter/material.dart';
// import 'package:mycrm/Bloc/BlocBase.dart';
// import 'package:mycrm/Bloc/Stage/StageListPageBloc.dart';
// import 'package:mycrm/Http/Repos/Stage/StageRepo.dart';
// import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
// import 'package:mycrm/Models/Core/Stage/Stage.dart';
// import 'package:mycrm/Models/Views/StageViewModel.dart';
// import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
// import 'package:mycrm/Services/ErrorService/ErrorService.dart';
// import 'package:mycrm/Styles/AppColors.dart';
// import 'package:mycrm/Styles/BoxDecorations.dart';
// import 'package:mycrm/Styles/GeneralIcons.dart';
// import 'package:mycrm/Styles/TextStyles.dart';
// import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
// import 'package:mycrm/generalWidgets/RoundedRaiseButton.dart';

// class EditStagePage extends StatefulWidget {
//   @override
//   EditStagePageState createState() => EditStagePageState();
// }

// class EditStagePageState extends State<EditStagePage> {
//   var newStagePositionSelectOption;
//   var showAllStagesDropDown;
//   var selectedStagePositionToInsertAfter;
//   var formKey;
//   var newStageNameTextFieldController;
//   List<StagesDropdownSelection> stageSelectionList;
//   String primarySummaryNameSelection;
//   String secondSummaryNameSelection;
//   String thirdSummaryNameSelection;
//   bool showSecondSummaryDropdown;
//   bool showThirdSummaryDropdown;
//   bool hasSecondSummary;
//   bool hasThirdSummary;
//   Stage selectedStage;
//   bool isloading;
//   bool _autoValidate;
//   List<Stage> stageList;
//   int selectedIconDataIndex;
//   final scaffHoldKey = GlobalKey<ScaffoldState>();
//   StageListPageBloc stageListPageBloc;

//   @override
//   void initState() {
//     initEditStagePageState();
//     initStages();
//     super.initState();
//   }

//   // @override
//   // void dispose() {
//   //   //stageListPageBloc?.dispose();
//   //   super.dispose();
//   // }

//   void initEditStagePageState() {
//     _autoValidate = false;
//     isloading = false;
//     showAllStagesDropDown = false;
//     selectedStagePositionToInsertAfter = 1;
//     newStagePositionSelectOption = radioButtonSelections.none;
//     formKey = new GlobalKey<FormState>();
//     stageSelectionList = new List<StagesDropdownSelection>();
//     showSecondSummaryDropdown = false;
//     showThirdSummaryDropdown = false;
//     hasSecondSummary = false;
//     hasThirdSummary = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     stageListPageBloc = BlocProvider.of<StageListPageBloc>(context);
//     selectedStage = ModalRoute.of(context).settings.arguments;
//     newStageNameTextFieldController = newStageNameTextFieldController ??
//         TextEditingController(text: selectedStage.name);
//     //hasSecondSummary = selectedStage.secondarySummaryName?.isNotEmpty ?? false;
//     //hasThirdSummary = selectedStage.thirdSummaryName?.isNotEmpty ?? false;
//     // primarySummaryNameSelection =
//     //     primarySummaryNameSelection ?? selectedStage.primarySummaryName;
//     // secondSummaryNameSelection =
//     //     secondSummaryNameSelection ?? selectedStage.secondarySummaryName;
//     // thirdSummaryNameSelection =
//     //     thirdSummaryNameSelection ?? selectedStage.thirdSummaryName;
//     selectedIconDataIndex = selectedIconDataIndex ?? selectedStage.iconIndex;
//     return Scaffold(
//       key: scaffHoldKey,
//       resizeToAvoidBottomPadding: false,
//       appBar: GeneralAppBar(
//               'Edit Stage', 'Stage', formKey, scaffHoldKey, confirmButtonAction)
//           .create(),
//       body: Form(
//         autovalidate: _autoValidate,
//         key: formKey,
//         child: isloading
//             ? LoadingIndicator()
//             : ListView(
//                 children: <Widget>[
//                   _editStageNameTextField,
//                   //_selectStageIcon,
//                   _summaryOptions,
//                   _editStagePositionSelectionRadioGroup
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget get _summaryOptions {
//     return Container(
//         margin: EdgeInsets.symmetric(vertical: 20),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               Container(
//                 margin: EdgeInsets.only(bottom: 20),
//                 child: Text(
//                   'Optional',
//                   style: TextStyles.onlyBoldTextStyle,
//                 ),
//               ),
//               Column(
//                 children: <Widget>[
//                   Text('Choose First Summary for this Stage'),
//                   SizedBox(height: 10),
//                   _firstSummaryDropdown
//                 ],
//               ),
//               showSecondSummaryDropdown || hasSecondSummary
//                   ? Column(
//                       children: <Widget>[
//                         SizedBox(height: 10),
//                         Text('Choose Second Summary for this Stage'),
//                         _secondSummaryDropdown
//                       ],
//                     )
//                   : Container(),
//               showThirdSummaryDropdown || hasThirdSummary
//                   ? Column(
//                       children: <Widget>[
//                         SizedBox(height: 5),
//                         Text('Choose Third Summary for this Stage'),
//                         _thirdSummaryDropdown
//                       ],
//                     )
//                   : Container()
//             ]));
//   }

//   Widget get _thirdSummaryDropdown {
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
//           showThirdSummaryDropdown = true;
//         });
//       }, GeneralIcons.addIconWhite)
//     ]);
//   }

//   Widget get _firstSummaryDropdown {
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
//             showSecondSummaryDropdown = true;
//           },
//         );
//       }, GeneralIcons.addIconWhite)
//     ]);
//   }

//   Widget get _editStageNameTextField {
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
//                                 labelText: "Enter stage name",
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

//   Widget get _editStagePositionSelectionRadioGroup {
//     return Container(
//         child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         Container(
//             child: Text(
//           'Position of the stage',
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
//       mainAxisAlignment: MainAxisAlignment.center,
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
//       mainAxisAlignment: MainAxisAlignment.center,
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
//       mainAxisAlignment: MainAxisAlignment.center,
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

//   Widget get _selectStageIcon {
//     return Container(
//       margin: EdgeInsets.only(top: 10, left: 150, right: 150),
//       height: 50,
//       child: RaisedButton(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         onPressed: () {
//           //icons gridview modal
//           showModalBottomSheet(
//               builder: (BuildContext context) {
//                 return DraggableScrollableSheet(
//                   initialChildSize: 1,
//                   minChildSize: 0.5,
//                   maxChildSize: 1,
//                   builder: (BuildContext context,
//                       ScrollController scrollController) {
//                     return Container(
//                         child: GridView.count(
//                       crossAxisCount: 5,
//                       children:
//                           List.generate(GeneralIcons.allIcons.length, (index) {
//                         return Center(
//                           child: IconButton(
//                             icon: Icon(GeneralIcons.allIcons[index]),
//                             onPressed: () {
//                               setState(() {
//                                 selectedIconDataIndex = index;
//                               });
//                               Navigator.pop(context);
//                             },
//                           ),
//                         );
//                       }),
//                     ));
//                   },
//                 );
//               },
//               context: context);
//         },
//         child: selectedIconDataIndex == null
//             ? Text(
//                 'Select Icon',
//                 style:
//                     TextStyle(color: AppColors.normalTextColor, fontSize: 15),
//               )
//             : Icon(
//                 GeneralIcons.allIcons[selectedIconDataIndex],
//                 color: Colors.white,
//                 size: 30,
//               ),
//       ),
//     );
//   }

//   void initStages() async {
//     stageList = await StageRepo().getAllStage();

//     stageSelectionList = stageList.map((s) {
//       return new StagesDropdownSelection(s.displayIndex, s.name);
//     }).toList();
//   }

//   void confirmButtonAction() {
//     _autoValidate = true;
//     setState(() {
//       isloading = true;
//     });
//     print('start add stage request');
//     //send post request to add stage
//     selectedStage.name = newStageNameTextFieldController.text;
//     // selectedStage.primarySummaryName = primarySummaryNameSelection;
//     // selectedStage.secondarySummaryName = secondSummaryNameSelection;
//     // selectedStage.thirdSummaryName = thirdSummaryNameSelection;
//     //selectedStage.iconIndex = selectedIconDataIndex;

//     if (formKey.currentState.validate()) {
//       postForm();
//     }
//   }

//   void postForm() async {
//     // if (newStagePositionSelectOption == radioButtonSelections.none) {
//     //   final snackBar = SnackBar(content: Text('Stage Position Required'));
//     //   scaffHoldKey.currentState.showSnackBar(snackBar);
//     //   setState(() {
//     //     isloading = false;
//     //   });
//     //   return;
//     //} else
//     if (newStagePositionSelectOption == radioButtonSelections.first) {
//       selectedStage.displayIndex = 1;
//     } else if (newStagePositionSelectOption == radioButtonSelections.last) {
//       selectedStage.displayIndex = stageList.length;
//     } else if (newStagePositionSelectOption == radioButtonSelections.manual) {
//       selectedStage.displayIndex = selectedStagePositionToInsertAfter + 1;
//     }

//     print('begin http request');
//     try {
//       //var result = await StageRepo().update(selectedStage);
//       //if (result.statusCode == 200 || result.statusCode == 204) {
//       await stageListPageBloc.updateStage(selectedStage);
//       await ShowSnackBarAndGoBackHelper.go(
//           scaffHoldKey, "Stage Updated", context);
//       //} else {
//       //locator<ErrorService>().handleErrorResult(result, context);
//       //}
//     } catch (e) {
//       //ErrorService().handlePageLevelException(e, context);
//     } finally {
//       setState(() {
//         isloading = false;
//       });
//     }
//   }
// }

// enum radioButtonSelections { none, first, last, manual }
