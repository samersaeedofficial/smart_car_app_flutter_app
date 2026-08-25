import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car_mode.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';
import 'mode_dialogs.dart';

class CyberHeader extends StatelessWidget {
  final VoidCallback? onBackToMenu;

  const CyberHeader({super.key, this.onBackToMenu});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();
    final isMenu = provider.currentMode == CarMode.menu;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: CyberTheme.surface.withOpacity(0.65),
            border: Border(
              bottom: BorderSide(
                color: CyberTheme.cyan.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Glowing Icon Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CyberTheme.cyan.withOpacity(0.25),
                        CyberTheme.cyan.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CyberTheme.cyan.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberTheme.cyan.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: CyberTheme.cyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Device Title & Status Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.connectedDeviceName ?? 'Smart Chassis',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.isDemoMode
                            ? 'Simulated Sandbox • SPP'
                            : (provider.connectedDeviceAddress ?? 'Classic SPP Link'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11,
                          fontFamily: 'monospace',
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Header Action Area
                if (!isMenu) ...[
                  // Three Dots Cyber Menu
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerTheme: DividerThemeData(
                        color: CyberTheme.cyan.withOpacity(0.2),
                      ),
                      popupMenuTheme: PopupMenuThemeData(
                        color: CyberTheme.surface.withOpacity(0.95),
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: CyberTheme.cyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 48),
                      icon: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CyberTheme.cyan.withOpacity(0.22),
                              CyberTheme.cyan.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CyberTheme.cyan.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberTheme.cyan.withOpacity(0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: CyberTheme.cyan,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'change_mode') {
                          ModeDialogs.showCancelConfirmation(
                            context,
                            onConfirm: () {
                              provider.cancelModeAndReturnToMenu();
                              if (onBackToMenu != null) onBackToMenu!();
                            },
                          );
                        } else if (value == 'disconnect') {
                          provider.disconnect();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'change_mode',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.swap_horiz_rounded,
                                color: CyberTheme.amber,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Change Mode',
                                style: TextStyle(
                                  color: CyberTheme.amber,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'disconnect',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.power_settings_new_rounded,
                                color: CyberTheme.rose,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Disconnect',
                                style: TextStyle(
                                  color: CyberTheme.rose,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Menu Mode Main Direct Disconnect Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => provider.disconnect(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CyberTheme.rose.withOpacity(0.22),
                              CyberTheme.rose.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CyberTheme.rose.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberTheme.rose.withOpacity(0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.power_settings_new_rounded,
                          color: CyberTheme.rose,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}