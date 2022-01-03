import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:notifications/screens/home_screen.dart';
import 'package:notifications/screens/message_screen.dart';
import 'package:notifications/services/push_notifications_service.dart';

void main() async {
  // Este metodo asegura que se construya un context antes de
  // que se ejecute la siguiente linea que necesita de ciertos widgets
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Se convirtio en StatefulWidget para poder tener acceso al Context
    // y poder escuchar el stream desde el inicio de la app

    // Para que la notificacion navegue si la app esta cerrada. Sin esto
    // no navega al hacer click
    PushNotificationService.messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final snackBar = SnackBar(content: Text(message.data['product']));
        messengerKey.currentState?.showSnackBar(snackBar);
        navigatorKey.currentState?.pushNamed('message', arguments: message.data['product']);
      }
    });

    PushNotificationService.mesaggeStream.listen((message) {
      // print('MyApp: $message');
      // Navigator.pushNamed(context, 'massage');
      // Navogator no funciona porque en este punto de la app el contexto
      // no tiene la creacion de MaterialApp. Por eso se usan GlobalKeys
      final snackBar = SnackBar(content: Text(message));
      messengerKey.currentState!.showSnackBar(snackBar);
      // Guarda la referencia a MaterialApp para que el metodo se ejecute
      //ni bien se crea el widget MaterialApp
      navigatorKey.currentState!.pushNamed('message', arguments: message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'home',
      navigatorKey: navigatorKey, // Navegacion
      scaffoldMessengerKey: messengerKey, // Snacks
      routes: {
        'home': (_) => const HomeScreen(),
        'message': (_) => const MessageScreen(),
      },
    );
  }
}
