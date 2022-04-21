import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mycrm/Styles/TextStyles.dart';

class TextHelper {
  static String checkTextIfNullReturnEmpty(String text) {
    if (text == null) return '';
    return text;
  }

  static String checkTextIfNullReturnTBD(String text) {
    if (text == null) return 'TBD';
    return text;
  }

  static Widget checkTextIfNullOrEmptyReturnEmptyContainer(String text) {
    if (text == null || text.isEmpty ?? true) return Container();
    return Text(
      text,
      style: TextStyles.setRelationTextStyle,
    );
  }

  static Widget checkTextIfNullOrEmptyReturnTitleWithRedTBDRow(
      String title, String content) {
    if (content == null || content.isEmpty ?? true)
      return Row(
        children: <Widget>[
          Text(title),
          Text(
            ' :TBD',
            style: TextStyle(color: Colors.red),
          )
        ],
      );
    return Text(title + ": " + content);
  }
}
