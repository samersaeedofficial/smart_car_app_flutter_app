enum LogType { info, success, warning, error }

class TelemetryLog {
  final String id;
  final String timestamp;
  final String message;
  final LogType type;

  TelemetryLog({
    required this.id,
    required this.timestamp,
    required this.message,
    this.type = LogType.info,
  });

  factory TelemetryLog.now(String message, {LogType type = LogType.info}) {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = (now.millisecond).toString().padLeft(3, '0');
    return TelemetryLog(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      timestamp: '$h:$m:$s.$ms',
      message: message,
      type: type,
    );
  }
}
