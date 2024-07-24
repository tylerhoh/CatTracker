import 'dart:math';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:meta/meta.dart';

import 'reactive_state.dart';

class BleDistanceTracker implements ReactiveState<BleDistanceTrackerState> {
  BleDistanceTracker({
    required this.updateDistanceCallback,
  }) : distanceBuffer = [-1.0, -1.0, -1.0];
  
   // _distanceTracker = BleDistanceTracker(
       //   distanceBuffer: [-1.0, -1.0, -1.0],
     //     updateDistanceCallback: (double distance) {
         //   _distance = distance;
          //},
        //)

  final List<double> distanceBuffer;
  final void Function(double distance) updateDistanceCallback;
  
  //double _distance = -1.0;
  int _numOfSamples = 0;
  void updateDistance(DiscoveredDevice device) {
      final currentDistance = pow(10, (-75 - device.rssi) / (10 * 3)) as double;

      distanceBuffer[_numOfSamples % 3] = currentDistance;

      if (distanceBuffer.contains(-1.0)) {
        updateDistanceCallback(-1.0);
      } else {
        final sum = distanceBuffer.reduce((a, b) => a + b);
        final averageDistance = sum / distanceBuffer.length;
        updateDistanceCallback(averageDistance);
      }
      _numOfSamples++;
  }
  
  @override
  // TODO: implement state
  Stream<BleDistanceTrackerState> get state => throw UnimplementedError();
}
@immutable
class BleDistanceTrackerState {
  const BleDistanceTrackerState({
    required this.distance,//should bleScannerState require distance??
    //it makes sense for devices that are scanned, but how necessary is it for devices that are on the list also provide distance if connected to it?
    //especially if distance should only be calculated if device name starts with aro.
  });
  final double distance;
}