import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/pages/WebViewPage/WebViewPage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TutorialPageState();
  }
}

class TutorialPageState extends State<TutorialPage> {
  ChewieController _chewieController;
  VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
        'https://etaccountingstorage.blob.core.windows.net/gis/01_contact.mp4');
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      autoInitialize: true,
      placeholder: new Container(
        color: Colors.grey,
      ),
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tutorials"),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Chewie(
                  controller: _chewieController,
                ),
                Container(
                    // padding: EdgeInsets.fromLTRB(0, 40, 10, 10),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/01_contact.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "01. Contact",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40), fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/02_employee.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "02. Employee",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40), fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/03_account.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "03. Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/04_deal.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "04. Dealo",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/05_stage.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "05. Stage",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/06_dashboard.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "06. Dashboard",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _chewieController.dispose();
                          _videoPlayerController.pause();
                          _videoPlayerController = VideoPlayerController.network(
                              'https://etaccountingstorage.blob.core.windows.net/gis/07_schedule.mp4');
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoPlay: true,
                            autoInitialize: true,
                          );
                        });
                      },
                      child: Text(
                        "07. Schedule",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ));
  }
}
