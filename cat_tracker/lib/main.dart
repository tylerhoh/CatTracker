// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:provider/provider.dart';
// import 'src/ble/ble_logger.dart';
// import 'src/ble/ble_scanner.dart';
// import 'src/ble/ble_device_connector.dart';
// import 'src/ble/ble_device_interactor.dart';
// import 'src/ble/ble_status_monitor.dart';
// import 'src/ui/ble_status_screen.dart';
// import 'src/ui/device_list.dart';

// const _themeColor = Colors.lightGreen;

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
  
  
//   final ble = FlutterReactiveBle();
//   final bleLogger = BleLogger(ble: ble);
//   final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
//   final monitor = BleStatusMonitor(ble);
//   final connector = BleDeviceConnector(
//     ble: ble,
//     logMessage: bleLogger.addToLog,
//   );
//   final serviceDiscoverer = BleDeviceInteractor(
//     bleDiscoverServices: ble.discoverAllServices,
//     readCharacteristic: ble.readCharacteristic,
//     writeWithResponse: ble.writeCharacteristicWithResponse,
//     writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
//     subscribeToCharacteristic: ble.subscribeToCharacteristic,
//     logMessage: bleLogger.addToLog,
//   );
//   runApp(
//     MultiProvider(
//       providers: [
//         Provider.value(value: scanner),
//         Provider.value(value: monitor),
//         Provider.value(value: connector),
//         Provider.value(value: serviceDiscoverer),
//         Provider.value(value: bleLogger),
//         StreamProvider<BleScannerState?>(
//           create: (_) => scanner.state,
//           initialData: const BleScannerState(
//             discoveredDevices: [],
//             scanIsInProgress: false,
//           ),
//         ),
//         StreamProvider<BleStatus?>(
//           create: (_) => monitor.state,
//           initialData: BleStatus.unknown,
//         ),
//         StreamProvider<ConnectionStateUpdate>(
//           create: (_) => connector.state,
//           initialData: const ConnectionStateUpdate(
//             deviceId: 'Unknown device',
//             connectionState: DeviceConnectionState.disconnected,
//             failure: null,
//           ),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Flutter Reactive BLE example',
//         color: _themeColor,
//         theme: ThemeData(primarySwatch: _themeColor),
//         home: const HomeScreen(),
//       ),
//     ),
//   );
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) => Consumer<BleStatus?>(
//         builder: (_, status, __) {
//           if (status == BleStatus.ready) {
            
//             return const DeviceListScreen();
//           } else {
//             return BleStatusScreen(status: status ?? BleStatus.unknown);
//           }
//         },
//       );
// }
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BleScanner(),
    );
  }
}

class BleScanner extends StatefulWidget {
  const BleScanner({super.key});

  @override
  _BleScannerState createState() => _BleScannerState();
}

class _BleScannerState extends State<BleScanner> {
  final flutterReactiveBle = FlutterReactiveBle();
  late Stream<DiscoveredDevice> scanStream;
  final List<double> distanceBuffer = [-1, -1, -1];
  int numOfSamples = 0;
  double distance = -1;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.every((status) => status.isGranted)) {
      startScan();
    } else {
      // Handle permissions not granted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions not granted')),
      );
    }
  }

  void startScan() {
    scanStream = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    );

    scanStream.listen((device) {
      if (device.name.contains('ARO')) {
        final currentDistance = calculateDistance(device.rssi);
        setState(() {
          distanceBuffer[numOfSamples % 3] = currentDistance;
          numOfSamples++;
          if (!distanceBuffer.contains(-1)) {
            distance = distanceBuffer.reduce((a, b) => a + b) /
                distanceBuffer.length;
          } else {
            distance = -1;
          }
        });
      }
    }, onError: (error) {
      // Handle scan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan error: $error')),
      );
    });
  }

  double calculateDistance(int rssi) {
    return rssi == 0 ? -1 : pow(10, (-75 - rssi) / (10 * 3)).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Cat'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Meters',
                      style: TextStyle(fontSize: 50, color: Colors.black),
                    ),
                    Text(
                      distance.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 100, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'FIND THE DISTANCE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
