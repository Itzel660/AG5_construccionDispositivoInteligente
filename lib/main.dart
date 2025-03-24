import 'splash_screen.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//para notificaciones locales
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("Notificación tocada: ${response.payload}");
    },
  );

  runApp(MyApp(flutterLocalNotificationsPlugin));
}
class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyApp(this.flutterLocalNotificationsPlugin);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima y LED Control',
      theme: ThemeData.light(), 
      darkTheme: ThemeData.dark(), 
      themeMode: ThemeMode.dark, 
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}