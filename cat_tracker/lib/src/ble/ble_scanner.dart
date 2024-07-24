import 'dart:async';
import 'dart:io';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'reactive_state.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'ble_distance_tracker.dart';

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner({
    required FlutterReactiveBle ble,
    required void Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;
//whenever BleScanner object is called in other classes, it requires these two params
  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  final StreamController<BleScannerState> _stateStreamController = StreamController();
  final List<DiscoveredDevice> _devices = [];
  //final BleDistanceTracker _distanceTracker;

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  StreamSubscription<DiscoveredDevice>? _subscription;

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }
  
  Future<void> startScan(List<Uuid> serviceIds) async {
    if (await _checkPermissions()) {
      print('start ble discovery');
      _logMessage('Start BLE discovery');
      _devices.clear();
      await _subscription?.cancel();
      _subscription = _ble
          .scanForDevices(
            withServices: serviceIds,
            scanMode: ScanMode.lowLatency,
          )
          .listen((device) {
            final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
            if (knownDeviceIndex >= 0) {
              _devices[knownDeviceIndex] = device;
            } else {
              _devices.add(device);
            }
            // _distanceTracker.updateDistance(device);
            _pushState();
          }, onError: (Object e) => _logMessage('Device scan fails with error: $e'));
      _pushState();
    } else {
      _logMessage('Permissions not granted');
    }
  }

  Future<void> stopScan() async {
    _logMessage('Stop BLE discovery');
    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  Future<bool> _checkPermissions() async {
    print('permissions say hello');
    // PermissionStatus permission = await Permission.bluetooth.status;
//1. get deviceInfo
//2. confirm if Android. if android, ask permissions
//3. else Ios, confirm  permissions natively
    if(Platform.isAndroid){
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();//good
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;//good
      final apiLevel = androidInfo.version.sdkInt;//good
      if (apiLevel >= 31) {
         final bluetoothScanStatus = await Permission.bluetoothScan.status;
         final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
         final locationStatus = await Permission.location.status;

        if (!bluetoothScanStatus.isGranted || !bluetoothConnectStatus.isGranted || !locationStatus.isGranted) {
        final bluetoothScanResult = await Permission.bluetoothScan.request();
        final bluetoothConnectResult = await Permission.bluetoothConnect.request();
        final locationResult = await Permission.location.request();
        return bluetoothScanResult.isGranted && bluetoothConnectResult.isGranted && locationResult.isGranted;
        }
      }
    } else if (Platform.isIOS){
      print('iphone says hello');
      final bluetoothStatus = await Permission.bluetooth.status;
      final locationStatus = await Permission.location.status;

      if (!bluetoothStatus.isGranted || !locationStatus.isGranted) {
        final bluetoothResult = await Permission.bluetooth.request();
        final locationResult = await Permission.location.request();
        return bluetoothResult.isGranted && locationResult.isGranted;
      }
    }
  return true;
  }
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
    //required this.distance,//should bleScannerState require distance??
    //it makes sense for devices that are scanned, but how necessary is it for devices that are on the list also provide distance if connected to it?
    //especially if distance should only be calculated if device name starts with aro.
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
  //final double distance;
}
