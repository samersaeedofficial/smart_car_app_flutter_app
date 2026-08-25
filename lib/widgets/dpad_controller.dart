import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';

class DPadController extends StatefulWidget {
  const DPadController({super.key});

  @override
  State<DPadController> createState() => _DPadControllerState();
}

class _DPadControllerState extends State<DPadController> {
  // Base Direction ('F' for Forward, 'B' for Reverse, null for None)
  String? _selectedBaseDirection;
  
  // Active momentary turn press ('L' or 'R')
  String? _pressedTurnCommand;

  // Handle Forward / Reverse Selection (Toggle / Select)
  void _toggleBaseDirection(String cmd, CarControllerProvider provider) {
    setState(() {
      if (_selectedBaseDirection == cmd) {
        // Dobara tap karne par deselect aur stop
        _selectedBaseDirection = null;
        provider.sendCommand('S', isStop: true);
      } else {
        _selectedBaseDirection = cmd;
        // Agar turning hold nahi ki hui toh base command bhejen
        if (_pressedTurnCommand == null) {
          provider.sendCommand(cmd);
        }
      }
    });
  }

  // Handle Turn Button Press Down (Left / Right Hold)
  void _onTurnPressDown(String cmd, CarControllerProvider provider) {
    setState(() => _pressedTurnCommand = cmd);
    provider.sendCommand(cmd);
  }

  // Handle Turn Button Release (Release Finger)
 void _onTurnRelease(CarControllerProvider provider) {
  setState(() => _pressedTurnCommand = null);
  
  if (_selectedBaseDirection != null) {
    // Agar Forward ('F') ya Reverse ('B') active tha toh us par wapas jayein
    provider.sendCommand(_selectedBaseDirection!);
  } else {
    // Agar car ruki hui thi toh immediate STOP ('S') command bhejen
    provider.sendCommand('S', isStop: true);
  }
}

