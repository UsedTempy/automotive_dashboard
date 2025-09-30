import 'package:flutter/material.dart';
import 'package:car_dashboard/widgets/bottombar/center_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomBarLayout extends StatefulWidget {
  final Function(bool) onMusicButtonToggle;
  final bool isMusicPlayerVisible;

  const BottomBarLayout({
    super.key,
    required this.onMusicButtonToggle,
    required this.isMusicPlayerVisible,
  });

  @override
  State<BottomBarLayout> createState() => _BottomBarLayoutState();
}

class _BottomBarLayoutState extends State<BottomBarLayout> {
  String selectedCenterButton = "gps";

  void _selectCenterButton(String button) {
    setState(() => selectedCenterButton = button);
    
    // Toggle music player visibility when music button is selected/deselected
    if (button == "music") {
      widget.onMusicButtonToggle(true);
    } else if (widget.isMusicPlayerVisible) {
      widget.onMusicButtonToggle(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF252525))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CenterButton(
            icon: FontAwesomeIcons.locationDot,
            isSelected: selectedCenterButton == "gps",
            onTap: () => _selectCenterButton("gps"),
          ),
          const SizedBox(width: 12),
          CenterButton(
            icon: FontAwesomeIcons.music,
            isSelected: selectedCenterButton == "music",
            onTap: () => _selectCenterButton("music"),
          ),
          const SizedBox(width: 12),
          CenterButton(
            icon: FontAwesomeIcons.camera,
            isSelected: selectedCenterButton == "camera",
            onTap: () => _selectCenterButton("camera"),
          ),
        ],
      ),
    );
  }
}