import 'package:flutter/material.dart';

class TopRightNumberNotifier extends StatelessWidget {
  final int number;
  final Widget bottomWidget;
  TopRightNumberNotifier(this.number, this.bottomWidget);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        bottomWidget,
        number > 0
            ? Positioned(
                child: Container(
                    width: 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).primaryColorDark),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    )),
                right: 0,
                top: -1,
              )
            : Container()
      ],
    );
  }
}
