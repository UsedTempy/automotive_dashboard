import 'package:flutter/material.dart';

class KeyboardController extends ChangeNotifier {
  bool _isVisible = false;
  String _text = "";
  TextEditingController? _activeController;

  bool get isVisible => _isVisible;
  String get text => _text;

  void registerInput(TextEditingController controller) {
    _activeController = controller;
    _text = controller.text;
  }

  void unregisterInput() {
    _activeController = null;
  }

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void addText(String value) {
    _text += value;
    _activeController?.text = _text;
    _activeController?.selection =
        TextSelection.collapsed(offset: _text.length);
    notifyListeners();
  }

  void backspace() {
    if (_text.isEmpty) return;

    _text = _text.substring(0, _text.length - 1);
    _activeController?.text = _text;
    _activeController?.selection =
        TextSelection.collapsed(offset: _text.length);
    notifyListeners();
  }

  void clear() {
    _text = "";
    _activeController?.clear();
    notifyListeners();
  }
}
