import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:permission_handler/permission_handler.dart' as prefix0;
import '../../Models/Core/Pipeline/Pipeline.dart';
import '../../Models/Core/contact/Company.dart';
import '../../infrastructure/TextHelper.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

class CompanyDetailPage extends StatefulWidget {
  @override
  _CompanyDetailPageState createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage> {
  Company company;
  Completer<GoogleMapController> _controller = Completer();
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  // Address latlng;
  @override
  Widget build(BuildContext context) {
    company = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: GeneralAppBar(null, 'Company Info', null, null, null).create(),
        body: SingleChildScrollView(
            child: Center(
          child: _companyDetailContainer,
        )));
  }

  @override
  void initState() {
    super.initState();
  }

  Widget get _companyDetailContainer {
    var peoples = company.peoples;
    List<Pipeline> allCompanyPipelines = List<Pipeline>();
    for (var people in peoples) {
      allCompanyPipelines.addAll(people.pipelines);
    }
    if (company?.pipelines != null) {
      if (company.pipelines.length > 0) {
        allCompanyPipelines.addAll(company.pipelines);
      }
    }
    return Container(
      constraints: BoxConstraints(maxHeight: 800, minHeight: 600),
      margin: EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          Card(
            color: Colors.green,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: Text(
                  TextHelper.checkTextIfNullReturnEmpty(
                      '${company.name.toUpperCase().substring(0, 1)}'),
                  style: TextStyle(
                      color: AppColors.normalTextColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(company.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),

              //subtitle: Text('contact(Test)'),
            ),
          ),
          allCompanyPipelines == null
              ? Center(
                  child: Text('No Deals Data'),
                )
              : Expanded(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Location:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(TextHelper.checkTextIfNullReturnTBD(
                            company.location)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Email Address:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            TextHelper.checkTextIfNullReturnTBD(company.email)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Email Address (Secondary):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(TextHelper.checkTextIfNullReturnTBD(
                            company.secondaryEmail)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Contact Number:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            TextHelper.checkTextIfNullReturnTBD(company.phone)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Contact Number (Secondary):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(TextHelper.checkTextIfNullReturnTBD(
                            company.secondaryPhone)),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Deals:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        allCompanyPipelines.length != 0
                            ? Expanded(
                                child: SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: allCompanyPipelines?.length ?? 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _pipelineCard(
                                        allCompanyPipelines[index]);
                                  },
                                ),
                              ))
                            : Container(),
                        VEmptyView(30),
                        FutureBuilder(
                          future: _getLatlng(),
                          builder: (ctx, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            CameraPosition cameraPosition =
                                snapshot.data as CameraPosition;

                            return _googleMapView(cameraPosition);
                          },
                        ),
                        VEmptyView(30)
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _pipelineCard(Pipeline pipeline) {
    return Card(
      child: Container(
        // height: 60,
        constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(500)),
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Deal Name: ${pipeline.dealName}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(40)),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Deal Amount: \$${pipeline.dealAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(40)),
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Contact Person: " +
                      TextHelper.checkTextIfNullReturnTBD(
                          pipeline.people?.name),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Stage: ${pipeline.stage.name}',
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            VEmptyView(20)
          ],
        ),
      ),
    );
  }

  Widget _googleMapView(CameraPosition cameraPosition) {
    //_getLatlng();

    return Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        height: 200,
        child: GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                  markerId: MarkerId(company.id.toString()),
                  position: LatLng(cameraPosition.target.latitude,
                      cameraPosition.target.longitude),
                  infoWindow: InfoWindow(title: company.name.toString())),
            }));
  }

  Future _getLatlng() async {
    print("get Latlng for company");
    PermissionStatus permissionawait =
        await LocationPermissions().requestPermissions();
    if (permissionawait == PermissionStatus.granted) {
      if (company.location != null) {
        var address =
            await Geocoder.local.findAddressesFromQuery(company.location);
        var latlng = address.first;
        var initPostion = CameraPosition(
            target: LatLng(
                latlng.coordinates.latitude, latlng.coordinates.longitude),
            zoom: 15);
        return initPostion;
      } else {
        //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
        var initPostion;
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        initPostion = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15);

        return initPostion;
      }
    }
  }
}
