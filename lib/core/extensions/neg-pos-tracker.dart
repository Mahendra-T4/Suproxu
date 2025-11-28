import 'dart:async';
import 'package:flutter/material.dart';

extension ColorNPExtension on Color {
  // Static variables for managing blink state
  static Timer? _blinkTimer;
  static bool _isBlinking = false;
  static num? _lastValue;

  // Constants for timing
  static const int blinkDuration = 300; // Total time the color shows for

  Color valueColor(num value) {
    // Check if value has changed
    if (_lastValue != value) {
      _lastValue = value;
      _isBlinking = true;

      // Cancel existing timer if any
      _blinkTimer?.cancel();

      // Set timer to stop blinking
      _blinkTimer = Timer(const Duration(milliseconds: blinkDuration), () {
        _isBlinking = false;
        _blinkTimer = null;
      });

      // Return color based on value when blinking
      if (value.toString().contains('-')) {
        return Colors.red.withOpacity(0.7); // Negative value
      } else if (value > 0) {
        return Colors.green.withOpacity(0.7); // Positive value
      }
    }

    // Default color when not blinking or no change
    return Colors.white;
  }
}
