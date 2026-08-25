import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_header.dart';
import '../widgets/dpad_controller.dart';
import '../widgets/horn_controller.dart';
import '../widgets/joystick_controller.dart';
import '../widgets/speed_controller.dart';
import '../widgets/telemetry_panel.dart';

class ManualControlScreen extends StatefulWidget {
  final VoidCallback onBackToMenu;

  const ManualControlScreen({super.key, required this.onBackToMenu});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  String _activeTab = 'dpad'; // 'dpad' | 'joystick'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CyberHeader(onBackToMenu: widget.onBackToMenu),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Controller Selector Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CyberTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeTab = 'dpad'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _activeTab == 'dpad' ? CyberTheme.cyan : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.gamepad_rounded,
                                    color: _activeTab == 'dpad' ? Colors.white : const Color(0xFF94A3B8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'D-Pad Deck',
                                    style: TextStyle(
                                      color: _activeTab == 'dpad' ? Colors.white : const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeTab = 'joystick'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _activeTab == 'joystick' ? CyberTheme.violet : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.radar_rounded,
                                    color: _activeTab == 'joystick' ? Colors.white : const Color(0xFF94A3B8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '360° Joystick',
                                    style: TextStyle(
                                      color: _activeTab == 'joystick' ? Colors.white : const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SECTION 1: Dynamic Controller (D-Pad / 360 Joystick)
                  if (_activeTab == 'dpad') const DPadController() else const JoystickController(),

                  const SizedBox(height: 16),

                  // SECTION 2: Horn Acoustic Controller
                  const HornControllerWidget(),

                  const SizedBox(height: 16),

                  // SECTION 3: Speed PWM Controller
                  const SpeedControllerWidget(),

                  const SizedBox(height: 16),

                  // SECTION 4: Live Telemetry & Serial Console Feed
                  const TelemetryPanelWidget(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
