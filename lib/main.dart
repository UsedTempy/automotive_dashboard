import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const CarDashboardApp());
}

class CarDashboardApp extends StatelessWidget {
  const CarDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Dashboard Mockup',
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

class _DashboardScreenState extends State<DashboardScreen> {
  int leftTemp = 22;
  int rightTemp = 22;
  late String currentTime;
  String selectedCenterButton = "gps";

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
      currentTime =
      "$hour12:${now.minute.toString().padLeft(2, '0')} $period";
    });
  }

  void _selectCenterButton(String button) {
    setState(() => selectedCenterButton = button);
  }

  void increaseLeftTemp() => setState(() => leftTemp++);
  void decreaseLeftTemp() => setState(() => leftTemp--);
  void increaseRightTemp() => setState(() => rightTemp++);
  void decreaseRightTemp() => setState(() => rightTemp--);

  String get currentTemperature => "${((leftTemp + rightTemp) / 2).round()}°C";

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
          child: Column(
            children: [
              // Top bar
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: const BoxDecoration(
                  color: Color(0xFF151515),
                  border: Border(bottom: BorderSide(color: Color(0xFF252525))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Automotive Dashboard",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE0E0E0)),
                    ),
                    Row(
                      children: [
                        Text(currentTemperature,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE0E0E0))),
                        const SizedBox(width: 15),
                        Text(currentTime,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE0E0E0))),
                      ],
                    )
                  ],
                ),
              ),
              // Map area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    border: Border(bottom: BorderSide(color: Color(0xFF252525))),
                  ),
                  child: const Center(
                    child: Text(
                      "Map Placeholder",
                      style: TextStyle(color: Colors.white24, fontSize: 24),
                    ),
                  ),
                ),
              ),
              // Climate controls + center buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  border: Border(top: BorderSide(color: Color(0xFF252525))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClimateControl(
                        temp: leftTemp,
                        onIncrease: increaseLeftTemp,
                        onDecrease: decreaseLeftTemp),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CenterButton(
                            icon: FontAwesomeIcons.locationDot,
                            isSelected: selectedCenterButton == "gps",
                            onTap: () => _selectCenterButton("gps")),
                        const SizedBox(width: 12),
                        _CenterButton(
                            icon: FontAwesomeIcons.music,
                            isSelected: selectedCenterButton == "music",
                            onTap: () => _selectCenterButton("music")),
                        const SizedBox(width: 12),
                        _CenterButton(
                            icon: FontAwesomeIcons.camera,
                            isSelected: selectedCenterButton == "camera",
                            onTap: () => _selectCenterButton("camera")),
                      ],
                    ),
                    ClimateControl(
                        temp: rightTemp,
                        onIncrease: increaseRightTemp,
                        onDecrease: decreaseRightTemp),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ClimateControl extends StatefulWidget {
  final int temp;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ClimateControl({
    required this.temp,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
  });

  @override
  State<ClimateControl> createState() => _ClimateControlState();
}

class _ClimateControlState extends State<ClimateControl> {
  bool _hoveringUp = false;
  bool _hoveringDown = false;

  Widget buildArrow({
    required bool hovering,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool clicked = false;

        void handleTap() {
          setLocalState(() => clicked = true);
          onTap();

          // Fade out the click glow
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setLocalState(() => clicked = false);
          });
        }

        return MouseRegion(
          onEnter: (_) => setState(() {
            if (icon == FontAwesomeIcons.chevronUp) _hoveringUp = true;
            else _hoveringDown = true;
          }),
          onExit: (_) => setState(() {
            if (icon == FontAwesomeIcons.chevronUp) _hoveringUp = false;
            else _hoveringDown = false;
          }),
          child: GestureDetector(
            onTap: handleTap,
            child: SizedBox(
              width: 22,
              height: 22,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hover glow
                  AnimatedOpacity(
                    opacity: hovering ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2)
                        ],
                      ),
                    ),
                  ),
                  // Click glow
                  AnimatedOpacity(
                    opacity: clicked ? 0.3 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.4),
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.7),
                              blurRadius: 15,
                              spreadRadius: 5),
                        ],
                      ),
                    ),
                  ),
                  FaIcon(icon, color: color, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease arrow
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: buildArrow(
                hovering: _hoveringDown,
                color: Colors.blue,
                icon: FontAwesomeIcons.chevronDown,
                onTap: widget.onDecrease),
          ),
          // Temperature text right next to fan icon
          SizedBox(
            width: 35,
            child: Center(
                child: Text("${widget.temp}°",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600))),
          ),
          const FaIcon(FontAwesomeIcons.fan, size: 14, color: Colors.white),
          // Increase arrow
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildArrow(
                hovering: _hoveringUp,
                color: Colors.red,
                icon: FontAwesomeIcons.chevronUp,
                onTap: widget.onIncrease),
          ),
        ],
      ),
    );
  }
}

// Center buttons (unchanged)
class _CenterButton extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

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

  bool _hovering = false;

  final double selectedWidth = 20;
  final double hoverWidth = 25;

  @override
  void initState() {
    super.initState();

    // Hover controller for growth of selected blue underline
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _hoverAnim = Tween<double>(begin: selectedWidth, end: hoverWidth).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack),
    );

    // Icon color tween
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _iconColorAnim = ColorTween(
      begin: const Color(0xFF555555), // darker gray
      end: Colors.white70,
    ).animate(_colorController);

    // Bounce controller for selected underline
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnim = Tween<double>(begin: selectedWidth, end: hoverWidth).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Initial state for selected
    if (widget.isSelected) {
      _colorController.value = 1.0;
      _bounceController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(_CenterButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate icon color and play bounce when selected
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _colorController.forward();
        _bounceController.forward(from: 0);
      } else {
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _colorController.dispose();
    _bounceController.dispose();
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

  Color _getGrayColor() {
    if (_hovering) return Colors.grey[300]!; // light gray on hover
    return Colors.grey[700]!; // default darker gray
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
              // Icon with color tween
              AnimatedBuilder(
                animation: _iconColorAnim,
                builder: (_, __) {
                  return FaIcon(
                    widget.icon,
                    size: 22,
                    color: _iconColorAnim.value,
                  );
                },
              ),

              // Gray hover underline (unselected)
              if (!widget.isSelected)
                Positioned(
                  bottom: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    width: _hovering ? hoverWidth : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _getGrayColor(),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),

              // Blue underline for selected (always visible + elastic bounce on select)
              if (widget.isSelected)
                Positioned(
                  bottom: 2,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_hoverController, _bounceController]),
                    builder: (_, __) {
                      // Width is max of hover growth and bounce animation
                      double width = _hoverAnim.value;
                      if (_bounceController.isAnimating) {
                        width = _bounceAnim.value;
                      }
                      return Container(
                        height: 2,
                        width: width,
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
