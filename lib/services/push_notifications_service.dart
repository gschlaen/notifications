// SHA1: E0:C5:73:83:15:3C:B9:C5:B7:B4:59:09:A8:03:1A:A8:87:89:8C:53

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static final StreamController<String> _messageStream = StreamController.broadcast();
  // broadcast es para poder escuchar el stream en mas de 1 lugar de la app
  static Stream<String> get mesaggeStream => _messageStream.stream;
  // getter para acceder al stream por fuera de la clase

  static Future _backgroundHandler(RemoteMessage message) async {
    // print('background Handler ${message.messageId}');
    _messageStream.add(message.data['product'] ?? 'No Data');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    // print('onMessage Handler ${message.messageId}');
    _messageStream.add(message.data['product'] ?? 'No Data');
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print('onMessageOpenApp Handler ${message.messageId}');
    _messageStream.add(message.data['product'] ?? 'No Data');
  }

  static Future initializeApp() async {
    // push notifications
    await Firebase.initializeApp();
    // token unico del dispositivo
    token = await FirebaseMessaging.instance.getToken();
    print('token: $token');
    // Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    // local notification
  }

  static closeStreams() {
    _messageStream.close();
    // Se crea la funcion de terminar el stream para que no tire mas
    // el warning, pero en verdad el stream va a estar emitiendo siempre
    // nunca se va a terminar
  }
}
