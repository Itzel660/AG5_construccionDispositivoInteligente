import 'dart:async';
import 'package:dispositivo_inteligente/my_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String ipESP = "192.168.1.87"; // Cambia esto con la IP de tu ESP8266
  double temperatura = 0.0;
  double humedad = 0.0;
  List<Map<String, dynamic>> historial = [];

  @override
  void initState() {
    super.initState();
    getDatos();
    Timer.periodic(Duration(minutes: 5), (Timer t) {
      DatabaseHelper.instance.insertarLectura(temperatura, humedad);
    });
    cargarHistorial();
    Timer.periodic(Duration(seconds: 5), (Timer t) {
      getDatos();
    });
  }

  void getDatos() async {
    try {
      var url = Uri.parse("http://$ipESP/datos");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          temperatura = data["temperatura"];
          humedad = data["humedad"];
        });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clima y LED Control")),
      body: Column(
        children: [
          MyColorPicker(),
          Text("Temperatura: $temperatura°C", style: TextStyle(fontSize: 20)),
          Text("Humedad: $humedad%", style: TextStyle(fontSize: 20)),
          ElevatedButton(onPressed: getDatos, child: Text("Actualizar Datos")),
          Expanded(child: buildChart()),
        ],
      ),
    );
  }

  Widget buildChart() {
    if (historial.isEmpty) return Center(child: Text("No hay datos"));

    return Padding(
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
              spots:
                  historial.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value['temperatura']);
                  }).toList(),
              isCurved: true,
              color: Colors.red,
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots:
                  historial.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value['humedad']);
                  }).toList(),
              isCurved: true,
              color: Colors.blue,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
