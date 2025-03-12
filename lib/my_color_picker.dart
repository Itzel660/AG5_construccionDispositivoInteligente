import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;

class MyColorPicker extends StatefulWidget {
  const MyColorPicker({super.key});

  @override
  State<MyColorPicker> createState() => _MyColorPickerState();
}

class _MyColorPickerState extends State<MyColorPicker> {
  String ipESP = "192.168.1.87";
  Timer? _debounce;
  Color currentColor = const Color.fromARGB(255, 7, 255, 73);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setColor(currentColor);
  }

  @override
  Widget build(BuildContext context) {
    return ColorPicker(
      pickerColor: currentColor,
      paletteType: PaletteType.hsl,
      enableAlpha: false,
      onColorChanged: (color) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 70), () {
          setColor(color);
        });
      },
    );
  }

  void setColor(color) async {
    setState(() => currentColor = color);
    int red = (currentColor.r * 255).round();
    int green = (currentColor.g * 255).round();
    int blue = (currentColor.b * 255).round();
    try {
      var url = Uri.parse("http://$ipESP/color?r=$red&g=$green&b=$blue");
      await http.get(url);
    } catch (e) {
      print("Error obteniendo datos: $e");
    }
  }
}
