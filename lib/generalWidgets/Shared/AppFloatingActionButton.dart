import 'package:flutter/material.dart';

class AppFloatingActionButton extends StatelessWidget {
  final Function onPressed;
  final String heroTag;
  AppFloatingActionButton(this.onPressed, this.heroTag);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          //label: Text("ADD"),
          heroTag: heroTag,
          child: Icon(Icons.add),
          onPressed: onPressed,
          elevation: 20,
          //icon: Icon(Icons.add),
        )
      ],
    );
  }
}
