import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/GeneralWidgets/RemoveBinIconButton.dart';
import 'package:mycrm/Http/Repos/Company/CompanyRepo.dart';
import 'package:mycrm/Http/Repos/Pipeline/PipelineRepo.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/NoContactInfoGuideWidget.dart';
import 'package:mycrm/generalWidgets/Shared/SetRelationWidget.dart';

class EditPeoplePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditPeopleState();
  }
}

class _EditPeopleState extends State<EditPeoplePage> {
  //Future<List<Company>> allCompaniesFuture;
  //Future<List<Pipeline>> allPipelinesFuture;
  bool _autoValidate = false;
  bool hasWorkEmail;
  bool hasWorkPhone;
  bool showWorkEmailInput;
  bool showWorkPhoneInput;
  Company selectedCompany;
  Pipeline selectedPipeline;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  People selectedPeople;
  ContactListPageBloc contactListPageBloc;
  bool isInit;

  final formKey = GlobalKey<FormState>();
  var _firstNameController;
  var _lastNameController;
  var _emailController;
  var _workEmailController;
  var _phoneController;
  var _workPhoneController;

  @override
  void initState() {
    isInit = true;
    hasWorkEmail = false;
    hasWorkPhone = false;
    showWorkEmailInput = false;
    showWorkPhoneInput = false;
    _autoValidate = false;
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   // _firstNameController.dispose();
  //   // _lastNameController.dispose();
  //   // _emailController.dispose();
  //   // _workEmailController.dispose();
  //   // _emailController.dispose();
  //   // _phoneController.dispose();
  //   // _workPhoneController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      //allCompaniesFuture = CompanyRepo().getAllCompanies();
      // allPipelinesFuture = PipelineRepo().getAllPipelines();
      selectedPeople = ModalRoute.of(context).settings.arguments;
      selectedCompany = selectedPeople.company;
      contactListPageBloc = BlocProvider.of<ContactListPageBloc>(context);
      isInit = false;
    }

    _firstNameController = _firstNameController ??
        TextEditingController(
            text: TextHelper.checkTextIfNullReturnEmpty(
                selectedPeople.firstName));
    _lastNameController = _lastNameController ??
        TextEditingController(
            text:
                TextHelper.checkTextIfNullReturnEmpty(selectedPeople.lastName));
    _emailController = _emailController ??
        TextEditingController(
            text: TextHelper.checkTextIfNullReturnEmpty(selectedPeople.email));
    _workEmailController = _workEmailController ??
        TextEditingController(
            text: TextHelper.checkTextIfNullReturnEmpty(
                selectedPeople.workEmail));
    _phoneController = _phoneController ??
        TextEditingController(
            text: TextHelper.checkTextIfNullReturnEmpty(selectedPeople.phone));
    _workPhoneController = _workPhoneController ??
        TextEditingController(
            text: TextHelper.checkTextIfNullReturnEmpty(
                selectedPeople.workPhone));

