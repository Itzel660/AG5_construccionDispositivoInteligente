import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration(seconds: 3), () {
      
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        Image.asset('assets/nube.png'),
        SizedBox(height: 20),
        Text(
          'Dispositivo Inteligente Cargando...',
          style: TextStyle(color: Colors.purple, fontSize: 15),
        ),
          ],
        ),
      )
    );
  }
}