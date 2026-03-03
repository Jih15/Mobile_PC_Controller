import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:mobile_app/app/services/websocket_service.dart';

class ConnectionController extends GetxController{
  final _ws = WebSocketService.to;

  RxBool get isConnected => _ws.isConnected;

  Timer? _reconnectTimer;
  static const _reconnectInterval = Duration(seconds: 3);

  @override
  void onInit() {
    super.onInit();

    ever(isConnected, (bool connected){
      if (!connected) {
        _scheduleReconnect();
      } else {
        _cancelReconnect();
        // log.info('websocket connected');
      }
    });
  }

  Future<void> connect()=> _ws.connect();

  void disconnect() {
    _cancelReconnect();
    _ws.disconnect();
  }

  void reconnect(){
    _ws.disconnect();
    _ws.connect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    // log.info('🔄 Reconnecting in ${_reconnectInterval.inSeconds}s...');

    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) async {
      if (isConnected.value) {
        _cancelReconnect();
        return;
      }
      // log.info('🔄 Attempting reconnect...');
      await _ws.connect();
    });
  }

  void _cancelReconnect(){
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _cancelReconnect();
  }
}