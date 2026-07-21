# 4WD Rover Controller - Flutter Mobile App & Autonomous Rover Simulators

A Flutter mobile application (Android-first) designed to control a 4WD metal detecting rover over Bluetooth Classic (HC-05/HC-06), along with companion web-based simulators for beach-cleaning and minefield-clearing autonomous rovers.

## Features

### Mobile App (Flutter)
- **Bluetooth Classic (SPP) Connection**: Connect to HC-05 or HC-06 Bluetooth modules
- **D-Pad Controller**: Intuitive directional control with 4 arrow buttons and a center STOP button
- **Drive Mode Toggle**: Switch between 2WD and 4WD modes
- **Metal Detection Alert**: Full-screen flashing overlay with sound and haptic feedback when metal is detected
- **Connection Status Indicator**: Real-time connection status in the app bar
- **Runtime Permissions**: Android 12+ runtime permission handling

### Web-Based Simulators
- **Beach-Cleaning Rover Simulator** (`simulations/beach.html`): Autonomous path-planning for beach cleanup
  - S-Curve (lawnmower sweep), Spiral, and Random sweep algorithms
  - Metal object detection with visual feedback
  - Real-time coverage tracking
  
- **Minefield Rover Simulator** (`simulations/minefield.html`): Autonomous mine detection and clearance
  - Multiple mine variant types (pressure mines, anti-tank, bounding mines)
  - Advanced sensor visualization with proximity danger glow
  - Manual WASD control and autonomous path modes
  - Mission logging with real-time status updates

## Project Structure

```
lib/
  main.dart                    # App entry point with Provider setup
  screens/
    bluetooth_screen.dart      # Device scanning and connection screen
    control_screen.dart        # Main control dashboard
  widgets/
    dpad_controller.dart       # Directional pad controller widget
    metal_alert_overlay.dart   # Full-screen metal detection alert
    mode_toggle_button.dart    # 2WD/4WD mode toggle
  services/
    bluetooth_service.dart     # Bluetooth Classic (SPP) management

simulations/
  beach.html                   # Autonomous beach-cleaning rover simulator
  minefield.html               # Autonomous minefield rover simulator

assets/
  sounds/
    beep.mp3                   # Alert warning sound

android/
  app/src/main/AndroidManifest.xml  # Bluetooth permissions

docs/
  ABSTRACT.docx                # Project abstract documentation
  Complete specification.docx  # Full technical specification
  drawing_cwc.docx             # Hardware design drawings
```

## Hardware Requirements

- **Bluetooth Module**: HC-05 or HC-06 (Classic Bluetooth, SPP profile)
- **Arduino or Microcontroller** sending:
  - Single characters: `'F'` (forward), `'B'` (backward), `'L'` (left), `'R'` (right), `'S'` (stop)
  - Strings: `"M2"` (2WD mode), `"M4"` (4WD mode)
  - Metal detection: `"METAL_DETECTED\n"`

## Installation

### 1. Clone and Setup

```bash
git clone <repo-url>
cd iot_rover_controller
flutter pub get
```

### 2. Add Sound Asset

Place your `beep.mp3` file in:
```
assets/sounds/beep.mp3
```

### 3. Android Configuration

- **Target SDK**: 31 or higher
- **Package name**: Update in `android/app/build.gradle` if needed
- **Permissions**: Already configured in `AndroidManifest.xml`

### 4. Build and Run

```bash
flutter run
```

### 5. Run Web Simulators

Open the simulator files directly in a web browser:
- Beach Cleaning: Open `simulations/beach.html` in your browser
- Minefield Detection: Open `simulations/minefield.html` in your browser

## Dependencies

### Flutter App
- **flutter_bluetooth_serial** (^0.4.0): Bluetooth Classic communication
- **provider** (^6.0.0): State management
- **audioplayers** (^5.1.0): Sound playback
- **permission_handler** (^11.4.0): Runtime permissions

### Web Simulators
- Pure HTML5 Canvas with vanilla JavaScript (no dependencies)

## Usage

### Mobile App

#### 1. Bluetooth Connection
- Launch the app
- Grant Bluetooth permissions when prompted
- Select your HC-05/HC-06 device from the list
- Wait for connection confirmation

#### 2. Control the Rover
- Use the **D-pad** to control movement:
  - **UP** → Forward (`'F'`)
  - **DOWN** → Backward (`'B'`)
  - **LEFT** → Left turn (`'L'`)
  - **RIGHT** → Right turn (`'R'`)
  - **STOP** → Stop all motors (`'S'`)
- Release any button to automatically send STOP

#### 3. Drive Mode
- Toggle between **2WD** and **4WD**
  - 2WD sends `"M2"` to Arduino
  - 4WD sends `"M4"` to Arduino

