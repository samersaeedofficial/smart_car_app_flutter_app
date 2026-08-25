import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  /// Raw Bluetooth exceptions ko short aur user-friendly text mein convert karta hai
  String _getSanitizedError(String rawError) {
    final lower = rawError.toLowerCase();
    if (lower.contains('read failed') || lower.contains('socket') || lower.contains('timeout')) {
      return 'Connection timed out. Ensure JDY-31 is powered ON & within 5 meters.';
    } else if (lower.contains('bond') || lower.contains('pair') || lower.contains('refused')) {
      return 'Pairing failed. Re-pair JDY-31 in Android Bluetooth Settings with PIN 1234.';
    } else if (lower.contains('permission') || lower.contains('location')) {
      return 'Bluetooth/Location permissions required. Please grant access in settings.';
    }
    return rawError.length > 110 ? '${rawError.substring(0, 110)}...' : rawError;
  }

  void _showDevicePicker(BuildContext context) {
    final provider = context.read<CarControllerProvider>();
    provider.startScan();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer<CarControllerProvider>(
        builder: (context, prov, _) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.68,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CyberTheme.surface.withOpacity(0.98),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: CyberTheme.cyan.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CyberTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECT JDY-31 DEVICE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Bluetooth Classic (SPP / RFCOMM)',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    if (prov.isScanning)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(CyberTheme.cyan),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: prov.startScan,
                        icon: const Icon(Icons.refresh_rounded, color: CyberTheme.cyan, size: 22),
                        tooltip: 'Rescan Devices',
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Device Lists
                Expanded(
                  child: ListView(
                    children: [
                      const Text(
                        'PAIRED BLUETOOTH DEVICES',
                        style: TextStyle(
                          color: CyberTheme.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (prov.pairedDevices.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No paired devices found. Pair JDY-31 in Android Settings with PIN 1234.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        )
                      else
                        ...prov.pairedDevices.map((dev) => _buildDeviceTile(
                              context,
                              name: dev.name ?? 'JDY-31 Module',
                              address: dev.address,
                              isPaired: true,
                              onTap: () {
                                Navigator.pop(ctx);
                                prov.connect(device: dev);
                              },
                            )),

                      const SizedBox(height: 16),

                      const Text(
                        'NEARBY DISCOVERED DEVICES',
                        style: TextStyle(
                          color: CyberTheme.violet,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (prov.discoveredDevices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            prov.isScanning ? 'Scanning for nearby Bluetooth devices...' : 'No other devices detected.',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        )
                      else
                        ...prov.discoveredDevices.map((res) => _buildDeviceTile(
                              context,
                              name: res.device.name ?? 'Unnamed Classic Device',
                              address: res.device.address,
                              rssi: res.rssi,
                              isPaired: false,
                              onTap: () {
                                Navigator.pop(ctx);
                                prov.connect(device: res.device);
                              },
                            )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      provider.stopScan();
    });
  }

  Widget _buildDeviceTile(
    BuildContext context, {
    required String name,
    required String address,
    int? rssi,
    required bool isPaired,
    required VoidCallback onTap,
  }) {
    final isJDY = name.toLowerCase().contains('jdy') || name.toLowerCase().contains('hc-');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isJDY ? CyberTheme.cyan.withOpacity(0.08) : const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJDY ? CyberTheme.cyan.withOpacity(0.4) : CyberTheme.borderSubtle,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isJDY ? CyberTheme.cyan.withOpacity(0.15) : CyberTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.bluetooth_connected_rounded,
            color: isJDY ? CyberTheme.cyan : const Color(0xFF94A3B8),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isJDY) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CyberTheme.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CAR MODULE',
                  style: TextStyle(color: CyberTheme.cyan, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          address,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontFamily: 'monospace'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF475569), size: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();
    final isConnecting = provider.isConnecting;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow Effects
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [CyberTheme.cyan.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [CyberTheme.violet.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),

          // Central Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(22),
                decoration: CyberTheme.glassCardDecoration(
                  borderColor: CyberTheme.cyan.withOpacity(0.3),
                  glowColor: CyberTheme.cyan,
                  borderRadius: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            'SMART CHASSIS ROBOT HUB',
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

                    const SizedBox(height: 20),

                    // Central Radar Icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: CyberTheme.cyan.withOpacity(0.15), width: 2),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF020617), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: CyberTheme.cyan.withOpacity(0.5), width: 1.5),
                            boxShadow: CyberTheme.glowShadow(CyberTheme.cyan, blur: 25, opacity: 0.4),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: CyberTheme.cyan,
                            size: 38,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Title & Description
                    const Text(
                      'CONNECT YOUR SMART CAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Establish a real-time wireless Bluetooth connection to initialize telemetry cockpit and autonomous modes.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 18),

                    // Refined Error Alert Banner
                    if (provider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CyberTheme.rose.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CyberTheme.rose.withOpacity(0.4)),
                          boxShadow: CyberTheme.glowShadow(CyberTheme.rose, blur: 15, opacity: 0.2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: CyberTheme.rose.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: CyberTheme.rose, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _getSanitizedError(provider.errorMessage!),
                                style: const TextStyle(
                                  color: Color(0xFFFECDD3),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: provider.dismissError,
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Modernized Overflow-Safe Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isConnecting
                            ? null
                            : () {
                                if (provider.isDemoMode) {
                                  provider.connect();
                                } else {
                                  _showDevicePicker(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: CyberTheme.cyan.withOpacity(0.4),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: CyberTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: CyberTheme.cyan.withOpacity(0.6)),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: isConnecting
                                  ? Row(
                                      key: const ValueKey('connecting_state'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            provider.connectionPhase ?? 'Connecting...',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      key: ValueKey('idle_state'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bluetooth_searching_rounded, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'CONNECT VEHICLE NOW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Demo Mode Toggle Switch Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: provider.isDemoMode ? CyberTheme.cyan.withOpacity(0.08) : const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: provider.isDemoMode ? CyberTheme.cyan.withOpacity(0.3) : CyberTheme.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: provider.isDemoMode
                                        ? CyberTheme.amber.withOpacity(0.15)
                                        : CyberTheme.surfaceElevated,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    color: provider.isDemoMode ? CyberTheme.amber : const Color(0xFF64748B),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Simulated Demo Mode',
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        provider.isDemoMode ? 'Interactive Sandbox active' : 'Live Hardware link',
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: provider.isDemoMode,
                            activeColor: CyberTheme.cyan,
                            onChanged: (val) => provider.setDemoMode(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Modern Glass Diagnostic Badges
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDiagBadge(Icons.bluetooth_rounded, 'SPP Ready', CyberTheme.cyan),
                        _buildDiagBadge(Icons.shield_outlined, 'RFCOMM Secure', CyberTheme.emerald),
                        _buildDiagBadge(Icons.memory_rounded, 'JDY-31 / Nano', CyberTheme.violet),
                      ],
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

  /// Modernized glassmorphic status badge
  Widget _buildDiagBadge(IconData icon, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
              boxShadow: CyberTheme.glowShadow(accentColor, blur: 6, opacity: 0.8),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, color: accentColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}