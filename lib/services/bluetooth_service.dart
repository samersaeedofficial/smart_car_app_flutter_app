import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _streamSubscription;

  bool get isConnected => _connection != null && _connection!.isConnected;

  // Check if Bluetooth adapter is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await FlutterBluetoothSerial.instance.isEnabled ?? false;
    } catch (_) {
      return false;
    }
  }

  // Request user to enable Bluetooth
  Future<bool> requestEnable() async {
    try {
      return await FlutterBluetoothSerial.instance.requestEnable() ?? false;
    } catch (_) {
      return false;
    }
  }

  // Get list of already bonded / paired devices in Android
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (_) {
      return [];
    }
  }

  // Start discovery stream for nearby Classic Bluetooth devices (e.g. JDY-31, HC-05)
  Stream<BluetoothDiscoveryResult> startDiscovery() {
    return FlutterBluetoothSerial.instance.startDiscovery();
  }

  Future<void> cancelDiscovery() async {
    try {
      await FlutterBluetoothSerial.instance.cancelDiscovery();
    } catch (_) {}
  }

  // Connect to target device address via RFCOMM SPP socket
  Future<void> connect(
    String address, {
    required Function(String data) onDataReceived,
    required Function() onDisconnected,
    required Function(dynamic error) onError,
  }) async {
    try {
      // Disconnect any existing session
      await disconnect();

      _connection = await BluetoothConnection.toAddress(address);

      _streamSubscription = _connection!.input?.listen(
        (Uint8List data) {
          final str = ascii.decode(data);
          onDataReceived(str);
        },
        onDone: () {
          disconnect();
          onDisconnected();
        },
        onError: (err) {
          disconnect();
          onError(err);
        },
      );
    } catch (e) {
      disconnect();
      rethrow;
    }
  }

  // Send ASCII string command (e.g. 'F', 'B', 'L', 'R', 'S', 'A', 'M', 'G', 'V180')
  Future<bool> sendCommand(String cmd) async {
    if (!isConnected || _connection == null) return false;

    try {
      final bytes = Uint8List.fromList(utf8.encode(cmd));
      _connection!.output.add(bytes);
      await _connection!.output.allSent;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Gracefully close connection
  Future<void> disconnect() async {
    try {
      if (isConnected) {
        // Send emergency stop before closing socket
        try {
          _connection?.output.add(Uint8List.fromList(utf8.encode('S')));
          await _connection?.output.allSent;
        } catch (_) {}
      }
      await _streamSubscription?.cancel();
      _streamSubscription = null;
      await _connection?.finish();
      _connection?.dispose();
      _connection = null;
    } catch (_) {
      _connection = null;
    }
  }
}
