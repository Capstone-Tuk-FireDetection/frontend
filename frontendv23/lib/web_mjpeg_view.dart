// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;                     // Web 전용
import 'dart:ui' as ui;                         // 플랫폼 뷰 등록
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebMjpegView extends StatelessWidget {
  final String url;
  const WebMjpegView(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    // kIsWeb 아닌 플랫폼(Android/iOS)에서는 기존 flutter_mjpeg 사용
    if (!kIsWeb) {
      throw UnsupportedError('WebMjpegView is for web only');
    }

    final viewId = 'mjpeg-${url.hashCode}';
    // 1) <img> 요소 등록
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = url                               // MJPEG 스트림 URL
        ..style.objectFit = 'contain'             // 화면에 맞춤
        ..style.width = '100%'
        ..style.height = '100%';
      return img;
    });
    // 2) 위에서 만든 <img> 를 위젯으로 삽입
    return HtmlElementView(viewType: viewId);
  }
}
