import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? pc;
  RTCVideoRenderer renderer = RTCVideoRenderer();

  Future<void> init() async {
    await renderer.initialize();
    pc = await createPeerConnection({

    });

    pc!.onTrack = (RTCTrackEvent event){
      if (event.streams.isNotEmpty){
        renderer.srcObject = event.streams.first;
      }
    };
  }
}
