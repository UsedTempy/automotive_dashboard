import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() {
  runApp(const CarDashboardApp());
}

class CarDashboardApp extends StatelessWidget {
  const CarDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Mockup',
      theme: ThemeData.dark(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late String currentTime;
  String selectedCenterButton = "gps"; // GPS auto selected
  bool fanActive = false;
  double fanSliderValue = 0.5;
  int fanSpeed = 1; // Fan speed setting (1-3)

  // Defrost buttons state
  bool frontDefrost = false;
  bool rearDefrost = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? "PM" : "AM";

    setState(() {
      currentTime = "$hour12:${now.minute.toString().padLeft(2, '0')} $period";
    });
  }

  void _selectCenterButton(String button) {
    setState(() => selectedCenterButton = button);
  }

  void _toggleFan() {
    setState(() => fanActive = !fanActive);
  }

  void _decreaseFanSpeed() {
    if (fanSpeed > 1) {
      setState(() => fanSpeed--);
    }
  }

  void _increaseFanSpeed() {
    if (fanSpeed < 3) {
      setState(() => fanSpeed++);
    }
  }

  void _toggleFrontDefrost() {
    setState(() => frontDefrost = !frontDefrost);
  }

  void _toggleRearDefrost() {
    setState(() => rearDefrost = !rearDefrost);
  }

