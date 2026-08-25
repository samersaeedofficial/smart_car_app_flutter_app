import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';

class SpeedControllerWidget extends StatelessWidget {
  const SpeedControllerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();
    final speed = provider.speed;
    final pct = ((speed / 255) * 100).round();

    // Theme based on speed level
    Color themeColor;
    String badgeText;
    IconData themeIcon;

    if (speed > 220) {
      themeColor = CyberTheme.rose;
      badgeText = 'MAX POWER';
      themeIcon = Icons.local_fire_department_rounded;
    } else if (speed > 160) {
      themeColor = CyberTheme.violet;
      badgeText = 'HIGH SPEED';
      themeIcon = Icons.bolt_rounded;
    } else if (speed > 90) {
      themeColor = CyberTheme.cyan;
      badgeText = 'BALANCED';
      themeIcon = Icons.speed_rounded;
    } else {
      themeColor = CyberTheme.emerald;
      badgeText = 'LOW POWER';
      themeIcon = Icons.eco_rounded;
    }

    final presets = [
      {'label': 'Crawl', 'val': 75, 'pct': '30%'},
      {'label': 'Normal', 'val': 128, 'pct': '50%'},
      {'label': 'Fast', 'val': 191, 'pct': '75%'},
      {'label': 'TURBO', 'val': 255, 'pct': '100%'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberTheme.glassCardDecoration(
        borderColor: themeColor.withOpacity(0.3),
        glowColor: themeColor,
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
                      color: themeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.speed_rounded, color: themeColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PWM SPEED CONTROLLER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '0 - 255 Register Output',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => provider.updateSpeed(0),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: CyberTheme.surfaceElevated,
                  foregroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                tooltip: 'Reset to 0',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main Visual Speed Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CyberTheme.borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOTOR THROTTLE',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$speed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Text(
                              ' / 255',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: themeColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(themeIcon, color: themeColor, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                badgeText,
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Linear Gradient Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: speed / 255.0,
                    backgroundColor: const Color(0xFF0F172A),
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Interactive Range Slider with +/- Step Buttons
          Row(
            children: [
              IconButton(
                onPressed: () => provider.updateSpeed(speed - 5),
                icon: const Icon(Icons.remove_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: CyberTheme.surfaceElevated,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: themeColor,
                    inactiveTrackColor: const Color(0xFF0F172A),
                    thumbColor: Colors.white,
                    overlayColor: themeColor.withOpacity(0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: speed.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (val) => provider.updateSpeed(val.round()),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => provider.updateSpeed(speed + 5),
                icon: const Icon(Icons.add_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: CyberTheme.surfaceElevated,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4 Presets Grid
          Row(
            children: presets.map((p) {
              final val = p['val'] as int;
              final isSelected = speed == val;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => provider.updateSpeed(val),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor.withOpacity(0.15) : CyberTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? themeColor : CyberTheme.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            p['pct'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['label'] as String,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
