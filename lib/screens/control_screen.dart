import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../widgets/dpad_controller.dart';
import '../widgets/metal_alert_overlay.dart';
import '../widgets/mode_toggle_button.dart';
import 'bluetooth_screen.dart';

/// ControlScreen is the main dashboard for controlling the 4WD rover
/// It displays the D-pad controller, mode toggle, and metal detector status
class ControlScreen extends StatefulWidget {
  const ControlScreen({Key? key}) : super(key: key);

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late AnimationController _metalAlertAnimationController;
  bool _showMetalAlert = false;
  String _driveMode = '4WD'; // Default to 4WD

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for metal alert pulsing
    _metalAlertAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start listening to incoming Bluetooth data
    _startListeningToBluetoothData();
  }

  /// Start listening to incoming Bluetooth data from the Arduino
  void _startListeningToBluetoothData() {
    final bluetoothService = context.read<BluetoothService>();
    final connection = bluetoothService.connection;

    if (connection == null) return;

    connection.input!.listen(
      (data) {
        final String receivedData = String.fromCharCodes(data);

        // Check if metal was detected
        if (receivedData.contains('METAL_DETECTED')) {
          _handleMetalDetected();
        }
      },
      onDone: () {
        // Connection closed, return to Bluetooth screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BluetoothScreen(),
            ),
          );
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bluetooth error: $error')),
        );
      },
    );
  }

  /// Handle metal detection: show alert, play sound, and trigger haptics
  void _handleMetalDetected() async {
    if (_showMetalAlert) return; // Already showing alert

    setState(() {
      _showMetalAlert = true;
    });

    // Start pulsing animation
    _metalAlertAnimationController.repeat(reverse: true);

    // Trigger haptic feedback (3 times with 200ms gap)
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Dismiss the metal alert overlay
  void _dismissMetalAlert() {
    _metalAlertAnimationController.stop();
    setState(() {
      _showMetalAlert = false;
    });
  }

  /// Handle D-pad button press
  Future<void> _sendCommand(String command) async {
    final bluetoothService = context.read<BluetoothService>();
    await bluetoothService.sendCommand(command);
  }

  /// Handle drive mode toggle (2WD / 4WD)
  Future<void> _toggleDriveMode() async {
    final newMode = _driveMode == '2WD' ? '4WD' : '2WD';
    final command = newMode == '4WD' ? 'M4' : 'M2';

    setState(() {
      _driveMode = newMode;
    });

    await _sendCommand(command);
  }

  /// Handle disconnect button
  Future<void> _disconnect() async {
    final bluetoothService = context.read<BluetoothService>();
    await bluetoothService.disconnect();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BluetoothScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _metalAlertAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BluetoothService>(
          builder: (context, bluetoothService, _) {
            final deviceName = bluetoothService.connectedDevice?.name ?? 'Unknown';
            return Text(deviceName);
          },
        ),
        centerTitle: false,
        elevation: 4,
        actions: [
          // Connection status indicator (green dot when connected)
          Consumer<BluetoothService>(
            builder: (context, bluetoothService, _) {
              final isConnected = bluetoothService.isConnected;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // Disconnect button
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: _disconnect,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main control interface
          Column(
            children: [
              // Drive mode toggle
              Padding(
                padding: const EdgeInsets.all(16),
                child: ModeToggleButton(
                  mode: _driveMode,
                  onToggle: _toggleDriveMode,
                ),
              ),

              // D-pad controller
              Expanded(
                child: Center(
                  child: DPadController(
                    onCommand: _sendCommand,
                  ),
                ),
              ),

              // Metal detector status widget
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Scanning...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Metal alert overlay (full-screen with flashing)
          if (_showMetalAlert)
            MetalAlertOverlay(
              animationController: _metalAlertAnimationController,
              onDismiss: _dismissMetalAlert,
            ),
        ],
      ),
    );
  }
}
