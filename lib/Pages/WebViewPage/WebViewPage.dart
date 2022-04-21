import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final Completer<WebViewController> _controller= Completer<WebViewController>();

  WebViewPage(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController c){
          _controller.complete(c);
        },
      ),
      // floatingActionButton: ,
    );
  }
}