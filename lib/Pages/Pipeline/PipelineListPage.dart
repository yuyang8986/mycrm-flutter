import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Employee/ApplicationUser.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineAddPage.dart';
import 'package:mycrm/Services/CurrencyService/CurrencyService.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/ExpandableListWithNestedListView.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Pipeline/PipelineCard.dart';
import 'package:mycrm/generalWidgets/Shared/AddDealSpeedDial.dart';

class PipelineListPage extends StatefulWidget {
  PipelineListPage({Key key}) : super(key: key);

  PipelineListPageState createState() => PipelineListPageState();
}

class PipelineListPageState extends State<PipelineListPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  //CalendarController _calendarController;
  // AnimationController _animationController;
  // AnimationController _animationController2;
  // Animation<Offset> offset;
  // Animation<Offset> offset2;
  TabController _tabController;
  //Map<DateTime, List<Pipeline>> events;
  //DateTime selectedPipelineDateTime;
  List<Pipeline> allPipelinesListView;
  List<Pipeline> allPipelinesListViewFiltered;
  //List<Pipeline> selectedPipelinesCalendarView;
  //List<Pipeline> selectedPipelinesFilteredCalendarView;
  //bool expandEvent;
  bool isSortingByStarListView;
  bool isSortingByOverdueListView;
  bool isSortingByTodayOnlyListView;
  bool isSortingByBiggestDealAmountListView;

  // bool isSortingByStarCalendarView;
  // bool isSortingByOverdueCalendarView;
  // bool isSortingByTodayOnlyCalendarView;
  // bool isSortingByBiggestDealAmountCalendarView;
  final PipelineListBloc _pipelineListBloc = PipelineListBloc();
  List<String> filterStringsListView;
  //List<String> filterStringsCalendarView;
  static bool isInit;
  bool isManager = HttpRequest.appUser.isManager;
  bool isSearchingListView;
  //bool isSearchingCalendarView;

  @override
  void initState() {
    print("init pipeline page");
    isInit = true;
    //isSearchingCalendarView = false;
    isSearchingListView = false;
    filterStringsListView = List<String>();
    //filterStringsCalendarView = List<String>();
    isSortingByOverdueListView = false;
    isSortingByStarListView = false;
    isSortingByTodayOnlyListView = false;
    isSortingByBiggestDealAmountListView = false;
    _tabController = TabController(length: 2, vsync: this);
    //isSortingByStarCalendarView = false;
    //isSortingByOverdueCalendarView = false;
    //isSortingByTodayOnlyCalendarView = false;
    //isSortingByBiggestDealAmountCalendarView = false;
    // _calendarController = CalendarController();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 150),
    // );
    // _animationController2 = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 150));
    // _tabController = TabController(
    //     vsync: this,
    //     length: HttpRequest.appUser.isManager ? 3 : 2,
    //     initialIndex: 0);
    // expandEvent = false;
    // offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.12))
    //     .animate(_animationController);
    // offset2 = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
    //     .animate(_animationController2);
    // events = {};
    // selectedPipelineDateTime = DateTime.now();
    super.initState();
  }

  // @override
  // void dispose() {
  //   //_calendarController?.dispose();
  //   // _animationController?.dispose();
  //   // _animationController2?.dispose();

  //   //reason not to dispose is to keep it alive for different pages
  //   //_pipelineListBloc.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return CustomStreamBuilder(
        retryCallback: _pipelineListBloc.getAllPipelines,
        stream: _pipelineListBloc.allPipelines,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          allPipelinesListView = snapshot?.data as List<Pipeline>;

          allPipelinesListViewFiltered =
              isInit ? allPipelinesListView : allPipelinesListViewFiltered;
          isInit = false;
          return tabView;
        });
  }

  Widget get tabView {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      floatingActionButton: _addPipelineButtonListView,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: !isManager
          ? PreferredSize(
              child: AppBar(),
              preferredSize: Size.fromHeight(0),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: AppBar(
                automaticallyImplyLeading: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Material(
                    color: Colors.black45,
                    textStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(40),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorWeight: 2,
                      labelColor: Colors.white,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: "QuickSand"),
                      indicatorColor: Colors.white,
                      tabs: isManager
                          ? [
                              // Tab(
                              //   text: 'Calendar View',
                              // ),
                              Tab(
                                text: 'List View',
                              ),
                              Tab(
                                text: 'Employee',
                              )
                            ]
                          : [
                              // Tab(
                              //   text: 'Calendar View',
                              // ),
                              Tab(
                                text: 'List View',
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ),
      body: !isManager
          ? pipelineListView(allPipelinesListViewFiltered, context)
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                  //floatingActionButton: addNewLineBtn(),
                  body: TabBarView(
                children: isManager
                    ? <Widget>[
                        //calendarToggleView,
                        pipelineListView(allPipelinesListViewFiltered, context),
                        employeePipelinesList()
                      ]
                    : <Widget>[
                        //calendarToggleView,
                        pipelineListView(allPipelinesListViewFiltered, context)
                      ],
                controller: _tabController,
              )),
            ),
    );
  }

  Widget employeePipelinesList() {
    // List<ApplicationUser> appUsers = List<ApplicationUser>();
    // for (var pipeline in pipelines) {
    //   appUsers.add(pipeline.applicationUser);
    // }

    // if (appUsers.length == 0)
    //   return NoDataWidget("No Pipelines. Please click on + to add Deals.");

    // appUsers.toSet().toList();
    //appUsers = Collection(appUsers).distinct().toList();
    //_pipelineListBloc.getAllEmployees();
    return CustomStreamBuilder(
      retryCallback: _pipelineListBloc.getAllEmployees,
      stream: _pipelineListBloc.allEmployeesStream,
      builder: (ctx, asyncdata) {
        List<ApplicationUser> appUsers = asyncdata.data;
        return RefreshIndicator(
          child: ListView.builder(
            // controller: expandableController,
            itemBuilder: (ctx, index) {
              ApplicationUser user = appUsers[index];
              return Card(
                  elevation: 5,
                  child: ExpandableListWithNestListView(
                      dealEmployeeListHeader(user),
                      dealEmployeeExpaneded(user)));
            },
            // shrinkWrap: true,
            itemCount: appUsers?.length,
          ),
          onRefresh: _refreshPipelines,
        );
      },
    );
  }

  Widget dealEmployeeExpaneded(ApplicationUser applicationUser) {
    return Container(
      // constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(500)),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, pipelineIndex) {
          if (applicationUser.pipeLineFlows == null) {
            return Container();
          }
          var pipeline = applicationUser.pipeLineFlows[pipelineIndex];
          return Card(
            child: Container(
              // constraints: BoxConstraints(
              //     maxHeight: ScreenUtil().setHeight(400)),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(left: 10, top: 10),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Deal Name: ' + pipeline.dealName,
                    style: TextStyles.onlyBoldTextStyle,
                  ),
                  Text(
                    'Deal Amount: '
                    "\$${pipeline.dealAmount.toStringAsFixed(2)}",
                    style: TextStyles.onlyBoldTextStyle,
                  ),
                  VEmptyView(20),
                  pipeline.people != null
                      ? Container(
                          constraints: BoxConstraints(
                              maxWidth: ScreenUtil().setWidth(900)),
                          child: Text(
                            'Company Name: ' +
                                pipeline.people.company.name +
                                '\n' +
                                'Contact Person: ' +
                                pipeline.people.name,
                            //style: TextStyles.onlyBoldTextStyle,
                          ),
                        )
                      : Text('Company Name: ' +
                          TextHelper.checkTextIfNullReturnEmpty(
                              pipeline.company?.name)),
                  Text('Stage: ' +
                      TextHelper.checkTextIfNullReturnEmpty(
                          pipeline.stage?.name))
                ],
              ),
            ),
          );
        },
        itemCount: applicationUser.pipeLineFlows?.length ?? 0,
        shrinkWrap: true,
      ),
    );
  }

  Widget dealEmployeeListHeader(ApplicationUser applicationUser) {
    return Container(
        margin: EdgeInsets.only(bottom: 5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.lightBlue,
            child: Text(
              TextHelper.checkTextIfNullReturnEmpty(
                  '${applicationUser.firstName.toUpperCase().substring(0, 1)}'),
              style: TextStyle(
                  color: AppColors.normalTextColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            applicationUser.firstName + " " + applicationUser.lastName,
            style: TextStyle(fontSize: ScreenUtil().setSp(45)),
          ),
          trailing: Text(applicationUser.pipeLineFlows?.length.toString(),
              style: TextStyle(fontSize: ScreenUtil().setSp(45))),
        ));
  }

  // Widget get calendarToggleView {
  //   return SingleChildScrollView(
  //       child: Column(
  //     children: [
  //       expandEvent
  //           ? Container()
  //           : _buildTableCalendarWithBuilders(), //calendar
  //       expandEvent
  //           ? _buildEventList() //list on date
  //           : Container(),
  //     ],
  //   ));
  // }

  // Widget _buildTableCalendarWithBuilders() {
  //   return Card(
  //     elevation: 5,
  //     child: SlideTransition(
  //       position: offset,
  //       child: TableCalendar(
  //         initialSelectedDay: DateTime.now(),
  //         calendarController: _calendarController,
  //         events: events,
  //         initialCalendarFormat: CalendarFormat.month,
  //         formatAnimation: FormatAnimation.scale,
  //         startingDayOfWeek: StartingDayOfWeek.sunday,
  //         availableGestures: AvailableGestures.all,
  //         calendarStyle: CalendarStyle(
  //           renderSelectedFirst: true,
  //           canEventMarkersOverflow: true,
  //           outsideDaysVisible: false,
  //           weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
  //           holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
  //         ),
  //         daysOfWeekStyle: DaysOfWeekStyle(
  //           weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
  //         ),
  //         headerStyle: HeaderStyle(
  //             centerHeaderTitle: true,
  //             formatButtonVisible: true,
  //             formatButtonTextStyle: TextStyles.whiteText,
  //             formatButtonDecoration: BoxDecoration(
  //                 color: Colors.blue, borderRadius: BorderRadius.circular(5))),
  //         builders: CalendarBuilders(
  //           // selectedDayBuilder: (context, date, _) {
  //           //   return Container(
  //           //     // margin: const EdgeInsets.all(4.0),
  //           //     // padding: const EdgeInsets.all(2.0),
  //           //     //decoration: BoxDecoration(),
  //           //     color: Colors.deepOrange[300],
  //           //     child: Text(
  //           //       '${date.day}',
  //           //       //style: TextStyle().copyWith(fontSize: 20.0),
  //           //     ),
  //           //   );
  //           // },
  //           // todayDayBuilder: (context, date, _) {
  //           //   return Container(
  //           //     decoration:
  //           //         BoxDecoration(borderRadius: BorderRadius.circular(10)),
  //           //     // margin: const EdgeInsets.all(4.0),
  //           //     // padding: const EdgeInsets.only(top: 5.0, left: 6.0),
  //           //     color: Colors.amber[400],
  //           //     // width: 100,
  //           //     // height: 100,
  //           //     child: Text(
  //           //       '${date.day}',
  //           //       style: TextStyle().copyWith(fontSize: 16.0),
  //           //     ),
  //           //   );
  //           // },
  //           markersBuilder: (context, date, events, holidays) {
  //             final children = <Widget>[];

  //             if (events.isNotEmpty) {
  //               children.add(
  //                 Positioned(
  //                   right: 1,
  //                   bottom: 1,
  //                   child: _buildEventsMarker(date, events),
  //                 ),
  //               );
  //             }

  //             if (holidays.isNotEmpty) {
  //               children.add(
  //                 Positioned(
  //                   right: -2,
  //                   top: -2,
  //                   child: _buildHolidaysMarker(),
  //                 ),
  //               );
  //             }

  //             return children;
  //           },
  //         ),
  //         onDaySelected: (date, events) {
  //           _onDaySelected(date, events);
  //           setState(() {
  //             expandEvent = true;
  //           });
  //           _animationController.forward();
  //           _animationController2.forward();
  //         },
  //         onVisibleDaysChanged: _onVisibleDaysChanged,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildEventsMarker(DateTime date, List events) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 100),
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: _calendarController.isSelected(date)
  //           ? Colors.brown[500]
  //           : _calendarController.isToday(date)
  //               ? Colors.brown[300]
  //               : Colors.blue[400],
  //     ),
  //     width: 16.0,
  //     height: 16.0,
  //     child: Center(
  //       child: Text(
  //         '${events.length}',
  //         style: TextStyle().copyWith(
  //           color: Colors.white,
  //           fontSize: 12.0,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildHolidaysMarker() {
  //   return Icon(
  //     Icons.add_box,
  //     size: 20.0,
  //     color: Colors.blueGrey[800],
  //   );
  // }

  // Widget _buildEventList() {
  //   return SlideTransition(
  //     position: offset2,
  //     child: Column(
  //       children: <Widget>[
  //         pipelineTopBar(selectedPipelinesFilteredCalendarView, false),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         ListView(
  //           shrinkWrap: true,
  //           children: selectedPipelinesFilteredCalendarView != null
  //               ? selectedPipelinesFilteredCalendarView
  //                   .map((event) => pipelineRow(event))
  //                   //Container(
  //                   //       decoration: BoxDecoration(
  //                   //         border: Border.all(width: 0.8),
  //                   //         borderRadius: BorderRadius.circular(12.0),
  //                   //       ),
  //                   //       margin: const EdgeInsets.symmetric(
  //                   //           horizontal: 8.0, vertical: 4.0),
  //                   //       child:
  //                   //           ListTile(
  //                   //             dense: true,
  //                   //             trailing: Text("Amount: " + (event as Pipeline).dealAmount.toString()),
  //                   //             leading: Text("Name: " + (event as Pipeline).dealName),
  //                   //             // trailing: TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer((event as Pipeline).people?.name),
  //                   //             onTap: () {

  //                   //             }),
  //                   //     ))
  //                   .toList()
  //               : [Container()],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _onDaySelected(DateTime day, List events) {
  //   setState(() {
  //     selectedPipelinesCalendarView = events.length == 0 ? null : events;
  //     selectedPipelinesFilteredCalendarView = selectedPipelinesCalendarView;
  //     selectedPipelineDateTime = day;
  //     _pipelineListBloc.selectedDateTime = day;
  //     //_pipelineListBloc.getAllPipelinesOnDate();
  //   });
  // }

  // void _onVisibleDaysChanged(
  //     DateTime first, DateTime last, CalendarFormat format) {
  //   print('CALLBACK: _onVisibleDaysChanged');
  // }

  Widget pipelineTopBar(List<Pipeline> pipelineList, bool isListView) {
    double pipelineAmountSum = 0;
    double pipelineGPSum = 0;
    int goodsSoldCount = 0;
    int serviceCount = 0;
    pipelineList?.forEach((e) {
      pipelineAmountSum += e.dealAmount;
      e.cogsAmount != null
          ? pipelineGPSum += (e.dealAmount - (e?.cogsAmount ?? 0))
          : pipelineGPSum += (e.dealAmount * (1 - (e?.margin ?? 0)));
      e.type == "Goods Sales" ? goodsSoldCount += 1 : serviceCount += 1;
    });
    String currencyTrailing = "";
    if (pipelineAmountSum >= 1000 && pipelineAmountSum < 1000000) {
      currencyTrailing = "K";
    } else if (pipelineAmountSum > 100000) {
      currencyTrailing = "M";
    } else {
      currencyTrailing = "";
    }

    String amount = CurrencyService.setAmountBasedOnTrailing(
        currencyTrailing, pipelineAmountSum);

    String gp = CurrencyService.setAmountBasedOnTrailing(
        currencyTrailing, pipelineGPSum);
    return Card(
        elevation: 5,
        color: Colors.white,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Total Deals: ' + pipelineList.length.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(40))),
                Text(
                  'Amount: \$' + amount.toString() + currencyTrailing,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(40)),
                ),
                pipelineTopBarFilterButtonsListView,
              ],
            )));
    // Table(
    //   children: <TableRow>[

    //     // TableRow(children: <Widget>[
    //     //   // new TableCell(
    //     //   //   child: Padding(
    //     //   //     padding: const EdgeInsets.symmetric(vertical: 5.0),
    //     //   //     child: Text(
    //     //   //       'Goods Sales: ' + goodsSoldCount.toString(),
    //     //   //       style: TextStyle(
    //     //   //           fontWeight: FontWeight.bold,
    //     //   //           fontSize: ScreenUtil().setSp(35)),
    //     //   //     ),
    //     //   //   ),
    //     //   // ),
    //     //   // new TableCell(
    //     //   //   child: Padding(
    //     //   //     padding: const EdgeInsets.symmetric(vertical: 5.0),
    //     //   //     child: Text(
    //     //   //       'Services: ' + serviceCount.toString(),
    //     //   //       style: TextStyle(
    //     //   //           fontWeight: FontWeight.bold,
    //     //   //           fontSize: ScreenUtil().setSp(35)),
    //     //   //     ),
    //     //   //   ),
    //     //   // ),
    //     // ])
    //   ],
    // )));
  }

  Widget get pipelineTopBarFilterButtonsListView {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: ScreenUtil().setHeight(100),
          width: ScreenUtil().setWidth(100),
          child: IconButton(
            icon: Icon(
              Icons.star,
              color: isSortingByStarListView ? Colors.red : Colors.grey,
              size: isSortingByStarListView ? 24 : 20,
            ),
            onPressed: () async {
              setState(() {
                isSortingByStarListView = !isSortingByStarListView;
              });
              if (isSortingByStarListView) {
                filterStringsListView.add('starred');
              } else if (filterStringsListView.contains('starred')) {
                filterStringsListView.remove('starred');
              }

              if (filterStringsListView.length > 0) {
                // await _pipelineListBloc.getFilteredPipelines(
                //     selectedEventFiltered, filterStrings);
                setState(() {
                  filterPipesListView();
                });
              } else {
                //await _pipelineListBloc.getAllPipelines();
                setState(() {
                  allPipelinesListViewFiltered = allPipelinesListView;
                });
              }
            },
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(100),
          width: ScreenUtil().setWidth(100),
          child: IconButton(
            icon: Icon(
              Icons.attach_money,
              color: isSortingByBiggestDealAmountListView
                  ? Colors.green
                  : Colors.grey,
              size: ScreenUtil().setWidth(50),
            ),
            onPressed: () async {
              setState(() {
                isSortingByBiggestDealAmountListView =
                    !isSortingByBiggestDealAmountListView;
              });
              if (isSortingByBiggestDealAmountListView) {
                filterStringsListView.add('biggestAmount');
              } else if (filterStringsListView.contains('biggestAmount')) {
                filterStringsListView.remove('biggestAmount');
              }

              if (filterStringsListView.length > 0) {
                // await _pipelineListBloc.getFilteredPipelines(
                //     selectedEventFiltered, filterStrings);
                setState(() {
                  filterPipesListView();
                });
              } else {
                //await _pipelineListBloc.getAllPipelines();
                setState(() {
                  allPipelinesListViewFiltered = allPipelinesListView;
                });
              }
            },
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(100),
          width: ScreenUtil().setWidth(100),
          child: IconButton(
            icon: Icon(
              isSearchingListView ? Icons.remove_circle : Icons.search,
              color: isSearchingListView ? Colors.red : Colors.grey,
              size: ScreenUtil().setWidth(50),
            ),
            onPressed: () async {
              isSearchingListView = !isSearchingListView;
              if (!isSearchingListView) {
                // await _pipelineListBloc.getAllPipelines();
                setState(() {
                  allPipelinesListViewFiltered = allPipelinesListView;
                });
              } else {
                DialogService().showTextInput(
                    context, "Search By Company Name or Person Name", "Search",
                    (searchText) async {
                  setState(() {
                    searchPipelines(searchText);
                  });
                  // isInit = true;
                  // await _pipelineListBloc.searchPipelines(searchText);
                }, () {
                  isSearchingListView = !isSearchingListView;
                  Navigator.of(context).pop();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  searchPipelines(String searchText) {
    allPipelinesListViewFiltered = allPipelinesListViewFiltered
        .where((s) =>
            (s.company?.name
                    ?.toLowerCase()
                    ?.contains(searchText.toString().toLowerCase()) ??
                false) ||
            (s.people?.company?.name
                    ?.toLowerCase()
                    ?.contains(searchText.toString().toLowerCase()) ??
                false) ||
            (s.people?.name
                    ?.toLowerCase()
                    ?.contains(searchText.toString().toLowerCase()) ??
                false))
        .toList();

    // if (prefix0.HttpRequest.appUser.isManager) {
    //   allPipelinesListViewFiltered = allPipelinesListViewFiltered.where((s) =>
    //       (s.applicationUser?.name
    //               ?.toLowerCase()
    //               ?.contains(searchText.toString().toLowerCase()) ??
    //           false)
    //           );
    // }
  }

  // Widget get pipelineTopBarFilterButtonsCalendariew {
  //   return Row(
  //     children: <Widget>[
  //       IconButton(
  //         icon: Icon(
  //           Icons.star,
  //           color: isSortingByStarCalendarView ? Colors.amber : Colors.grey,
  //           size: isSortingByStarCalendarView ? 24 : 20,
  //         ),
  //         onPressed: () async {
  //           setState(() {
  //             isSortingByStarCalendarView = !isSortingByStarCalendarView;
  //           });
  //           if (isSortingByStarCalendarView) {
  //             filterStringsCalendarView.add('starred');
  //           } else if (filterStringsCalendarView.contains('starred')) {
  //             filterStringsCalendarView.remove('starred');
  //           }

  //           if (filterStringsCalendarView.length > 0) {
  //             //await _pipelineListBloc.getFilteredPipelines(filterStrings);
  //             setState(() {
  //               filterPipesCalendarView();
  //             });
  //           } else {
  //             //await _pipelineListBloc.getAllPipelines();
  //             setState(() {
  //               selectedPipelinesFilteredCalendarView =
  //                   selectedPipelinesCalendarView;
  //             });
  //           }
  //         },
  //       ),
  //       Container(
  //         height: 20,
  //         width: 80,
  //         child: RaisedButton(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //           onPressed: () async {
  //             setState(() {
  //               isSortingByOverdueCalendarView =
  //                   !isSortingByOverdueCalendarView;
  //             });
  //             if (isSortingByOverdueCalendarView) {
  //               filterStringsCalendarView.add('overdue');
  //             } else if (filterStringsCalendarView.contains('overdue')) {
  //               filterStringsCalendarView.remove('overdue');
  //             }

  //             if (filterStringsCalendarView.length > 0) {
  //               //await _pipelineListBloc.getFilteredPipelines(filterStrings);
  //               setState(() {
  //                 filterPipesCalendarView();
  //               });
  //             } else {
  //               //await _pipelineListBloc.getAllPipelines();
  //               setState(() {
  //                 selectedPipelinesFilteredCalendarView =
  //                     selectedPipelinesCalendarView;
  //               });
  //             }
  //           },
  //           child: Text(
  //             'OVERDUE',
  //             style: TextStyle(color: AppColors.normalTextColor, fontSize: 10),
  //           ),
  //           color: isSortingByOverdueCalendarView ? Colors.red : Colors.grey,
  //         ),
  //       ),
  //       // IconButton(
  //       //   icon: Icon(
  //       //     Icons.date_range,
  //       //     color: isSortingByTodayOnlyCalendarView ? Colors.blue : Colors.grey,
  //       //     size: 20,
  //       //   ),
  //       //   onPressed: () async {
  //       //     setState(() {
  //       //       isSortingByTodayOnlyCalendarView =
  //       //           !isSortingByTodayOnlyCalendarView;
  //       //     });
  //       //     if (isSortingByTodayOnlyCalendarView) {
  //       //       filterStringsCalendarView.add('todayOnly');
  //       //     } else if (filterStringsCalendarView.contains('todayOnly')) {
  //       //       filterStringsCalendarView.remove('todayOnly');
  //       //     }

  //       //     if (filterStringsCalendarView.length > 0) {
  //       //       //await _pipelineListBloc.getFilteredPipelines(filterStrings);
  //       //       setState(() {
  //       //         selectedEventFiltered = filterPipes(selectedEventFiltered);
  //       //       });
  //       //     } else {
  //       //       //await _pipelineListBloc.getAllPipelines();
  //       //       setState(() {
  //       //         selectedEventFiltered = selectedEvents;
  //       //       });
  //       //     }
  //       //   },
  //       // ),
  //       IconButton(
  //         icon: Icon(
  //           Icons.attach_money,
  //           color: isSortingByBiggestDealAmountCalendarView
  //               ? Colors.green
  //               : Colors.grey,
  //           size: 20,
  //         ),
  //         onPressed: () async {
  //           setState(() {
  //             isSortingByBiggestDealAmountCalendarView =
  //                 !isSortingByBiggestDealAmountCalendarView;
  //           });
  //           if (isSortingByBiggestDealAmountCalendarView) {
  //             filterStringsCalendarView.add('biggestAmount');
  //           } else if (filterStringsCalendarView.contains('biggestAmount')) {
  //             filterStringsCalendarView.remove('biggestAmount');
  //           }

  //           if (filterStringsCalendarView.length > 0) {
  //             //await _pipelineListBloc.getFilteredPipelines(filterStrings);
  //             setState(() {
  //               filterPipesCalendarView();
  //             });
  //           } else {
  //             //await _pipelineListBloc.getAllPipelines();
  //             setState(() {
  //               selectedPipelinesFilteredCalendarView =
  //                   selectedPipelinesCalendarView;
  //             });
  //           }
  //         },
  //       ),
  //       IconButton(
  //         icon: Icon(
  //           isSearchingCalendarView ? Icons.remove_circle : Icons.search,
  //           color: isSearchingCalendarView ? Colors.red : Colors.grey,
  //           size: 20,
  //         ),
  //         onPressed: () async {
  //           isSearchingCalendarView = !isSearchingCalendarView;
  //           if (!isSearchingCalendarView) {
  //             setState(() {
  //               selectedPipelinesFilteredCalendarView =
  //                   selectedPipelinesCalendarView;
  //             });
  //           } else {
  //             if (selectedPipelinesCalendarView == null) {
  //               isSearchingCalendarView = !isSearchingCalendarView;
  //               return;
  //             }

  //             DialogService().showTextInput(
  //                 context, "Search By Company Name or Employee Name",
  //                 (searchText) {
  //               setState(() {
  //                 selectedPipelinesFilteredCalendarView =
  //                     selectedPipelinesCalendarView
  //                         .where((s) =>
  //                             (s.company?.name?.toLowerCase()?.contains(
  //                                     searchText.toString().toLowerCase()) ??
  //                                 false) ||
  //                             (s.applicationUser?.name?.toLowerCase()?.contains(
  //                                     searchText.toString().toLowerCase()) ??
  //                                 false))
  //                         .toList();
  //               });
  //             }, () {
  //               setState(() {
  //                 isSearchingCalendarView = !isSearchingCalendarView;
  //               });
  //               Navigator.of(context).pop();
  //             });
  //           }
  //         },
  //       ),
  //     ],
  //   );
  // }

  // filterPipesCalendarView() {
  //   if (filterStringsCalendarView.contains("starred")) {
  //     if (selectedPipelinesFilteredCalendarView != null)
  //       selectedPipelinesFilteredCalendarView =
  //           selectedPipelinesFilteredCalendarView
  //               .where((s) => s.isStarred)
  //               .toList();
  //   }

  //   if (filterStringsCalendarView.contains("overdue")) {
  //     if (selectedPipelinesFilteredCalendarView != null)
  //       selectedPipelinesFilteredCalendarView =
  //           selectedPipelinesFilteredCalendarView
  //               .where((s) => s.isOverdue)
  //               .toList();
  //   }

  //   if (filterStringsCalendarView.contains("todayOnly")) {
  //     if (selectedPipelinesFilteredCalendarView != null)
  //       selectedPipelinesFilteredCalendarView =
  //           selectedPipelinesFilteredCalendarView
  //               .where((s) => DateTimeHelper.compareDatesIsSameDate(
  //                   s.appointment?.eventStartDateTime, DateTime.now()))
  //               .toList();
  //   }

  //   if (filterStringsCalendarView.contains("biggestAmount")) {
  //     if (selectedPipelinesFilteredCalendarView != null)
  //       selectedPipelinesFilteredCalendarView
  //           .sort((a, b) => b.dealAmount.compareTo(a.dealAmount));
  //   }

  //   //return selectedPipelinesFilteredCalendarView;
  // }

  filterPipesListView() {
    if (filterStringsListView.contains("starred")) {
      if (allPipelinesListViewFiltered != null)
        allPipelinesListViewFiltered =
            allPipelinesListViewFiltered.where((s) => s.isStarred).toList();
    }

    if (filterStringsListView.contains("overdue")) {
      if (allPipelinesListViewFiltered != null)
        allPipelinesListViewFiltered =
            allPipelinesListViewFiltered.where((s) => s.isOverdue).toList();
    }

    // if (filterStringsListView.contains("todayOnly")) {
    //   if (allPipelinesListViewFiltered != null)
    //     allPipelinesListViewFiltered = allPipelinesListViewFiltered
    //         .where((s) => DateTimeHelper.compareDatesIsSameDate(
    //             s.appointment?.eventStartDateTime, DateTime.now()))
    //         .toList();
    // }

    if (filterStringsListView.contains("biggestAmount")) {
      if (allPipelinesListViewFiltered != null)
        allPipelinesListViewFiltered
            .sort((a, b) => b.dealAmount.compareTo(a.dealAmount));
    }

    //return selectedPipelinesFilteredCalendarView;
  }

  Widget get _addPipelineButtonListView {
    return AddDealSpeedDial(
        true, navToAddPipelinePage, "AddPipelineListView", _pipelineListBloc);
    // AppFloatingActionButton(() {
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (BuildContext context) {
    //     return BlocProvider<PipelineListBloc>(
    //       bloc: _pipelineListBloc,
    //       child: PipelineAddPage(),
    //     );
    //   }));
    // }, "AddPipelineListView");
  }

  navToAddPipelinePage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return BlocProvider<PipelineListBloc>(
        bloc: _pipelineListBloc,
        child: PipelineAddPage(),
      );
    }));
  }

  // Widget get _addPipelineButtonManagerView {
  //   return
  //   AddDealSpeedDial(true, navToAddPipelinePage,"AddPipelineManagerView");
  //   // AppFloatingActionButton(() {
  //   //   Navigator.of(context)
  //   //       .push(MaterialPageRoute(builder: (BuildContext context) {
  //   //     return BlocProvider<PipelineListBloc>(
  //   //       bloc: _pipelineListBloc,
  //   //       child: PipelineAddPage(),
  //   //     );
  //   //   }));
  //   // }, "AddPipelineManagerView");
  // }

  Widget pipelineRow(Pipeline pipeline) {
    return PipelineCard(
      parentContext: context,
      pipeline: pipeline,
      pipelineListBloc: _pipelineListBloc,
      //filterStrings: filterStrings
    );
  }

  Widget pipelineListView(List<Pipeline> pipelineList, BuildContext _context) {
    return Container(
        //margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(200)),
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        pipelineTopBar(pipelineList, true),
        // RaisedButton.icon(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(_context);
        //   },
        //   label: Text('Back to Calendar'),
        // ),mm
        pipelineList.length == 0 &&
                !isSortingByTodayOnlyListView &&
                !isSortingByStarListView &&
                !isSortingByOverdueListView &&
                !isSortingByBiggestDealAmountListView &&
                !isSearchingListView
            ? Column(
                children: <Widget>[
                  VEmptyView(200),
                  Icon(
                    FontAwesomeIcons.handsHelping,
                    color: Colors.blue,
                    size: ScreenUtil().setHeight(100),
                  ),
                  VEmptyView(100),
                  Center(
                    child: NoDataWidget(
                        "No Deals. Please click on + to add Deals."),
                  ),
                  // VEmptyView(200),
                  // Icon(
                  //   Icons.arrow_downward,
                  //   size: ScreenUtil().setHeight(200),
                  // )
                ],
              )
            : Expanded(
                child: RefreshIndicator(
                child: ListView.builder(
                  itemCount: pipelineList?.length,
                  padding: EdgeInsets.only(bottom: 90),
                  itemBuilder: (BuildContext context, int index) {
                    // pipelineList
                    //     .sort((a, b) => b.dealAmount.compareTo(a.dealAmount));
                    return pipelineRow(pipelineList[index]);
                  },
                ),
                onRefresh: _refreshPipelines,
              )),
      ],
    ));
  }

  Future<void> _refreshPipelines() async {
    HttpRequest.forceRefresh = true;
    await _pipelineListBloc.getAllPipelines();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  // @override
  // bool get wantKeepAlive => false;

  // Widget pipelineRowRightIconButtons(Pipeline pipeline) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: <Widget>[
  //       PopupMenuButton(
  //         onSelected: (value) async {
  //           switch (value) {
  //             case PipelineCardDotsMenu.setToWon:
  //               await _pipelineListBloc.setWonLostClose(
  //                   pipeline.id, 'Won', pipeline);
  //               break;
  //             case PipelineCardDotsMenu.setToLost:
  //               await _pipelineListBloc.setWonLostClose(
  //                   pipeline.id, 'Lost', pipeline);
  //               break;
  //             case PipelineCardDotsMenu.setToClose:
  //               await _pipelineListBloc.setWonLostClose(
  //                   pipeline.id, 'Closed', pipeline);
  //               break;
  //             case PipelineCardDotsMenu.editLead:
  //               Navigator.of(context).push(MaterialPageRoute(
  //                   builder: (BuildContext context) {
  //                     return BlocProvider<PipelineListBloc>(
  //                       bloc: _pipelineListBloc,
  //                       child: PipelineEditPage(),
  //                     );
  //                   },
  //                   settings: RouteSettings(arguments: pipeline)));
  //               break;
  //             case PipelineCardDotsMenu.deleteLead:
  //               DialogService().showConfirm(
  //                   context, 'Are you sure to delete this lead?', () async {
  //                 await _pipelineListBloc.deletePipelineById(pipeline.id);
  //                 Navigator.pop(context);
  //               });
  //               break;
  //             default:
  //           }
  //         },
  //         icon: Icon(
  //           FontAwesomeIcons.ellipsisV,
  //           color: Colors.lightBlue,
  //         ),
  //         itemBuilder: (BuildContext context) {
  //           return [
  //             PopupMenuItem(
  //               child: Text('Set to WON'),
  //               value: PipelineCardDotsMenu.setToWon,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Set to LOST'),
  //               value: PipelineCardDotsMenu.setToLost,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Set to CLOSED'),
  //               value: PipelineCardDotsMenu.setToClose,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Edit Lead'),
  //               value: PipelineCardDotsMenu.editLead,
  //             ),
  //             PopupMenuItem(
  //               child: Text('Delete'),
  //               value: PipelineCardDotsMenu.deleteLead,
  //             )
  //           ];
  //         },
  //       ),
  //       IconButton(
  //         icon: Icon(
  //           pipeline.isStarred ? Icons.star : FontAwesomeIcons.star,
  //           size: pipeline.isStarred ? 22 : 18,
  //         ),
  //         color: Colors.amber,
  //         onPressed: () async {
  //           pipeline.isStarred = !pipeline.isStarred;
  //           await _pipelineListBloc.updatePipeline(pipeline);
  //           await _pipelineListBloc.getFilteredPipelines(filterStrings);
  //         },
  //       ),
  //       IconButton(
  //         icon: Icon(
  //           Icons.attach_file,
  //           color: Colors.grey,
  //         ),
  //         onPressed: () {},
  //       ),
  //       PopupMenuButton(
  //         onSelected: (value) async {
  //           switch (value) {
  //             case PipelineCardContactMenu.sms:
  //               if (pipeline.people?.phone?.isEmpty ?? true) {
  //                 DialogService().show(context, 'No Phone number');
  //                 return;
  //               }
  //               UrlSchemeService().sendSMS(pipeline.people.phone);
  //               break;
  //             case PipelineCardContactMenu.call:
  //               if (pipeline.people?.phone?.isEmpty ?? true) {
  //                 DialogService().show(context, 'No Phone number');
  //                 return;
  //               }
  //               UrlSchemeService().makePhoneCall(pipeline.people.phone);
  //               break;
  //             case PipelineCardContactMenu.email:
  //               if (pipeline.people?.email?.isEmpty ?? true) {
  //                 DialogService().show(context, 'No Email');
  //                 return;
  //               }
  //               UrlSchemeService().sendEmail(pipeline.people.email);
  //               break;

  //             default:
  //           }
  //         },
  //         icon: Icon(
  //           Icons.message,
  //           color: Colors.green,
  //         ),
  //         itemBuilder: (BuildContext context) {
  //           return [
  //             PopupMenuItem(
  //               child: Center(
  //                 child: Icon(Icons.sms),
  //               ),
  //               value: PipelineCardContactMenu.sms,
  //             ),
  //             PopupMenuItem(
  //               child: Center(
  //                 child: Icon(Icons.call),
  //               ),
  //               value: PipelineCardContactMenu.call,
  //             ),
  //             PopupMenuItem(
  //               child: Center(
  //                 child: Icon(Icons.email),
  //               ),
  //               value: PipelineCardContactMenu.email,
  //             ),
  //           ];
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget pipelineRowLeftInfo(Pipeline pipeline) {
  //   bool nextFollowUpDateDue = false;
  //   if (pipeline.nextFollowUpDate != null)
  //     nextFollowUpDateDue =
  //         pipeline.nextFollowUpDate.difference(DateTime.now()).inHours < 0;
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       Text(
  //         TextHelper.checkTextIfNullReturnEmpty(pipeline.company?.name),
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       Text(
  //         TextHelper.checkTextIfNullReturnEmpty(pipeline.dealName) +
  //             ': \$${pipeline.dealAmount}',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       Text('Contact Person: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.people?.name)),
  //       Text('Email: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.people?.email)),
  //       Text('Phone: ' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.people?.phone)),
  //       SizedBox(height: 10),
  //       Text('Deal Stage: ' +
  //           (pipeline.stage?.isDeleted ?? false ? "(obsolete)" : "") +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.stage?.name)),
  //       Text('Follow Up Task:' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.activity?.name)),
  //       Row(
  //         children: <Widget>[
  //           Text('Follow Up Time: ' +
  //               TextHelper.checkTextIfNullReturnEmpty(
  //                   DateTimeHelper.parseDateTimeToDateHHMM(
  //                       pipeline.nextFollowUpDate))),
  //           nextFollowUpDateDue
  //               ? Container(
  //                   margin: EdgeInsets.only(left: 5),
  //                   padding: EdgeInsets.all(2),
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(5),
  //                       color: Colors.red),
  //                   child: Text(
  //                     'OVERDUE',
  //                     style: TextStyle(
  //                         color: AppColors.normalTextColor, fontSize: 10),
  //                   ),
  //                 )
  //               : Container()
  //         ],
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       Text('Assigned to:' +
  //           TextHelper.checkTextIfNullReturnEmpty(pipeline.employee?.name)),
  //       //Text('Notes: ' + TextHelper.checkTextIfNullReturnEmpty(pipeline.note))
  //     ],
  //   );
  // }
}
