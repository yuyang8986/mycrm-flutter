import 'package:flutter/material.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';

class NoContactInfoGuideWidget extends StatelessWidget {
  final int navDepth;
  NoContactInfoGuideWidget(this.navDepth);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("No Contacts has been created.",
              style: TextStyles.noDataDisplayText),
          VEmptyView(60),
          RaisedButton(
            onPressed: () {
              //Navigator.popUntil(context, ModalRoute.of(MainPageState.rootContext).pop);
              //Navigator.popUntil(context, ModalRoute.withName(Routes.mainPage));
              //Navigator.of(context, rootNavigator: true).pop(context);
              for (var i = 0; i < navDepth; i++) {
                Navigator.pop(context);
              }
              MainPage.mainPageState.manualNavToPage(PageIndex.contact);
            },
            child: Text(
              "Go back and Create Contact",
              style: TextStyles.whiteText,
            ),
          )
        ],
      ),
    );
  }
}
