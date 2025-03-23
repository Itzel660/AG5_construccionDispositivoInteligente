import 'dart:async';
import 'package:dispositivo_inteligente/my_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class HomePage extends StatefulWidget {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const HomePage({super.key, required this.flutterLocalNotificationsPlugin});
  

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String ipESP = "192.168.1.71";
  double alarmaTemp = 25.0;
  double alarmaHumedad = 50.0;
  double temperatura = 0.0;
  double humedad = 0.0;
  bool _notificacionesActivadas = true; 
  List<Map<String, dynamic>> historial = [];
  final TextEditingController ipController = TextEditingController();
  int _selectedIndex = 0;

  

@override
void initState() {
  super.initState();
  ipController.text = ipESP;
  getDatos();
  Timer.periodic(Duration(seconds: 5), (Timer t) {
    DatabaseHelper.instance.insertarLectura(temperatura, humedad);
  });
  cargarHistorial();
  Timer.periodic(Duration(seconds: 5), (Timer t) {
    getDatos();
  });

  _crearCanalNotificaciones();
}

void _crearCanalNotificaciones() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'canal_alertas',
    'Alertas Importantes',
    description: 'Canal para notificaciones críticas de alertas',
    importance: Importance.max, // Asegurar que tiene la prioridad más alta
    playSound: true,
    enableLights: true,
    enableVibration: true,
  );

  await widget.flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}



void getDatos() async {
  try {
    var url = Uri.parse("http://$ipESP/sensor");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        temperatura = data["temperatura"];
        humedad = data["humedad"];
      });

      print("Temperatura: $temperatura, Humedad: $humedad");

      if(_notificacionesActivadas){

              if (temperatura > alarmaTemp) {
        print("Temperatura alta, enviando notificación...");
        mostrarNotificacion(
          "Alerta de Temperatura", 
          "La temperatura es elevada: $temperatura°C"
        );
      }

      if (humedad > alarmaHumedad) {
        print("Humedad alta, enviando notificación...");
        mostrarNotificacion(
          "Alerta de Humedad", 
          "La humedad es elevada: $humedad%"
        );
      }

      }



      cargarHistorial();
    }
  } catch (e) {
    print("Error obteniendo datos: $e");
  }
}


  void cargarHistorial() async {
    var datos = await DatabaseHelper.instance.obtenerLecturas();
    setState(() {
      historial = datos;
    });
  }

