import 'package:flutter/material.dart';
import '../models/car_mode.dart';
import '../theme/cyber_theme.dart';

class ModeDialogs {
  static Future<void> showModeActivation(
    BuildContext context, {
    required CarMode mode,
    required VoidCallback onConfirm,
  }) async {
    Color themeColor = CyberTheme.cyan;
    IconData themeIcon = Icons.gamepad_rounded;

    if (mode == CarMode.moveFreely) {
      themeColor = CyberTheme.emerald;
      themeIcon = Icons.radar_rounded;
    } else if (mode == CarMode.moveLine) {
      themeColor = CyberTheme.violet;
      themeIcon = Icons.alt_route_rounded;
    }

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: CyberTheme.glassCardDecoration(
            borderColor: themeColor.withOpacity(0.4),
            glowColor: themeColor,
            borderRadius: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(themeIcon, color: themeColor, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Activate ${mode.title}?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This will transmit command "${mode.commandChar}" to your Smart Chassis to switch operational routines.',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: CyberTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        shadowColor: themeColor.withOpacity(0.5),
                        elevation: 8,
                      ),
                      child: const Text('Activate', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showCancelConfirmation(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: CyberTheme.glassCardDecoration(
            borderColor: CyberTheme.amber.withOpacity(0.4),
            glowColor: CyberTheme.amber,
            borderRadius: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CyberTheme.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: CyberTheme.amber.withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: CyberTheme.amber, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Halt Active Mode?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'This will transmit Emergency Stop ("S") to halt motor motion and return to the main mode selector.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: CyberTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Stay', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberTheme.rose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        shadowColor: CyberTheme.rose.withOpacity(0.5),
                        elevation: 8,
                      ),
                      child: const Text('Stop & Exit', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
