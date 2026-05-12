import 'package:flutter/material.dart';

/// ModeToggleButton allows switching between 2WD and 4WD drive modes
/// Sends "M2" or "M4" command to the Arduino when toggled
class ModeToggleButton extends StatelessWidget {
  final String mode;
  final VoidCallback onToggle;

  const ModeToggleButton({
    Key? key,
    required this.mode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2WD option
          Expanded(
            child: GestureDetector(
              onTap: mode == '2WD' ? null : onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: mode == '2WD' ? Colors.blue[600] : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '2WD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mode == '2WD' ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 4WD option
          Expanded(
            child: GestureDetector(
              onTap: mode == '4WD' ? null : onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: mode == '4WD' ? Colors.blue[600] : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '4WD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mode == '4WD' ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
