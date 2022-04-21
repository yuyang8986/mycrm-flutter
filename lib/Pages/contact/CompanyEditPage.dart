import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Services/ErrorService/ErrorService.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/SetLocationWidget.dart';

class CompanyEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CompanyEditState();
  }
}

class _CompanyEditState extends State<CompanyEditPage> {
  bool _autoValidate = false;
  var addressSearchTerm;
  bool hasSecondaryEmail;
  bool hasSecondaryPhone;
  bool showSecondaryEmailInput;
  bool showSecondaryPhoneInput;
  Company selectedCompany;
  Pipeline selectedPipeline;
  People selectedPeople;
  String location;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Future<RepoResponse> allPipelinesFuture;
  //Future<RepoResponse> allPeoplesFuture;
  final geocoding = new GoogleMapsGeocoding(apiKey: Constants.googleAPI);
  Future<GeocodingResponse> googleMapSearchFuture;

  ContactListPageBloc contactListPageBloc;
  bool isInit;

  final formKey = GlobalKey<FormState>();
  var _companyNameController;
  var _emailController;
  var _secondaryEmailController;
  var _phoneController;
  var __secondaryPhoneController;

  @override
  void initState() {
    hasSecondaryEmail = false;
    hasSecondaryPhone = false;
    showSecondaryEmailInput = false;
    showSecondaryPhoneInput = false;
    _autoValidate = false;
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      // allPipelinesFuture = PipelineRepo().getAllPipelines();
      //allPeoplesFuture = PeopleRepo().getAllPeoples();
      contactListPageBloc = BlocProvider.of<ContactListPageBloc>(context);
      selectedCompany = ModalRoute.of(context).settings.arguments;
      _companyNameController = TextEditingController(
          text: TextHelper.checkTextIfNullReturnEmpty(selectedCompany?.name));
      _emailController = TextEditingController(
          text: TextHelper.checkTextIfNullReturnEmpty(selectedCompany?.email));
      _secondaryEmailController = TextEditingController(
          text: TextHelper.checkTextIfNullReturnEmpty(
              selectedCompany?.secondaryEmail));
      _phoneController = TextEditingController(
          text: TextHelper.checkTextIfNullReturnEmpty(selectedCompany?.phone));
      __secondaryPhoneController = TextEditingController(
          text: TextHelper.checkTextIfNullReturnEmpty(
              selectedCompany?.secondaryPhone));
      location = selectedCompany.location;
      hasSecondaryEmail = selectedCompany.secondaryEmail?.isNotEmpty ?? false;
      hasSecondaryPhone = selectedCompany.secondaryPhone?.isNotEmpty ?? false;
      isInit = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar('Edit Company', 'Contact', formKey, _scaffoldKey,
              confirmButtonCallback)
          .create(),
      body: companyContainer(),
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
    try {
      selectedCompany.name = _companyNameController.text;
      selectedCompany.email = _emailController.text;
      selectedCompany.secondaryEmail = _secondaryEmailController.text;
      selectedCompany.phone = _phoneController.text;
      selectedCompany.secondaryPhone = __secondaryPhoneController.text;
      selectedCompany.location = location;

      await contactListPageBloc.updateCompany(selectedCompany);
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Company Updated", context);
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    }
  }

