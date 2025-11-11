import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

class CameraController extends ChangeNotifier {
  three.Camera? _camera;
  VoidCallback? _onToggleTirePressure;
  bool _isAnimating = false;
  three.Vector3 _currentLookAt = three.Vector3(0, 0.7, 0.56);

  void setCamera(three.Camera camera) {
    _camera = camera;
    notifyListeners();
  }

  three.Camera? get camera => _camera;

  void setTirePressureToggle(VoidCallback callback) {
    _onToggleTirePressure = callback;
  }

  Future<void> _animateCamera({
    required three.Vector3 targetPosition,
    required three.Vector3 targetLookAt,
    int durationMs = 600,
    bool toggleTirePressureAfter = false,
  }) async {
    if (_camera == null || _isAnimating) return;
    _isAnimating = true;

    final startPos = _camera!.position.clone();
    final startTarget = _currentLookAt.clone();
    const steps = 60;
    final dt = durationMs ~/ steps;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final easedT = Curves.easeInOut.transform(t);

      final currentPos = three.Vector3(
        _lerp(startPos.x, targetPosition.x, easedT),
        _lerp(startPos.y, targetPosition.y, easedT),
        _lerp(startPos.z, targetPosition.z, easedT),
      );

      final currentLook = three.Vector3(
        _lerp(startTarget.x, targetLookAt.x, easedT),
        _lerp(startTarget.y, targetLookAt.y, easedT),
        _lerp(startTarget.z, targetLookAt.z, easedT),
      );

      _camera!.position.setFrom(currentPos);
      _camera!.lookAt(currentLook);
      notifyListeners();

      await Future.delayed(Duration(milliseconds: dt));
    }

    _currentLookAt = targetLookAt.clone();
    _isAnimating = false;

    if (toggleTirePressureAfter) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _onToggleTirePressure?.call();
      });
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  Future<void> showTirePressure() async {
    await _animateCamera(
      targetPosition: three.Vector3(0, 10, -4),
      targetLookAt: three.Vector3(0, 1.5, 0),
      durationMs: 800,
      toggleTirePressureAfter: true,
    );
  }

  Future<void> setIsometricView() async {
    await _animateCamera(
      targetPosition: three.Vector3(2.8, 2.2, 8.5),
      targetLookAt: three.Vector3(0, 0.7, 0.56),
      durationMs: 800,
      toggleTirePressureAfter: true,
    );
  }
}
