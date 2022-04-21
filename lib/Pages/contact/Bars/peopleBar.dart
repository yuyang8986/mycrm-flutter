import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Dto/People/AddPeopleDto.dart';
import 'package:mycrm/Models/Dto/People/ImportPeopleDto.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Models/Views/ContactFromPhoneSelectModel.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/contact/PeopleAddPage.dart';
import 'package:mycrm/Pages/contact/PeopleEditPage.dart';
import 'package:mycrm/Services/LoadingService/LoadingService.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/SpeedDial.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';
import 'package:mycrm/services/UrlSchemeService/UrlSchemeService.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Models/Constants/Constants.dart';
import '../../../Infrastructure/TextHelper.dart';

class PeopleTabBarPage extends StatefulWidget {
  final ContactListPageBloc contactListPageBloc;

  PeopleTabBarPage(this.contactListPageBloc);
  @override
  State<StatefulWidget> createState() {
    return PeopleTabBarPageState();
  }
}

class PeopleTabBarPageState extends State<PeopleTabBarPage> {
  ContactListPageBloc contactListPageBloc;
  bool isInit;

  List<ContactFromPhoneSelectModel> contactSelectModels;
  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      contactListPageBloc = widget.contactListPageBloc;
      contactListPageBloc.getAllPeoples();
      isInit = false;
    }

    return Scaffold(
      floatingActionButton: _addPeopleButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        child: CustomStreamBuilder(
          retryCallback: contactListPageBloc.getAllPeoples,
          stream: contactListPageBloc.allPeoplesStream,
          //allPeopleFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // if (snapshot.connectionState == ConnectionState.active &&
            //     snapshot.data == null) {
            //   return ErrorPage(() {
            //     contactListPageBloc.getAllPeoples();
            //   });
            // }
            // if (snapshot.hasError)
            //   return ErrorPage(() {
            //     contactListPageBloc.getAllPeoples();
            //   });
            // if (!snapshot.hasData) return LoadingIndicator();

            var peopleList = snapshot.data as List<People>;
            return peopleRowContent(peopleList);
          },
        ),
      ),
    );
  }

  Widget get _addPeopleButton {
    return SpeedDialActions(true, navToAddPerson, importPhoneContacts,
        "AddPeople", contactListPageBloc);
    // return AppFloatingActionButton(() {
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (BuildContext context) {
    //     return BlocProvider<ContactListPageBloc>(
    //       bloc: contactListPageBloc,
    //       child: AddPeoplePage(),
    //     );
    //   }));
    // }, "AddPeople");
  }

  navToAddPerson() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return BlocProvider<ContactListPageBloc>(
        bloc: contactListPageBloc,
        child: AddPeoplePage(),
      );
    }));
  }

  importPhoneContacts() async {
    if (HttpRequest.appUser.subscriptionPlan == SubcriptionPlan.essential) {
      Fluttertoast.showToast(
          msg: "Please upgrade Subscription Plan to enable this feature");
      return;
    }
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);

      if (permissions[PermissionGroup.contacts] == PermissionStatus.granted) {
        await startImport();
      }
    } else {
      await startImport();
    }
  }

  startImport() async {
    LoadingService.showLoading(context);
    Iterable<Contact> contacts = await ContactsService.getContacts();
    List<Contact> contactList = contacts.toList();
    contactSelectModels = contactSelectModels ??
        contactList.map((c) {
          return new ContactFromPhoneSelectModel(
              emails: c.emails,
              phones: c.phones,
              company: c.company,
              familyName: c.familyName,
              isChecked: false,
              givenName: c.givenName);
        }).toList();
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (BuildContext context) {
    //   return BlocProvider<ContactListPageBloc>(
    //     bloc: contactListPageBloc,
    //     child: ImportContactsPage(),
    //   );
    // }));
    LoadingService.hideLoading(context);

    await showModalBottomSheet(
        // backgroundColor: Colors.grey,
        isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setModalState) {
              return Container(
                constraints:
                    BoxConstraints(maxHeight: ScreenUtil().setHeight(1500)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Center(
                              child: Text("Select Person to Import",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            child: contactSelectModels.length == 0
                                ? NoDataWidget(
                                    "No Contacts Information Found in your phone")
                                : ListView.builder(
                                    shrinkWrap: false,
                                    itemCount: contactSelectModels?.length,
                                    itemBuilder: (ctx, index) {
                                      var contact = contactSelectModels[index];
                                      return CheckboxListTile(
                                        onChanged: (v) {
                                          setModalState(() {
                                            contact.isChecked = v;
                                          });
                                          print(contact.isChecked);
                                        },
                                        title: Text(
                                          "${contact?.givenName ?? ""} ${contact?.familyName ?? ""}",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(45)),
                                        ),
                                        isThreeLine: true,
                                        subtitle: Text(
                                          "Company: ${contact?.company ?? ""}",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(45)),
                                        ),
                                        value: contact.isChecked,
                                      );
                                    },
                                  ),
                          )
                        ],
                      ),
                    ),
                    contactSelectModels.length == 0
                        ? RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Back",
                                style: TextStyle(color: Colors.white)),
                          )
                        : Container(
                            alignment: Alignment.bottomCenter,
                            child: RaisedButton(
                              onPressed: () async {
                                var importingContacts = contactSelectModels
                                    .where((s) => s.isChecked)
                                    .toList();
                                if (importingContacts.length == 0) {
                                  DialogService()
                                      .show(context, "No Contact is selected");
                                  return;
                                }
                                List<AddPeopleDto> peopleList =
                                    importingContacts.map((contactImporting) {
                                  return new AddPeopleDto(
                                      firstName: contactImporting.givenName,
                                      lastName: contactImporting.familyName,
                                      phone: contactImporting.phones.length > 0
                                          ? contactImporting.phones.first.value
                                          : null,
                                      email: contactImporting.emails.length > 0
                                          ? contactImporting.emails.first.value
                                          : null,
                                      companyName: contactImporting.company);
                                }).toList();

                                var request = new ImportPeopleDto(peopleList);

                                //TODO add range

                                await contactListPageBloc.addRange(request);
                                Fluttertoast.showToast(
                                    msg: "Imported Contacts");
                                Navigator.pop(context);
                              },
                              child: contactSelectModels.length == 0
                                  ? Container()
                                  : Text("Import",
                                      style: TextStyle(color: Colors.white)),
                            ),
                          )
                  ],
                ),
              );
            },
          );
        });
  }

  Widget peopleRowContent(List<People> peopleList) {
    return RefreshIndicator(
      child: peopleList.length == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.contacts,
                  color: Theme.of(context).primaryColor,
                  size: ScreenUtil().setHeight(150),
                ),
                VEmptyView(100),
                NoDataWidget(
                    "No Contact Person, you can import contact, scan a business card, or input manually"),
                // VEmptyView(200),
                // Icon(
                //   Icons.arrow_downward,
                //   size: ScreenUtil().setHeight(200),
                // )
                // RaisedButton(
                //   onPressed: () async {
                //     PermissionStatus permission = await PermissionHandler()
                //         .checkPermissionStatus(PermissionGroup.contacts);
                //     if (permission != PermissionStatus.granted) {
                //       Map<PermissionGroup, PermissionStatus> permissions =
                //           await PermissionHandler()
                //               .requestPermissions([PermissionGroup.contacts]);

                //       if (permissions[PermissionGroup.contacts] ==
                //           PermissionStatus.granted) {
                //         await importPhoneContacts();
                //       }
                //     } else {
                //       await importPhoneContacts();
                //     }
                //   },
                //   child: Text("Import Contacts",
                //       style: TextStyle(color: Colors.white)),
                // )
              ],
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: 90),
              itemCount: peopleList?.length,
              itemBuilder: (BuildContext context, int index) {
                return peopleRow(peopleList[index]);
              },
            ),
      onRefresh: () async {
        HttpRequest.forceRefresh = true;
        await contactListPageBloc.getAllPeoples();
      },
    );
  }

  Widget peopleRow(People people) {
    return Card(
        child: Slidable(
      actionExtentRatio: 0.16,
      child: Material(
          color: Colors.transparent,
          child: Container(
              // elevation: 5,
              child: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(210)),
            child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.peopleDetailPage,
                      arguments: people);
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Text(
                      TextHelper.checkTextIfNullReturnEmpty(
                          '${people.firstName.isEmpty?"": people.firstName.toUpperCase().substring(0, 1)}'),
                      style: TextStyle(
                          color: AppColors.normalTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(people.name +
                      (HttpRequest.appUser.isManager
                          ? " (${people.applicationUser?.name})"
                          : ""), style: TextStyle(fontSize: ScreenUtil().setSp(45)),),
                  subtitle: Text('Company: ' +
                      TextHelper.checkTextIfNullReturnEmpty(
                          (people.company?.isDeleted ?? false
                              ? "(former: " +
                                  TextHelper.checkTextIfNullReturnEmpty(
                                      people.company?.name) +
                                  ')'
                              : TextHelper.checkTextIfNullReturnEmpty(
                                  people.company?.name))), style: TextStyle(fontSize: ScreenUtil().setSp(40)),),
                  //subtitle: Text('contact(Test)'),
                )),
          ))),
      actionPane: SlidableDrawerActionPane(),
      actions: <Widget>[
        IconSlideAction(
          //caption: '',
          color: Colors.green,
          icon: Icons.phone,
          onTap: () async {
            if (people.phone?.isEmpty ?? true) {
              DialogService().show(context, 'No phone number avaliable');
            } else {
              UrlSchemeService().makePhoneCall(people.phone);
            }
          },
        ),
        IconSlideAction(
          //caption: '',
          color: Colors.purple,
          icon: Icons.message,
          onTap: () async {
            if (people.phone?.isEmpty ?? true) {
              DialogService().show(context, 'No phone number avaliable');
            } else {
              UrlSchemeService().sendSMS(people.phone);
            }
          },
        ),
        IconSlideAction(
          //caption: '',
          color: Colors.orange[400],
          icon: Icons.mail,
          onTap: () async {
            if (people.email?.isEmpty ?? true) {
              DialogService().show(context, 'No Email Address avaliable');
            } else {
              UrlSchemeService().sendEmail(people.email);
            }
          },
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          //caption: '',
          color: Colors.blue[700],
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return BlocProvider<ContactListPageBloc>(
                    bloc: contactListPageBloc,
                    child: EditPeoplePage(),
                  );
                },
                settings: RouteSettings(arguments: people)));
          },
        ),
        IconSlideAction(
          //caption: '',
          color: Colors.red[600],
          icon: Icons.delete,

          onTap: () async {
            DialogService().showConfirm(
                context, "Are you to delete this person?", () async {
              await contactListPageBloc.deletePeople(people.id);
              Navigator.pop(context);
            });
          },
        ),
      ],
    ));
  }
}
