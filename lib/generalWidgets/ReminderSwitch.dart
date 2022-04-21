import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderSwitch extends StatefulWidget {
  final bool isReminderOn;
  final Function onChanged;
  ReminderSwitch(this.isReminderOn, this.onChanged);
  @override
  _ReminderSwitchState createState() => _ReminderSwitchState();
}

class _ReminderSwitchState extends State<ReminderSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(120),
      //constraints: BoxConstraints(maxWidth: 100),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(5)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.isReminderOn?Colors.green:Colors.grey,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.alarm_on,
            color: widget.isReminderOn ? Colors.green : Colors.white,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Reminder: ' + (widget.isReminderOn ? "On" : "Off"),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          Switch(
            activeColor: Colors.white,
            onChanged: widget.onChanged,
            value: widget.isReminderOn,
          )
        ],
      ),
    );
  }
}
