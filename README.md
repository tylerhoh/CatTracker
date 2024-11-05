# Cat Tracker - BLE Beacon Cat Collar with Distance Measuring and Tracking

## Table of Contents
1. [Project Requirements](#project-requirements)
2. [What, How, and Why](#what-how-and-why)
3. [References and Articles](#references-and-articles)
4. [Components and Setup](#components-and-setup)
5. [Step by Step Instructions](#step-by-step-instructions)

## Project Requirements

### Functional Requirements
#### App/UI
- **Display Nearby Bluetooth Devices**: Scan and display a list of nearby Bluetooth devices.
- **Connection Status**: Show if connected or disconnected.
- **Distance and Direction Display**: Calculate and display distance and direction to the collar.

... (and so on)

### Non-Functional Requirements

...

## What, How, and Why?

**What?**  
CatTracker is a digital collar designed to help owners track their cats within the home using a smartphone.

**How?**  
Utilizes BLE beacon technology to track and measure the cat's distance and direction relative to the smartphone user.

**Why?**  
To help pet owners locate cats who are hiding out of sight.

...

## Components and Setup
- **BLE Beacon**: [AROCO Industrial Grade BLE Beacon](https://www.rodsum.com/product-page/ac-ble-t110g).
- **Device**: iOS or Android smartphone required for compatibility.

...

## Step-by-Step Instructions
1. **Listen for BLE events**: Use UI dispatch for starting and stopping BLE scans.
2. **State Management**: Use a reactive approach to manage BLE state changes.
3. ...

## References and Articles
- [Optimizing Latency on BLE Data Transfer](https://medium.com/@nijmehar16/optimising-latency-on-ble-data-transfer-from-a-mobile-app-built-in-flutter-fe7efe699c35)
- [React Native Beacon Sample](https://github.com/friyiajr/BLEBeaconSample/blob/main/useBLE.tsx)

...

### Demo
In the demo, I first clicked the button labeled "Find the Distance" which starts finding the RSSI signals after Bluetooth pairing is complete. 

Iphone in hand, I walked away from the bluetooth beacon. 

https://github.com/user-attachments/assets/72a708d9-b94a-4b51-aa67-2c0705a92ded

The app calculated the distance based on the beacon's RSSI signals. 
