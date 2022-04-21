import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Function onFresh;

  ErrorPage(this.onFresh);
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onFresh,
      child: Container(
        constraints: BoxConstraints(maxWidth: 300),
        alignment: FractionalOffset.center,
        child: Center(
          child: Text(
              "Oops, something went wrong when loading the content, please pull to refresh"),
        ),
      ),
    );
  }
}
