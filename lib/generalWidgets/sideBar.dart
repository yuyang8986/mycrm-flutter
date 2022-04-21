import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Pages/PaymentPage/AccountInfoPage.dart';
import 'package:mycrm/Pages/SettingsPage.dart';
import 'package:mycrm/Pages/Tutorial/TutorialPage.dart';
import 'package:mycrm/Pages/WebViewPage/WebViewPage.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/main.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 5,
      child: new Column(
        children: <Widget>[
          Container(
            height: ScreenUtil().setHeight(600),
            child: DrawerHeader(
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Colors.grey
                      ]),
                ),
                child: Stack(
                  children: <Widget>[
                    // Center(
                    //   child: Text(
                    //     HttpRequest.appUser.name.substring(0, 1),
                    //     style: TextStyle(color: Colors.white30, fontSize: ScreenUtil().setSp(60)),
                    //   ),
                    // ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          InkResponse(
                              onTap: () {},
                              child: Container(
                                width: ScreenUtil().setWidth(120),
                                height: ScreenUtil().setHeight(180),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: Text(
                                  HttpRequest.appUser.name.substring(0, 1),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(80),
                                      color: Colors.white),
                                )),
                              )),
                          Text(
                            HttpRequest.appUser.name,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(50),
                                color: AppColors.normalTextColor),
                          ),
                          Text(
                            HttpRequest.appUser.companyName,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(50),
                                color: AppColors.normalTextColor),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                // InkWell(
                //   child: ListTile(
                //     title: Text('Home',
                //         style: TextStyles.sideBarSectionTitleTextStyle),
                //     leading: Icon(Icons.home),
                //   ),
                //   onTap: () {
                //     // NavigationService().navigateTo(Routes.mainPage);
                //     MainPage.mainPageState.manualNavToPage(PageIndex.dashboard);
                //   },
                // ),
                InkWell(
                  child: ListTile(
                    title: Text('Logout',
                        style: TextStyles.sideBarSectionTitleTextStyle),
                    leading: Icon(
                      Icons.arrow_back,
                    ),
                  ),
                  onTap: () {
                    //HttpRequest.logout();
                    if (sp.containsKey("token")) {
                      sp.remove("token");
                    }
                    MainPage.mainPageState.logOurAndMoveToLoginPage();
                    //MainPage.mainPageState.dispose();
                    // final MainPage widget =
                    //     context.ancestorWidgetOfExactType(MainPage);
                    // final MainPageState state = widget?.mainPageState;
                    //state.moveToLoginPage();
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                // Divider(
                //   color: Colors.black,
                // ),
                InkWell(
                  child: ListTile(leading: Text('Modules')),
                  onTap: () {},
                ),
                // InkWell(
                //   child: ListTile(
                //     title: Text('Expense',
                //         style: TextStyles.sideBarSectionTitleTextStyle),
                //     leading: Icon(
                //       Icons.attach_money,
                //     ),
                //   ),
                //   onTap: () {},
                // ),
                // Divider(
                //   color: Colors.black,
                // ),
                // InkWell(
                //   child: ListTile(
                //     title: Text('Position',
                //         style: TextStyles.sideBarSectionTitleTextStyle),
                //     leading: Icon(
                //       Icons.map,
                //     ),
                //   ),
                //   onTap: () {},
                // ),
                // Divider(
                //   color: Colors.black,
                // ),
                // InkWell(
                //   child: ListTile(
                //     title: Text('Clear Cached Data',
                //         style: TextStyles.sideBarSectionTitleTextStyle),
                //     leading: Icon(
                //       Icons.cached,
                //     ),
                //   ),
                //   onTap: () async {
                //     var result =
                //         await prefix0.HttpRequest.dioCacheManager.clearAll();
                //     if (result)
                //       Fluttertoast.showToast(msg: "Cached Data Cleared");
                //   },
                // ),
                InkWell(
                    child: ListTile(
                      title: Text('Account',
                          style: TextStyles.sideBarSectionTitleTextStyle),
                      leading: Icon(
                        Icons.account_balance_wallet,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return AccountInfoPage();
                      }));
                    }),

                InkWell(
                    child: ListTile(
                      title: Text('Tutorial',
                          style: TextStyles.sideBarSectionTitleTextStyle),
                      leading: Icon(
                        Icons.dvr,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return TutorialPage();
                      }));
                    }),

                InkWell(
                  child: ListTile(
                    title: Text('Settings',
                        style: TextStyles.sideBarSectionTitleTextStyle),
                    leading: Icon(
                      Icons.settings,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return SettingsPage();
                    }));
                  },
                ),
                VEmptyView(150),
                InkWell(
                  child: Text("      Privacy Policy"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return WebViewPage(
                          "https://www.dealo.app/privacy-policy");
                    }));
                  },
                ),
                VEmptyView(50),
                Container(
                  child: Text("      App Version: " + packageInfo.version),
                )
                // Divider(
                //   color: Colors.black,
                // ),
                // InkWell(
                //   child: ListTile(
                //     title: Text(
                //         'Offline Mode: ' + (MyApp.isOfflineMode ? "On" : "Off"),
                //         style: TextStyles.sideBarSectionTitleTextStyle),
                //     leading: Icon(Icons.cloud_download),
                //   ),
                //   onTap: () {},
                // ),
                // Divider(
                //   color: Colors.black,
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
