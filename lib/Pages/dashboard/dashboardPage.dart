import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Dashboard/DashboardPageBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Dashboard/DashboardModel.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:mycrm/Models/User/AppUser.dart';
import 'package:mycrm/Pages/Dashboard/MyBarChart.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/Target/TargetListPage.dart';
import 'package:mycrm/Services/CurrencyService/CurrencyService.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Styles/GeneralIcons.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import './myPieChart.dart';

final currentMonth = DateTime.now().month;
final currentYear = DateTime.now().year;

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardPageState();
  }
}

class DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  //List<charts.Series> seriesList;
  final DashboardPageBloc dashboardPageBloc = DashboardPageBloc();
  bool isInit;
  List<ApplicationUser> allEmployees;
  final all = ApplicationUser(name: "All");
  ApplicationUser employSelection;
  int currentMonthIndex;
  int currentYearIndex = currentYear;
  int currentMonthPositionIndex;
  OverallSummary currentMonthSummary;
  OverallSummary currentYearSummary;
  List<OverallSummary> monthSummaryForCurrentYear;
  var sumCountOfDeals;

  bool employeChanged;
  bool refreshing;
  bool showExpiry = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    isInit = true;
    print("init dashboard page");
    employeChanged = false;
    refreshing = false;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (showExpiry) return;
      if (HttpRequest.appUser == null) return;
      if (!HttpRequest.appUser.isFreeTrail) {
        if (HttpRequest.appUser.isSubAboutToExpire) {
          DialogService().show(context,
              "Your Subscription is expired, please check the payment for service continuity");
          showExpiry = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;
    }
    return Scaffold(
      body: _dashboardContentPage,
    );
  }

  String getMonthName(int index) {
    String month = "";
    switch (index) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    return month;
  }

  Widget _dealsOverallSummary(DashboardModel dashboardModel) {
    List<OverallSummary> monthSummary = dashboardModel.monthOverallSummary;
    List<OverallSummary> yearSummary = dashboardModel.yearOverallSummary;
    // List<OverallSummary> quarterSummary = dashboardModel.quarterOverallSummary;
    if (employeChanged || refreshing) {
      monthSummaryForCurrentYear =
          monthSummary.where((x) => x.year == currentYearIndex).toList();
      currentMonthSummary = monthSummaryForCurrentYear[currentMonth - 1];
      currentYearSummary =
          yearSummary.where((x) => x.year == currentYearIndex).first;
      currentMonthPositionIndex = 0;
      currentYearIndex = DateTime.now().year;
      currentMonthIndex = DateTime.now().month;
      employeChanged = false;
      refreshing = false;
    } else {
      monthSummaryForCurrentYear =
          monthSummary.where((x) => x.year == currentYearIndex).toList();
      currentMonthSummary =
          currentMonthSummary ?? monthSummaryForCurrentYear[currentMonth - 1];
      currentYearSummary = currentYearSummary ??
          yearSummary.where((x) => x.year == currentYearIndex).first;

      currentMonthPositionIndex = currentMonthPositionIndex ?? 0;
      currentMonthIndex = currentMonthIndex ?? DateTime.now().month;
      currentYearIndex = currentYearIndex ?? DateTime.now().year;
    }

    var pipelineAmountSum = (currentYearSummary.lostAmount +
        currentYearSummary.openLeadAmount +
        currentYearSummary.wonAmount);
    //      /
    // (dashboardModel.yearOverallSummary.lost +
    //     dashboardModel.yearOverallSummary.won +
    //     dashboardModel.yearOverallSummary.openLead);
    String currencyTrailing = "";
    if (pipelineAmountSum >= 1000 && pipelineAmountSum < 1000000) {
      currencyTrailing = "K";
    } else if (pipelineAmountSum > 100000) {
      currencyTrailing = "M";
    } else {
      currencyTrailing = "";
    }

    sumCountOfDeals = currentMonthSummary.lost +
        currentMonthSummary.won +
        currentMonthSummary.openLead;
    return Card(
        elevation: 5,
        child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text('Deal Summary', style: dashboardTitleTextStyle),
                ),
                VEmptyView(10),
                Container(
                  alignment: Alignment.centerLeft,
                  height: ScreenUtil().setHeight(550),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      leftPie(monthSummary, yearSummary, sumCountOfDeals),
                      WEmptyView(220),
                      statsOpenWonLost(currencyTrailing, currentYearSummary),
                      WEmptyView(50),
                      rightPie(sumCountOfDeals, currentYearSummary)
                    ],
                  ),
                )
              ],
            )));
  }

  Widget statsOpenWonLost(currencyTrailing, OverallSummary yearSummary) {
    return Container(
      height: ScreenUtil().setHeight(500),
      width: ScreenUtil().setWidth(470),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Row(
            children: <Widget>[
              Text(
                'Open ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                color: Colors.lightBlue,
                width: ScreenUtil().setHeight(20),
                height: ScreenUtil().setWidth(20),
              )
            ],
          )),
          Row(
            children: <Widget>[
              Text(
                  "${currentMonthSummary.openLead} : \$${CurrencyService.setAmountBasedOnTrailing(currencyTrailing, currentMonthSummary.openLeadAmount)}$currencyTrailing"),
              Text('  |  '),
              Text(
                  "\$${CurrencyService.setAmountBasedOnTrailing(currencyTrailing, yearSummary.openLeadAmount)}$currencyTrailing : ${yearSummary.openLead}")
            ],
          ),
          VEmptyView(40),
          Container(
              child: Row(
            children: <Widget>[
              Text(
                'Won ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                color: Colors.green,
                width: ScreenUtil().setHeight(20),
                height: ScreenUtil().setWidth(20),
              )
            ],
          )),
          Row(
            children: <Widget>[
              Text(
                  "${currentMonthSummary.won} : \$${CurrencyService.setAmountBasedOnTrailing(currencyTrailing, currentMonthSummary.wonAmount)}$currencyTrailing"),
              Text('  |  '),
              Text(
                  "\$${CurrencyService.setAmountBasedOnTrailing(currencyTrailing, yearSummary.wonAmount)}$currencyTrailing : ${yearSummary.won}")
            ],
          ),
          VEmptyView(40),
          Container(
              child: Row(
            children: <Widget>[
              Text(
                'Lost ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                color: Colors.red,
                width: ScreenUtil().setHeight(20),
                height: ScreenUtil().setWidth(20),
              )
            ],
          )),
          Row(
            children: <Widget>[
              Text(
                  "${currentMonthSummary.lost} : \$${CurrencyService.setAmountBasedOnTrailing(currencyTrailing, currentMonthSummary.lostAmount)}$currencyTrailing"),
              Text('  |  '),
              Text(
                  "\$${CurrencyService.setAmountBasedOnTrailing(currencyTrailing, yearSummary.lostAmount)}$currencyTrailing : ${yearSummary.lost}")
            ],
          ),
        ],
      ),
    );
  }

  Widget rightPie(sumCountOfDeals, OverallSummary yearSummary) {
    return Column(
      children: <Widget>[
        VEmptyView(65),
        Container(
          // margin: EdgeInsets.all(5),
          child: Text(yearSummary.year.toString(),
              style: TextStyle(fontSize: ScreenUtil().setSp(50))),
        ),
        VEmptyView(31),
        Container(
          height: ScreenUtil().setHeight(370),
          width: ScreenUtil().setWidth(555),
          child:
              (yearSummary.lost + yearSummary.won + yearSummary.openLead == 0)
                  ? NoDataWidget("No Data")
                  : MyPieChart(PassDonutData._createYearData(yearSummary)),
        ),
      ],
    );
  }

  Widget leftPie(monthSummary, yearSummary, sumCountOfDeals) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        HttpRequest.appUser.subscriptionPlan == SubcriptionPlan.essential
            ? Container()
            : leftPieMonthSelect(monthSummary, yearSummary),
        Container(
          height: ScreenUtil().setHeight(375),
          width: ScreenUtil().setWidth(555),
          child: sumCountOfDeals == 0
              ? NoDataWidget("No Data")
              : MyPieChart(PassDonutData._createMonthData(currentMonthSummary)),
        ),
      ],
    );
  }

  Widget leftPieMonthSelect(monthSummary, yearSummary) {
    return Container(
      // alignment: Alignment.topLeft,
      // width: ScreenUtil().setWidth(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          currentYearIndex <= currentYear - 2 && currentMonthIndex == 1
              ? Container()
              : currentMonthIndex == 1
                  ? Container(
                      padding: EdgeInsets.all(0),
                      width: ScreenUtil().setWidth(100),
                      child: IconButton(
                        iconSize: ScreenUtil().setWidth(100),
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            currentMonthIndex = 12;
                            currentYearIndex -= 1;
                            currentMonthPositionIndex = 11;
                            monthSummaryForCurrentYear = monthSummary
                                .where((x) => x.year == currentYearIndex)
                                .toList();
                            currentYearSummary = yearSummary
                                .where((x) => x.year == currentYearIndex)
                                .first;
                            currentMonthSummary = monthSummaryForCurrentYear[
                               currentMonthPositionIndex];
                          });
                        },
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(0),
                      width: ScreenUtil().setWidth(100),
                      child: IconButton(
                        iconSize: ScreenUtil().setWidth(100),
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            currentMonthIndex -= 1;
                            currentMonthPositionIndex -= 1;
                            currentMonthSummary = monthSummaryForCurrentYear[
                                currentMonth - 1 + currentMonthPositionIndex];
                          });
                        },
                      ),
                    ),
          Container(
            child: Text(
              getMonthName(currentMonthIndex) +
                  " " +
                  currentYearIndex.toString(),
              style: TextStyle(fontSize: ScreenUtil().setSp(50)),
            ),
          ),
          currentYearIndex >= currentYear && currentMonthIndex == 12
              ? Container()
              : currentMonthIndex == 12
                  ? Container(
                      padding: EdgeInsets.all(0),
                      width: ScreenUtil().setWidth(100),
                      child: IconButton(
                        iconSize: ScreenUtil().setWidth(100),
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(Icons.arrow_right),
                        onPressed: () {
                          setState(() {
                            currentYearIndex += 1;
                            currentMonthPositionIndex = 0;
                            currentMonthIndex = 1;
                            monthSummaryForCurrentYear = monthSummary
                                .where((x) => x.year == currentYearIndex)
                                .toList();
                            currentYearSummary = yearSummary
                                .where((x) => x.year == currentYearIndex)
                                .first;
                            currentMonthSummary = monthSummaryForCurrentYear[
                                currentMonth - 1 + currentMonthPositionIndex];
                          });
                        },
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(0),
                      width: ScreenUtil().setWidth(100),
                      child: IconButton(
                        iconSize: ScreenUtil().setWidth(100),
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(Icons.arrow_right),
                        onPressed: () {
                          setState(() {
                            currentMonthPositionIndex += 1;
                            currentMonthIndex += 1;
                            currentMonthSummary = monthSummaryForCurrentYear[
                                currentMonth - 1 + currentMonthPositionIndex];
                          });
                        },
                      ),
                    )
        ],
      ),
    );
  }

  Widget get _dashboardContentPage {
    return CustomStreamBuilder(
      stream: dashboardPageBloc.dashBoardDataStream,
      retryCallback: dashboardPageBloc.getDashboard,
      builder: (ctx, asyncdata) {
        DashboardModel dashboardModel = asyncdata.data as DashboardModel;
        return RefreshIndicator(
            onRefresh: () async {
              refreshing = true;
              if (employSelection?.id != null) {
                await dashboardPageBloc.getDashboardById(employSelection.id);
              } else if (employSelection?.name == "All") {
                await dashboardPageBloc.getDashboard();
              } else {
                await dashboardPageBloc
                    .getDashboardById(HttpRequest.appUser.sub);
              }
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: ScreenUtil().setHeight(500),
                  floating: false,
                  pinned: true,
                  primary: true,
                  title: Text("Hi, ${HttpRequest.appUser.firstName}"),
                  actions: HttpRequest.appUser.subscriptionPlan ==
                          SubcriptionPlan.essential
                      ? null
                      : <Widget>[
                          selectEmployee(),
                        ],
                  //snap: true,
                  // elevation: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      //centerTitle: true,
                      // title: Text(
                      //   "${HttpRequest.appUser.name}",
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.white,
                      //       fontSize: ScreenUtil().setSp(50)),
                      // ),
                      background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.grey[500],
                                  Theme.of(context).primaryColor,
                                ]),
                          ),
                          child: Material(
                              color: Colors.transparent,
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(45),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "QuickSand"),
                              child: Container(
                                margin:
                                    EdgeInsets.all(ScreenUtil().setWidth(60)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[                                   
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: ScreenUtil().setWidth(400),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(dashboardModel
                                                  .countSummary.dealCount
                                                  .toString()),
                                              Text("Total Open Deals"),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(400),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(dashboardModel
                                                  .countSummary.appointmentCount
                                                  .toString()),
                                              Text("Appointments"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    VEmptyView(ScreenUtil().setHeight(100)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: ScreenUtil().setWidth(400),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(dashboardModel
                                                  .countSummary.eventCount
                                                  .toString()),
                                              Text("Events"),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(400),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(dashboardModel
                                                  .countSummary.taskCount
                                                  .toString()),
                                              Text("Tasks"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )))),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    VEmptyView(20),
                    _dealsOverallSummary(dashboardModel),
                    HttpRequest.appUser.subscriptionPlan ==
                            SubcriptionPlan.essential
                        ? Container()
                        : targetCard(dashboardModel),
                    // //_dealAverageHigestSummary(),
                    HttpRequest.appUser.subscriptionPlan ==
                            SubcriptionPlan.essential
                        ? Container()
                        : performanceIndex(dashboardModel),
                    scheduleCard(dashboardModel)
                  ]),
                )
              ],
            ));
      },
    );
  }

  static getRandomColor() =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

  Widget selectEmployee() {
    return HttpRequest.appUser.isManager
        ? CustomStreamBuilder(
            retryCallback: dashboardPageBloc.getEmployees,
            stream: dashboardPageBloc.allEmployeesStream,
            builder: (ctx, snapshot) {
              allEmployees = snapshot.data as List<ApplicationUser>;
              if (!allEmployees.contains(all)) allEmployees.add(all);
              return Center(
                  child: Container(
                      height: ScreenUtil().setHeight(150),
                      child: Material(
                          color: Colors.transparent,
                          child: Theme(
                            data: ThemeData(
                                canvasColor: Theme.of(context).primaryColor),
                            child: DropdownButton<ApplicationUser>(
                              onChanged: (ApplicationUser e) async {
                                //setState(() {
                                employeChanged = true;
                                if (e.name == "All") {
                                  employSelection = all;
                                } else {
                                  employSelection = e;
                                }
                                //}
                                //);

                                if (e.name == "All") {
                                  await dashboardPageBloc.getDashboard();
                                } else {
                                  await dashboardPageBloc
                                      .getDashboardById(e.id);
                                }
                              },
                              hint: Text(
                                "Select Employee",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(50),
                                    fontFamily: "QuickSand"),
                              ),
                              value: employSelection,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(50)),
                              items: allEmployees.map((e) {
                                return DropdownMenuItem(
                                    child: Text(e.name), value: e);
                              }).toList(),
                            ),
                          ))));
            },
          )
        : Container();
  }

  Icon calculatePerformanceIcon(double index) {
    if (index > 1) {
      return GeneralIcons.performanceUp;
    } else if (index < 1 && index != 0) {
      return GeneralIcons.performanceDown;
    } else if (index == 0) {
      return GeneralIcons.performanceEqual;
    } else {
      return GeneralIcons.performanceEqual;
    }
  }

  Color calculatePerformanceColor(double index) {
    if (index > 1) {
      return Colors.green;
    } else if (index < 1 && index != 0) {
      return Colors.red;
    } else if (index == 0) {
      return Colors.grey;
    } else {
      return Colors.yellow;
    }
  }

  Widget performanceIndex(DashboardModel dashboardModel) {
    Performance performance = dashboardModel.performance;
    return Card(
      elevation: 5,
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child:
                  Text('Performance: \$ Won', style: dashboardTitleTextStyle),
            ),
            VEmptyView(40),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  calculatePerformanceColor(performance?.q1)),
                          child: calculatePerformanceIcon(performance?.q1)),
                      VEmptyView(10),
                      Text("Q1: ${performance.q1}")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: calculatePerformanceColor(performance.q2)),
                          child: calculatePerformanceIcon(performance.q2)),
                      VEmptyView(10),
                      Text("Q2: ${performance.q2}")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: calculatePerformanceColor(performance.q3)),
                          child: calculatePerformanceIcon(performance.q3)),
                      VEmptyView(10),
                      Text("Q3: ${performance.q3}")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: calculatePerformanceColor(performance.q4)),
                          child: calculatePerformanceIcon(performance.q4)),
                      VEmptyView(10),
                      Text("Q4: ${performance.q4}")
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget targetCard(DashboardModel dashboardModel) {
    var targetAchieved = dashboardModel.targetAchieved;
    return Card(
        elevation: 5,
        child: Container(
          margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(20), top: ScreenUtil().setWidth(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('\$: Target vs Achieved',
                      style: dashboardTitleTextStyle),
                  !HttpRequest.appUser.isManager ||
                          HttpRequest.appUser.subscriptionPlan ==
                              SubcriptionPlan.essential
                      ? Container()
                      : Container(
                          padding: EdgeInsets.all(0),
                          margin: EdgeInsets.only(left: 10),
                          height: ScreenUtil().setHeight(70),
                          width: ScreenUtil().setWidth(380),
                          child: HttpRequest.appUser?.isManager ?? false
                              ? RaisedButton(
                                  color: Theme.of(context).primaryColor,
                                  child: Text(
                                    "Set Target",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                  // icon: Icon(
                                  //   FontAwesomeIcons.weight,
                                  //   color: Colors.green,
                                  // ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return BlocProvider<DashboardPageBloc>(
                                        bloc: dashboardPageBloc,
                                        child: TargetListPage(),
                                      );
                                    }));
                                  },
                                )
                              : Container(),
                        )
                ],
              ),
              new Container(
                height: ScreenUtil().setHeight(600),
                child:
                    MyBarChart(PassBarData._createSampleData(targetAchieved)),
              )
            ],
          ),
        ));
  }

  Widget scheduleCard(DashboardModel dashboardModel) {
    List<ScheduleEvent> schdedules = dashboardModel.todaySchedule;
    var events = schdedules.where((s) {
      return s.eventType.toLowerCase() == "event";
    }).toList();
    var firstEvent = events.length == 0 ? null : events.first;
    var appointments = schdedules.where((s) {
      return s.eventType.toLowerCase() == "appointment";
    }).toList();
    var firstAppointment = appointments.length == 0 ? null : appointments.first;
    var tasks = schdedules.where((s) {
      return s.eventType.toLowerCase() == "task";
    }).toList();
    var firstTask = tasks.length == 0 ? null : tasks.first;
    return Material(

        // textStyle: TextStyles.whiteAndBoldText,
        child: Card(
      elevation: 5,
      child: Container(
          margin: EdgeInsets.all(7),
          child: Theme(
              data: ThemeData().copyWith(
                textTheme: TextTheme(body1: TextStyles.onlyBoldTextStyle),
                cardTheme: CardTheme(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    color: Colors.blueGrey[300]),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.all(2),
                    child: Text("Today's Schedule",
                        style: dashboardTitleTextStyle),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(500),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        Container(
                          // constraints: BoxConstraints(
                          //     minHeight: ScreenUtil().setHeight(300)),
                          width: ScreenUtil().setWidth(500),
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Appointments",
                                ),
                                // VEmptyView(10),
                                firstAppointment == null
                                    ? Container(
                                        child: Text(
                                          "N/A",
                                          style: TextStyle(
                                              fontFamily: "QuickSand"),
                                        ),
                                      )
                                    : Column(
                                        children: <Widget>[
                                          VEmptyView(10),
                                          Text(
                                            TextHelper.checkTextIfNullReturnTBD(
                                                firstAppointment
                                                    ?.appointment?.summary),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "QuickSand"),
                                          ),
                                          VEmptyView(10),
                                          Text(
                                            TextHelper.checkTextIfNullReturnTBD(
                                                    DateTimeHelper
                                                        .parseDateTimeToHHMMOnly(
                                                            firstAppointment
                                                                ?.eventDateTime)) +
                                                " - " +
                                                TextHelper.checkTextIfNullReturnTBD(
                                                    DateTimeHelper.parseDateTimeToHHMMOnly(
                                                        firstAppointment
                                                            ?.eventDateTime
                                                            ?.add(Duration(
                                                                minutes: firstAppointment
                                                                    ?.appointment
                                                                    ?.durationMinutes)))),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "QuickSand"),
                                          ),
                                          VEmptyView(10),
                                        ],
                                      ),
                                firstAppointment == null
                                    ? Container()
                                    : InkWell(
                                        child: Text(
                                          "See More",
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontFamily: "QuickSand",
                                          ),
                                        ),
                                        onTap: () {
                                          MainPage.mainPageState
                                              .manualNavToPage(
                                                  PageIndex.schedule);
                                        },
                                      )
                              ],
                            ),
                          )),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(500),
                          // constraints: BoxConstraints(
                          //     minHeight: ScreenUtil().setHeight(300)),
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Events",
                                  style: TextStyle(
                                      fontFamily: "QuickSand",
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                // VEmptyView(10),
                                firstEvent == null
                                    ? Container(
                                        child: Text(
                                          "N/A",
                                          style: TextStyle(
                                              fontFamily: "QuickSand",
                                              color: Colors.white),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            TextHelper.checkTextIfNullReturnTBD(
                                                firstEvent?.event?.summary),
                                            style: TextStyle(
                                                fontFamily: "QuickSand",
                                                color: Colors.white),
                                          ),
                                          VEmptyView(10),
                                          Text(
                                            TextHelper.checkTextIfNullReturnTBD(
                                                    DateTimeHelper
                                                        .parseDateTimeToHHMMOnly(
                                                            firstEvent
                                                                ?.eventDateTime)) +
                                                " - " +
                                                TextHelper.checkTextIfNullReturnTBD(
                                                    DateTimeHelper
                                                        .parseDateTimeToHHMMOnly(
                                                            firstEvent
                                                                ?.eventDateTime
                                                                ?.add(Duration(
                                                                    minutes: firstEvent
                                                                        ?.event
                                                                        ?.durationMinutes)))),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "QuickSand",
                                                color: Colors.white),
                                          ),
                                          VEmptyView(10),
                                        ],
                                      ),
                                firstEvent == null
                                    ? Container()
                                    : InkWell(
                                        child: Text(
                                          "See More",
                                          style: TextStyle(
                                              color: Colors.blue[800],
                                              fontFamily: "QuickSand"),
                                        ),
                                        onTap: () {
                                          MainPage.mainPageState
                                              .manualNavToPage(
                                                  PageIndex.schedule);
                                        },
                                      )
                              ],
                            ),
                          )),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(500),
                          // constraints: BoxConstraints(
                          //     minHeight: ScreenUtil().setHeight(300)),

                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Tasks",
                                  style: TextStyle(
                                      fontFamily: "QuickSand",
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                // VEmptyView(10),
                                firstTask == null
                                    ? Container(
                                        child: Text(
                                          "N/A",
                                          style: TextStyle(
                                              fontFamily: "QuickSand",
                                              color: Colors.white),
                                        ),
                                      )
                                    : Column(
                                        children: <Widget>[
                                          Text(
                                            TextHelper.checkTextIfNullReturnTBD(
                                                firstTask?.task?.summary),
                                            style: TextStyle(
                                                fontFamily: "QuickSand",
                                                color: Colors.white),
                                          ),
                                          VEmptyView(10),
                                          Text(
                                            TextHelper.checkTextIfNullReturnTBD(
                                                    DateTimeHelper
                                                        .parseDateTimeToHHMMOnly(
                                                            firstTask
                                                                ?.eventDateTime)) +
                                                " - " +
                                                TextHelper.checkTextIfNullReturnTBD(
                                                    DateTimeHelper
                                                        .parseDateTimeToHHMMOnly(
                                                            firstTask
                                                                ?.eventDateTime
                                                                ?.add(Duration(
                                                                    minutes: firstTask
                                                                        ?.task
                                                                        ?.durationMinutes)))),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "QuickSand",
                                                color: Colors.white),
                                          ),
                                          VEmptyView(10),
                                        ],
                                      ),
                                firstTask == null
                                    ? Container()
                                    : InkWell(
                                        child: Text(
                                          "See More",
                                          style: TextStyle(
                                              color: Colors.blue[800],
                                              fontFamily: "QuickSand"),
                                        ),
                                        onTap: () {
                                          MainPage.mainPageState
                                              .manualNavToPage(
                                                  PageIndex.schedule);
                                        },
                                      )
                              ],
                            ),
                          )),
                        )
                      ],
                    ),
                  )
                ],
              ))),
    ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  // @override
  // bool get wantKeepAlive => false;
}

