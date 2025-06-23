import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart'; // pub.dev
import 'web_mjpeg_view.dart';  
import 'api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<int> _flameFuture;

  @override
  void initState() {
    super.initState();
    _flameFuture = ApiService.fetchFlame();
  }

@override
Widget build(BuildContext context) {
  final streamUrl = ApiService.streamUrl();
  return Column(
    children: [
      Expanded(
        child: kIsWeb
            ? WebMjpegView(streamUrl: streamUrl)      // ⚡ 웹일 때
            : Mjpeg(                           // 모바일·데스크톱
                stream: streamUrl,
                isLive: true,
                error: (_, err, __) => Center(child: Text('스트림 오류: $err')),
              ),
      ),
      FutureBuilder<int>(
        future: _flameFuture,
        builder: (ctx, snap) {
          final txt = snap.connectionState != ConnectionState.done
              ? '불꽃 상태 확인 중...'
              : (snap.data == 1 ? '🔥 불꽃 감지!' : '정상');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(txt, style: const TextStyle(fontSize: 18)),
          );
        },
      ),
      const SizedBox(height: 8),
    ]);
  }
}
