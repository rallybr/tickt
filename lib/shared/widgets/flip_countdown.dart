import 'package:flutter/material.dart';

class FlipCountdown extends StatefulWidget {
  final DateTime targetDate;
  final TextStyle? labelStyle;
  final TextStyle? digitStyle;
  final double spacing;

  const FlipCountdown({
    Key? key,
    required this.targetDate,
    this.labelStyle,
    this.digitStyle,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  State<FlipCountdown> createState() => _FlipCountdownState();
}

class _FlipCountdownState extends State<FlipCountdown> {
  late Duration _duration;
  late int months;
  late int days;
  late int hours;
  late int minutes;
  late int seconds;
  late final Ticker _ticker;
  int _lastSecond = 0;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _lastSecond = seconds;
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    setState(_updateCountdown);
  }

  void _updateCountdown() {
    final now = DateTime.now();
    _duration = widget.targetDate.difference(now);
    // Calcular meses e dias
    months = (widget.targetDate.year - now.year) * 12 + (widget.targetDate.month - now.month);
    DateTime monthStart = DateTime(now.year, now.month + months, now.day, now.hour, now.minute, now.second);
    if (monthStart.isAfter(widget.targetDate)) {
      months -= 1;
      monthStart = DateTime(now.year, now.month + months, now.day, now.hour, now.minute, now.second);
    }
    final remaining = widget.targetDate.difference(monthStart);
    days = remaining.inDays;
    hours = remaining.inHours % 24;
    minutes = remaining.inMinutes % 60;
    seconds = remaining.inSeconds % 60;
    if (_duration.isNegative) {
      months = days = hours = minutes = seconds = 0;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Widget _buildStaticUnit(int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          width: 56,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: widget.digitStyle ?? const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'RobotoMono',
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: widget.labelStyle ?? const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFlipSeconds(int value) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              final flipAnim = Tween(begin: 1.0, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: flipAnim,
                child: child,
                builder: (context, child) {
                  final isUnder = (animation.status == AnimationStatus.reverse);
                  final tilt = (isUnder ? (1 - flipAnim.value) : flipAnim.value) * 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(3.14 * tilt),
                    child: child,
                  );
                },
              );
            },
            child: Text(
              value.toString().padLeft(2, '0'),
              key: ValueKey(value),
              style: widget.digitStyle ?? const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SEG',
          style: widget.labelStyle ?? const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStaticUnit(months, 'MES')),
        SizedBox(width: widget.spacing),
        Expanded(child: _buildStaticUnit(days, 'DIAS')),
        SizedBox(width: widget.spacing),
        Expanded(child: _buildStaticUnit(hours, 'HRS')),
        SizedBox(width: widget.spacing),
        Expanded(child: _buildStaticUnit(minutes, 'MIN')),
        SizedBox(width: widget.spacing),
        Expanded(child: _buildFlipSeconds(seconds)),
      ],
    );
  }
}

// Ticker para atualização a cada segundo
class Ticker {
  final void Function(Duration) onTick;
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  bool _isActive = false;

  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1)}) {
    _interval = interval;
    _stopwatch = Stopwatch();
  }

  void start() {
    if (_isActive) return;
    _isActive = true;
    _stopwatch.start();
    _tick();
  }

  void _tick() async {
    while (_isActive) {
      await Future.delayed(_interval);
      if (!_isActive) break;
      onTick(_stopwatch.elapsed);
    }
  }

  void dispose() {
    _isActive = false;
    _stopwatch.stop();
  }
} 