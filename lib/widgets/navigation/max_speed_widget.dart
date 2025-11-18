import 'package:flutter/material.dart';

class MaxSpeedWidget extends StatefulWidget {
  const MaxSpeedWidget({super.key});

  @override
  State<MaxSpeedWidget> createState() => MaxSpeedWidgetState();
}

class MaxSpeedWidgetState extends State<MaxSpeedWidget> {
  final size = 28.00;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        child: CircleAvatar(
          backgroundColor: Colors.red[800],
          radius: size,
        ),
      ),
      Positioned(
        bottom: 6,
        left: 6,
        child: CircleAvatar(
          radius: size - 6,
          backgroundColor: const Color.fromARGB(255, 192, 192, 192),
          child: Text(
            '60',
            style: TextStyle(color: Colors.black, fontFamily: 'anwb'),
          ),
        ),
      ),
    ]);
  }
}
