import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/Pipeline/PipelineListBloc.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Dto/FileItemDto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:open_file/open_file.dart';

class _TaskInfo {
  final String name;
  final String link;

  _TaskInfo({this.name, this.link});
}

class FileDownloadPage extends StatefulWidget {
  final List<FileItemDto> files;
  final Pipeline pipeline;
  final PipelineListBloc pipelineListBloc;

  FileDownloadPage(
      {this.files, @required this.pipeline, @required this.pipelineListBloc});
  @override
  State<StatefulWidget> createState() {
    return FileDownloadPageState();
  }
}

// class GoogleHttpClient extends IOClient {
//   Map<String, String> _headers;

//   GoogleHttpClient(this._headers) : super();

//   @override
//   Future<StreamedResponse> send(BaseRequest request) =>
//       super.send(request..headers.addAll(_headers));

//   @override
//   Future<prefix1.Response> head(Object url, {Map<String, String> headers}) =>
//       super.head(url, headers: headers..addAll(_headers));
// }

class FileDownloadPageState extends State<FileDownloadPage> {
  Dio dio = new Dio();
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, type: ProgressDialogType.Download);
    pr.style(
      message: 'Downloading file...',
      borderRadius: 10,
      backgroundColor: Colors.white,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(title: Text("Attached File")),
        body: Container(
            child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(120.0),
                  1: FixedColumnWidth(20.0),
                  2: FixedColumnWidth(300.0)
                },
                children: <TableRow>[
                  TableRow(children: <Widget>[
                    TableCell(
                      child: Text('Deal Name'),
                    ),
                    TableCell(
                      child: Text(
                        ':',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    TableCell(
                      child: Text(widget.pipeline.dealName),
                    )
                  ]),
                  TableRow(children: <Widget>[
                    TableCell(
                      child: Text('Deal Amount'),
                    ),
                    TableCell(
                      child: Text(':', textAlign: TextAlign.left),
                    ),
                    TableCell(
                      child: Text(widget.pipeline.dealAmount.toString()),
                    )
                  ]),
                  TableRow(children: <Widget>[
                    TableCell(
                      child: Text('Company Name'),
                    ),
                    TableCell(
                      child: Text(':', textAlign: TextAlign.left),
                    ),
                    TableCell(
                      child: Text(
                        (widget.pipeline.people != null
                            ? (widget.pipeline.people?.company?.name ?? "") +
                                (widget.pipeline.people?.company?.isDeleted ??
                                        false
                                    ? " (former)"
                                    : "")
                            : (widget.pipeline.company?.name ?? "") +
                                (widget.pipeline.company?.isDeleted ?? false
                                    ? " (former)"
                                    : "")),
                      ),
                    )
                  ]),
                  TableRow(children: <Widget>[
                    TableCell(
                      child: Text('Contact Name'),
                    ),
                    TableCell(
                      child: Text(':', textAlign: TextAlign.left),
                    ),
                    TableCell(
                      child: widget.pipeline.people != null
                          ? Text(widget.pipeline.people.name)
                          : Text("TBD"),
                    )
                  ])
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 1), bottom: BorderSide(width: 1))),
              child: Text(
                "List of attached file(s)",
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                  margin: EdgeInsets.all(10),
                  child: widget.files != null
                      ? ListView.builder(
                          itemCount: widget.files.length,
                          itemBuilder: (context, index) {
                            FileItemDto fileItemDto = widget.files[index];
                            return Card(
                                elevation: 5,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: InkWell(
                                    onTap: () async {
                                      await _doDownloadOperation(
                                          fileItemDto.url, fileItemDto.name);
                                    },
                                    child: Text(fileItemDto.name),
                                  ),
                                ));
                          },
                        )
                      : Container()),
            )
          ],
        )));
  }

  Future _doDownloadOperation(String url, String name) async {
    CancelToken cancelToken = CancelToken();
    try {
      dio.interceptors.add(LogInterceptor());
      var isPermissionReady = await _checkPermission();
      if (isPermissionReady) {
        var downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
        await dio.download(url, ('${downloadsDirectory.path}' + '/' + name),
            onReceiveProgress: showDownloadProgress, cancelToken: cancelToken);
        OpenFile.open('${downloadsDirectory.path}' + '/' + name);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Download Failed:' + e.toString());
    }
  }

  void showDownloadProgress(int received, int total) {
    try {
      if (total != -1) {
        //print((received / total * 100).toStringAsFixed(0) + "%");
        pr.show();
        pr.update(
          progress: received / total * 100.round(),
        );
        if (received / total * 100.round() == 100) {
          pr.hide();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _checkPermission() async {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    return false;
  }
}