#### 4. Metal Detection
- When `"METAL_DETECTED"` is received from Arduino:
  - Full-screen red flashing overlay appears
  - Warning beep plays
  - Device vibrates 3 times
  - Tap "Dismiss" to close alert

### Web Simulators

#### Beach-Cleaning Rover
1. Open `simulations/beach.html` in your browser
2. Select a cleaning mode: S-Curve, Spiral, or Random Sweep
3. Click **START** to begin autonomous operation
4. The rover will follow the selected algorithm and detect buried metal objects
5. Press **EMERGENCY STOP** to halt operations
6. Click **Reset & Rescatter** to restart with new object placement

#### Minefield Rover
1. Open `simulations/minefield.html` in your browser
2. Select detection mode: S-Curve, Spiral, or Random Sweep
3. Click **Start Auto** to begin autonomous operation
4. Use **WASD keys** for manual override control
5. Monitor the mission log for detection events
6. Press **E-Stop** to halt immediately on mine detection

## Key Implementation Details

### Bluetooth Service (`bluetooth_service.dart`)
- Uses `FlutterBluetoothSerial` for Classic Bluetooth (SPP)
- Manages connection lifecycle
- Listens to incoming data with `connection.input!.listen()`
- Parses incoming bytes: `String.fromCharCodes(data)`
- Detects `"METAL_DETECTED"` string in received data

### Control Screen (`control_screen.dart`)
- Maintains D-pad state and drive mode
- Listens to Bluetooth stream for metal detection
- Triggers alert overlay on detection
- Handles haptic feedback with `HapticFeedback.vibrate()`
- Gracefully handles disconnection

### D-Pad Controller (`dpad_controller.dart`)
- Uses `GestureDetector` with `onTapDown` and `onTapUp`
- Sends direction on press, STOP on release
- Styled with custom button designs

### Metal Alert Overlay (`metal_alert_overlay.dart`)
- Pulsing animation using `AnimationController`
- Plays sound with `audioplayers`
- Shows dismiss button
- Non-blocking: doesn't interrupt Bluetooth listener

### Beach Simulator (`simulations/beach.html`)
- **Path Algorithms**:
  - S-Curve: Lawnmower-style zigzag sweep for complete coverage
  - Spiral: Concentric circular expansion from center
  - Random: Roomba-style bounce algorithm with edge detection
- **Detection**: Proximity-based mine detection within sensor radius
- **Visualization**: Sand texture, cleaned trail overlay, metal object highlighting
- **Rendering**: Canvas 2D with animated sensor rings and object pulsing

### Minefield Simulator (`simulations/minefield.html`)
- **Mine Types**: Three variants (round pressure mines, anti-tank boxes, bounding mines)
- **Dual Control**: Automatic path execution or manual WASD keyboard control
- **Alert System**: Flashing overlay with hazard tape border on detection
- **Logging**: Real-time mission event log with color-coded severity
- **Terrain**: Procedurally generated dirt terrain with rocks, cracks, and atmospheric effects
- **Status Bar**: Live coverage %, mine count, control mode, and Bluetooth command display

## Android Permissions

Required permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

Runtime permissions are handled via `permission_handler` package.

## Troubleshooting

### Device Not Found
- Ensure Bluetooth is enabled on Android device
- Pair the HC-05/HC-06 in Android settings first
- Check that device name appears in Bluetooth settings

### Connection Fails
- Verify HC-05/HC-06 is powered and in range
- Check that pincode is correct (default: 1234 or 0000)
- Try restarting the Bluetooth module

### No Sound on Alert
- Ensure `assets/sounds/beep.mp3` exists
- Check `pubspec.yaml` includes the asset path
- Run `flutter clean` and rebuild if needed

### Permissions Error (Android 12+)
- App requests permissions at runtime
- Accept all Bluetooth permissions when prompted
- Go to Settings > Apps > 4WD Rover Controller > Permissions if needed

### Simulator Not Loading
- Ensure you're opening `.html` files with a modern browser (Chrome, Firefox, Safari, Edge)
- Check browser console for JavaScript errors (press F12)
- Some browsers may require `http://` (not `file://`) due to CORS — consider using a local web server
- Try: `python -m http.server 8000` then visit `http://localhost:8000/simulations/`

## Documentation

Complete project documentation is available in the `docs/` directory:
- **ABSTRACT.docx** - High-level project overview
- **Complete specification.docx** - Detailed technical and hardware specifications
- **drawing_cwc.docx** - Circuit diagrams and hardware design drawings

## License

MIT License

---

**Note**: 
- This app is designed for Android 12+ (SDK 31+)
- Bluetooth Classic (HC-05/HC-06) is used instead of BLE due to Arduino SPP communication requirements
- Web simulators are fully standalone and require only a modern web browser with Canvas 2D support
