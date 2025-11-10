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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth / 3,
      height: screenHeight,
      child: Stack(
        children: [const ModelWidget(), Positioned(child: const CarTopBar())],
      ),
    );
  }
}
