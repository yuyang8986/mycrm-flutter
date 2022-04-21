import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoDataWidget extends StatelessWidget {
  final String content;

  NoDataWidget(this.content);
  @override
  Widget build(BuildContext context) {
    return Center(
      //heightFactor: 10,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
        child: Text(
          content,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
        ),
        constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(840)),
      ),
    );
  }
}
