import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// BluetoothService manages all Bluetooth Classic (SPP) operations
/// including device scanning, connection management, and data communication
class BluetoothService extends ChangeNotifier {
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  final List<BluetoothDevice> _pairedDevices = [];
  bool _isConnecting = false;
  bool _isConnected = false;
  String _statusMessage = 'Disconnected';

  // Getters
  BluetoothConnection? get connection => _connection;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDevice> get pairedDevices => _pairedDevices;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;

  /// Initialize by fetching paired devices
  Future<void> initializeBluetooth() async {
    try {
      final List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      _pairedDevices.clear();
      _pairedDevices.addAll(devices);
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error getting paired devices: $e';
      notifyListeners();
    }
  }

  /// Connect to a Bluetooth device
  /// Returns true if connection successful, false otherwise
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting || _isConnected) {
      return false;
    }

    _isConnecting = true;
    _statusMessage = 'Connecting to ${device.name}...';
    notifyListeners();

    try {
      final BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      _connection = connection;
      _connectedDevice = device;
      _isConnected = true;
      _isConnecting = false;
      _statusMessage = 'Connected to ${device.name}';
      notifyListeners();

      // Start listening to incoming data
      _listenToIncomingData();

      return true;
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _statusMessage = 'Connection failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.close();
      }
      _connection = null;
      _connectedDevice = null;
      _isConnected = false;
      _statusMessage = 'Disconnected';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Disconnect error: $e';
      notifyListeners();
    }
  }

  /// Send a command (character or string) to the Arduino
  Future<void> sendCommand(String command) async {
    if (_connection == null || !_isConnected) {
      return;
    }

    try {
      _connection!.output.add(command.codeUnits);
      await _connection!.output.allSent;
    } catch (e) {
      _statusMessage = 'Send error: $e';
      notifyListeners();
    }
  }

  /// Listen to incoming Bluetooth data from the Arduino
  void _listenToIncomingData() {
    if (_connection == null) return;

    _connection!.input!.listen(
      (data) {
        // Convert bytes to string
        final String receivedData = String.fromCharCodes(data);

        // Check if metal was detected
        if (receivedData.contains('METAL_DETECTED')) {
          _handleMetalDetected();
        }
      },
      onDone: () {
        // Connection closed by device
        _isConnected = false;
        _connection = null;
        _connectedDevice = null;
        _statusMessage = 'Device disconnected';
        notifyListeners();
      },
      onError: (error) {
        _statusMessage = 'Bluetooth error: $error';
        notifyListeners();
      },
    );
  }

  /// Handle metal detection event
  void _handleMetalDetected() {
    // This method is called when "METAL_DETECTED" is received
    // The ControlScreen will listen to a broadcast/event to trigger the alert overlay
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
