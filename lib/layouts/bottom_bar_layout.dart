import 'package:car_dashboard/controllers/camera_controller.dart';
import 'package:car_dashboard/layouts/car_view_layout/tire_pressure_widget.dart';
import 'package:flutter/material.dart';
import 'package:car_dashboard/widgets/bottombar/center_button.dart';
import 'package:provider/provider.dart';

class BottomBarLayout extends StatefulWidget {
  final Function(bool) onMusicButtonToggle;
  final Function(bool) onCarButtonToggle;
  final bool isMusicPlayerVisible;
  final bool isCarModelVisible;

  const BottomBarLayout({
    super.key,
    required this.onMusicButtonToggle,
    required this.isMusicPlayerVisible,
    required this.isCarModelVisible,
    required this.onCarButtonToggle,
  });

  @override
  State<BottomBarLayout> createState() => _BottomBarLayoutState();
}

class _BottomBarLayoutState extends State<BottomBarLayout> {
  String selectedCenterButton = "gps";
  bool isShowingTirePressure = false;

  void _selectCenterButton(String button) {
    if (button == "music") {
      final isCurrentlyVisible = widget.isMusicPlayerVisible;

      widget.onMusicButtonToggle(!isCurrentlyVisible);

      if (!isCurrentlyVisible) widget.onCarButtonToggle(false);

      setState(
          () => selectedCenterButton = !isCurrentlyVisible ? "music" : "gps");
    } else if (button == "tire") {
      // Toggle tire pressure display
      _toggleTirePressure();
      setState(() => selectedCenterButton = "tire");
    } else {
      setState(() => selectedCenterButton = button);

      // Hide music player if visible
      if (widget.isMusicPlayerVisible) widget.onMusicButtonToggle(false);
    }
  }

  void _toggleCarButton() {
    final newState = !widget.isCarModelVisible;

    setState(() {
      if (newState) {
        selectedCenterButton = "gps";
      }
    });

    widget.onCarButtonToggle(newState);
    if (newState && widget.isMusicPlayerVisible) {
      widget.onMusicButtonToggle(false);
    }
  }

  void _toggleTirePressure() {
    final cameraController = context.read<CameraController>();
    isShowingTirePressure = !isShowingTirePressure;
    if (isShowingTirePressure) {
      cameraController.showTirePressure();
      Future.delayed(const Duration(seconds: 1), () {
        toggleTirePressureVisibility(true);
      });
    } else {
      cameraController.setIsometricView();
      toggleTirePressureVisibility(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(
          top: BorderSide(color: Color(0xFF252525)),
          bottom: BorderSide(color: Color(0xFF252525)),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CenterButton(
              icon: Icons.directions_car,
              isSelected: widget.isCarModelVisible,
              onTap: _toggleCarButton,
              activeColor: Colors.blueAccent,
            ),
          ),

          // Center buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CenterButton(
                icon: Icons.location_on,
                isSelected: selectedCenterButton == "gps",
                onTap: () => _selectCenterButton("gps"),
              ),
              const SizedBox(width: 12),
              CenterButton(
                icon: Icons.music_note,
                isSelected: selectedCenterButton == "music",
                onTap: () => _selectCenterButton("music"),
              ),
              const SizedBox(width: 12),
              CenterButton(
                icon: Icons.photo_camera,
                isSelected: selectedCenterButton == "camera",
                onTap: () => _selectCenterButton("camera"),
              ),
              const SizedBox(width: 12),
              CenterButton(
                icon: Icons.tire_repair,
                isSelected: selectedCenterButton == "tire",
                onTap: () => _selectCenterButton("tire"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