  Widget companyContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            VEmptyView(20),
            locationRow,
            VEmptyView(40),
            companyNameRow,
            VEmptyView(20),
            emailInputRow,
            VEmptyView(20),
            !hasSecondaryEmail ? addSecondaryEmailButton : Container(),
            showSecondaryEmailInput || hasSecondaryEmail
                ? secondaryEmailInputRow
                : Container(),
            phoneInputRow,
            VEmptyView(20),
            !hasSecondaryPhone ? addsecondaryPhoneButton : Container(),
            showSecondaryPhoneInput || hasSecondaryPhone
                ? secondaryPhoneInputRow
                : Container(),
            //SizedBox(height: 10),
            //linkPeopleRow,
            //linkDealRow
          ],
        ),
      ),
    );
  }

  Widget get locationRow {
    return SetLocationWidget(
        location,
        googleMapSearchFuture,
        setLocationFromResultCallBack,
        manualSetLocation,
        setGeoSearchFutureCallback,
        removeSelectedLocationCallBack);
  }

  setGeoSearchFutureCallback(addressController) {
    setState(() {
      googleMapSearchFuture = geocoding.searchByAddress(addressController.text,
          components: [new Component(Component.country, "au")]);
    });
  }

  manualSetLocation(addressController) {
    setState(() {
      location = addressController.text;
    });
  }

  setLocationFromResultCallBack(addressResponse, index) {
    setState(() {
      location = addressResponse.results[index].formattedAddress;
    });
  }

  removeSelectedLocationCallBack() {
    setState(() {
      location = null;
    });
  }

  // Widget get linkPeopleRow {
  //   return Container(
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           margin: const EdgeInsets.only(right: 15),
  //           child: Icon(
  //             Icons.person,
  //             size: 35,
  //             color: Colors.orange,
  //           ),
  //         ),
  //         Expanded(
  //           child: InkWell(
  //             child: Text(
  //               'ADD A PERSON',
  //               style: TextStyle(color: Colors.blue[600]),
  //             ),
  //             onTap: () async {
  //               ModalBottomSheetListViewBuilder(allPeoplesFuture, context,
  //                   (People people) {
  //                 setState(() {
  //                   selectedPeople = people;
  //                 });
  //               }).showModal();
  //             },
  //           ),
  //         ),
  //         selectedPeople != null
  //             ? MultilineFixedWidthWidget([
  //                 Text(selectedPeople.name),
  //                 selectedPeople.phone?.isEmpty ?? true
  //                     ? Container()
  //                     : Text(selectedPeople.phone)
  //               ])
  //             : Container(),
  //         selectedPeople != null
  //             ? RemoveBinIconButton(() {
  //                 setState(() {
  //                   selectedPeople = null;
  //                 });
  //               })
  //             : Container(),
  //       ],
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

  // Widget get removeSelectedPipeline {
  //   if (selectedPipeline != null) {
  //     return RemoveBinIconButton(() {
  //       setState(() {
  //         selectedPipeline = null;
  //       });
  //     });
  //   }
  //   return Container();
  // }

  // Widget get selectedPiplineInfo {
  //   if (selectedPipeline != null) {
  //     return MultilineFixedWidthWidget([
  //       Text(selectedPipeline.dealName),
  //       Text(selectedPipeline.dealAmount.toString()),
  //       Text(TextHelper.checkTextIfNullReturnEmpty(
  //           selectedPipeline.people?.company?.name))
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

  // Widget get companyLocationRow {
  //   return Container(
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           margin: const EdgeInsets.only(right: 15),
  //           child: Icon(
  //             Icons.map,
  //             size: 35,
  //             color: Colors.orange,
  //           ),
  //         ),
  //         Expanded(
  //           child: InkWell(
  //             child: Text(
  //               'Location',
  //               style: TextStyle(color: Colors.blue[600]),
  //             ),
  //             onTap: () async {
  //               final addressController = new TextEditingController();
  //               showModalBottomSheet(
  //                   builder: (BuildContext context) {
  //                     return DraggableScrollableSheet(
  //                       initialChildSize: 1,
  //                       minChildSize: 0.5,
  //                       maxChildSize: 1,
  //                       builder: (BuildContext context,
  //                           ScrollController scrollController) {
  //                         return Container(
  //                             child: Column(
  //                           children: <Widget>[
  //                             TextField(
  //                               decoration:
  //                                   InputDecoration(hintText: 'Search Address'),
  //                               controller: addressController,
  //                               autofocus: true,
  //                               onEditingComplete: () {
  //                                 if (addressController.text == '') return;
  //                                 FocusScope.of(context).unfocus();
  //                                 setState(() {
  //                                   addressSearchTerm = addressController.text;
  //                                   googleMapSearchFuture = geocoding
  //                                       .searchByAddress(addressSearchTerm,
  //                                           components: [
  //                                         new Component(Component.country, "au")
  //                                       ]);
  //                                 });
  //                               },
  //                               // onChanged: (value) {
  //                               //   if (value == '') return;
  //                               //   setState(() {
  //                               //     addressSearchTerm = value;
  //                               //   });
  //                               // },
  //                             ),
  //                             FutureBuilder(
  //                               future: googleMapSearchFuture,
  //                               builder: (BuildContext context,
  //                                   AsyncSnapshot snapshot) {
  //                                 if (snapshot.hasData) {
  //                                   if (snapshot.data != null) {
  //                                     GeocodingResponse addressResponse =
  //                                         snapshot.data as GeocodingResponse;
  //                                     return Expanded(
  //                                       child: ListView.builder(
  //                                           itemCount:
  //                                               addressResponse.results.length,
  //                                           itemBuilder: (BuildContext context,
  //                                               int index) {
  //                                             return addressResponse
  //                                                             .results.length ==
  //                                                         0 ||
  //                                                     (addressResponse.results
  //                                                                 .length ==
  //                                                             1 &&
  //                                                         addressResponse
  //                                                                 .results
  //                                                                 .single
  //                                                                 .formattedAddress ==
  //                                                             'Australia' &&
  //                                                         addressController
  //                                                                 .text.length >
  //                                                             0)
  //                                                 ? Center(
  //                                                     child: Column(
  //                                                     children: <Widget>[
  //                                                       Text(
  //                                                           'No matched address found.'),
  //                                                       RaisedButton(
  //                                                         child: Text(
  //                                                             'Add this address manually'),
  //                                                         onPressed: () {
  //                                                           setState(() {
  //                                                             location =
  //                                                                 addressController
  //                                                                     .text;
  //                                                           });
  //                                                           Navigator.pop(
  //                                                               context);
  //                                                         },
  //                                                       )
  //                                                     ],
  //                                                   ))
  //                                                 : ListTile(
  //                                                     onTap: () {
  //                                                       setState(() {
  //                                                         location = addressResponse
  //                                                             .results[index]
  //                                                             .formattedAddress;
  //                                                       });
  //                                                       Navigator.pop(context);
  //                                                     },
  //                                                     leading: Text(TextHelper
  //                                                         .checkTextIfNullReturnEmpty(
  //                                                             addressResponse
  //                                                                 .results[
  //                                                                     index]
  //                                                                 .formattedAddress)));
  //                                           }),
  //                                     );
  //                                   }
  //                                   return Container();
  //                                 } else {
  //                                   return Container();
  //                                 }
  //                               },
  //                             )
  //                           ],
  //                         ));
  //                       },
  //                     );
  //                   },
  //                   context: context);
  //             },
  //           ),
  //         ),
  //       ],
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
              size: ScreenUtil().setWidth(90),
              color: Colors.green[600],
            ),
          ),
          Expanded(
            child: TextFormField(
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

  Widget get secondaryPhoneInputRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.phone,
              size: ScreenUtil().setWidth(90),
              color: Colors.green[600],
            ),
          ),
          Expanded(
            child: TextFormField(
              inputFormatters: <TextInputFormatter>[
                //WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: __secondaryPhoneController,
              validator: locator<FormValidateService>().validateMobile,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number(Secondary)'),
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
              size: ScreenUtil().setWidth(90),
              color: Colors.purple,
            ),
          ),
          Expanded(
            child: TextFormField(
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

  Widget get secondaryEmailInputRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.local_post_office,
              size: ScreenUtil().setWidth(90),
              color: Colors.purple,
            ),
          ),
          Expanded(
            child: TextFormField(
              //initialValue: TextHelper.checkTextIfNullReturnEmpty(
              //selectedPeople?.workEmail),
              controller: _secondaryEmailController,
              validator: locator<FormValidateService>().validateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email(Secondary)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get addSecondaryEmailButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: ScreenUtil().setWidth(100), bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(showSecondaryEmailInput ? 'Hide' : 'Add Secondary Email',
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showSecondaryEmailInput = !showSecondaryEmailInput;
          });
        },
      ),
    );
  }

  Widget get addsecondaryPhoneButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: ScreenUtil().setWidth(100), bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(showSecondaryPhoneInput ? 'Hide' : 'Add Secondary Phone',
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showSecondaryPhoneInput = !showSecondaryPhoneInput;
          });
        },
      ),
    );
  }

  Widget get companyNameRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.home,
              size: ScreenUtil().setWidth(90),
              color: Colors.blue,
            ),
          ),
          Expanded(
            child: TextFormField(
              maxLength: 40,
              maxLengthEnforced: true,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              controller: _companyNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Company Name.';
                }
                // if (value.length > 20) {
                //   return 'Name length exceed max allowed.';
                // }
                return null;
              },
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
          )
        ],
      ),
    );
  }
}
