import 'package:car_dashboard/layouts/car_view_layout/tire_pressure_widget.dart';
import 'package:car_dashboard/widgets/car_view/3d_model_widget.dart';
import 'package:car_dashboard/widgets/car_view/top_bar.dart';
import 'package:flutter/material.dart';

class ModelLayout extends StatefulWidget {
  const ModelLayout({super.key});

  @override
  State<ModelLayout> createState() => ModelLayoutState();
}

class ModelLayoutState extends State<ModelLayout> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModelWidget(),
        const Positioned(child: CarTopBar()),
        TirePressureWidget(),
      ],
    );
  }
}
