import 'dart:async';
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  // Separate timers for each value to prevent interference
  static final Map<String, Timer> _blinkTimers = {};
  static final Map<String, Timer> _resetTimers = {};
  static final Map<String, num> _lastValues = {};
  static final Map<String, bool> _isBlinking = {};
  static final Map<String, int> _blinkCount = {};
  static const int maxBlinks = 2; // Quick blinks for trading
  static const int blinkInterval = 16; // 60fps for smooth animation
  static const int totalDuration = 100; // Short duration but visible enough

  Color blink({required dynamic baseValue, required dynamic compValue}) {
    // Convert values to numeric for accurate comparison
    num currentValue = num.tryParse(baseValue.toString()) ?? 0;
    String key = compValue.toString();

    // Check if value has changed
    bool valueChanged = _lastValues[key] != currentValue;

    if (valueChanged) {
      // Store the new value
      _lastValues[key] = currentValue;

      // Cancel any existing timers for this value
      _blinkTimers[key]?.cancel();
      _resetTimers[key]?.cancel();

      // Reset blink state
      _isBlinking[key] = true;
      _blinkCount[key] = 0;

      // Start new blink timer with faster interval
      _blinkTimers[key] =
          Timer.periodic(Duration(milliseconds: blinkInterval), (timer) {
        _isBlinking[key] = !(_isBlinking[key] ?? false);
        _blinkCount[key] = (_blinkCount[key] ?? 0) + 1;

        // Stop blinking after reaching max blinks
        if (_blinkCount[key]! >= maxBlinks) {
          timer.cancel();
          _isBlinking[key] = false;
          _blinkCount[key] = 0;
        }
      });

      // Set a reset timer to ensure cleanup
      _resetTimers[key] = Timer(Duration(milliseconds: totalDuration), () {
        _blinkTimers[key]?.cancel();
        _isBlinking[key] = false;
        _blinkCount[key] = 0;
      });
    }

    // Determine color based on value change and blink state
    if (_isBlinking[key] == true) {
      num compareValue = num.tryParse(compValue.toString()) ?? 0;

      if (currentValue < compareValue) {
        return Colors.green.withOpacity(.6); // Value increased
      } else if (currentValue > compareValue) {
        return Colors.red.withOpacity(.7); // Value decreased
      }
    }

    return Colors.white;
  }
}