Future<void> mostrarNotificacion(String titulo, String cuerpo) async {
  print("Intentando mostrar notificación: $titulo - $cuerpo");

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'canal_alertas',
    'Alertas',
    channelDescription: 'Canal para notificaciones de alertas',
    importance: Importance.high,
    priority: Priority.high,
        playSound: true,
    enableLights: true,
    enableVibration: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await widget.flutterLocalNotificationsPlugin.show(
    0,
    titulo,
    cuerpo,
    platformChannelSpecifics,
    payload: 'alerta',
  );
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dispositivo Inteligente")),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat_auto),
            label: "Clima",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny),
            label: "Led",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_repeat),
            label: "Historial",
          ),
          BottomNavigationBarItem(
          icon:Icon(Icons.settings), 
          label: "Configuración",
          ),

        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Column(
 

          

          children: [
                        ElevatedButton(
              onPressed: () {
                mostrarNotificacion("Prueba", "Esto es una notificación de prueba");
              },
              child: Text("Probar Notificación"),
            ),
            
            Padding(padding: const EdgeInsets.all(32.0),),
            Text("Conectado al servidor ESP:", style: TextStyle(fontSize: 15)), 
            Padding(padding:  const EdgeInsets.all(8.0),),
            Text('$ipESP', style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 125, 27, 143)), ),
            Padding(padding: const EdgeInsets.all(40.0),),
            

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              Column(
                children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.thermostat, color: Colors.redAccent, size: 40),
                ),
                SizedBox(height: 8),
                Text(
                  "Temperatura",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$temperatura°C",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ],
              ),
              Column(
                children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.water_drop, color: Colors.blueAccent, size: 40),
                ),
                SizedBox(height: 8),
                Text(
                  "Humedad",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$humedad%",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ],
              ),
              ],
            ),
            
            Padding(padding: const EdgeInsets.all(40.0),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                temperatura > alarmaTemp ? Icons.warning : Icons.check_circle,
                color: temperatura > alarmaTemp ? Colors.yellow : Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                temperatura > alarmaTemp
                  ? "Estado de temperatura: Elevada"
                  : "Estado de temperatura: Correcto",
                style: TextStyle(
                color: temperatura > alarmaTemp ? Colors.yellow : Colors.green,
                fontSize: 16,
                ),
              ),
              ],
            ),
            Padding(padding: const EdgeInsets.all(10.0),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                humedad > alarmaHumedad ? Icons.warning : Icons.check_circle,
                color: humedad > alarmaHumedad ? Colors.yellow : Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                humedad > alarmaHumedad
                  ? "Estado de humedad: Elevada"
                  : "Estado de humedad: Correcta",
                style: TextStyle(
                color: humedad > alarmaHumedad ? Colors.yellow : Colors.green,
                fontSize: 16,
                ),
              ),
              ],
            ),

          ],
        );
      case 1:
        return Column(
          children: [
            Padding(padding: const EdgeInsets.all(20.0),),
            Text("Control de LED", style: TextStyle(fontSize: 20)),
            Padding(padding: const EdgeInsets.all(32.0),),
            MyColorPicker(),
            
          ],
           
          );
      case 2:
        return Column(
          children: [
            Padding(padding: const EdgeInsets.all(32.0),),
            Text("Historial de datos", style: TextStyle(fontSize: 20)),
            buildChart(),

          ],
          

          );
      case 3:
        return Column(
            children: [
            Padding(padding: const EdgeInsets.all(10.0),),
            Text("Configuración", style: TextStyle(fontSize: 30)),
            Padding(padding: const EdgeInsets.all(15.0),),
            Text("Activar Notificaciones", style: TextStyle(fontSize: 16)),
            Switch(
              value: _notificacionesActivadas,
              onChanged: (bool value) {
                setState(() {
                  _notificacionesActivadas = value;
                });
              },
            ),
            Padding(padding:  const EdgeInsets.all(20),),
            Text("IP del dispositivo", style: TextStyle(fontSize: 15)), 
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
              
              children: [
                
                Expanded(
                child: TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                  hintText: "Ingrese la IP del ESP",
                  border: OutlineInputBorder(),
                  ),
                ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                onPressed: () {
                  setState(() {
                  ipESP = ipController.text;
                  });
                },
                child: Text("Actualizar IP"),
                ),
              ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(30.0),),
            
            Text("Establecer alarmas", style: TextStyle(fontSize: 20)),
            Padding(padding:  const EdgeInsets.all(15.0),),
            Text("Alarma de temperatura: $alarmaTemp"),
            
            Slider(
              value: alarmaTemp,
              onChanged: (value) {
              setState(() {
                alarmaTemp = double.parse(value.toStringAsFixed(1));
              });
              },
              min: 0,
              max: 50,
              divisions: 100,
              label: "Alarma de temperatura: $alarmaTemp",
            ),
            Text("Alarma de humedad: $alarmaHumedad"),
            Slider(
              value: alarmaHumedad,
              onChanged: (value) {
              setState(() {
                alarmaHumedad = double.parse(value.toStringAsFixed(1));
              });
              },
              min: 0,
              max: 100,
              divisions: 200,
              label: "Alarma de humedad: $alarmaHumedad",
            ),
          ],
        );
      default:
        return Center(child: Text("Pantalla no encontrada"));
    }
  }

  Widget buildChart() {
    if (historial.isEmpty) return Center(child: Text("No hay datos"));

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2, 
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 22),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: historial.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value['temperatura']);
                }).toList(),
                isCurved: true,
                color: Colors.red,
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: historial.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value['humedad']);
                }).toList(),
                isCurved: true,
                color: Colors.blue,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