  // Emergency / Manual Stop
  void _handleStop(CarControllerProvider provider) {
    setState(() {
      _selectedBaseDirection = null;
      _pressedTurnCommand = null;
    });
    provider.sendCommand('S', isStop: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();
    
    // Active command calculation for visual state display
    final currentVisualCmd = _pressedTurnCommand ?? _selectedBaseDirection ?? 'S';

    return Container(
  padding: const EdgeInsets.all(20),
  decoration: CyberTheme.glassCardDecoration(
    borderColor: CyberTheme.cyan.withOpacity(0.25),
    glowColor: CyberTheme.cyan,
    borderRadius: 28,
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Header / Active Vector Bar (Fixed Overflow with Flexible Layout)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side Title Section (Wrapped in Expanded)
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CyberTheme.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.gamepad_rounded,
                    color: CyberTheme.cyan,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'D-PAD MOTION CONTROLLER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Right side Status Badge (Stays neatly aligned inside the Card)
          _buildVectorBadge(currentVisualCmd),
        ],
      ),

      const SizedBox(height: 24),

      // Central D-Pad Cross Layout
      Center(
        child: SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative Concentric Rings
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CyberTheme.borderSubtle, width: 1.5),
                ),
              ),
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CyberTheme.cyan.withOpacity(0.12), width: 1.2),
                ),
              ),

              // FORWARD BUTTON (Selectable State)
              Positioned(
                top: 0,
                child: _buildSelectableButton(
                  label: 'FORWARD',
                  icon: Icons.arrow_upward_rounded,
                  command: 'F',
                  isSelected: _selectedBaseDirection == 'F',
                  activeGradient: const LinearGradient(
                    colors: [CyberTheme.cyan, Color(0xFF2563EB)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onTap: () => _toggleBaseDirection('F', provider),
                  width: 96,
                  height: 72,
                ),
              ),

              // REVERSE BUTTON (Selectable State)
              Positioned(
                bottom: 0,
                child: _buildSelectableButton(
                  label: 'REVERSE',
                  icon: Icons.arrow_downward_rounded,
                  command: 'B',
                  isSelected: _selectedBaseDirection == 'B',
                  activeGradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  onTap: () => _toggleBaseDirection('B', provider),
                  width: 96,
                  height: 72,
                ),
              ),

              // LEFT BUTTON (Momentary / Push-to-Hold State)
              Positioned(
                left: 0,
                child: _buildMomentaryButton(
                  label: 'LEFT',
                  icon: Icons.arrow_back_rounded,
                  isPressed: _pressedTurnCommand == 'L',
                  activeGradient: const LinearGradient(
                    colors: [CyberTheme.violet, Color(0xFF7C3AED)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  onPressDown: () => _onTurnPressDown('L', provider),
                  onRelease: () => _onTurnRelease(provider),
                  width: 72,
                  height: 96,
                ),
              ),

              // RIGHT BUTTON (Momentary / Push-to-Hold State)
              Positioned(
                right: 0,
                child: _buildMomentaryButton(
                  label: 'RIGHT',
                  icon: Icons.arrow_forward_rounded,
                  isPressed: _pressedTurnCommand == 'R',
                  activeGradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  onPressDown: () => _onTurnPressDown('R', provider),
                  onRelease: () => _onTurnRelease(provider),
                  width: 72,
                  height: 96,
                ),
              ),

              // CENTER EMERGENCY STOP BUTTON
              GestureDetector(
                onTap: () => _handleStop(provider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: currentVisualCmd == 'S'
                        ? CyberTheme.roseGradient
                        : const LinearGradient(
                            colors: [Color(0xFF4C0519), Color(0xFF881337)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: Border.all(
                      color: currentVisualCmd == 'S' ? Colors.white : CyberTheme.rose,
                      width: 2.5,
                    ),
                    boxShadow: CyberTheme.glowShadow(CyberTheme.rose, blur: 20, opacity: 0.6),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stop_circle_rounded, color: Colors.white, size: 28),
                      SizedBox(height: 2),
                      Text(
                        'STOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Quick Horn Action Bar on D-Pad
      Listener(
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
      ),

      const SizedBox(height: 4),
    ],
  ),
);
  }

  // Selectable Widget (Forward & Reverse)
  Widget _buildSelectableButton({
    required String label,
    required IconData icon,
    required String command,
    required bool isSelected,
    required Gradient activeGradient,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? activeGradient
              : const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: isSelected ? Colors.white : CyberTheme.border,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? CyberTheme.glowShadow(CyberTheme.cyan, blur: 20, opacity: 0.7)
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : CyberTheme.cyanGlow,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Momentary Push-to-Hold Widget (Left & Right)
  Widget _buildMomentaryButton({
    required String label,
    required IconData icon,
    required bool isPressed,
    required Gradient activeGradient,
    required VoidCallback onPressDown,
    required VoidCallback onRelease,
    required double width,
    required double height,
  }) {
    return Listener(
      onPointerDown: (_) => onPressDown(),
      onPointerUp: (_) => onRelease(),
      onPointerCancel: (_) => onRelease(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isPressed
            ? activeGradient
            : const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            border: Border.all(
            color: isPressed ? Colors.white : CyberTheme.border,
            width: isPressed ? 2.5 : 1.2,
          ),
          boxShadow: isPressed
            ? CyberTheme.glowShadow(CyberTheme.violet, blur: 20, opacity: 0.8)
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isPressed ? Colors.white : CyberTheme.cyanGlow,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isPressed ? Colors.white : const Color(0xFFCBD5E1),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildVectorBadge(String activeCmd) {
    String label = 'STOPPED';
    Color color = CyberTheme.rose;

    switch (activeCmd) {
      case 'F':
        label = 'FORWARD';
        color = CyberTheme.cyan;
        break;
      case 'B':
        label = 'REVERSE';
        color = const Color(0xFF6366F1);
        break;
      case 'L':
        label = 'LEFT';
        color = CyberTheme.violet;
        break;
      case 'R':
        label = 'RIGHT';
        color = const Color(0xFFA855F7);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}