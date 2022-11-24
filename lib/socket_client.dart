import 'dart:async';
import 'dart:developer';

import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

class CallClient {
  static CallClient? _instance;

  factory CallClient() => _instance ??= CallClient._();

  late final Socket _socket;

  Socket get socket => _socket;

  CallClient._() {
    _socket = io(
      'ws://123.31.12.162:3005',
      OptionBuilder().setTransports(['websocket']).build(),
    );
    _socket.connect();
    // _socket.onConnect((_) {
    //   print('connected');
    // });

    _listenEvents();

    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        ping();
      },
    );
  }

  final _uuid = const Uuid();
  show() async {
    final _currentUuid = _uuid.v4();
    var params = <String, dynamic>{
      'id': _currentUuid,
      'nameCaller': 'Hướng Đoàn',
      'appName': 'Callkit',
      'avatar': 'https://i.pravatar.cc/100',
      'type': 0,
      'textAccept': 'Accept',
      'textDecline': 'Decline',
      'textMissedCall': 'Missed call',
      'textCallback': 'Call back',
      'duration': 30000,
      'extra': <String, dynamic>{'userId': '1a2b3c4d'},
      'headers': <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      'android': <String, dynamic>{
        'isCustomNotification': true,
        'isShowLogo': false,
        'isShowCallback': false,
        'isShowMissedCallNotification': true,
        'ringtonePath': 'system_ringtone_default',
        'backgroundColor': '#0955fa',
        'backgroundUrl': 'https://i.pravatar.cc/500',
        'actionColor': '#4CAF50'
      },
      'ios': <String, dynamic>{
        'iconName': 'CallKitLogo',
        'handleType': 'generic',
        'supportsVideo': true,
        'maximumCallGroups': 2,
        'maximumCallsPerCallGroup': 1,
        'audioSessionMode': 'default',
        'audioSessionActive': true,
        'audioSessionPreferredSampleRate': 44100.0,
        'audioSessionPreferredIOBufferDuration': 0.005,
        'supportsDTMF': true,
        'supportsHolding': true,
        'supportsGrouping': false,
        'supportsUngrouping': false,
        'ringtonePath': 'system_ringtone_default'
      }
    };
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  _listenEvents() {
    _socket.onConnect(_onConnectHandler);
    _socket.onConnectError(_onConnectErrorHandler);
    _socket.onConnectTimeout(_onConnectTimeoutHandler);
    _socket.onDisconnect(_onDisconnectHandler);
    _socket.onError(_onErrorHandler);
    _socket.on('pingpong', (data) => _log('receive: ', data));
    _socket.on('test', (data) async {
      show();
      _log('receive test: ', data);
    });
  }

  _onConnectHandler(dynamic value) => _log('connected to server', value);

  _onConnectErrorHandler(dynamic value) =>
      _log('ConnectError', value.toString());

  _onConnectTimeoutHandler(dynamic value) =>
      _log('ConnectTimeout', value.toString());

  _onDisconnectHandler(dynamic value) => _log('Disconnect', value);
  _onErrorHandler(dynamic value) => _log('Error', value);

  _log(String type, String? msg) {
    log("$type: $msg", name: 'Socket');
  }

  ping() {
    _log('send', 'ping');
    socket.emit('pingpong', DateTime.now().toString());
  }

  late Timer timer;

  static dispose() {
    // Memory leak issues in iOS when closing socket.
    // https://pub.dev/packages/socket_io_client#:~:text=Memory%20leak%20issues%20in%20iOS%20when%20closing%20socket.%20%23
    _instance?._socket.dispose();
  }
}
