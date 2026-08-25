import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/car_mode.dart';
import '../models/telemetry_log.dart';
import '../services/bluetooth_service.dart';

class CarControllerProvider extends ChangeNotifier {
  final BluetoothService _btService = BluetoothService();

  // Connection State
  String _status = 'disconnected'; // 'disconnected' | 'connecting' | 'connected'
  String get status => _status;
  bool get isConnected => _status == 'connected';
  bool get isConnecting => _status == 'connecting';

  String? _connectedDeviceName;
  String? get connectedDeviceName => _connectedDeviceName;
  String? _connectedDeviceAddress;
  String? get connectedDeviceAddress => _connectedDeviceAddress;

  String? _connectionPhase;
  String? get connectionPhase => _connectionPhase;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  // Active Operational Mode & Motion Vectors
  CarMode _currentMode = CarMode.menu;
  CarMode get currentMode => _currentMode;

  String _activeCommand = 'S'; // 'F', 'B', 'L', 'R', 'S'
  String get activeCommand => _activeCommand;

  // Horn State
  bool _isHornActive = false;
  bool get isHornActive => _isHornActive;

  int _speed = 120; // 0 - 255 PWM
  int get speed => _speed;

  // Telemetry & Metrics
  int _packetsSent = 0;
  int get packetsSent => _packetsSent;

  int? _lastLatencyMs;
  int? get lastLatencyMs => _lastLatencyMs;

  int _uptimeSeconds = 0;
  int get uptimeSeconds => _uptimeSeconds;
  Timer? _uptimeTimer;

  // Logs Feed
  final List<TelemetryLog> _logs = [];
  List<TelemetryLog> get logs => List.unmodifiable(_logs);

  // Device Discovery
  List<BluetoothDevice> _pairedDevices = [];
  List<BluetoothDevice> get pairedDevices => _pairedDevices;

  final List<BluetoothDiscoveryResult> _discoveredDevices = [];
  List<BluetoothDiscoveryResult> get discoveredDevices => _discoveredDevices;

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  StreamSubscription<BluetoothDiscoveryResult>? _scanSubscription;

  DateTime _lastSendTime = DateTime.now();

  CarControllerProvider() {
    addLog('System initialized. Ready for Bluetooth Classic connection.', type: LogType.info);
  }

  // Add Log Entry
  void addLog(String message, {LogType type = LogType.info}) {
    _logs.insert(0, TelemetryLog.now(message, type: type));
    if (_logs.length > 200) {
      _logs.removeLast();
    }
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void dismissError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Toggle Simulated Demo Mode
  void setDemoMode(bool value) {
    _isDemoMode = value;
    if (_isDemoMode) {
      addLog('Interactive Simulated Demo Mode enabled.', type: LogType.warning);
    } else {
      addLog('Live Bluetooth Hardware mode enabled.', type: LogType.info);
    }
    notifyListeners();
  }

  // Request Bluetooth and Location Permissions
  Future<bool> requestPermissions() async {
    try {
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      final allGranted = statuses.values.every((s) => s.isGranted || s.isLimited);
      return allGranted;
    } catch (e) {
      return false;
    }
  }

  // Load Paired Devices from Android Bluetooth Settings
  Future<void> fetchPairedDevices() async {
    try {
      _pairedDevices = await _btService.getBondedDevices();
      notifyListeners();
    } catch (e) {
      addLog('Failed to fetch paired devices: $e', type: LogType.error);
    }
  }

  // Start Discovery for Nearby JDY-31 / Classic Bluetooth Devices
  Future<void> startScan() async {
    if (_isScanning) return;

    await requestPermissions();
    await fetchPairedDevices();

    _discoveredDevices.clear();
    _isScanning = true;
    notifyListeners();

    try {
      _scanSubscription = _btService.startDiscovery().listen(
        (result) {
          final index = _discoveredDevices.indexWhere((r) => r.device.address == result.device.address);
          if (index >= 0) {
            _discoveredDevices[index] = result;
          } else {
            _discoveredDevices.add(result);
          }
          notifyListeners();
        },
        onDone: () {
          _isScanning = false;
          notifyListeners();
        },
        onError: (err) {
          _isScanning = false;
          addLog('Scan error: $err', type: LogType.error);
          notifyListeners();
        },
      );
    } catch (e) {
      _isScanning = false;
      addLog('Unable to start scan: $e', type: LogType.error);
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _btService.cancelDiscovery();
    _isScanning = false;
    notifyListeners();
  }

  // Connect to Target Bluetooth Device (e.g. JDY-31)
  Future<void> connect({BluetoothDevice? device}) async {
    _errorMessage = null;

    if (_isDemoMode) {
      _status = 'connecting';
      _connectionPhase = 'Initializing Simulated Nano Chassis...';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 600));
      _status = 'connected';
      _connectedDeviceName = 'Arduino Nano SPP (Simulated)';
      _connectedDeviceAddress = 'SIM:00:AA:BB:31';
      _connectionPhase = null;
      _startUptime();
      addLog('Connected to Simulated Arduino Smart Car!', type: LogType.success);
      HapticFeedback.mediumImpact();
      notifyListeners();
      return;
    }

    if (device == null) {
      _errorMessage = 'No Bluetooth device selected. Please pick your JDY-31 module from the list.';
      notifyListeners();
      return;
    }

    _status = 'connecting';
    _connectionPhase = 'Opening SPP RFCOMM Socket to ${device.name ?? device.address}...';
    notifyListeners();

    try {
      await stopScan();

      await _btService.connect(
        device.address,
        onDataReceived: (data) {
          addLog('[RX]: ${data.trim()}', type: LogType.info);
        },
        onDisconnected: () {
          handleDisconnection();
        },
        onError: (err) {
          _status = 'disconnected';
          _errorMessage = 'Connection lost: $err';
          addLog('Socket error: $err', type: LogType.error);
          _stopUptime();
          notifyListeners();
        },
      );

      _status = 'connected';
      _connectedDeviceName = device.name ?? 'JDY-31 Device';
      _connectedDeviceAddress = device.address;
      _connectionPhase = null;
      _startUptime();
      addLog('Connected to ${_connectedDeviceName!} via SPP RFCOMM!', type: LogType.success);
      HapticFeedback.heavyImpact();
      notifyListeners();
    } catch (e) {
      _status = 'disconnected';
      _connectionPhase = null;
      _errorMessage = 'Failed to connect to ${device.name ?? "device"}: $e\nEnsure module is powered and paired.';
      addLog('Connection failed: $e', type: LogType.error);
      notifyListeners();
    }
  }

