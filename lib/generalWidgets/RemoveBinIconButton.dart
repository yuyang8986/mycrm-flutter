import 'package:flutter/material.dart';

class RemoveBinIconButton extends StatelessWidget {
  RemoveBinIconButton(this.onPress);

  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
          icon: Icon(
            Icons.remove_circle,
            color: Colors.white,
          ),
          onPressed: onPress),
      alignment: Alignment.centerRight,
    );
  }
}
