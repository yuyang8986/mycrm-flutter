import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/GeneralWidgets/SideBar.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Pages/Login/LoginPage.dart';
import 'package:mycrm/Pages/PaymentPage/SubscriptionPurchasePage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Pages/Schedule/SchedulePage.dart';
import 'package:mycrm/Pages/Stage/StageListPage.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/TopRightNumberNotifier.dart';
import 'package:mycrm/Pages/contact/ContactMainPage.dart';
import 'package:mycrm/main.dart';
import 'dashboard/dashboardPage.dart';

class Page {
  PageIndex index;
  Widget page;
  String titleName;

  Page(this.index, this.page, this.titleName);
}

enum PageIndex {
  dashboard,
  contact,
  deal,
  stage,
  schedule,

  //news,
}

class MainPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  // final PageIndex pageIndex;
  static MainPageState mainPageState;
  @override
  MainPageState createState() {
    mainPageState = MainPageState();
    return mainPageState;
  }
}

enum MainState { login, dashboard }

class MainPageState extends State<MainPage> {
  static BuildContext rootContext;
  MainState mainState;
  // static bool showExpiry;
  //ScrollController scrollController = new ScrollController();
  //_MainPageState(this.currentPageIndex);
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  moveFromLoginToDashboard() {
    setState(() {
      mainState = MainState.dashboard;
    });
  }

  logOurAndMoveToLoginPage() {
    currentPageIndex = PageIndex.dashboard;
    if (pageController != null) {
      pageController.animateToPage(currentPageIndex.index,
          duration: Duration(milliseconds: 150), curve: Curves.ease);
    }

    HttpRequest.logout();
    if (mounted) {
      setState(() {
        mainState = MainState.login;
      });
    }
  }

