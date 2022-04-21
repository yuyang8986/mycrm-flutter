import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/generalWidgets/Infrastructure/NetErrorWidget.dart';
import 'package:mycrm/generalWidgets/loadingIndicator.dart';
import 'package:rxdart/rxdart.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
  BuildContext context,
  AsyncSnapshot value,
);

/// FutureBuilder 简单封装，除正确返回和错误外，其他返回 小菊花
/// 错误时返回定义好的错误 Widget，例如点击重新请求
class CustomStreamBuilder<T> extends StatefulWidget {
  final ValueWidgetBuilder<T> builder;
  final Observable<T> stream;
  final Function retryCallback;
  //final Map<String, dynamic> params;

  CustomStreamBuilder(
      {@required this.stream,
      @required this.builder,
      @required this.retryCallback
      //this.params,
      });

  @override
  _CustomStreamBuilderState<T> createState() => _CustomStreamBuilderState<T>();
}

class _CustomStreamBuilderState<T> extends State<CustomStreamBuilder<T>> {
  Observable<T> _observable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      if (!mounted) return;
      _request();
    });
  }

  void _request() {
    setState(() {
      _observable = widget.stream;
    });
  }

  void retry() async {
    await widget.retryCallback();
  }

  @override
  Widget build(BuildContext context) {
    return _observable == null
        ? Container(
            alignment: Alignment.center,
            //  height: ScreenUtil().setWidth(600),
            child: LoadingIndicator(),
          )
        : StreamBuilder(
            stream: _observable,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Container(
                    alignment: Alignment.center,
                    //height: ScreenUtil().setWidth(600),
                    child: Align(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.transparent,
                          child: LoadingIndicator(),
                        ),
                      ),
                    ),
                  );
                case ConnectionState.waiting:
                  return Container(
                    alignment: Alignment.center,
                    // height: ScreenUtil().setWidth(600),
                    child: Align(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.transparent,
                          child: LoadingIndicator(),
                        ),
                      ),
                    ),
                  );
                case ConnectionState.active:
                  // return Container(
                  //   alignment: Alignment.center,
                  //   height: ScreenUtil().setWidth(200),
                  //   child: CupertinoActivityIndicator(),
                  // );
                  if (snapshot.hasData) {
                    return widget.builder(context, snapshot);
                  } else if (snapshot.hasError) {
                    return NetErrorWidget(
                      callback: () {
                        retry();
                      },
                    );
                  }
                  break;
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return widget.builder(context, snapshot);
                  } else if (snapshot.hasError) {
                    return NetErrorWidget(
                      callback: () {
                        retry();
                      },
                    );
                  }
              }
              return Container();
            },
          );
  }
}
