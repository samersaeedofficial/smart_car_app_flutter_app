import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';

class HornControllerWidget extends StatefulWidget {
  const HornControllerWidget({super.key});

  @override
  State<HornControllerWidget> createState() => _HornControllerWidgetState();
}

class _HornControllerWidgetState extends State<HornControllerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();
    final isHornActive = provider.isHornActive;

    const Color activeColor = CyberTheme.amber;
    final Color badgeColor = isHornActive ? CyberTheme.amber : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberTheme.glassCardDecoration(
        borderColor: isHornActive ? activeColor.withOpacity(0.5) : CyberTheme.amber.withOpacity(0.25),
        glowColor: isHornActive ? activeColor : Colors.transparent,
        borderRadius: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberTheme.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: CyberTheme.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACOUSTIC HORN SYSTEM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Tone 400Hz • Arduino Pin 8',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Active Indicator Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        boxShadow: isHornActive
                            ? CyberTheme.glowShadow(badgeColor, blur: 8, opacity: 0.9)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHornActive ? 'BLARING' : 'STANDBY',
                      style: TextStyle(
                        color: isHornActive ? CyberTheme.amber : const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main Horn Trigger Deck
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isHornActive ? CyberTheme.amber.withOpacity(0.4) : CyberTheme.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                // Left: Massive Push-to-Hold Horn Button with Soundwave Ring
                Expanded(
                  flex: 3,
                  child: Listener(
                    onPointerDown: (_) => provider.setHorn(true),
                    onPointerUp: (_) => provider.setHorn(false),
                    onPointerCancel: (_) => provider.setHorn(false),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated Pulse Wave Rings when active
                        if (isHornActive)
                          AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              final waveVal = _waveController.value;
                              return Container(
                                width: 90 + (waveVal * 30),
                                height: 90 + (waveVal * 30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CyberTheme.amber.withOpacity(1.0 - waveVal),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                        // Core Horn Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isHornActive
                                ? CyberTheme.amberGradient
                                : const LinearGradient(
                                    colors: [Color(0xFF261D11), Color(0xFF130E07)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            border: Border.all(
                              color: isHornActive ? Colors.white : CyberTheme.amber.withOpacity(0.5),
                              width: isHornActive ? 2.5 : 1.5,
                            ),
                            boxShadow: isHornActive
                                ? CyberTheme.glowShadow(CyberTheme.amber, blur: 25, opacity: 0.9)
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: isHornActive ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 100),
                                child: Icon(
                                  isHornActive ? Icons.campaign_rounded : Icons.volume_up_rounded,
                                  color: isHornActive ? Colors.white : CyberTheme.amber,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isHornActive ? 'SOUNDING HORN' : 'HOLD TO HONK',
                                    style: TextStyle(
                                      color: isHornActive ? Colors.white : const Color(0xFFFDE68A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isHornActive ? 'Continuous Signal (\'H\')' : 'Press & Hold Finger',
                                    style: TextStyle(
                                      color: isHornActive
                                          ? Colors.white.withOpacity(0.9)
                                          : const Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right: Quick Pulse / Tap Beep Button
                InkWell(
                  onTap: () => provider.pulseHorn(durationMs: 250),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                    decoration: BoxDecoration(
                      color: CyberTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CyberTheme.borderSubtle),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: CyberTheme.amber,
                          size: 20,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BEEP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '250ms',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
