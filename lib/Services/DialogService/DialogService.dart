import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Pages/Login/LoginPage.dart';
import 'package:mycrm/main.dart';

class DialogService {
  Future show(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(capitalize(message)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future showTextInput(
      BuildContext context,
      String title,
      String confirmButtonText,
      Function confirmCallBack,
      Function cancelCallBack,
      {String initialValue}) async {
    final textCtrl = TextEditingController(text: initialValue ?? "");
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(capitalize(title)),
          content: Container(
            constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(800)),
            child: TextField(
              textCapitalization: TextCapitalization.words,
              maxLines: null,
              controller: textCtrl,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                cancelCallBack();
              },
            ),
            new FlatButton(
              child: new Text(confirmButtonText),
              onPressed: () async {
                await confirmCallBack(textCtrl.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showConfirm(BuildContext context, String message, Function confirmCallBack) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: Text("Confirm"),
              onPressed: confirmCallBack,
            )
          ],
        );
      },
    );
  }

  Future showConfirmPopOnConfirm(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {},
            ),
            new FlatButton(
                child: Text("Confirm"),
                onPressed: () {
                  Navigator.pop(
                      context, true); // It worked for me instead of above line
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                })
          ],
        );
      },
    );
  }
}
