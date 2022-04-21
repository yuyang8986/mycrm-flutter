import 'package:flutter/material.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Styles/TextStyles.dart';

class ModalListViewAddContactWidget extends StatelessWidget {
  final int navDepth;
  ModalListViewAddContactWidget(this.navDepth);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
              "Create New Contact",
              style: TextStyles.whiteText,
            ),
          )
        ],
      ),
    );
  }
}
