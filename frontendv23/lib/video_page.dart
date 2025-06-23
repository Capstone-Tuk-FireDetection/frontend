import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';
import 'web_mjpeg_view.dart';                 // 웹 전용 <img>→HtmlElementView
import 'package:flutter_mjpeg/flutter_mjpeg.dart'; // 모바일/데스크톱

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});
  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<Map<String, String>> _devicesF; // 장치 목록
  late Future<int> _flameF;                   // 불꽃 값
  String? _selected;                          // 현재 선택된 장치 이름

  @override
  void initState() {
    super.initState();
    _devicesF = ApiService.fetchDevices();    // {espcam1: 192.168..., ...}
    _flameF   = ApiService.fetchFlame();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _devicesF,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data!.isEmpty) {
          return Center(child: Text('장치가 없습니다: ${snap.error ?? ''}'));
        }

        final devices = snap.data!.keys.toList()..sort();
        _selected ??= devices.first;          // 첫 진입 시 0번 선택

        final streamUrl = ApiService.streamUrl(_selected); // /stream/<device>

        return Column(
          children: [
          // ─── 장치 선택 Drop-down ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selected,
                elevation: 2,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                items: devices
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Row(
                            children: [
                              const Icon(Icons.videocam, size: 16),
                              const SizedBox(width: 8),
                              Text(d),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selected = val),
              ),
            ),
          ),
            // ─── 스트림 영역 ───────────────────────────────────────────────
            Expanded(
              child: kIsWeb
                  ? WebMjpegView(streamUrl: streamUrl)     // Edge/Chrome 등 Web
                  : Mjpeg(
                      stream: streamUrl,         // Android/iOS/데스크톱
                      isLive: true,
                      error: (_, err, __) =>
                          Center(child: Text('스트림 오류: $err')),
                    ),
            ),

            // ─── 불꽃 상태 ────────────────────────────────────────────────
            FutureBuilder<int>(
              future: _flameF,
              builder: (ctx, fSnap) {
                final txt = fSnap.connectionState != ConnectionState.done
                    ? '불꽃 상태 확인 중...'
                    : (fSnap.data == 1 ? '🔥 불꽃 감지!' : '정상');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(txt, style: const TextStyle(fontSize: 18)),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
