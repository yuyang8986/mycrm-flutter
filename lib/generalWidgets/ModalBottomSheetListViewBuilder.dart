import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Services/FutureBuilderDataHandler/FutureBuilderHandler.dart';
import 'package:mycrm/generalWidgets/Infrastructure/NetErrorWidget.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:mycrm/generalWidgets/Shared/ModalListViewAddContactWidget.dart';
import 'package:mycrm/generalWidgets/Shared/NoContactInfoGuideWidget.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';

class ModalBottomSheetListViewBuilder<T> {
  final Future<RepoResponse> futureList;
  BuildContext context;
  Function onTapCallback;
  final Widget noDataDisplay;
  ModalBottomSheetListViewBuilder(
      this.futureList, this.context, this.onTapCallback,
      {this.noDataDisplay});
  showModal() async {
    await showModalBottomSheet(
        // backgroundColor: Colors.red[300],
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                child: FutureBuilder(
                    future: futureList,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError)
                        return NetErrorWidget(
                          callback: null,
                        );
                      if (!snapshot.hasData) return LoadingIndicator();

                      RepoResponse response = snapshot.data;
                      if (response.success) {
                        List<T> entities = response.model as List<T>;
                        return FutureBuilderDataHandler.handle(response,
                            _buildListView<T>(entities, onTapCallback), null,
                            noDataDisplay: noDataDisplay);
                      }

                      return NetErrorWidget(
                        callback: null,
                      );
                    }),
              );
            },
          );
        },
        context: context);
  }

  _buildListView<T>(
    List<T> entities,
    Function onTapCallback,
  ) {
    List<Widget> displayContent;

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(
            ScreenUtil().setWidth(15),
          ),
          child: Text(
            "Please Select From List",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40),
                fontWeight: FontWeight.bold,
                fontFamily: "QuickSand"),
          ),
        ),
        Divider(
          thickness: 2,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: entities?.length,
              itemBuilder: (BuildContext context, int index) {
                if (entities.elementAt(0)?.runtimeType == Pipeline) {
                  Pipeline pipeline = (entities[index] as Pipeline);
                  Company company = pipeline.people != null
                      ? pipeline.people.company
                      : pipeline.company;
                  People people = pipeline.people;
                  displayContent = <Widget>[
                    Text(
                      "Deal Name: " +
                          TextHelper.checkTextIfNullReturnTBD(
                              (pipeline.dealName)),
                      textAlign: TextAlign.center,
                    ),
                    VEmptyView(10),
                    Text('Deal Amount: \$' +
                        TextHelper.checkTextIfNullReturnTBD(
                            (pipeline.dealAmount.toStringAsFixed(2)))),
                    VEmptyView(10),
                    Text("Company: " +
                        (company?.isDeleted ?? false ? "(former)" : "") +
                        (TextHelper.checkTextIfNullReturnTBD(company?.name))),
                    VEmptyView(10),
                    Text("Contact Person: " +
                        (people?.isDeleted ?? false ? "(former)" : "") +
                        TextHelper.checkTextIfNullReturnTBD(people?.name))
                  ];

                  // trailing = ("People Name: " +
                  //     TextHelper.checkTextIfNullReturnTBD(
                  //         (entities[index] as Pipeline).people?.name));
                }

                if (entities.elementAt(0)?.runtimeType == People) {
                  People people = (entities[index] as People);
                  Company company = people.company;
                  displayContent = <Widget>[
                    Text("Person Name: " +
                        (people.isDeleted ? "(former)" : "") +
                        TextHelper.checkTextIfNullReturnTBD((people?.name))),
                    VEmptyView(10),
                    Text("Company Name: " +
                        (company.isDeleted ? "(former) " : "") +
                        TextHelper.checkTextIfNullReturnTBD(
                            (company?.name ?? "")))
                  ];

                  // trailing = "Location: " +
                  //     ((entities[index] as People).company?.location ?? "");
                }

                if (entities.elementAt(0)?.runtimeType == Company) {
                  Company company = (entities[index] as Company);
                  displayContent = <Widget>[
                    Text("Company Name: " +
                        (company?.isDeleted ?? false ? "(former)" : "") +
                        TextHelper.checkTextIfNullReturnTBD((company?.name))),
                    VEmptyView(10),
                    Text("Location: " +
                        TextHelper.checkTextIfNullReturnTBD(company?.location)),
                  ];

                  //trailing = (entities[index] as Company).company.location;
                }
                return Material(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(38),
                      fontWeight: FontWeight.bold,
                      fontFamily: "QuickSand"),
                  child: InkWell(
                      onTap: () async {
                        await onTapCallback(entities[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                          margin: EdgeInsets.all(ScreenUtil().setWidth(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: displayContent),
                              Divider(
                                color: Colors.grey,
                                thickness: 1.5,
                              ),
                            ],
                          ))),
                );
              }),
        ),
       // ModalListViewAddContactWidget(2),
      ],
    );
  }
}
