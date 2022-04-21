import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleInputText extends StatelessWidget {
  final _nameController;
  final labelText;

  TitleInputText(this._nameController, this.labelText);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(20)),
      // decoration: BoxDecoration(
      //     border: Border.all(color: Colors.blue, width: 2),
      //     borderRadius: BorderRadius.circular(10)),
      child:
          // margin: EdgeInsets.all(10),
          Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Container(
            padding: EdgeInsets.all(2),
            //decoration: BoxDecoration(color: Colors.white),
            child: TextFormField(
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              maxLength: 30,
              maxLengthEnforced: true,
              controller: _nameController,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
                  fontWeight: FontWeight.bold),
              decoration: new InputDecoration(
                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.white)),
                  // border: OutlineInputBorder(
                  //     borderSide: BorderSide(
                  //         color: Colors.white,
                  //         width: 0.5,
                  //         style: BorderStyle.solid)),
                  labelText: labelText,
                  labelStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(50))),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter $labelText';
                }
                return null;
              },
            ),
          )),
        ],
      ),
    );
  }
}
