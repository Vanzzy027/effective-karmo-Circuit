# Karmo Controller App

## About Karmo Controller

**Karmo** lets you control your ESP8266-based smart devices over WiFi.  
Use sliders to adjust dimmers, servos, or other actuators smoothly and in real time.

### Key Features
- Discover and connect to devices on your local network
- Live control with smooth motion for dimmers and servos
- Manage multiple devices at once
- Syncs device state automatically with the app
- Robust, non-blocking communication between app and hardware

**Developer:** SWE Evans (VansKE)  
**License:** MIT © SWE Evans

---

## App Overview

The Karmo Controller App is a **Flutter mobile application** designed to control ESP8266-based hardware. It allows users to pair, monitor, and operate multiple devices over a local WiFi network without relying on Bluetooth. The app communicates via **HTTP requests with JSON responses**, ensuring stable, fast, and reliable control of actuators like servos or dimmers.

**Why this approach?**
- Avoids WiFi AP limitations and mobile hotspot instability
- Smooth device control and live UI updates
- Devices identified by **stable device IDs**, even if their IP changes
- Multiple devices can be controlled simultaneously

---

## How Devices Pair

1. **Connect to the Same WiFi Network**  
   Ensure your phone and Karmo devices share the same network.

2. **Automatic Discovery**  
   The app scans the subnet for devices exposing the `/getState` endpoint.  
   Each device responds with:
    - `deviceId` → stable identifier
    - `name` → user-friendly device label
    - `angle` → current actuator position

3. **Select a Device**  
   Pick a device from the list to pair.  
   The app maintains a connection using the device’s IP and ID.

4. **Control Devices**
    - Use sliders to send position updates.
    - Firmware ensures smooth motion and **prioritizes live user input** to prevent queued commands.

---

## Supported Hardware

- ESP8266-based controllers (NodeMCU, Wemos D1 Mini, etc.)
- Actuators: servos, dimmers, PWM-controlled devices
- Firmware exposes two main endpoints:
    - `GET /getState` → fetch current state
    - `GET /setServo?angle=0..180` → update actuator position

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/Vanzzy027/effective-karmo-Circuit.git
cd effective-karmo-Circuit
