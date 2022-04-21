import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/generalWidgets/GeoLocationBottomSheet.dart';

import '../RemoveBinIconButton.dart';

class SetLocationWidget extends StatefulWidget {
  final String location;
  final Future<GeocodingResponse> googleMapSearchFuture;
  final Function setSearchFutureCallBack;
  final Function manualSetLocationCallBack;
  final Function setLocationByResult;
  final Function removeSelectedLocationCallBack;

  SetLocationWidget(
      this.location,
      this.googleMapSearchFuture,
      this.setLocationByResult,
      this.manualSetLocationCallBack,
      this.setSearchFutureCallBack,
      this.removeSelectedLocationCallBack);

  @override
  State<StatefulWidget> createState() {
    return SetLocationWidgetState();
  }
}

class SetLocationWidgetState extends State<SetLocationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
        constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // SizedBox(
              //   width: 20,
              // ),
              // Icon(
              //   FontAwesomeIcons.mapMarked,
              //   size: ScreenUtil().setWidth(50),
              //   color: Colors.white,
              // ),
              widget.location?.isEmpty ?? true
                  ? Container(
                      //constraints: BoxConstraints(maxWidth: 200),
                      alignment: Alignment.center,
                      child: Text(
                        'Set Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(50)),
                      ),
                    )
                  : Container(
                      constraints:
                          BoxConstraints(maxWidth: ScreenUtil().setWidth(600)),
                      child: Text(
                        TextHelper.checkTextIfNullReturnEmpty(widget.location),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      //margin: EdgeInsets.only(left: 50),
                    ),
              widget.location != null
                  ? RemoveBinIconButton(() {
                      widget.removeSelectedLocationCallBack();
                    })
                  : Container()
            ],
          ),
          onTap: () async {
            final addressController = new TextEditingController();
            await showModalBottomSheet(
                builder: (BuildContext context) {
                  return GeoLocationSearchWidget(
                      addressController,
                      widget.googleMapSearchFuture,
                      widget.setSearchFutureCallBack,
                      widget.manualSetLocationCallBack,
                      widget.setLocationByResult);
                },
                context: context);
          },
        ));
  }
}
