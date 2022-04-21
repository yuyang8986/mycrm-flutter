import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart' as prefix0;
import 'package:mycrm/Models/Dto/People/ScanPeopleDto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/FormValidateService/FormValidateService.dart';
import 'package:mycrm/Services/LoadingService/LoadingService.dart';
import 'package:mycrm/Services/service_locator.dart';
import 'package:mycrm/generalWidgets/Infrastructure/EnsureVisibleWhenFocused.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeedDialActions extends StatefulWidget {
  final bool visible;
  final Function onTapCallBackSecond;
  final Function onTapCallBackThird;
  final String heroTag;
  final ContactListPageBloc contactListPageBloc;
  SpeedDialActions(this.visible, this.onTapCallBackSecond,
      this.onTapCallBackThird, this.heroTag, this.contactListPageBloc);

  @override
  State<StatefulWidget> createState() {
    return SpeedDialActionsState();
  }
}

class SpeedDialActionsState extends State<SpeedDialActions> {
  bool autoValidate = false;
  FocusNode _focusNodeFirstName = new FocusNode();
  FocusNode _focusNodeLastName = new FocusNode();
  FocusNode _focusNodeCompanyName = new FocusNode();
  FocusNode _focusNodeCompanyLocation = new FocusNode();
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodePhone = new FocusNode();
  FocusNode _focusNodeLandline = new FocusNode();
  String mailAddress;
  String mobile;
  String landline;
  String companyName;
  String companyLocation;
  var firstName;
  var lastName;
  var concatenateMobile = StringBuffer();
  var concatenateLandline = StringBuffer();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      // both default to 16
      marginRight: ScreenUtil().setWidth(500),
      // marginBottom: ScreenUtil().setWidth(400),
      animatedIcon: AnimatedIcons.view_list,
      animatedIconTheme: IconThemeData(size: ScreenUtil().setSp(50)),
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
            child: Icon(Icons.people),            
            backgroundColor: prefix0.HttpRequest.appUser.subscriptionPlan ==
                    SubcriptionPlan.essential
                ? Colors.grey
                : Colors.amber,
            label: 'Scan Business Card',
            labelStyle: TextStyle(fontSize: ScreenUtil().setSp(32)),
            onTap: () async {
              if (prefix0.HttpRequest.appUser.subscriptionPlan ==
                  SubcriptionPlan.essential) {
                Fluttertoast.showToast(
                    msg:
                        "Please upgrade Subscription Plan to enable this feature");
                return;
              }
              print("scan business card started");
              PermissionStatus permission = await PermissionHandler()
                  .checkPermissionStatus(PermissionGroup.camera);
              if (permission != PermissionStatus.granted) {
                Map<PermissionGroup, PermissionStatus> permissions =
                    await PermissionHandler()
                        .requestPermissions([PermissionGroup.camera]);

                if (permissions[PermissionGroup.camera] ==
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
          label: 'Input New Contact',
          labelStyle: TextStyle(fontSize: ScreenUtil().setWidth(32)),
          onTap: widget.onTapCallBackSecond,
        ),
        SpeedDialChild(
          child: Icon(Icons.contacts),
          backgroundColor: prefix0.HttpRequest.appUser.subscriptionPlan ==
                  SubcriptionPlan.essential
              ? Colors.grey
              : Colors.green,
          label: 'Import Contacts',
          labelStyle: TextStyle(fontSize: ScreenUtil().setWidth(32)),
          onTap: widget.onTapCallBackThird,
        ),
      ],
    );
  }

  bool isNumber(String item) {
    return '0123456789'.split('').contains(item);
  }

  Future<Response> uploadToAI(File imageFile) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var tempCompressedImage = await compressAndGetFile(
        imageFile, tempPath + '/tempCard' + imageFile.hashCode.toString());
    var file = await MultipartFile.fromFile(tempCompressedImage.path,
        filename: "scannedcard");
    FormData formData = FormData.fromMap({"file": file});

    return await prefix0.HttpRequest.dio
        .post(HttpRequest.baseUrl + "businesscard", data: formData);
  }

  Future processImage(File picture) async {
    ScanPeopleDto scanPeopleDto;
    try {
      LoadingService.showLoading(context);
      if (HttpRequest.appUser.subscriptionPlan == SubcriptionPlan.premium ||
          HttpRequest.appUser.subscriptionPlan == SubcriptionPlan.advanced) {
        var response = await uploadToAI(picture);
        //TODO add timeout and switch to Firebase
        if (response.statusCode != 200) {
          DialogService()
              .show(context, "Can not process the request, please try again.");
          LoadingService.hideLoading(context);
          return;
        } else {
          if (response.data == null) {
            DialogService()
                .show(context, "Can not process the result, please try again");
          } else {
            scanPeopleDto = ScanPeopleDto.fromJson(response.data);
            //await widget.contactListPageBloc.scan(scanPeopleDto);
          }
        }
      } else if (HttpRequest.appUser.subscriptionPlan ==
          SubcriptionPlan.advanced) {
        scanPeopleDto = await processImageWithFirebaseML(picture);
      } else {
        DialogService()
            .show(context, "Sorry, your plan does support this feature.");
        return;
      }
      LoadingService.hideLoading(context);
      final formKey = GlobalKey<FormState>();
      final firstNameTextController =
          TextEditingController(text: scanPeopleDto.firstName);
      final lastNameTextController =
          TextEditingController(text: scanPeopleDto.lastName);
      final companyNameTextController =
          TextEditingController(text: scanPeopleDto.company);
      final companyLocationTextController =
          TextEditingController(text: scanPeopleDto.address);
      final emailTextController =
          TextEditingController(text: scanPeopleDto.email);
      final phoneTextController =
          TextEditingController(text: scanPeopleDto.phone);
      final workphoneTextController =
          TextEditingController(text: scanPeopleDto.workPhone);
      await showModalBottomSheet(
        isScrollControlled: true,
        builder: (ctx) {
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
                        "Scan Results" +
                            (prefix0.HttpRequest.appUser.subscriptionPlan ==
                                    SubcriptionPlan.premium
                                ? " (AI)"
                                : ""),
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
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodeFirstName,
                                child: TextFormField(
                                  controller: firstNameTextController,
                                  textCapitalization: TextCapitalization.words,
                                  // initialValue: scanPeopleDto.firstName ?? "",
                                  decoration: InputDecoration(
                                    labelText: "First Name",
                                  ),
                                  focusNode: _focusNodeFirstName,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "First Name can not be empty";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodeLastName,
                                child: TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  controller: lastNameTextController,
                                  // initialValue: scanPeopleDto.lastName ?? "",
                                  decoration: InputDecoration(
                                    labelText: "Last Name",
                                  ),
                                  focusNode: _focusNodeLastName,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Last Name can not be empty";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodeCompanyName,
                                child: TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  controller: companyNameTextController,
                                  // initialValue: scanPeopleDto.company ?? "",
                                  decoration: InputDecoration(
                                    labelText: "Company",
                                  ),
                                  focusNode: _focusNodeCompanyName,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Company Name can not be empty";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodeCompanyLocation,
                                child: TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  controller: companyLocationTextController,
                                  // initialValue: scanPeopleDto.address ?? "",
                                  decoration: InputDecoration(
                                    labelText: "Location",
                                  ),
                                  focusNode: _focusNodeCompanyLocation,
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodePhone,
                                child: TextFormField(
                                  controller: phoneTextController,
                                  keyboardType: TextInputType.phone,
                                  // initialValue:
                                  //     scanPeopleDto.phone?.toString() ?? "",
                                  focusNode: _focusNodePhone,
                                  decoration: InputDecoration(
                                    labelText: "Mobile Phone",
                                  ),
                                  validator: locator<FormValidateService>()
                                      .validateMobile,
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodeLandline,
                                child: TextFormField(
                                  focusNode: _focusNodeLandline,
                                  keyboardType: TextInputType.phone,
                                  controller: workphoneTextController,
                                  // initialValue:
                                  //     scanPeopleDto.workPhone?.toString() ?? "",
                                  decoration: InputDecoration(
                                    labelText: "Landline",
                                  ),
                                  validator: locator<FormValidateService>()
                                      .validateMobile,
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _focusNodeEmail,
                                child: TextFormField(
                                  focusNode: _focusNodeEmail,
                                  controller: emailTextController,
                                  // initialValue:
                                  //     scanPeopleDto.email?.toLowerCase() ?? "",
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                  ),
                                  validator: locator<FormValidateService>()
                                      .validateEmail,
                                ),
                              ),
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
                                      "Add Person",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        autoValidate = true;
                                      });
                                      if (formKey.currentState.validate()) {
                                        scanPeopleDto.firstName =
                                            firstNameTextController.text;
                                        scanPeopleDto.lastName =
                                            lastNameTextController.text;
                                        scanPeopleDto.company =
                                            companyNameTextController.text;
                                        scanPeopleDto.address =
                                            companyLocationTextController.text;
                                        scanPeopleDto.email =
                                            emailTextController.text;
                                        scanPeopleDto.phone =
                                            phoneTextController.text;
                                        scanPeopleDto.workPhone =
                                            workphoneTextController.text;

                                        await widget.contactListPageBloc
                                            .scan(scanPeopleDto);
                                        Fluttertoast.showToast(
                                            msg: "Person Added");
                                        Navigator.pop(context);
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
        context: context,
      );
      //LoadingService.hideLoading(context);
      // Navigator.pop(context);
    } catch (e) {
      LoadingService.hideLoading(context);
      DialogService().show(context, "Scan Failed");
    }
  }

  Future<ScanPeopleDto> processImageWithFirebaseML(File picture) async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(picture);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

    VisionText visionText = await textRecognizer.processImage(visionImage);
    String emailPattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regExEmail = RegExp(emailPattern);

    String mobilePattern = r"(\(+61\)|\+61|\(0[1-9]\)|0[1-9])?( ?-?[0-9]){6,9}";
    RegExp regExMobile = RegExp(mobilePattern);

    String landlinePattern =
        r"(\(+61\)|\+61|\(0[1-9]\)|0[1-9])?( ?-?[0-9]){6,9}";
    RegExp regExlandline = RegExp(landlinePattern);

    String namePattern = r"([A-Z][a-zA-Z]*)";
    RegExp regRxName = RegExp(namePattern);

    String companyPattern = r"^[A-Z]([a-zA-Z0-9]|[- @\.#&!])*$";
    RegExp regRxCompany = RegExp(companyPattern);

    String companyLocationPattern =
        r"^([A-Z]+(?:\s[A-Z]+)*),\s*([A-Z]{2,3}),\s*([0-9]{3,4})$";
    RegExp regRxCompanyLocation = RegExp(companyLocationPattern);

    String name;

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        if (regExEmail.hasMatch(line.text)) {
          mailAddress = line.text;
        }

        if (regExMobile.hasMatch(line.text)) {
          mobile = line.text;
        }

        if (regRxCompanyLocation.hasMatch(line.text)) {
          companyLocation = line.text;
        }

        if (regExlandline.hasMatch(line.text)) {
          if (line.text == mobile) continue;
          landline = line.text;
        }
        var lineTextLower = line.text.toLowerCase();
        if (lineTextLower.contains("pty") ||
            lineTextLower.contains("ltd") ||
            lineTextLower.contains("limited") ||
            lineTextLower.contains("company") ||
            lineTextLower.contains("inc")) {
          companyName = line.text;
        }
      }
    }

    if (mailAddress != null) {
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          if (regRxName.hasMatch(line.text)) {
            int positionOfAt = mailAddress.indexOf('@');
            var nameFromEmail =
                mailAddress.replaceRange(positionOfAt, mailAddress.length, "");
            var nameSplits;
            if (nameFromEmail.contains('.')) {
              nameSplits = nameFromEmail.split('.');

              name = nameSplits[0] + " " + nameSplits[1];
            } else if (line.text
                    .toLowerCase()
                    .contains(nameFromEmail.toLowerCase()) &&
                !line.text.contains('@')) {
              name = line.text;
            }
          }

          if (regRxCompany.hasMatch(line.text) && companyName == null) {
            int positionOfAt = mailAddress.indexOf('@');
            var contentAfterAt = mailAddress.replaceRange(0, positionOfAt, "");

            int dotPosition = contentAfterAt.indexOf('.');
            var potentialCompany = contentAfterAt
                .replaceRange(dotPosition, contentAfterAt.length, "")
                .toLowerCase()
                .replaceAll("@", "");
            if (line.text.toLowerCase().contains(potentialCompany)) {
              companyName = potentialCompany.replaceAll("@", "");
            }
          }
        }
      }
    }

    var names;
    if (name != null) {
      names = name.toLowerCase().split(" ");
    }

    if (names != null) {
      firstName = names[0];
      firstName = '${firstName[0].toUpperCase()}${firstName.substring(1)}';
      lastName = names[1];
      lastName = '${lastName[0].toUpperCase()}${lastName.substring(1)}';
    }

    if (mobile != null) {
      mobile?.replaceAll(' ', '');
      List<String> mobileLetters = new List<String>.from(mobile.split(''));
      mobileLetters.removeWhere((s) => !isNumber(s));
      mobileLetters.forEach((item) {
        concatenateMobile.write(item);
      });
    }

    if (landline != null) {
      landline?.replaceAll(' ', '');
      List<String> landlineLetters = new List<String>.from(landline.split(''));
      landlineLetters.removeWhere((s) => !isNumber(s));
      landlineLetters.forEach((item) {
        concatenateLandline.write(item);
      });
    }

    LoadingService.hideLoading(context);
    ScanPeopleDto scanPeopleDto;
    if (firstName == null && lastName == null && mailAddress == null) {
      DialogService()
          .show(context, "Can't recgonize the picture, please try again");
    } else {
      scanPeopleDto = new ScanPeopleDto(
          address: companyLocation,
          company: companyName,
          email: mailAddress,
          firstName: firstName,
          lastName: lastName,
          phone: mobile,
          workPhone: landlinePattern);
    }

    return scanPeopleDto;
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 75, minWidth: 768, minHeight: 1024
        //rotate: 180,
        );
    return result;
  }

  Future<void> _optionsDialogBox() {
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
                            Icon(Icons.camera_alt),
                            WEmptyView(20),
                            Text('Take a picture'),
                          ],
                        )),
                    onTap: () async {
                      DialogService().showConfirm(context,
                          "Make sure you have a good lightning for a clear scanned image, accuracy of the result is depending on image clarity",
                          () async {
                        var picture = await ImagePicker.pickImage(
                          source: ImageSource.camera,
                        );

                        Navigator.pop(context);
                        if (picture != null) await processImage(picture);
                      });
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
                            Icon(Icons.image),
                            WEmptyView(20),
                            Text('Select from gallery'),
                          ],
                        )),
                    onTap: () async {
                      var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      Navigator.pop(context);
                      if (image != null) processImage(image);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