    hasWorkEmail = selectedPeople.workEmail?.isNotEmpty ?? false;
    hasWorkPhone = selectedPeople.workPhone?.isNotEmpty ?? false;
    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar('Edit Person', 'Contact', formKey, _scaffoldKey,
              confirmButtonCallback)
          .create(),
      body: peopleContainer(),
    );
  }

  confirmButtonCallback() {
    _autoValidate = true;
    if (formKey.currentState.validate()) {
      try {
        postForm();
      } catch (e) {
        ErrorService().handlePageLevelException(e, context);
      } finally {}
    } else {
      final SnackBar snackBar = new SnackBar(
        content: Text('Please fill in all information.'),
        duration: Duration(milliseconds: 3000),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void postForm() async {
    if (selectedCompany == null) {
      DialogService().show(context, "Please set Company");
      return;
    }
    try {
      selectedPeople.firstName = _firstNameController.text;
      selectedPeople.lastName = _lastNameController.text;
      selectedPeople.email = _emailController.text;
      selectedPeople.workEmail = _workEmailController.text;
      selectedPeople.phone = _phoneController.text;
      selectedPeople.workPhone = _workPhoneController.text;
      selectedPeople.companyId = selectedCompany.id;
      await contactListPageBloc.updatePeople(selectedPeople);
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Person Updated", context);
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    }
  }

  Widget peopleContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            VEmptyView(20),
            linkCompanyRow,
            peopleFirstNameRow,
            peopleLastNameRow,
            emailInputRow,
            VEmptyView(20),
            !hasWorkEmail && selectedCompany != null
                ? addWorkEmailButton
                : Container(),
            showWorkEmailInput || hasWorkEmail
                ? workEmailInputRow
                : Container(),
            phoneInputRow,
            VEmptyView(20),
            !hasWorkPhone && selectedCompany != null
                ? addWorkPhoneButton
                : Container(),
            showWorkPhoneInput || hasWorkPhone
                ? workPhoneInputRow
                : Container(),
            //SizedBox(height: 10),
            //linkDealRow
          ],
        ),
      ),
    );
  }

  // Widget get linkCompanyInkWell {
  //   return Expanded(
  //     child: InkWell(
  //       child: Text(
  //         'CHANGE COMPANY',
  //         style: TextStyle(color: Colors.blue[600]),
  //       ),
  //       onTap: () async {
  //         ModalBottomSheetListViewBuilder(allCompaniesFuture, context,
  //             (Company company) {
  //           setState(() {
  //             selectedCompany = company;
  //           });
  //         }).showModal();
  //       },
  //     ),
  //   );
  // }

  // Widget get linkDealRow {
  //   return Container(
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           margin: const EdgeInsets.only(right: 15),
  //           child: Icon(
  //             FontAwesomeIcons.handsHelping,
  //             size: 35,
  //             color: Colors.lightBlue,
  //           ),
  //         ),
  //         linkPipelineInkWell,
  //         selectedPiplineInfo,
  //         removeSelectedPipeline
  //       ],
  //     ),
  //   );
  // }

  Widget get removeSelectedPipeline {
    if (selectedPipeline != null) {
      return RemoveBinIconButton(() {
        setState(() {
          selectedPipeline = null;
        });
      });
    }
    return Container();
  }

  // Widget get selectedPiplineInfo {
  //   if (selectedPipeline != null) {
  //     return MultilineFixedWidthWidget([
  //       Text(selectedPipeline.dealName),
  //       Text(selectedPipeline.dealAmount.toString()),
  //       Text(TextHelper.checkTextIfNullReturnEmpty(
  //           selectedPipeline.people.company?.name))
  //     ]);
  //   }

  //   return Container();
  // }

  // Widget get linkPipelineInkWell {
  //   return Expanded(
  //     child: InkWell(
  //       child: Text(
  //         'ADD A DEAL',
  //         style: TextStyle(color: Colors.blue[600]),
  //       ),
  //       onTap: () async {
  //         ModalBottomSheetListViewBuilder(allPipelinesFuture, context,
  //             (Pipeline pipeline) {
  //           setState(() {
  //             selectedPipeline = pipeline;
  //           });
  //         }).showModal();
  //       },
  //     ),
  //   );
  // }

  Widget get phoneInputRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.phone,
              size: 35,
              color: Colors.green[600],
            ),
          ),
          Expanded(
            child: TextFormField(
              enabled: selectedCompany != null,
              inputFormatters: <TextInputFormatter>[
               // WhitelistingTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.phone,
              validator: locator<FormValidateService>().validateMobile,
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
          )
        ],
      ),
    );
  }

  Widget get workPhoneInputRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.phone,
              size: 35,
              color: Colors.green[600],
            ),
          ),
          Expanded(
            child: TextFormField(
              enabled: selectedCompany != null,
              inputFormatters: <TextInputFormatter>[
                //WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: _workPhoneController,
              validator: locator<FormValidateService>().validateMobile,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number(Work)'),
            ),
          )
        ],
      ),
    );
  }

  Widget get emailInputRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.local_post_office,
              size: 35,
              color: Colors.purple,
            ),
          ),
          Expanded(
            child: TextFormField(
              enabled: selectedCompany != null,

              //initialValue:
              //TextHelper.checkTextIfNullReturnEmpty(selectedPeople?.email),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: locator<FormValidateService>().validateEmail,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get workEmailInputRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.local_post_office,
              size: 35,
              color: Colors.purple,
            ),
          ),
          Expanded(
            child: TextFormField(
              enabled: selectedCompany != null,

              //initialValue: TextHelper.checkTextIfNullReturnEmpty(
              //selectedPeople?.workEmail),
              controller: _workEmailController,
              validator: locator<FormValidateService>().validateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email(Work)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get linkCompanyRow {
    return SetRelationWidget(
      SetRelationOption.company,
      (c) {
        setState(() {
          selectedCompany = c;
        });
      },
      () {
        setState(() {
          selectedCompany = null;
        });
      },
      selectedCompany: selectedCompany, noDataDisplay: NoContactInfoGuideWidget(2),
    );
  }
  // Widget get linkCompanyRow {
  //   return Container(
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           margin: const EdgeInsets.only(right: 15),
  //           child: Icon(
  //             Icons.home,
  //             size: 35,
  //             color: Colors.lightBlue,
  //           ),
  //         ),
  //         linkCompanyInkWell,
  //         selectedPeople?.company != null
  //             ? MultilineFixedWidthWidget([
  //                 TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //                     (selectedPeople?.company?.isDeleted ?? false
  //                             ? "(former)"
  //                             : "") +
  //                         selectedPeople?.company?.name),
  //                 TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //                     selectedPeople?.company?.location)
  //               ])
  //             : selectedCompany != null
  //                 ? MultilineFixedWidthWidget([
  //                     TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //                         selectedCompany?.name),
  //                     TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
  //                         selectedCompany?.location)
  //                   ])
  //                 : Container(),
  //         selectedCompany != null
  //             ? RemoveBinIconButton(() {
  //                 setState(() {
  //                   selectedCompany = null;
  //                 });
  //               })
  //             : Container()
  //       ],
  //     ),
  //   );
  // }

  Widget get addWorkEmailButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: 100, bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(showWorkEmailInput ? 'Hide' : 'Add Work Email',
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showWorkEmailInput = !showWorkEmailInput;
          });
        },
      ),
    );
  }

  Widget get addWorkPhoneButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: 100, bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(showWorkPhoneInput ? 'Hide' : 'Add Work Phone',
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showWorkPhoneInput = !showWorkPhoneInput;
          });
        },
      ),
    );
  }

  // Widget linkCompanyContent(List<Company> companys) {
  //   return ListView.builder(
  //       itemCount: companys?.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return ListTile(
  //           leading: Text(companys[index].name),
  //           trailing: Text(TextHelper.checkTextIfNullReturnEmpty(
  //               companys[index].location)),
  //           onTap: () {
  //             //select the company and close bottomsheet and show the name on form
  //             setState(() {
  //               selectedCompany = companys[index];
  //             });
  //             Navigator.pop(context);
  //           },
  //         );
  //       });
  // }

  Widget get peopleFirstNameRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.person_outline,
              size: 35,
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: TextFormField(
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              enabled: selectedCompany != null,
              //initialValue: TextHelper.checkTextIfNullReturnEmpty(selectedPeople?.firstName),
              controller: _firstNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter First Name.';
                }
                if (value.length > 20) {
                  return 'Name length exceed max allowed.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'First name'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get peopleLastNameRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(right: 50), child: Container()),
          Expanded(
            child: TextFormField(
              enabled: selectedCompany != null,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              //initialValue: selectedPeople?.lastName,
              controller: _lastNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Last Name.';
                }
                if (value.length > 20) {
                  return 'Name length exceed max allowed.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
          )
        ],
      ),
    );
  }
}
