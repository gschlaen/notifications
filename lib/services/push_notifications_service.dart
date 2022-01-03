// SHA1: E0:C5:73:83:15:3C:B9:C5:B7:B4:59:09:A8:03:1A:A8:87:89:8C:53

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static final StreamController<String> _messageStream = StreamController.broadcast();
  // broadcast es para poder escuchar el stream en mas de 1 lugar de la app
  static Stream<String> get mesaggeStream => _messageStream.stream;
  // getter para acceder al stream por fuera de la clase

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future _backgroundHandler(RemoteMessage message) async {
    // print('background Handler ${message.messageId}');
    _messageStream.add(message.data['product'] ?? 'No Data');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    // print('onMessage Handler ${message.messageId}');

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    RemoteNotification? notification = message.notification;
    String iconName = const AndroidInitializationSettings('@mipmap/ic_launcher').defaultIcon.toString();

    // Si `onMessage` es activado con una notificación, construimos nuestra propia
    // notificación local para mostrar a los usuarios, usando el canal creado.
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: iconName,
            ),
          ));
    }

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