Widget _dealAverageHigestSummary() {
  return Card(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(280),
            child: Column(
              children: <Widget>[
                Text(
                  "Deal Amount",
                  style: TextStyles.onlyBoldTextStyle,
                ),
                VEmptyView(10),
                Text("May-2019"),
                VEmptyView(10),
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(260),
                      child: Text('Highest'),
                    ),
                    VEmptyView(5),
                    Container(
                      width: ScreenUtil().setWidth(160),
                      color: Colors.blue,
                      child: Text(
                        "\$3200",
                        style: TextStyles.whiteText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                VEmptyView(10),
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(60),
                      child: Text('Average'),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      color: Colors.green,
                      width: ScreenUtil().setWidth(90),
                      child: Text(
                        "\$3200",
                        style: TextStyles.whiteText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                VEmptyView(10),
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(60),
                      child: Text('Lowest'),
                    ),
                    VEmptyView(10),
                    Container(
                      color: Colors.red,
                      width: ScreenUtil().setWidth(50),
                      child: Text(
                        "\$3200",
                        style: TextStyles.whiteText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: ScreenUtil().setWidth(10),
                  child: VerticalDivider(color: Colors.grey)),
            ],
          ),
          Container(
            width: ScreenUtil().setWidth(280),
            child: Column(
              children: <Widget>[
                Text("Deal: Starred vs Overdue",
                    style: TextStyles.onlyBoldTextStyle),
                VEmptyView(10),
                Text("May-2019"),
                VEmptyView(10),
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(250),
                      child: Text('Starred'),
                    ),
                    VEmptyView(10),
                    Container(
                      color: Colors.blue,
                      child: Text(
                        "200",
                        style: TextStyles.whiteText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                VEmptyView(10),
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(250),
                      child: Text('Overdue'),
                    ),
                    VEmptyView(10),
                    Container(
                      color: Colors.blue,
                      child: Text(
                        "\10",
                        style: TextStyles.whiteText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

class PassDonutData {
  static List<charts.Series<LinearSales, int>> _createMonthData(
      OverallSummary currentMonthSummary) {
    final data = [
      new LinearSales(0, currentMonthSummary.openLead, Colors.lightBlue),
      new LinearSales(1, currentMonthSummary.won, Colors.green[400]),
      new LinearSales(2, currentMonthSummary.lost, Colors.red[500])
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.index,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        colorFn: (LinearSales sales, _) => sales.color,
        labelAccessorFn: (LinearSales row, _) => '${row.sales}',
      )
    ];
  }

  static List<charts.Series<LinearSales, int>> _createYearData(
      OverallSummary yearSummary) {
    final data = [
      new LinearSales(0, yearSummary.openLead, Colors.lightBlue),
      new LinearSales(1, yearSummary.won, Colors.green[400]),
      new LinearSales(2, yearSummary.lost, Colors.red[500])
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.index,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        colorFn: (LinearSales sales, _) => sales.color,
        labelAccessorFn: (LinearSales row, _) => '${row.sales}',
      )
    ];
  }
}

class PassBarData {
  static setAmountBasedOnTrailing(String currencyTrailing, double amount) {
    switch (currencyTrailing) {
      case "":
        return amount.toStringAsFixed(1);
      case "K":
        return (amount / 1000).toStringAsFixed(1);
      case "M":
        return (amount / 1000000).toStringAsFixed(1);

      default:
        return amount;
    }
  }

  static List<charts.Series<OrdinalSales, String>> _createSampleData(
      TargetAchieved targetAchieved) {
    final data = [
      new OrdinalSales('Q1', targetAchieved?.q1?.target ?? 0),
      new OrdinalSales('Q2', targetAchieved?.q2?.target ?? 0),
      new OrdinalSales('Q3', targetAchieved?.q3?.target ?? 0),
      new OrdinalSales('Q4', targetAchieved?.q4?.target ?? 0),
    ];

    final data2 = [
      new OrdinalSales('Q1', targetAchieved?.q1?.achieved ?? 0),
      new OrdinalSales('Q2', targetAchieved?.q2?.achieved ?? 0),
      new OrdinalSales('Q3', targetAchieved?.q3?.achieved ?? 0),
      new OrdinalSales('Q4', targetAchieved?.q4?.achieved ?? 0),
    ];
    double sumAll = 0;
    data.forEach((d) {
      sumAll += d.amount;
    });
    data2.forEach((d) {
      sumAll += d.amount;
    });

    double average = sumAll / (data.length + data2.length);
    String currencyTraling;
    if (average >= 1000 && average < 1000000) {
      currencyTraling = "K";
    } else if (average > 100000) {
      currencyTraling = "M";
    } else {
      currencyTraling = "";
    }

    return [
      new charts.Series<OrdinalSales, String>(
          id: 'Target',
          domainFn: (OrdinalSales sales, _) => sales.quarter,
          measureFn: (OrdinalSales sales, _) => sales.amount,
          colorFn: (_, __) => charts.MaterialPalette.indigo.shadeDefault,
          //seriesCategory: "red",
          // domainLowerBoundFn: (OrdinalSales sales, _) => sales.target.toString(),
          // domainUpperBoundFn: (OrdinalSales sales, _) => sales.achieved.toString(),
          data: data,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (OrdinalSales sales, _) =>
              '${setAmountBasedOnTrailing(currencyTraling, sales.amount)}$currencyTraling'),
      new charts.Series<OrdinalSales, String>(
          id: 'Achieved',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (OrdinalSales sales, _) => sales.quarter,
          measureFn: (OrdinalSales sales, _) => sales.amount,
          // domainLowerBoundFn: (OrdinalSales sales, _) => sales.target.toString(),
          // domainUpperBoundFn: (OrdinalSales sales, _) => sales.achieved.toString(),
          data: data2,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (OrdinalSales sales, _) =>
              '${setAmountBasedOnTrailing(currencyTraling, sales.amount)}$currencyTraling')
    ];
  }
}
