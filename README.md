# 4WD Metal Detecting Rover 🚗⚡

A Bluetooth-controlled 4WD rover built with an Arduino Uno, an L293D motor shield, and a custom 555-timer metal detector circuit. The rover is controlled via a custom mobile application.

## Features
* **Full 4WD Control:** Independent control of all four motors via Bluetooth.
* **Drive Modes:** Toggle between 2WD (battery saver) and 4WD (max traction) modes.
* **Metal Detection:** Custom 555-timer LC oscillator circuit detects metal via frequency shifts.
* **App Integration:** Mobile app provides directional controls and real-time visual/audio alerts when metal is detected.

## Hardware Components
* Arduino Uno
* L293D Motor Drive Shield (HW-130)
* HC-05 / HC-06 Bluetooth Module
* 4x DC Gear Motors and Wheels
* Custom 555-Timer Metal Detector Circuit (Oscillator coil design)
* Power Supply (e.g., 9V battery for Arduino, separate high-current pack for Motors)

## Wiring & Pinout Guide

| Component | Arduino / Shield Pin | Notes |
| :--- | :--- | :--- |
| **Bluetooth RX** | `A1` (TX via SoftwareSerial) | Connects to A1 to prevent USB upload conflicts. |
| **Bluetooth TX** | `A0` (RX via SoftwareSerial) | Connects to A0. |
| **Bluetooth Power** | `5V` & `GND` | Standard logic power. |
| **Metal Detector Signal**| `A2` | Connects to Pin 3 (Output) of the 555 IC. |
| **Metal Detector Power** | `5V` & `GND` | **CRITICAL:** Do not use a 9V battery for the 555 circuit to avoid damaging the Arduino. Power it from the 5V shield pin. |
| **Motors 1-4** | `M1, M2, M3, M4` | Blue screw terminals on the L293D shield. |
| **Motor Power** | `EXT_PWR` | Remove the yellow 'PWR' jumper if using a voltage higher than 9V or a high-current battery pack. |

## Software Setup

### Arduino Firmware
1. Open the `Arduino/` folder in the Arduino IDE.
2. Ensure you have the **Adafruit Motor Shield library (v1)** installed.
3. Select the correct COM port and board (Arduino Uno).
4. Upload `rover_main.ino`.

### Mobile Application
*(Add instructions here based on what your AI code generator provides for Flutter or React Native, e.g., `flutter run` or `npm install && npx react-native run-android`)*

## Metal Detector Calibration
The metal detector uses the `pulseIn()` function to read the frequency from the 555 timer. The baseline is established automatically upon startup.
* If you are getting false positives, increase the `threshold` variable in the Arduino sketch.
* Ensure the rover is stationary and the coil is clear of metal during the first 3 seconds of powering on.
* 
