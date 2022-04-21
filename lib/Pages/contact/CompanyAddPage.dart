import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/GeneralWidgets/LoadingIndicator.dart';
import 'package:mycrm/Infrastructure/ShowSnackbarAndGoBackerHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/SetLocationWidget.dart';

class AddCompanyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddCompanyState();
  }
}

class _AddCompanyState extends State<AddCompanyPage> {
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _secondaryEmailController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();

  ContactListPageBloc contactListPageBloc;

  //Future<List<People>> allPeoplesFuture = PeopleRepo().getAllPeoples();
  //Future<List<Pipeline>> allPipelinesFuture = PipelineRepo().getAllPipelines();

  final geocoding = new GoogleMapsGeocoding(apiKey: Constants.googleAPI);
  Future<GeocodingResponse> googleMapSearchFuture;

  bool _autoValidate = false;
  var addressSearchTerm;
  bool showSecondaryEmailInput = false;
  bool showSecondaryPhoneInput = false;
  String location;
  People selectedPeople;
  Pipeline selectedPipeline;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Company newCompany = new Company();
  Company addedCompany = new Company();
  //bool isloading = false;
  bool isInit;

  final formKey = GlobalKey<FormState>();

  // @override
  // void dispose() {
  //   _companyNameController.dispose();
  //   _emailController.dispose();
  //   _phoneController.dispose();
  //   _secondaryEmailController.dispose();
  //   _secondaryPhoneController.dispose();

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
      //contactListPageBloc.getAllCompanies();
      isInit = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: GeneralAppBar('Add Company', 'Company', formKey, _scaffoldKey,
              confirmButtonCallback)
          .create(),
      body: newCompanyContainer(),
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
    newCompany.name = _companyNameController.text;
    newCompany.email = _emailController.text;
    newCompany.phone = _phoneController.text;
    newCompany.secondaryEmail = _secondaryEmailController.text;
    newCompany.secondaryPhone = _secondaryPhoneController.text;
    newCompany.location = location;
    try {
      print('begin http request');
      var result = await contactListPageBloc.addCompanyReturnNewCompany(newCompany);
      
      await ShowSnackBarAndGoBackHelper.go(
          _scaffoldKey, "Company Added", context, data: result);
    } catch (e) {
      //ErrorService().handlePageLevelException(e, context);
    } finally {}
  }

  Widget newCompanyContainer() {
    return Container(
      child: Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            VEmptyView(20),
            locationRow,
            companyNameRow,

            // Container(
            //   child: Text(TextHelper.checkTextIfNullReturnEmpty(location)),
            //   margin: EdgeInsets.only(left: 50),
            // ),
            //SizedBox(height: 10),
            emailInputRow,
            VEmptyView(20),
            addSecondaryEmailButton,
            VEmptyView(20),
            showSecondaryEmailInput ? secondEmailInputRow : Container(),
            VEmptyView(20),
            phoneInputRow,
               VEmptyView(20),
            addSecondaryPhoneButton,
            VEmptyView(20),
            showSecondaryPhoneInput ? secondaryPhoneInputRow : Container(),
            //SizedBox(height: 10),
            //linkPeopleRow,
            //SizedBox(height: 10),
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
  //         Expanded(
  //           child: InkWell(
  //             child: Text(
  //               'LINK A DEAL',
  //               style: TextStyle(color: Colors.blue[600]),
  //             ),
  //             onTap: () async {
  //               ModalBottomSheetListViewBuilder<Pipeline>(
  //                   allPipelinesFuture, context, (Pipeline pipeline) {
  //                 setState(() {
  //                   selectedPipeline = pipeline;
  //                 });
  //               }).showModal();
  //             },
  //           ),
  //         ),
  //         selectedPipeline != null
  //             ? MultilineFixedWidthWidget([
  //                 Text(selectedPipeline.dealName),
  //                 Text(selectedPipeline.dealAmount.toString()),
  //                 Text(TextHelper.checkTextIfNullReturnEmpty(
  //                     selectedPipeline.company?.name))
  //               ])
  //             : Container(),
  //         selectedPipeline != null
  //             ? RemoveBinIconButton(() {
  //                 setState(() {
  //                   selectedPipeline = null;
  //                 });
  //               })
  //             : Container(),
  //       ],
  //     ),
  //   );
  // }

  // Widget linkDealRowContent(List<Pipeline> pipelines) {
  //   return ListView.builder(
  //       itemCount: pipelines?.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return ListTile(
  //           dense: true,
  //           leading: Text(pipelines[index].dealName),
  //           title: Text(pipelines[index].dealAmount.toString()),
  //           trailing: Text(TextHelper.checkTextIfNullReturnEmpty(
  //               pipelines[index].people?.company?.name)),
  //           onTap: () {
  //             //select the Pipeline and close bottomsheet and show the name on form
  //             setState(() {
  //               selectedPipeline = pipelines[index];
  //             });
  //             Navigator.pop(context);
  //           },
  //         );
  //       });
  // }

  Widget get addSecondaryEmailButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: ScreenUtil().setWidth(100), bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(
            showSecondaryEmailInput ? 'Hide ' : 'Add ' + ('Secondary Email'),
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showSecondaryEmailInput = !showSecondaryEmailInput;
          });
        },
      ),
    );
  }

  Widget get addSecondaryPhoneButton {
    return Container(
      margin: EdgeInsets.only(left: 50, right: ScreenUtil().setWidth(100), bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(
            showSecondaryPhoneInput ? 'Hide ' : 'Add Secondary Number',
            style: TextStyle(color: AppColors.normalTextColor)),
        onPressed: () {
          setState(() {
            showSecondaryPhoneInput = !showSecondaryPhoneInput;
          });
        },
      ),
    );
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
              size: 35,
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
              controller: _secondaryPhoneController,
              decoration: InputDecoration(labelText: 'Secondary Phone Number'),
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

  Widget get secondEmailInputRow {
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
              keyboardType: TextInputType.emailAddress,
              controller: _secondaryEmailController,
              validator: locator<FormValidateService>().validateEmail,
              decoration: InputDecoration(labelText: 'Secondary Email'),
            ),
          ),
        ],
      ),
    );
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
  //               'LINK A PERSON',
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
  //                 selectedPeople.company.name?.isEmpty ?? true
  //                     ? Container()
  //                     : Text(selectedPeople.company.name)
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
  //                             Center(
  //                               child: TextField(
  //                                 decoration: InputDecoration(
  //                                     hintText: 'Search Address'),
  //                                 controller: addressController,
  //                                 autofocus: true,
  //                                 onEditingComplete: () {
  //                                   if (addressController.text == '') return;
  //                                   FocusScope.of(context).unfocus();
  //                                   setState(() {
  //                                     addressSearchTerm =
  //                                         addressController.text;
  //                                     googleMapSearchFuture = geocoding
  //                                         .searchByAddress(addressSearchTerm,
  //                                             components: [
  //                                           new Component(
  //                                               Component.country, "au")
  //                                         ]);
  //                                   });
  //                                 },
  //                                 // onChanged: (value) {
  //                                 //   if (value == '') return;
  //                                 //   setState(() {
  //                                 //     addressSearchTerm = value;
  //                                 //   });
  //                                 // },
  //                               ),
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

  Widget linkPeopleContent(List<People> peoples) {
    return ListView.builder(
        itemCount: peoples?.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Text(peoples[index].name),
            trailing: Text(
                TextHelper.checkTextIfNullReturnEmpty(peoples[index].phone)),
            onTap: () {
              //select the company and close bottomsheet and show the name on form
              setState(() {
                selectedPeople = peoples[index];
              });
              Navigator.pop(context);
            },
          );
        });
  }

  Widget get companyNameRow {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.home,
              size: 35,
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
                // if (value.length > 30) {
                //   return 'Name length exceed max allowed.';
                // }
                return null;
              },
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
          ),
        ],
      ),
    );
  }
}
