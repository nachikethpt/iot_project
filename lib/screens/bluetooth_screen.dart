import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'control_screen.dart';

/// BluetoothScreen is the landing screen where users can scan for and select
/// paired HC-05/HC-06 Bluetooth devices to control the 4WD rover
class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    _initializeBluetoothAndRequestPermissions();
  }

  /// Request necessary Bluetooth permissions and initialize the service
  Future<void> _initializeBluetoothAndRequestPermissions() async {
    // Request runtime permissions for Android 12+
    final status = await Permission.bluetooth.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth permission denied')),
        );
      }
      return;
    }

    // Initialize Bluetooth service to fetch paired devices
    if (mounted) {
      await context.read<BluetoothService>().initializeBluetooth();
    }
  }

  /// Handle device selection and attempt connection
  Future<void> _connectToDevice(BuildContext context, int index) async {
    final bluetoothService = context.read<BluetoothService>();
    final device = bluetoothService.pairedDevices[index];

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Attempt connection
    final success = await bluetoothService.connectToDevice(device);

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (success) {
      // Navigate to control screen on successful connection
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ControlScreen(),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bluetoothService.statusMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4WD Rover Controller'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Consumer<BluetoothService>(
        builder: (context, bluetoothService, _) {
          final pairedDevices = bluetoothService.pairedDevices;

          if (pairedDevices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bluetooth_disabled,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No paired devices found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initializeBluetoothAndRequestPermissions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pairedDevices.length,
            itemBuilder: (context, index) {
              final device = pairedDevices[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text(device.address),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _connectToDevice(context, index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
