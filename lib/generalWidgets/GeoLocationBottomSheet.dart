import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Pages/NoDataPage/NoDataPage.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';

class GeoLocationSearchWidget extends StatefulWidget {
  final TextEditingController addressController;
  final Future<GeocodingResponse> googleMapSearchFuture;
  final Function setSearchFutureCallBack;
  final Function manualSetLocationCallBack;
  final Function setLocationByResult;
  GeoLocationSearchWidget(
      this.addressController,
      this.googleMapSearchFuture,
      this.setSearchFutureCallBack,
      this.manualSetLocationCallBack,
      this.setLocationByResult);
  @override
  _GeoLocationSearchWidgetState createState() =>
      _GeoLocationSearchWidgetState();
}

class _GeoLocationSearchWidgetState extends State<GeoLocationSearchWidget> {
  bool searching;

  @override
  void initState() {
    searching = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.5,
      maxChildSize: 1,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
            child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(hintText: 'Search Address'),
                controller: widget.addressController,
                autofocus: true,
                onEditingComplete: () {
                  setState(() {
                    searching = true;
                  });
                  if (widget.addressController.text == '') return;
                  FocusScope.of(context).unfocus();
                  widget.setSearchFutureCallBack(widget.addressController);
                },
                // onChanged: (value) {
                //   if (value == '') return;
                //   setState(() {
                //     addressSearchTerm = value;
                //   });
                // },
              ),
            ),
            FutureBuilder(
              future: widget.googleMapSearchFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    var addressResponse = snapshot.data as GeocodingResponse;
                    return Expanded(
                      child: addressResponse.status == "ZERO_RESULTS" &&
                              searching
                          ? Center(
                              child: Column(
                              children: <Widget>[
                                VEmptyView(100),
                                Text('No matched address found.'),
                                RaisedButton(
                                  child: Text(
                                    'Add this address manually',
                                    style: TextStyles.whiteText,
                                  ),
                                  onPressed: () {
                                    widget.manualSetLocationCallBack(
                                        widget.addressController);
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ))
                          : ListView.builder(
                              itemCount: addressResponse.results.length,
                              itemBuilder: (BuildContext context, int index) {
                                return addressResponse.results.length == 0 ||
                                        (addressResponse.results.length == 1 &&
                                            addressResponse.results.single
                                                    .formattedAddress ==
                                                'Australia' &&
                                            widget.addressController.text
                                                    .length >
                                                0)
                                    ? Center(
                                        child: Column(
                                        children: <Widget>[
                                          Text('No matched address found.'),
                                          RaisedButton(
                                            child: Text(
                                              'Add this address manually',
                                              style: TextStyles.whiteText,
                                            ),
                                            onPressed: () {
                                              widget.manualSetLocationCallBack(
                                                  widget.addressController);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ))
                                    : ListTile(
                                        onTap: () {
                                          widget.setLocationByResult(
                                              addressResponse, index);

                                          Navigator.pop(context);
                                        },
                                        leading: Text(TextHelper
                                            .checkTextIfNullReturnEmpty(
                                                addressResponse.results[index]
                                                    .formattedAddress)));
                              }),
                    );
                  }
                  return NoDataWidget("No Address Found");
                } else {
                  return Container();
                }
              },
            )
          ],
        ));
      },
    );
  }
}
