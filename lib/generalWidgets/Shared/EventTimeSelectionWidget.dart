import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Infrastructure/CustomDurationPicker.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';

class EventTimeSelectionWidget extends StatefulWidget {
  final selectedEventStartDateTime;
  final durationMinutes;
  final Function selectStartTimeCallBack;
  final Function selectDurationCallBack;
  EventTimeSelectionWidget(
      this.selectedEventStartDateTime,
      this.durationMinutes,
      this.selectStartTimeCallBack,
      this.selectDurationCallBack);
  @override
  _EventTimeSelectionWidgetState createState() =>
      _EventTimeSelectionWidgetState();
}

class _EventTimeSelectionWidgetState extends State<EventTimeSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          eventStartDateTimeRow,
          WEmptyView(40),
          durationRow,
        ],
      ),
    );
  }

  Widget get eventStartDateTimeRow {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 50),
      width: ScreenUtil().setWidth(610),
      child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          colorBrightness: Brightness.light,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            DatePicker.showDateTimePicker(context, showTitleActions: true,
                // minTime: DateTime.now().add(-Duration(days: 365)),
                // maxTime: DateTime.now().add(Duration(days: 365)),
                onConfirm: (date) {
              widget.selectStartTimeCallBack(date);
            },
                currentTime: DateTime.now().add(Duration(days: 1)),
                locale: LocaleType.en);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.selectedEventStartDateTime != null
                  ? selectEventStartDateTimeText
                  : Text(
                      'Set Start Time',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
              // Icon(
              //   Icons.timer,
              //   color: Theme.of(context).primaryColor,
              // )
            ],
          )),
    );
  }

  Widget get selectEventStartDateTimeText {
    return Container(
      child: Text(
          TextHelper.checkTextIfNullReturnEmpty(
              DateTimeHelper.parseDateTimeToDateHHMM(
                  widget.selectedEventStartDateTime)),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(44),
              color: Colors.white)),
    );
  }

  Widget get durationRow {
    return Container(
      width: ScreenUtil().setWidth(390),
      child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          colorBrightness: Brightness.light,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            DatePicker.showPicker(context,
                pickerModel: CustomDurationPicker(), showTitleActions: true,
                // minTime: DateTime.now().add(-Duration(days: 365)),
                // maxTime: DateTime.now().add(Duration(days: 365)),
                onConfirm: (date) {
              var hours = date.hour;
              var minutes = date.minute;

              widget.selectDurationCallBack(hours * 60 + minutes);
            },
                //currentTime: DateTime.now().add(Duration(days: 1)),
                locale: LocaleType.en);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.durationMinutes != null
                  ? Text(
                      '${widget.durationMinutes} minutes',
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  : Text(
                      'Set Duration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(40),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              // Icon(
              //   Icons.timer,
              //   color: Theme.of(context).primaryColor,
              // )
            ],
          )),
    );
  }
}
