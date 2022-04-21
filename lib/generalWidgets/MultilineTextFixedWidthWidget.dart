import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MultilineFixedWidthWidget extends StatelessWidget {
  final List<Widget> widgets;
  MultilineFixedWidthWidget(this.widgets);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(800)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets),
    );
  }
}
