import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/contact/CompanyAddPage.dart';
import 'package:mycrm/Pages/contact/CompanyEditPage.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/ExpandableListWithNestedListView.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/AppFloatingActionButton.dart';
import 'package:mycrm/services/DialogService/DialogService.dart';
import 'package:mycrm/services/UrlSchemeService/UrlSchemeService.dart';
import '../../../Models/Constants/Constants.dart';

class CompanyTabBarPage extends StatefulWidget {
  final ContactListPageBloc contactListPageBloc;

  CompanyTabBarPage(this.contactListPageBloc);
  @override
  State<StatefulWidget> createState() {
    return CompanyTabBarPageState();
  }
}

class CompanyTabBarPageState extends State<CompanyTabBarPage> {
  ContactListPageBloc contactListPageBloc;
  bool isInit;

  @override
  void initState() {
    isInit = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      contactListPageBloc = widget.contactListPageBloc;
      contactListPageBloc.getAllCompanies();
      isInit = false;
    }
    return Scaffold(
      floatingActionButton: _addCompanyButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
          child: CustomStreamBuilder(
              retryCallback: contactListPageBloc.getAllCompanies,
              stream: contactListPageBloc.allCompaniesStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // if (snapshot.connectionState == ConnectionState.active &&
                //     snapshot.data == null) {
                //   return ErrorPage(() {
                //     contactListPageBloc.getAllCompanies();
                //   });
                // }
                // if (snapshot.hasError)
                //   return ErrorPage(() {
                //     contactListPageBloc.getAllCompanies();
                //   });
                // if (!snapshot.hasData) return LoadingIndicator();
                var companyList = snapshot.data as List<Company>;
                return companyListTileRow(companyList);
              })),
    );
  }

  Widget get _addCompanyButton {
    return AppFloatingActionButton(navToAddCompany, "AddCompany");
  }

  navToAddCompany() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return BlocProvider<ContactListPageBloc>(
        bloc: contactListPageBloc,
        child: AddCompanyPage(),
      );
    }));
  }

  Widget companyListTileRow(List<Company> companyList) {
    return RefreshIndicator(
      child: companyList.length == 0
          ? Column(
              children: <Widget>[
                VEmptyView(220),
                Icon(
                  Icons.contacts,
                  color: Theme.of(context).primaryColor,
                  size: ScreenUtil().setHeight(150),
                ),
                VEmptyView(100),
                NoDataWidget(
                    "No Companies Created, please click + to add companies.\n\n(Company is required when adding new person.)"),
                // VEmptyView(80),
                // Icon(
                //   Icons.arrow_downward,
                //   size: ScreenUtil().setHeight(200),
                // )
              ],
            )
          : ListView.builder(
            padding: EdgeInsets.only(bottom: 80),
              itemCount: companyList?.length,
              itemBuilder: (BuildContext context, int index) {
                return companyListTileItem(companyList[index]);
              },
            ),
      onRefresh: () async {
        HttpRequest.forceRefresh = true;
        print("forch refreshing");
        await contactListPageBloc.getAllCompanies();
      },
    );
  }

  Widget companyListTile(Company company) {
    return ExpandableListWithNestListView(
        companyListTileHeader(company), companyListTileExpanded(company));
  }

  Widget companyListTileExpanded(Company company) {
    return company.peoples?.length == 0 || company.peoples == null
        ? Center(
            child: Text('No person linked to this company'),
          )
        : Container(
            // height:
            //     ScreenUtil().setHeight(company.peoples.length * 230.0),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: company.peoples.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    elevation: 1,
                    color: Colors.grey[100],
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.peopleDetailPage,
                              arguments: company.peoples[index]);
                        },
                        child: Padding(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Name: " + company.peoples[index].name,
                                style: TextStyles.onlyBoldTextStyle,
                              ),
                              Text(
                                  "Phone: " +
                                      TextHelper.checkTextIfNullReturnEmpty(
                                          company.peoples[index].phone),
                                  style: TextStyles.onlyBoldTextStyle),
                              Text(
                                  "Email: " +
                                      TextHelper.checkTextIfNullReturnEmpty(
                                          company.peoples[index].email),
                                  style: TextStyles.onlyBoldTextStyle),
                            ],
                          ),
                          padding: EdgeInsets.all(5),
                        )));
              },
            ),
          );
  }

  Widget companyListTileHeader(Company company) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(210)),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, Routes.companyDetailPage,
              arguments: company);
        },
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue,
          child: Text(
            company.name.substring(0, 1),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(company.name +
            (HttpRequest.appUser.isManager
                ? " (${company.applicationUser?.name})"
                : ""), style: TextStyle(fontSize: ScreenUtil().setSp(45)),),
        subtitle: Text('Location: ' +
            TextHelper.checkTextIfNullReturnEmpty(company.location), style: TextStyle(fontSize: ScreenUtil().setSp(40)),),
      ),
    );
  }

  Widget companyListTileItem(Company company) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      color: Colors.grey[200],
      child: Card(
        elevation: 5,
        child: Slidable(
          actionExtentRatio: 0.16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () {}, child: companyListTile(company)),
          ),
          actionPane: SlidableDrawerActionPane(),
          actions: <Widget>[
            IconSlideAction(
              //caption: '',
              color: Colors.green,
              icon: Icons.phone,
              onTap: () async {
                if (company.phone?.isEmpty ?? true) {
                  DialogService().show(context, 'No Phone Number avaliable');
                } else {
                  UrlSchemeService().makePhoneCall(company.phone);
                }
              },
            ),
            IconSlideAction(
              //caption: '',
              color: Colors.purple,
              icon: Icons.email,
              onTap: () async {
                if (company.email?.isEmpty ?? true) {
                  DialogService().show(context, 'No Email Address avaliable');
                } else {
                  UrlSchemeService().sendEmail(company.email);
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
                        child: CompanyEditPage(),
                      );
                    },
                    settings: RouteSettings(arguments: company)));
              },
            ),
            IconSlideAction(
              //caption: '',
              color: Colors.red[600],
              icon: Icons.delete,
              onTap: () async {
                DialogService().showConfirm(
                    context, "Are you to delete this company?", () async {
                  await contactListPageBloc.deleteCompany(company.id);
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
