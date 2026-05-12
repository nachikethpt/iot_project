import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// MetalAlertOverlay displays a full-screen red flashing overlay when metal is detected
/// Plays a warning sound and triggers haptic feedback
class MetalAlertOverlay extends StatefulWidget {
  final AnimationController animationController;
  final VoidCallback onDismiss;

  const MetalAlertOverlay({
    Key? key,
    required this.animationController,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<MetalAlertOverlay> createState() => _MetalAlertOverlayState();
}

class _MetalAlertOverlayState extends State<MetalAlertOverlay> {
  late AudioPlayer _audioPlayer;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playWarningSound();
  }

  /// Play the warning beep sound
  Future<void> _playWarningSound() async {
    if (_soundPlayed) return;

    try {
      // Play the bundled beep.mp3 asset
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
      _soundPlayed = true;
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        // Opacity animation: pulsing effect (0.5 to 1.0)
        final opacity = 0.5 + (widget.animationController.value * 0.5);

        return Container(
          color: Colors.red.withOpacity(opacity * 0.7),
          child: Stack(
            children: [
              // Full-screen overlay
              GestureDetector(
                onTap: widget.onDismiss,
                child: Container(
                  color: Colors.transparent,
                ),
              ),

              // Alert content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '⚠ Metal Detected!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      onPressed: widget.onDismiss,
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
