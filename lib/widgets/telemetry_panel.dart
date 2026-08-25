import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/telemetry_log.dart';
import '../providers/car_controller_provider.dart';
import '../theme/cyber_theme.dart';

class TelemetryPanelWidget extends StatefulWidget {
  const TelemetryPanelWidget({super.key});

  @override
  State<TelemetryPanelWidget> createState() => _TelemetryPanelWidgetState();
}

class _TelemetryPanelWidgetState extends State<TelemetryPanelWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String _formatUptime(int totalSec) {
    final hrs = totalSec ~/ 3600;
    final mins = (totalSec % 3600) ~/ 60;
    final secs = totalSec % 60;
    if (hrs > 0) {
      return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _copyLogs(List<TelemetryLog> logs) {
    if (logs.isEmpty) return;
    final text = logs.map((l) => '[${l.timestamp}] [${l.type.name.toUpperCase()}] ${l.message}').join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Console logs copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: CyberTheme.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();
    final activeCmd = provider.activeCommand;
    final logs = provider.logs;

    // Auto-scroll to latest stream item
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Calculate dynamic stream stats
    final errorCount = logs.where((l) => l.type == LogType.error).length;
    final warnCount = logs.where((l) => l.type == LogType.warning).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberTheme.glassCardDecoration(
        borderColor: CyberTheme.borderSubtle,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CyberTheme.cyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CyberTheme.cyan.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.analytics_rounded, color: CyberTheme.cyan, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIVE TELEMETRY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'SPP Real-time Stream & Diagnostics',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4 Bento Metric Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'COMMAND',
                  icon: Icons.send_rounded,
                  iconColor: CyberTheme.cyan,
                  content: Text(
                    activeCmd,
                    style: const TextStyle(
                      color: CyberTheme.cyan,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  label: 'THROTTLE',
                  icon: Icons.speed_rounded,
                  iconColor: CyberTheme.violet,
                  content: Text(
                    '${provider.speed}/255',
                    style: const TextStyle(
                      color: CyberTheme.violet,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'UPTIME',
                  icon: Icons.timer_rounded,
                  iconColor: CyberTheme.emerald,
                  content: Text(
                    _formatUptime(provider.uptimeSeconds),
                    style: const TextStyle(
                      color: CyberTheme.emerald,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  label: 'TX / PING',
                  icon: Icons.bolt_rounded,
                  iconColor: CyberTheme.amber,
                  content: Text(
                    '${provider.packetsSent} / ${provider.lastLatencyMs ?? 0}ms',
                    style: const TextStyle(
                      color: CyberTheme.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Modernized Glass Console Container
          Container(
            height: 220,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: CyberTheme.borderSubtle.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Terminal Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.8),
                    border: const Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terminal_rounded, color: CyberTheme.cyan, size: 15),
                          const SizedBox(width: 8),
                          const Text(
                            'Serial Log Stream',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Counter pills
                          _buildLogCountBadge('${logs.length}', const Color(0xFF475569), Colors.white70),
                          if (warnCount > 0) ...[
                            const SizedBox(width: 4),
                            _buildLogCountBadge('$warnCount WARN', CyberTheme.amber.withOpacity(0.2), CyberTheme.amber),
                          ],
                          if (errorCount > 0) ...[
                            const SizedBox(width: 4),
                            _buildLogCountBadge('$errorCount ERR', CyberTheme.rose.withOpacity(0.2), CyberTheme.rose),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            tooltip: 'Copy Logs',
                            onTap: () => _copyLogs(logs),
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Clear Stream',
                            onTap: provider.clearLogs,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dynamic Stream View
                Expanded(
                  child: logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wifi_tethering_off_rounded, color: const Color(0xFF334155), size: 28),
                              const SizedBox(height: 8),
                              const Text(
                                'Awaiting SPP Telemetry Stream...',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            return _buildLogTile(logs[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Micro Glass Card for Log Row
  Widget _buildLogTile(TelemetryLog log) {
    final (Color mainColor, IconData iconData, String badgeLabel) = switch (log.type) {
      LogType.success => (CyberTheme.emerald, Icons.check_circle_outline_rounded, 'OK'),
      LogType.warning => (CyberTheme.amber, Icons.warning_amber_rounded, 'WARN'),
      LogType.error => (CyberTheme.rose, Icons.error_outline_rounded, 'ERR'),
      LogType.info => (CyberTheme.cyan, Icons.info_outline_rounded, 'INFO'),
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: mainColor.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Indicator
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(iconData, color: mainColor, size: 13),
          ),
          const SizedBox(width: 8),

          // Monospace Timestamp Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Text(
              log.timestamp,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Type Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                color: mainColor,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Log Message Body
          Expanded(
            child: Text(
              log.message,
              style: TextStyle(
                color: mainColor.withOpacity(0.95),
                fontSize: 10.5,
                fontFamily: 'monospace',
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCountBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CyberTheme.borderSubtle.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          content,
        ],
      ),
    );
  }
}