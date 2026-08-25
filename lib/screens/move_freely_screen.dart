import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_header.dart';
import '../widgets/mode_dialogs.dart';

class MoveFreelyScreen extends StatefulWidget {
  final VoidCallback onBackToMenu;

  const MoveFreelyScreen({super.key, required this.onBackToMenu});

  @override
  State<MoveFreelyScreen> createState() => _MoveFreelyScreenState();
}

class _MoveFreelyScreenState extends State<MoveFreelyScreen> {
  int _sessionSeconds = 0;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    // Start session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _sessionSeconds++);
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hrs = (_sessionSeconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((_sessionSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_sessionSeconds % 60).toString().padLeft(2, '0');

    final stats = [
      {'icon': Icons.radar_rounded, 'label': 'Sensor', 'value': 'Ultrasonic', 'color': CyberTheme.emerald},
      {'icon': Icons.memory_rounded, 'label': 'Mode', 'value': 'Autonomous', 'color': CyberTheme.cyan},
      {'icon': Icons.shield_rounded, 'label': 'Collision', 'value': 'Protected', 'color': CyberTheme.violet},
      {'icon': Icons.bolt_rounded, 'label': 'Status', 'value': 'Active Loop', 'color': CyberTheme.amber},
    ];

    return Scaffold(
      body: Column(
        children: [
          CyberHeader(onBackToMenu: widget.onBackToMenu),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: CyberTheme.glassCardDecoration(
                  borderColor: CyberTheme.emerald.withOpacity(0.3),
                  glowColor: CyberTheme.emerald,
                  borderRadius: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Session Badge & Back Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ModeDialogs.showCancelConfirmation(context, onConfirm: () {
                              context.read<CarControllerProvider>().cancelModeAndReturnToMenu();
                              widget.onBackToMenu();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFCBD5E1),
                            side: const BorderSide(color: CyberTheme.borderSubtle),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 14),
                          label: const Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: CyberTheme.emerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CyberTheme.emerald.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: CyberTheme.emerald, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'MOVE FREELY ACTIVE',
                                style: TextStyle(
                                  color: CyberTheme.emerald,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Autonomous\nObstacle Avoidance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your Smart Chassis is operating in Move Freely Mode. The ultrasonic sensor scans surroundings in real-time, detecting obstacles and automatically adjusting direction.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pulse Status Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CyberTheme.emerald.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: CyberTheme.emerald,
                              shape: BoxShape.circle,
                              boxShadow: CyberTheme.glowShadow(CyberTheme.emerald, blur: 10, opacity: 0.8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Telemetry Active & Protected',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Sensor scanning & navigating autonomously',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Live Session Timer Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CyberTheme.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_rounded, color: Color(0xFF94A3B8), size: 14),
                              SizedBox(width: 6),
                              Text(
                                'SESSION DURATION',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimeBlock(hrs, 'HRS'),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(':', style: TextStyle(color: Color(0xFF475569), fontSize: 24, fontWeight: FontWeight.bold)),
                              ),
                              _buildTimeBlock(mins, 'MIN'),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(':', style: TextStyle(color: Color(0xFF475569), fontSize: 24, fontWeight: FontWeight.bold)),
                              ),
                              _buildTimeBlock(secs, 'SEC'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Bento Stats Grid (2x2)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: stats.length,
                      itemBuilder: (context, idx) {
                        final stat = stats[idx];
                        final color = stat['color'] as Color;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(stat['icon'] as IconData, color: color, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      stat['label'] as String,
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontFamily: 'monospace'),
                                    ),
                                    Text(
                                      stat['value'] as String,
                                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String num, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            num,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
