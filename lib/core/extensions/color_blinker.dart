import 'dart:async';
import 'package:flutter/material.dart';
import 'package:suproxu/core/extensions/textstyle.dart';


class BlinkingPriceText extends StatefulWidget {
  final String text; // Text to display (e.g., price)
  final num currentValue; // Current price/value
  final num compareValue; // Previous price/value for comparison
  final String assetId; // Unique identifier for tracking

  const BlinkingPriceText({
    Key? key,
    required this.text,
    required this.currentValue,
    required this.compareValue,
    required this.assetId,
  }) : super(key: key);

  @override
  _BlinkingPriceTextState createState() => _BlinkingPriceTextState();
}

class _BlinkingPriceTextState extends State<BlinkingPriceText> {
  static final Map<String, num> _lastValues = {};
  static final Map<String, Timer> _blinkTimers = {};
  static final Map<String, Timer> _resetTimers = {};
  static final Map<String, bool> _isBlinking = {};
  static final Map<String, int> _blinkCount = {};
  static const int maxBlinks = 2; // Number of full blink cycles
  static const int blinkInterval = 200; // 30ms per cycle (15ms per color)
  static const int totalDuration = 180; // Enough for 2 blinks + buffer

  Color _currentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _updateBlinking();
  }

  @override
  void didUpdateWidget(BlinkingPriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _updateBlinking();
    }
  }

  void _updateBlinking() {
    String key = widget.assetId;
    num currentValue = widget.currentValue;
    num compareValue = _lastValues[key] ?? widget.compareValue;

    // Check if value has changed
    bool valueChanged = _lastValues[key] != currentValue;

    if (valueChanged) {
      // Store the new value
      _lastValues[key] = currentValue;

      // Cancel existing timers
      _blinkTimers[key]?.cancel();
      _resetTimers[key]?.cancel();

      // Reset blink state
      _isBlinking[key] = true;
      _blinkCount[key] = 0;

      // Start new blink timer
      _blinkTimers[key] = Timer.periodic(
          const Duration(milliseconds: blinkInterval + 100), (timer) {
        setState(() {
          _isBlinking[key] = !(_isBlinking[key] ?? false);
          _blinkCount[key] = (_blinkCount[key] ?? 0) + 1;

          // Stop after max blinks
          if (_blinkCount[key]! >= maxBlinks) {
            timer.cancel();
            _isBlinking[key] = false;
            _blinkCount[key] = 0;
            _currentColor = Colors.transparent; // Reset to neutral
          } else {
            _updateColor(key, currentValue, compareValue);
          }
        });
      });

      // Reset timer for cleanup
      _resetTimers[key] =
          Timer(const Duration(milliseconds: totalDuration + 300), () {
        _blinkTimers[key]?.cancel();
        setState(() {
          _isBlinking[key] = false;
          _blinkCount[key] = 0;
          _currentColor = Colors.transparent;
        });
      });

      // Set initial color
      _updateColor(key, currentValue, compareValue);
    } else {
      _currentColor = Colors.transparent; // Neutral for no change
    }
  }

  void _updateColor(String key, num currentValue, num compareValue) {
    if (_isBlinking[key] == true) {
      if (currentValue > compareValue) {
        _currentColor = Colors.green.shade400; // Value increased
      } else if (currentValue < compareValue) {
        _currentColor = Colors.red.shade400; // Value decreased
      } else {
        _currentColor = Colors.transparent; // No change
      }
    } else {
      _currentColor = Colors.transparent; // Neutral when not blinking
    }
  }

  @override
  void dispose() {
    _blinkTimers[widget.assetId]?.cancel();
    _resetTimers[widget.assetId]?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentColor,
      ),
      child: Text(
        widget.text,
      ).textStyleH1(),
    );
  }
}
