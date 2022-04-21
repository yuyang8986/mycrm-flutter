import 'package:flutter/material.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Contact/ContactListPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Pages/Contact/Bars/EmployeeBar.dart';
import 'package:mycrm/Pages/Contact/PeopleAddPage.dart';
import 'package:mycrm/Pages/contact/CompanyAddPage.dart';
import 'package:mycrm/Styles/GeneralIcons.dart';
import './Bars/PeopleBar.dart';
import './Bars/CompanyBar.dart';

class ContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactPageState();
  }
}

class ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  String pageController = '';
  TabController _tabController;
  final ContactListPageBloc contactListPageBloc = ContactListPageBloc();
  bool isInit;
  int tabNum;
  @override
  void initState() {
    isInit = true;
    print("init contact page");
    tabNum = HttpRequest.appUser.isAdmin ? 3 : 2;
    _tabController = new TabController(vsync: this, length: tabNum);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;
    }
    return DefaultTabController(
      length: tabNum,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: AppBar(
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Material(
                color: Colors.black45,
                child: TabBar(
                  controller: _tabController,
                  //onTap: (int){print('tabBar tapped');},
                  indicatorWeight: 2,
                  labelColor: Colors.white,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: "QuickSand"),
                  indicatorColor: Colors.white,
                  tabs: HttpRequest.appUser.isAdmin
                      ? <Widget>[
                          Tab(
                            text: 'Company',
                          ),
                          Tab(
                            text: 'Person',
                          ),
                          Tab(
                            text: 'Employee',
                          )
                        ]
                      : <Widget>[
                          Tab(
                            text: 'Company',
                          ),
                          Tab(
                            text: 'Person',
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
        //floatingActionButton: addNewLineBtn(),
        body: TabBarView(
          controller: _tabController,
          children: HttpRequest.appUser.isAdmin
              ? <Widget>[
                  CompanyTabBarPage(contactListPageBloc),
                  PeopleTabBarPage(contactListPageBloc),
                  EmployeeTabBarPage(contactListPageBloc)
                ]
              : <Widget>[
                  CompanyTabBarPage(contactListPageBloc),
                  PeopleTabBarPage(contactListPageBloc),
                ],
        ),
      ),
    );
  }

  // ///////////////////////////// general widgets and functions
  // Widget addNewLineBtn() {
  //   return Container(
  //     decoration:
  //         BoxDecoration(shape: BoxShape.circle, color: Colors.blue[600]),
  //     child: IconButton(
  //       icon: GeneralIcons.addIconWhite,
  //       onPressed: addNewContact,
  //     ),
  //   );
  // }

  void addNewContact() {
    pageController = _tabController?.index == 0 ? 'CompanyPage' : 'PeoplePage';
    print(pageController);

    if (pageController == 'PeoplePage') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return BlocProvider<ContactListPageBloc>(
          bloc: contactListPageBloc,
          child: AddPeoplePage(),
        );
      }));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return BlocProvider<ContactListPageBloc>(
          bloc: contactListPageBloc,
          child: AddCompanyPage(),
        );
      }));
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  // @override
  // bool get wantKeepAlive => false;
}
