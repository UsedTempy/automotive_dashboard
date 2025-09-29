import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:car_dashboard/widgets/center_button.dart';

class BottomLeftBarLayout extends StatefulWidget {
  const BottomLeftBarLayout({super.key});

  @override
  State<BottomLeftBarLayout> createState() => BottomLeftBarLayoutState();
}

class BottomLeftBarLayoutState extends State<BottomLeftBarLayout> {
  // Defrost buttons state
  bool frontDefrost = false;
  bool rearDefrost = false;

  void _toggleFrontDefrost() {
    setState(() => frontDefrost = !frontDefrost);
  }

  void _toggleRearDefrost() {
    setState(() => rearDefrost = !rearDefrost);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10, // same bottom as the center buttons/fan
      left: 30, // spacing from the left edge
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CenterButton(
            icon: MdiIcons.carDefrostFront,
            isSelected: frontDefrost,
            onTap: _toggleFrontDefrost,
            activeColor: Colors.yellow,
          ),
          const SizedBox(width: 10),
          CenterButton(
            icon: MdiIcons.carDefrostRear,
            isSelected: rearDefrost,
            onTap: _toggleRearDefrost,
            activeColor: Colors.yellow,
          ),
        ],
      ),
    );
  }
}