  logOurAndMoveToLoginPageKeepToken() {
    currentPageIndex = PageIndex.dashboard;
    if (pageController != null) {
      pageController.animateToPage(currentPageIndex.index,
          duration: Duration(milliseconds: 150), curve: Curves.ease);
    }

    HttpRequest.logoutLeepToken();
    if (mounted) {
      setState(() {
        mainState = MainState.login;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    currentPageIndex = PageIndex.dashboard;
    offlineModeNotificationShowed = false;
    onlineModeNotificationShowed = false;
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await DialogService().show(context,
    //       "Warning: Dealo is in Alpha Test Version and under development, please report bugs to development@gis-global.co, thank you");
    // });
  }

  bool offlineModeNotificationShowed;
  bool onlineModeNotificationShowed;
  //bool popUpMenuEnabled = true;
  //List<PopupMenuItem> popUpMenuItems;
  //Page currentPage;
  PageIndex currentPageIndex;
  // final List<Page> pageList = [
  //   new Page(PageIndex.dashboard, DashboardPage(), 'Dashboard'),
  //   new Page(PageIndex.pipeline, PipelineListPage(), 'Deal'),
  //   new Page(PageIndex.stagesList, StageListPage(), 'Stage'),
  //   new Page(PageIndex.schedule, ScheduleListPage(), 'Schedule'),
  //   new Page(PageIndex.contact, ContactPage(), 'Contact'),
  //   new Page(PageIndex.newsFeed, Scaffold(), 'News Feed'),
  // ];
  DateTime currentBackPressTime;

  checkSubscription() async {
    if (currentPageIndex == PageIndex.contact ||
        currentPageIndex == PageIndex.deal) {
      HttpRequest.appUser = await HttpRequest.fetchAppUserLiveData();

      if (HttpRequest.appUser != null) {
        if (HttpRequest.appUser.isSubExpired) {
          sp.setString("subId", HttpRequest.appUser.subId ?? "");
          if (mainState != MainState.login) logOurAndMoveToLoginPageKeepToken();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) {
                  return SubscriptionPurchasePage();
                },
                settings: RouteSettings(arguments: sp.getString("subId"))),
          );
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
          //   return LoginPage();
          // }));
          // Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          //   return SubscriptionPurchasePage();
          // }));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkSubscription();
    rootContext = context;
    //填入设计稿中设备的屏幕尺寸

//默认 width : 1080px , height:1920px , allowFontScaling:false
//ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
// //假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334)
//     ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

// //设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 1920, allowFontScaling: true)
          ..init(context);
    //setPopUpMenu();
    return WillPopScope(
        child: Scaffold(key: widget.scaffoldKey, body: rootScaffold),
        onWillPop: onWillPop);
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "Press back again to exit Dealo", backgroundColor: Colors.black);
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget get rootScaffold {
    // if (MyApp.isOfflineMode && !offlineModeNotificationShowed) {
    //   final snackBar = SnackBar(
    //       content: Text("No Internet Detected, Offline Mode Switch On"));
    //   widget.scaffoldKey.currentState.showSnackBar(snackBar);
    //   offlineModeNotificationShowed = true;
    //   onlineModeNotificationShowed = false;
    // }
    // else if (!MyApp.isOfflineMode && !onlineModeNotificationShowed) {
    //   final snackBar =
    //       SnackBar(content: Text("Internet Detected, Off Mode Switch Off"));
    //   if (widget.scaffoldKey.currentState != null) {
    //     widget.scaffoldKey.currentState.showSnackBar(snackBar);
    //     onlineModeNotificationShowed = true;
    //     offlineModeNotificationShowed = false;
    //   }
    // }

    mainState =
        HttpRequest.appUser == null ? MainState.login : MainState.dashboard;
    //return HttpRequest.appUser == null ? LoginPage() : mainPageScaffold;
    return mainState == MainState.login ? LoginPage() : mainPageScaffold;
    // FutureBuilder(
    //   future: SharedPreferences.getInstance(),
    //   builder: (ctx, asyncdata) {
    //     if (!asyncdata.hasData) return LoadingIndicator();
    //     SharedPreferences pref = asyncdata.data;
    //     String str = pref.getString("tokenExpiration");
    //     String token = pref.getString("token");
    //     DateTime tokenExpiration = DateTime.parse(str);
    //     if (tokenExpiration.isAfter(DateTime.now()) &&
    //         (token?.isNotEmpty ?? false)) {
    //       var appUser = new AppUser();
    //       appUser.companyName = pref.getString("companyName");
    //       appUser.name = pref.getString("name");
    //       appUser.email = pref.getString("email");
    //       appUser.isAdmin = pref.getBool("isAdmin");
    //       appUser.isManager = pref.getBool("isManager");
    //       appUser.eventNumbers = pref.getInt("eventNumbers");
    //       HttpRequest.appUser = appUser;
    //       return mainPageScaffold;
    //     } else {
    //       return LoginPage();
    //     }
    //   },
    // );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  manualNavToPage(PageIndex pageIndex) {
    setState(() {
      currentPageIndex = pageIndex;
    });
    pageController.animateToPage(pageIndex.index,
        duration: Duration(milliseconds: 150), curve: Curves.ease);
  }

  Widget get mainPageScaffold {
    if (HttpRequest.appUser.isSubExpired) {
      // Navigator.pushNamed(context, Routes.subscriptionPage);
      //print("Sub Exp: ${HttpRequest.appUser.isSubExpired}");

      HttpRequest.appUser = null;
      return SubscriptionPurchasePage();
    }
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.grey,
        centerTitle: true,
        title: Text(capitalize(currentPageIndex
            .toString()
            .substring(currentPageIndex.toString().indexOf('.') + 1)
            .trim())),
        // actions: <Widget>[
        //   PopupMenuButton(
        //     itemBuilder: (BuildContext context) {
        //       return popUpMenuItems;
        //     },
        //     enabled: popUpMenuEnabled,
        //   )
      ),
      body:
          //currentPage.page,
          PageView(
        physics: new NeverScrollableScrollPhysics(),
        controller: pageController,
        // onPageChanged: (index) {
        //   setState(() {
        //     currentPageIndex = pageList[index].index;
        //     currentPage = pageList[index];
        //   });
        // },
        children: <Widget>[
          DashboardPage(),
          ContactPage(),
          PipelineListPage(),
          StageListPage(),
          ScheduleListPage(),
          //Container()
        ],
      ),
      drawer: SideBar(),
      bottomNavigationBar: _botNavBar,
    );
  }

  // setPopUpMenu() {
  //   popUpMenuItems = new List<PopupMenuItem>();
  //   switch (currentPage.page.runtimeType) {
  //     case DashboardPage:
  //       setState(() {
  //         popUpMenuEnabled = false;
  //       });
  //       break;
  //     case PipelineListPage:
  //       setState(() {
  //         popUpMenuEnabled = true;
  //       });
  //       popUpMenuItems.add(createNewPopUpMenuItem('Add New Deal', () {
  //         locator<NavigationService>().navigateTo(Routes.pipelineaddPage);
  //       }));
  //       break;
  //     case StageListPage:
  //       setState(() {
  //         popUpMenuEnabled = true;
  //       });
  //       popUpMenuItems.add(createNewPopUpMenuItem('Add New Stage', () {
  //         locator<NavigationService>().navigateTo(Routes.addStagePage);
  //       }));
  //       break;

  //     case ContactPage:
  //       setState(() {
  //         popUpMenuEnabled = true;
  //       });
  //       popUpMenuItems.add(createNewPopUpMenuItem('Add New Person', () {
  //         locator<NavigationService>().navigateTo(Routes.addPeoplePage);
  //       }));

  //       popUpMenuItems.add(createNewPopUpMenuItem('Add New Company', () {
  //         locator<NavigationService>().navigateTo(Routes.addCompanyPage);
  //       }));
  //       break;

  //     default:
  //   }
  // }

  // Widget createNewPopUpMenuItem(String text, Function onPressedAction) {
  //   return PopupMenuItem(
  //       child: Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       Expanded(
  //         child: RaisedButton(
  //           color: Theme.of(context).primaryColor,
  //           elevation: 5,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //           child:
  //               Text(text, style: TextStyle(color: AppColors.normalTextColor)),
  //           onPressed: () {
  //             Navigator.pop(context);
  //             onPressedAction();
  //           },
  //         ),
  //       )
  //     ],
  //   ));
  // }

//main bottom bar nav
  Widget get _botNavBar {
    void _onItemTapped(int value) {
      setState(() {
        //currentPage = pageList[value];
        currentPageIndex = PageIndex.values[value];
        if (currentPageIndex == PageIndex.schedule) {
          HttpRequest.appUser.eventNumbers = 0;
        }

        pageController.animateToPage(value,
            duration: Duration(milliseconds: 150), curve: Curves.ease);
      });
    }

    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 5),
      child: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey[300],
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
          currentIndex: currentPageIndex?.index ?? 0,
          items: _bottomNavBarItems),
    );
  }

  List<BottomNavigationBarItem> get _bottomNavBarItems => [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.insert_chart,
            ),
            title: Text(
              'Dashboard',
              style: TextStyles.bottomNavBarTextStyle,
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.contacts,
            ),
            title: Text(
              'Contact',
              style: TextStyles.bottomNavBarTextStyle,
            )),

        BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money,
            ),
            title: Text(
              'Deal',
              style: TextStyles.bottomNavBarTextStyle,
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.storage,
            ),
            title: Text(
              'Stage',
              style: TextStyles.bottomNavBarTextStyle,
            )),
        BottomNavigationBarItem(
            icon: HttpRequest.appUser?.eventNumbers != 0
                ? TopRightNumberNotifier(
                    HttpRequest.appUser?.eventNumbers,
                    Icon(
                      Icons.calendar_today,
                    ),
                  )
                : Icon(
                    Icons.calendar_today,
                  ),
            title: Text(
              'Schedule',
              style: TextStyles.bottomNavBarTextStyle,
            )),

        // BottomNavigationBarItem(
        //     icon: Icon(
        //       Icons.info,
        //     ),
        //     title: Text(
        //       'News feed',
        //       style: TextStyles.bottomNavBarTextStyle,
        //     )),
      ];
}

// class MainWrapper extends StatelessWidget {
//   final Widget widget;
//   MainWrapper(this.widget);
//   @override
//   Widget build(BuildContext context) {
//     return widget;
//   }
// }
