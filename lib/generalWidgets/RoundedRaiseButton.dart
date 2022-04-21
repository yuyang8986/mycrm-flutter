import 'package:flutter/material.dart';

class RoundedRaisedButton extends RaisedButton {
  final Function onPressedCallback;
  final Widget child;
  RoundedRaisedButton(this.onPressedCallback, this.child);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressedCallback,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: child,
    );
  }
}