  void handleDisconnection() {
    _status = 'disconnected';
    _connectedDeviceName = null;
    _connectedDeviceAddress = null;
    _currentMode = CarMode.menu;
    _activeCommand = 'S';
    _isHornActive = false;
    _stopUptime();
    addLog('Bluetooth link disconnected.', type: LogType.warning);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> disconnect() async {
    _isHornActive = false;
    if (_isDemoMode) {
      _status = 'disconnected';
      _connectedDeviceName = null;
      _connectedDeviceAddress = null;
      _currentMode = CarMode.menu;
      _stopUptime();
      addLog('Disconnected from Demo sandbox.', type: LogType.warning);
      notifyListeners();
      return;
    }

    await _btService.disconnect();
    handleDisconnection();
  }

  // Switch Active Operational Mode
  Future<void> setMode(CarMode mode) async {
    // Transmit the mode byte first, then commit state so the Arduino
    // receives the command before the UI navigates away.
    await sendCommand(mode.commandChar);
    _currentMode = mode;
    notifyListeners();
  }

  // Cancel Current Mode and Return to Menu
  void cancelModeAndReturnToMenu() {
    _isHornActive = false;
    sendCommand('S', isStop: true);
    _currentMode = CarMode.menu;
    notifyListeners();
  }

  // Horn Control ('H' for Sound ON, 'h' for Sound OFF)
  void setHorn(bool active) {
    if (_isHornActive == active) return;
    _isHornActive = active;
    sendCommand(active ? 'H' : 'h', priority: true);
    if (active) {
      HapticFeedback.heavyImpact();
      addLog('[HORN ON]: Horn activated (Tone 400Hz)', type: LogType.warning);
    } else {
      addLog('[HORN OFF]: Horn silenced', type: LogType.info);
    }
    notifyListeners();
  }

  // Quick Horn Beep / Pulse
  Future<void> pulseHorn({int durationMs = 250}) async {
    setHorn(true);
    await Future.delayed(Duration(milliseconds: durationMs));
    setHorn(false);
  }

  // Send Single Byte / String ASCII Command to Arduino
  Future<bool> sendCommand(String cmd, {bool isStop = false, bool priority = false}) async {
    if (cmd.isEmpty) return false;

    final isHornCmd = (cmd == 'H' || cmd == 'h');

    // Minimum throttle interval of 20ms to prevent buffer flooding, except for stops/horn
    final now = DateTime.now();
    if (!priority && !isStop && !isHornCmd && now.difference(_lastSendTime).inMilliseconds < 20) {
      addLog('[THROTTLED]: $cmd dropped (< 20ms since last send)', type: LogType.warning);
      notifyListeners();
      return false;
    }
    _lastSendTime = now;

    final stopwatch = Stopwatch()..start();

    if (['F', 'B', 'L', 'R', 'S'].contains(cmd)) {
      _activeCommand = cmd;
    }

    if (isStop) {
      HapticFeedback.heavyImpact();
    } else if (!isHornCmd) {
      HapticFeedback.lightImpact();
    }

    if (_isDemoMode) {
      _packetsSent++;
      final simLatency = Random().nextInt(8) + 6;
      _lastLatencyMs = simLatency;
      addLog('[DEMO TX SUCCESS]: $cmd (${cmd.length} byte, ~${simLatency}ms)', type: isStop ? LogType.warning : LogType.info);
      notifyListeners();
      return true;
    }

    if (!isConnected) {
      addLog('[TX ERROR]: "$cmd" — not connected to Bluetooth.', type: LogType.error);
      notifyListeners();
      return false;
    }

    final success = await _btService.sendCommand(cmd);
    stopwatch.stop();

    if (success) {
      _packetsSent++;
      _lastLatencyMs = stopwatch.elapsedMilliseconds;
      addLog('[TX SUCCESS]: $cmd (Latency: ${_lastLatencyMs}ms)', type: isStop ? LogType.warning : LogType.info);
    } else {
      addLog('[TX ERROR]: Failed to transmit "$cmd" over SPP socket.', type: LogType.error);
    }

    notifyListeners();
    return success;
  }

  // Update PWM Speed
  void updateSpeed(int newSpeed) {
    final clamped = newSpeed.clamp(0, 255);
    _speed = clamped;
    sendCommand('V$clamped');
    notifyListeners();
  }

  void _startUptime() {
    _uptimeSeconds = 0;
    _uptimeTimer?.cancel();
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _uptimeSeconds++;
      notifyListeners();
    });
  }

  void _stopUptime() {
    _uptimeTimer?.cancel();
    _uptimeTimer = null;
    _uptimeSeconds = 0;
  }

  @override
  void dispose() {
    _uptimeTimer?.cancel();
    _scanSubscription?.cancel();
    _btService.disconnect();
    super.dispose();
  }
}
