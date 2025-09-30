import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CenterButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath; // optional image
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final int fanSpeed;

  const CenterButton({
    this.icon,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.activeColor = Colors.blue,
    this.fanSpeed = 1,
  }) : assert(icon != null || imagePath != null,
  'Either icon or imagePath must be provided');

  @override
  State<CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<CenterButton>
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
    _hoverController = AnimationController(
        duration: const Duration(milliseconds: 180), vsync: this);
    _hoverAnim = Tween<double>(begin: selectedWidth, end: hoverWidth).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack));

    _colorController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _iconColorAnim =
        ColorTween(begin: const Color(0xFF555555), end: Colors.white70)
            .animate(_colorController);

    _bounceController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _bounceAnim = Tween<double>(begin: selectedWidth, end: hoverWidth).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _rotationController = AnimationController(
        duration: Duration(milliseconds: _getRotationDuration(widget.fanSpeed)),
        vsync: this);
    _rotationAnim =
        Tween<double>(begin: 0, end: 1).animate(_rotationController);

    if (widget.isSelected) {
      _colorController.value = 1.0;
      _bounceController.forward(from: 0);
      if (widget.icon == FontAwesomeIcons.fan) _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(CenterButton oldWidget) {
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
                      color: widget.isSelected
                          ? widget.activeColor
                          : _iconColorAnim.value,
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
                    animation:
                    Listenable.merge([_hoverController, _bounceController]),
                    builder: (_, __) {
                      double width = _hoverAnim.value;
                      if (_bounceController.isAnimating)
                        width = _bounceAnim.value;
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