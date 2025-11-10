import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CarTopBar extends StatefulWidget {
  const CarTopBar({super.key});

  @override
  State<CarTopBar> createState() => CarTopBarState();
}

class CarTopBarState extends State<CarTopBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '40',
                  style: TextStyle(fontSize: 58),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'KM/H',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white.withOpacity(0.5)),
                )
              ],
            ),
            Divider(
              thickness: 0.4,
            )
          ],
        ),
      ),
      Positioned(
          left: 50,
          top: 25,
          child: Column(
            children: [
              Row(
                children: [
                  Text('N', style: TextStyle(fontSize: 35)),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Symbols.auto_transmission,
                    color: Colors.white.withOpacity(0.5),
                  )
                ],
              )
            ],
          ))
    ]);
  }
}
