import 'package:car_dashboard/widgets/car_view/gasoline_meter_widget.dart';
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
        height: 140,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text('N', style: TextStyle(fontSize: 50)),
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
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          '40',
                          style: TextStyle(fontSize: 50),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          'KM/H',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox()
              ],
            ),
            Divider(
              thickness: 0.4,
            )
          ],
        ),
      ),
      Positioned(
          top: 0,
          child: Column(
            children: [
              Row(
                children: [
                  FuelMeter(
                    currentLitres: 35,
                    maxLitres: 47,
                    showPercentage: false,
                  )
                ],
              )
            ],
          ))
    ]);
  }
}