  Color _getSliderThumbColor(double value) {
    return Color.lerp(Colors.blue, Colors.red, value)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Container(
          width: 1000,
          height: 450,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF252525)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F0F0F),
                        border: Border(
                            bottom: BorderSide(color: Color(0xFF252525))),
                      ),
                      child: const Center(
                        child: Text(
                          "Map Placeholder",
                          style: TextStyle(color: Colors.white24, fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                  // Center buttons row
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF111111),
                      border: Border(top: BorderSide(color: Color(0xFF252525))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _CenterButton(
                          icon: FontAwesomeIcons.locationDot,
                          isSelected: selectedCenterButton == "gps",
                          onTap: () => _selectCenterButton("gps"),
                        ),
                        const SizedBox(width: 12),
                        _CenterButton(
                          icon: FontAwesomeIcons.music,
                          isSelected: selectedCenterButton == "music",
                          onTap: () => _selectCenterButton("music"),
                        ),
                        const SizedBox(width: 12),
                        _CenterButton(
                          icon: FontAwesomeIcons.camera,
                          isSelected: selectedCenterButton == "camera",
                          onTap: () => _selectCenterButton("camera"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating island with time
              Positioned(
                top: 15,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    currentTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
              // Fan button and slider
              Positioned(
                bottom: 10,
                right: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (fanActive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: SizedBox(
                          height: 180,
                          width: 30,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.blue, Colors.red],
                                  ),
                                ),
                              ),
                              _FanSliderThumb(
                                value: fanSliderValue,
                                onChanged: (v) =>
                                    setState(() => fanSliderValue = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          child: fanActive && fanSpeed > 1
                              ? GestureDetector(
                            onTap: _decreaseFanSpeed,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.chevron_left,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          )
                              : null,
                        ),
                        _CenterButton(
                          icon: FontAwesomeIcons.fan,
                          isSelected: fanActive,
                          onTap: _toggleFan,
                          activeColor: Colors.yellow,
                          fanSpeed: fanSpeed,
                        ),
                        SizedBox(
                          width: 28,
                          child: fanActive && fanSpeed < 3
                              ? GestureDetector(
                            onTap: _increaseFanSpeed,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Defrost buttons on left aligned to bottom bar
              Positioned(
                bottom: 10, // same bottom as the center buttons/fan
                left: 30,   // spacing from the left edge
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CenterButton(
                      icon: MdiIcons.carDefrostFront,
                      isSelected: frontDefrost,
                      onTap: _toggleFrontDefrost,
                      activeColor: Colors.yellow,
                    ),
                    const SizedBox(width: 10),
                    _CenterButton(
                      icon: MdiIcons.carDefrostRear,
                      isSelected: rearDefrost,
                      onTap: _toggleRearDefrost,
                      activeColor: Colors.yellow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Fan slider thumb ---
class _FanSliderThumb extends StatefulWidget {
  final double value;
  final Function(double) onChanged;

  const _FanSliderThumb(
      {super.key, required this.value, required this.onChanged});

  @override
  State<_FanSliderThumb> createState() => _FanSliderThumbState();
}

class _FanSliderThumbState extends State<_FanSliderThumb>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
  }

  void _onPress() {
    _scaleController.forward(from: 0);
  }

  void _onRelease() {
    _scaleController.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final trackHeight = constraints.maxHeight;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (details) {
          _onPress();
          double newValue = 1 - (details.localPosition.dy / trackHeight);
          newValue = newValue.clamp(0.0, 1.0);
          widget.onChanged(newValue);
        },
        onVerticalDragUpdate: (details) {
          double newValue = 1 - (details.localPosition.dy / trackHeight);
          newValue = newValue.clamp(0.0, 1.0);
          widget.onChanged(newValue);
        },
        onVerticalDragEnd: (_) => _onRelease(),
        onTapDown: (details) {
          _onPress();
          double newValue = 1 - (details.localPosition.dy / trackHeight);
          newValue = newValue.clamp(0.0, 1.0);
          widget.onChanged(newValue);
        },
        onTapUp: (_) => _onRelease(),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) {
                  double pos = (trackHeight - 20) * widget.value;
                  Color color =
                  Color.lerp(Colors.blue, Colors.red, widget.value)!;
                  return Transform.translate(
                    offset: Offset(0, -pos),
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2)
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

// --- Center button widget with image support ---
class _CenterButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath; // optional image
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final int fanSpeed;

  const _CenterButton({
    this.icon,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.activeColor = Colors.blue,
    this.fanSpeed = 1,
  }) : assert(icon != null || imagePath != null,
  'Either icon or imagePath must be provided');

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnim;
  late AnimationController _colorController;
  late Animation<Color?> _iconColorAnim;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnim;

  bool _hovering = false;
  final double selectedWidth = 20;
  final double hoverWidth = 25;

  @override
  void initState() {
    super.initState();
    _hoverController =
        AnimationController(duration: const Duration(milliseconds: 180), vsync: this);
    _hoverAnim = Tween<double>(begin: selectedWidth, end: hoverWidth).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack));

    _colorController =
        AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _iconColorAnim =
        ColorTween(begin: const Color(0xFF555555), end: Colors.white70)
            .animate(_colorController);

    _bounceController =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _bounceAnim = Tween<double>(begin: selectedWidth, end: hoverWidth).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _rotationController = AnimationController(
        duration: Duration(milliseconds: _getRotationDuration(widget.fanSpeed)),
        vsync: this);
    _rotationAnim = Tween<double>(begin: 0, end: 1).animate(_rotationController);

    if (widget.isSelected) {
      _colorController.value = 1.0;
      _bounceController.forward(from: 0);
      if (widget.icon == FontAwesomeIcons.fan) _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(_CenterButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fanSpeed != oldWidget.fanSpeed &&
        widget.icon == FontAwesomeIcons.fan) {
      _rotationController.duration =
          Duration(milliseconds: _getRotationDuration(widget.fanSpeed));
      if (widget.isSelected) _rotationController.repeat();
    }

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _colorController.forward();
        _bounceController.forward(from: 0);
        if (widget.icon == FontAwesomeIcons.fan) _rotationController.repeat();
      } else {
        _colorController.reverse();
        if (widget.icon == FontAwesomeIcons.fan) {
          _rotationController.stop();
          _rotationController.reset();
        }
      }
    }
  }

  int _getRotationDuration(int speed) {
    switch (speed) {
      case 1:
        return 2000;
      case 2:
        return 1000;
      case 3:
        return 500;
      default:
        return 1500;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _colorController.dispose();
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _hovering = hovering);
    if (hovering) {
      _hoverController.forward();
      if (!widget.isSelected) _colorController.forward();
    } else {
      _hoverController.reverse();
      if (!widget.isSelected) _colorController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_iconColorAnim, _rotationAnim]),
                builder: (_, __) {
                  Widget iconWidget;
                  if (widget.imagePath != null) {
                    iconWidget = Image.asset(
                      widget.imagePath!,
                      width: 22,
                      height: 22,
                      color: widget.isSelected ? widget.activeColor : _iconColorAnim.value,
                    );
                  } else {
                    iconWidget = FaIcon(
                      widget.icon!,
                      size: 22,
                      color: _iconColorAnim.value,
                    );

                    if (widget.icon == FontAwesomeIcons.fan &&
                        widget.isSelected) {
                      iconWidget = Transform.rotate(
                        angle: _rotationAnim.value * 2 * 3.14159,
                        child: iconWidget,
                      );
                    }
                  }
                  return iconWidget;
                },
              ),
              if (!widget.isSelected)
                Positioned(
                  bottom: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    width: _hovering ? hoverWidth : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _hovering ? Colors.grey[300] : Colors.grey[700],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              if (widget.isSelected)
                Positioned(
                  bottom: 2,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_hoverController, _bounceController]),
                    builder: (_, __) {
                      double width = _hoverAnim.value;
                      if (_bounceController.isAnimating) width = _bounceAnim.value;
                      return Container(
                        height: 2,
                        width: width,
                        decoration: BoxDecoration(
                          color: widget.activeColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
