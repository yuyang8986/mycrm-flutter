import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/GeneralWidgets/MultilineTextFixedWidthWidget.dart';
import 'package:mycrm/GeneralWidgets/RemoveBinIconButton.dart';
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

import 'CompanyAddPage.dart';

class AddPeoplePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPeopleState();
  }
}

class _AddPeopleState extends State<AddPeoplePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _workEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workPhoneController = TextEditingController();
  ContactListPageBloc contactListPageBloc;
  bool isInit;

  // Future<List<Company>> allCompaniesFuture =
  //     CompanyRepo().getAllCompaniesForCurrentEmployee();
  //Future<List<Pipeline>> allPipelinesFuture = PipelineRepo().getAllPipelines();

  bool _autoValidate = false;
  bool showWorkEmailInput = false;
  bool showWorkPhoneInput = false;
  Company selectedCompany;
  Pipeline selectedPipeline;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  People newPeople = new People();

  final formKey = GlobalKey<FormState>();

  // @override
  // void dispose() {
  //   // _firstNameController.dispose();
  //   // _lastNameController.dispose();
  //   // _emailController.dispose();
  //   // _workEmailController.dispose();
  //   // _emailController.dispose();
  //   // _phoneController.dispose();
  //   // _workPhoneController.dispose();
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
      contactListPageBloc = BlocProvider.of<ContactListPageBloc>(context);
      isInit = false;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar('Add Person', 'Contact', formKey, _scaffoldKey,
              confirmButtonCallback)
          .create(),
      body: newPeopleContainer(),
    );
  }

  confirmButtonCallback() {
    _autoValidate = true;
    if (formKey.currentState.validate()) {
      try {
        postForm();
      } catch (e) {
        locator<ErrorService>().handlePageLevelException(e, context);
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
    try {
      if (selectedCompany == null) {
        DialogService().show(context, "Please set Company.");
        return;
      }
      newPeople.firstName = _firstNameController.text;
      newPeople.lastName = _lastNameController.text;
      newPeople.email = _emailController.text;
      newPeople.workEmail = _workEmailController.text;
      newPeople.phone = _phoneController.text;
      newPeople.workPhone = _workPhoneController.text;
      newPeople.companyId = selectedCompany?.id;

      print('begin http request');
      await contactListPageBloc.addPeople(newPeople);

      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Person Added", context);
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    }
  }

  Widget newPeopleContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            VEmptyView(20),
            linkCompanyRow,
            VEmptyView(20),
            selectedCompany == null ? addCompanyRow : Container(),
            peopleFirstNameRow,
            peopleLastNameRow,
            emailInputRow,
            VEmptyView(20),
            selectedCompany != null ? addWorkEmailButton : Container(),
            showWorkEmailInput ? workEmailInputRow : Container(),
            phoneInputRow,
            VEmptyView(20),
            selectedCompany != null ? addWorkPhoneButton : Container(),
            VEmptyView(20),
            showWorkPhoneInput ? workPhoneInputRow : Container(),
            //SizedBox(height: 10),
            //linkDealRow
          ],
        ),
      ),
    );
  }

  Widget get addWorkEmailButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: ScreenUtil().setWidth(100), bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(showWorkEmailInput ? 'Hide' : 'Add Secondary Email',
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
      // height: 30,
      margin: EdgeInsets.only(left: 50, right: ScreenUtil().setWidth(100), bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(showWorkPhoneInput ? 'Hide' : 'Add Secondary Number',
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showWorkPhoneInput = !showWorkPhoneInput;
          });
        },
      ),
    );
  }

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

  Widget get selectedPiplineInfo {
    if (selectedPipeline != null) {
      return MultilineFixedWidthWidget([
        Text(selectedPipeline.dealName),
        Text(selectedPipeline.dealAmount.toString()),
        Text(TextHelper.checkTextIfNullReturnEmpty(
            selectedPipeline.people?.company?.name))
      ]);
    }

    return Container();
  }

  // Widget get linkCompanyInkWell {
  //   return Expanded(
  //     child: InkWell(
  //       child: Text(
  //         'Set Company',
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

  Widget linkDealRowContent(List<Pipeline> pipelines) {
    return ListView.builder(
        itemCount: pipelines?.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            dense: true,
            leading: Text(pipelines[index].dealName),
            title: Text(pipelines[index].dealAmount.toString()),
            trailing: Text(TextHelper.checkTextIfNullReturnEmpty(
                pipelines[index].people?.company?.name)),
            onTap: () {
              //select the Pipeline and close bottomsheet and show the name on form
              setState(() {
                selectedPipeline = pipelines[index];
              });
              Navigator.pop(context);
            },
          );
        });
  }

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
                //WhitelistingTextInputFormatter.digitsOnly
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
      (Company company) {
        setState(() {
          selectedCompany = company;
        });
      },
      () {
        setState(() {
          selectedCompany = null;
        });
      },
      selectedCompany: selectedCompany,
      noDataDisplay: NoContactInfoGuideWidget(2),
    );
  }

  Widget get addCompanyRow {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("or",style: TextStyle(fontSize: ScreenUtil().setSp(50),fontWeight: FontWeight.bold),),
        VEmptyView(ScreenUtil().setHeight(40)),
        InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            return BlocProvider<ContactListPageBloc>(
              bloc: contactListPageBloc,
              child: AddCompanyPage(),
            );
          }),
        );
        setState(() {
          selectedCompany = result;
        });
      },
      child: Container(
          height: ScreenUtil().setHeight(160),
          margin: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(10),
          ),
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
          constraints: BoxConstraints(
            minHeight: ScreenUtil().setHeight(140),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryColorNormal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Add Company",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(50),
                ),
              ),
            ],
          )),
    ),
      ],
    );
    
  }

  // Widget get linkPipelineInkWell {
  //   return Expanded(
  //     child: InkWell(
  //       child: Text(
  //         'LINK A DEAL',
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

  Widget linkCompanyContent(List<Company> companys) {
    return ListView.builder(
        itemCount: companys?.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Text(companys[index].name),
            trailing: Text(
                TextHelper.checkTextIfNullReturnTBD(companys[index].location)),
            onTap: () {
              //select the company and close bottomsheet and show the name on form
              setState(() {
                selectedCompany = companys[index];
              });
              Navigator.pop(context);
            },
          );
        });
  }

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
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              enabled: selectedCompany != null,
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
