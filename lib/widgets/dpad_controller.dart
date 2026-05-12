import 'package:flutter/material.dart';

/// DPadController widget provides a directional pad interface with 4 arrow buttons
/// and a center STOP button. Uses onTapDown/onTapUp to send commands when button
/// is pressed/released (releasing any direction sends 'S' for stop)
class DPadController extends StatelessWidget {
  final Function(String) onCommand;

  const DPadController({
    Key? key,
    required this.onCommand,
  }) : super(key: key);

  /// Build a directional button with given label, icon, and command
  Widget _buildDPadButton({
    required String label,
    required IconData icon,
    required String command,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) {
        // Release any button sends STOP command
        onCommand('S');
      },
      onTapCancel: () {
        // If tap is cancelled, also send STOP
        onCommand('S');
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the center STOP button
  Widget _buildCenterStopButton() {
    return GestureDetector(
      onTapDown: (_) => onCommand('S'),
      onTapUp: (_) {
        // Optional: could send another command on release if needed
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_circle, color: Colors.white, size: 36),
            SizedBox(height: 4),
            Text(
              'STOP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // UP button
        _buildDPadButton(
          label: 'UP',
          icon: Icons.arrow_upward,
          command: 'F',
          onPressed: () => onCommand('F'),
        ),
        const SizedBox(height: 20),

        // LEFT, CENTER STOP, RIGHT buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LEFT button
            _buildDPadButton(
              label: 'LEFT',
              icon: Icons.arrow_back,
              command: 'L',
              onPressed: () => onCommand('L'),
            ),
            const SizedBox(width: 40),

            // CENTER STOP button
            _buildCenterStopButton(),
            const SizedBox(width: 40),

            // RIGHT button
            _buildDPadButton(
              label: 'RIGHT',
              icon: Icons.arrow_forward,
              command: 'R',
              onPressed: () => onCommand('R'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // DOWN button
        _buildDPadButton(
          label: 'DOWN',
          icon: Icons.arrow_downward,
          command: 'B',
          onPressed: () => onCommand('B'),
        ),
      ],
    );
  }
}
