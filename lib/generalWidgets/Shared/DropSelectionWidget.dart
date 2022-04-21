import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Models/Core/Activitty/Activity.dart';
import 'package:mycrm/Models/Core/Stage/Stage.dart';
import 'package:mycrm/Styles/GeneralIcons.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';

class CustomDropdownSelection<T> extends StatefulWidget {
  final String title;
  final List<T> listModel;
  T selectedModel;
  final Function onChangedCalllBack;
  final Function createCallBack;
  CustomDropdownSelection(
      this.title, this.listModel, this.selectedModel, this.onChangedCalllBack,
      {@required this.createCallBack});
  @override
  _CustomDropdownSelectionState createState() =>
      _CustomDropdownSelectionState();
}

class _CustomDropdownSelectionState<T>
    extends State<CustomDropdownSelection<T>> {
  var selectedModel;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selectedModel = widget.selectedModel;
    return Container(
      margin: EdgeInsets.all(5),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        // WEmptyView(50),
        Container(
          child: Text(
            "${widget.title}",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(50), fontWeight: FontWeight.bold),
          ),
        ),
        WEmptyView(40),
        Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.white, width: 0),
              color: Theme.of(context).primaryColor,
            ),
            constraints: BoxConstraints(
                // maxWidth: ScreenUtil().setWidth(650),
                minHeight: ScreenUtil().setHeight(120)),
            //height: 40,
            //color: Colors.grey[200],
            child: Theme(
              data: ThemeData(canvasColor: Theme.of(context).primaryColor),
              child: DropdownButton<T>(
                iconDisabledColor: Colors.transparent,
                // disabledHint: Text(
                //   "No Items",
                //   style: TextStyle(color: Colors.white),
                // ),
                underline: Container(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil().setSp(48),
                    fontWeight: FontWeight.bold),
                isDense: true,
                icon: Icon(
                  FontAwesomeIcons.angleDown,
                  color: Colors.white,
                ),
                isExpanded: false,
                hint: Text(
                  "No Item",
                  style: TextStyle(color: Colors.white),
                ),
                items: widget.listModel.map((T selection) {
                  String selectedDisplay = "";
                  switch (selectedModel.runtimeType) {
                    case Activity:
                      selectedDisplay = (selection as Activity).name;
                      break;
                    case Stage:
                      selectedDisplay = (selection as Stage).name;
                      break;

                    default:
                  }
                  return DropdownMenuItem<T>(
                      value: selection,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // WEmptyView(160),

                          Container(
                            width: ScreenUtil().setWidth(400),
                            child: Text(
                              selectedDisplay,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedModel = value;
                  });
                  widget.onChangedCalllBack(value);
                },
                value: selectedModel,
              ),
            )),
        WEmptyView(10),
        !HttpRequest.appUser.isManager
            ? Container()
            : Row(
                children: <Widget>[
                  Container(
                      width: ScreenUtil().setWidth(100),
                      height: ScreenUtil().setHeight(100),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: IconButton(
                            iconSize: ScreenUtil().setWidth(50),
                            icon: GeneralIcons.addIconWhite,
                            onPressed: () {
                              widget.createCallBack();
                            }),
                      ))
                ],
              )
      ]),
    );
  }
}
