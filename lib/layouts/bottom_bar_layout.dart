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
  bool _isTireAnimating = false;

  void _selectCenterButton(String button) {
    if (button == "music") {
      final isCurrentlyVisible = widget.isMusicPlayerVisible;

      widget.onMusicButtonToggle(!isCurrentlyVisible);

      if (!isCurrentlyVisible) widget.onCarButtonToggle(false);

      setState(
          () => selectedCenterButton = !isCurrentlyVisible ? "music" : "gps");
    } else if (button == "tire") {
      if (!widget.isCarModelVisible || _isTireAnimating) return;
      _toggleTirePressure();
    } else {
      setState(() => selectedCenterButton = button);
      if (widget.isMusicPlayerVisible) widget.onMusicButtonToggle(false);
    }
  }

  void _toggleCarButton() {
    final newState = !widget.isCarModelVisible;

    setState(() {
      if (newState) {
        selectedCenterButton = "gps";
      } else {
        if (isShowingTirePressure) {
          isShowingTirePressure = false;
          toggleTirePressureVisibility(false);
          final cameraController = context.read<CameraController>();
          cameraController.setIsometricView();
        }

        if (selectedCenterButton == "tire") {
          selectedCenterButton = "gps";
        }
      }
    });

    widget.onCarButtonToggle(newState);

    if (newState && widget.isMusicPlayerVisible) {
      widget.onMusicButtonToggle(false);
    }
  }

  Future<void> _toggleTirePressure() async {
    if (_isTireAnimating) return;

    setState(() => _isTireAnimating = true);

    final cameraController = context.read<CameraController>();
    final newState = !isShowingTirePressure;
    isShowingTirePressure = newState;
    setState(() => selectedCenterButton = newState ? "tire" : "gps");

    try {
      if (newState) {
        Future.delayed(const Duration(seconds: 1), () {
          toggleTirePressureVisibility(true);
        });

        await cameraController.showTirePressure();
      } else {
        toggleTirePressureVisibility(false);
        await cameraController.setIsometricView();
      }
    } finally {
      if (mounted) {
        setState(() => _isTireAnimating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTireButtonEnabled = widget.isCarModelVisible && !_isTireAnimating;

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
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CenterButton(
                icon: Icons.directions_car,
                isSelected: widget.isCarModelVisible,
                onTap: _toggleCarButton,
                activeColor: Colors.blueAccent,
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
                isEnabled: isTireButtonEnabled,
                onTap: () => _selectCenterButton("tire"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
