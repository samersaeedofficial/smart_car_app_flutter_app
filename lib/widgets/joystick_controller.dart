import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';

class JoystickController extends StatefulWidget {
  const JoystickController({super.key});

  @override
  State<JoystickController> createState() => _JoystickControllerState();
}

class _JoystickControllerState extends State<JoystickController> {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  final double _maxRadius = 65.0;

  void _onPointerDown(PointerDownEvent event, BoxConstraints constraints) {
    setState(() => _isDragging = true);
    _updateOffset(event.localPosition, constraints);
  }

  void _onPointerMove(PointerMoveEvent event, BoxConstraints constraints) {
    if (_isDragging) {
      _updateOffset(event.localPosition, constraints);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _resetJoystick();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _resetJoystick();
  }

  void _resetJoystick() {
    if (!_isDragging) return;
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
    final provider = context.read<CarControllerProvider>();
    provider.sendCommand('S', isStop: true);
  }

  void _updateOffset(Offset localPos, BoxConstraints constraints) {
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final delta = localPos - center;
    final distance = delta.distance;

    Offset clampedOffset;
    if (distance > _maxRadius) {
      final angle = atan2(delta.dy, delta.dx);
      clampedOffset = Offset(cos(angle) * _maxRadius, sin(angle) * _maxRadius);
    } else {
      clampedOffset = delta;
    }

    setState(() => _dragOffset = clampedOffset);

    // Compute Vector Command ('F', 'B', 'L', 'R', 'S')
    final provider = context.read<CarControllerProvider>();
    final absX = clampedOffset.dx.abs();
    final absY = clampedOffset.dy.abs();

    if (clampedOffset.distance < 15) {
      provider.sendCommand('S', isStop: true);
    } else if (absY > absX) {
      if (clampedOffset.dy < 0) {
        provider.sendCommand('F');
      } else {
        provider.sendCommand('B');
      }
    } else {
      if (clampedOffset.dx < 0) {
        provider.sendCommand('L');
      } else {
        provider.sendCommand('R');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberTheme.glassCardDecoration(
        borderColor: CyberTheme.violet.withOpacity(0.25),
        glowColor: CyberTheme.violet,
        borderRadius: 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberTheme.violet.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.radar_rounded, color: CyberTheme.violet, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '360° TOUCH JOYSTICK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CyberTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberTheme.borderSubtle),
                ),
                child: const Text(
                  'DRAG & STEER',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 360 Joystick Arena
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RawGestureDetector(
                    gestures: <Type, GestureRecognizerFactory>{
                      EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                        (EagerGestureRecognizer instance) {},
                      ),
                    },
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) => _onPointerDown(event, constraints),
                      onPointerMove: (event) => _onPointerMove(event, constraints),
                      onPointerUp: _onPointerUp,
                      onPointerCancel: _onPointerCancel,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF020617),
                          border: Border.all(
                            color: _isDragging ? CyberTheme.violet : CyberTheme.border,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                            if (_isDragging)
                              BoxShadow(
                                color: CyberTheme.violet.withOpacity(0.2),
                                blurRadius: 25,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Crosshair Guidelines
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: CyberTheme.borderSubtle,
                            ),
                            Container(
                              height: double.infinity,
                              width: 1,
                              color: CyberTheme.borderSubtle,
                            ),

                            // Inner Dashed Ring
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CyberTheme.violet.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                            ),

                            // Direction Labels
                            const Positioned(
                              top: 8,
                              child: Text(
                                'F',
                                style: TextStyle(
                                  color: CyberTheme.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 8,
                              child: Text(
                                'B',
                                style: TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 10,
                              child: Text(
                                'L',
                                style: TextStyle(
                                  color: CyberTheme.violet,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 10,
                              child: Text(
                                'R',
                                style: TextStyle(
                                  color: Color(0xFFA855F7),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            // Joystick Drag Thumb
                            Transform.translate(
                              offset: _dragOffset,
                              child: AnimatedContainer(
                                duration: _isDragging ? Duration.zero : const Duration(milliseconds: 150),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _isDragging
                                      ? CyberTheme.violetGradient
                                      : const LinearGradient(
                                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  border: Border.all(
                                    color: _isDragging ? Colors.white : CyberTheme.violet.withOpacity(0.5),
                                    width: 2.5,
                                  ),
                                  boxShadow: _isDragging
                                      ? CyberTheme.glowShadow(CyberTheme.violet, blur: 20, opacity: 0.8)
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.4),
                                            blurRadius: 10,
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.radio_button_checked_rounded,
                                    color: _isDragging ? Colors.white : CyberTheme.violetGlow,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            'Drag handle in 360° to steer • Release to center and stop',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          // Quick Horn Action Bar on Joystick
          Consumer<CarControllerProvider>(
            builder: (context, provider, _) {
              return Listener(
                onPointerDown: (_) => provider.setHorn(true),
                onPointerUp: (_) => provider.setHorn(false),
                onPointerCancel: (_) => provider.setHorn(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: provider.isHornActive
                        ? CyberTheme.amber
                        : CyberTheme.surfaceElevated.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: provider.isHornActive ? Colors.white : CyberTheme.amber.withOpacity(0.4),
                      width: provider.isHornActive ? 2 : 1,
                    ),
                    boxShadow: provider.isHornActive
                        ? CyberTheme.glowShadow(CyberTheme.amber, blur: 20, opacity: 0.8)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        provider.isHornActive ? Icons.campaign_rounded : Icons.volume_up_rounded,
                        color: provider.isHornActive ? Colors.white : CyberTheme.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isHornActive ? 'HORN ACTIVE (400Hz)' : 'HOLD TO HONK HORN',
                        style: TextStyle(
                          color: provider.isHornActive ? Colors.white : const Color(0xFFFDE68A),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}