import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car_mode.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_header.dart';
import '../widgets/mode_dialogs.dart';

class ModeSelectionScreen extends StatelessWidget {
  final Function(CarMode) onModeSelected;

  const ModeSelectionScreen({super.key, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CyberHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Top Title Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: CyberTheme.cyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CyberTheme.cyan.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: CyberTheme.cyan, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'VEHICLE OPERATIONAL MODES',
                          style: TextStyle(
                            color: CyberTheme.cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'SELECT CHASSIS MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose an operational mode below to command your Smart Chassis device.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // 3 BENTO CARDS
                  _buildModeCard(
                    context,
                    mode: CarMode.moveFreely,
                    badgeText: 'AUTONOMOUS',
                    title: 'Move Freely',
                    subtitle: 'Obstacle Avoidance Mode',
                    description:
                        'Automatic movement mode using Ultrasonic distance sensor to scan and avoid obstacles freely in real-time.',
                    actionLabel: 'Launch Ultrasonic Mode',
                    icon: Icons.radar_rounded,
                    themeColor: CyberTheme.emerald,
                    gradient: CyberTheme.emeraldGradient,
                  ),

                  const SizedBox(height: 16),

                  _buildModeCard(
                    context,
                    mode: CarMode.control,
                    badgeText: 'MANUAL CONTROL',
                    title: 'Control',
                    subtitle: 'Full Manual Cockpit App',
                    description:
                        'Take full manual command over your Smart Chassis with responsive D-Pad & 360° Joystick controllers, speed regulation, and telemetry.',
                    actionLabel: 'Open Controller App',
                    icon: Icons.gamepad_rounded,
                    themeColor: CyberTheme.cyan,
                    gradient: CyberTheme.primaryGradient,
                  ),

                  const SizedBox(height: 16),

                  _buildModeCard(
                    context,
                    mode: CarMode.moveLine,
                    badgeText: 'LINE FOLLOWER',
                    title: 'Move in Line Chassis',
                    subtitle: 'IR Track Following Mode',
                    description:
                        'Automatic line-following chassis mode using IR sensors to detect black tracks and correct direction automatically.',
                    actionLabel: 'Launch Line Follower Mode',
                    icon: Icons.alt_route_rounded,
                    themeColor: CyberTheme.violet,
                    gradient: CyberTheme.violetGradient,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required CarMode mode,
    required String badgeText,
    required String title,
    required String subtitle,
    required String description,
    required String actionLabel,
    required IconData icon,
    required Color themeColor,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: () {
        ModeDialogs.showModeActivation(
          context,
          mode: mode,
          onConfirm: () {
            context.read<CarControllerProvider>().setMode(mode);
            onModeSelected(mode);
          },
        );
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: CyberTheme.glassCardDecoration(
          borderColor: themeColor.withOpacity(0.35),
          glowColor: themeColor,
          borderRadius: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Icon(icon, color: themeColor, size: 26),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title & Subtitle
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: themeColor,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // Footer Action Row
            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: CyberTheme.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_rounded, color: themeColor, size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
