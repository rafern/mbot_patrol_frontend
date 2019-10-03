import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'dart:async';

import 'bluetooth_device_wrapper.dart';

// The bluetooth manager is a static class that manages the bluetooth adapter.
// Bluetooth devices are abstracted by the BluetoothDeviceWrapper class. A new
// connection can be made and is represented by the BluetoothConnection class
class BluetoothManager {
  static StreamSubscription<BluetoothDiscoveryResult> _discoveryStream;

  // (Re)start discovery. Needs to have a callback for when a device is
  // discovered and can have a callback for when discovery stops
  static Future<void> startDiscovery(Function(BluetoothDeviceWrapper) onDevice, [Function onDone]) async {
    await stopDiscovery();

    _discoveryStream = FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      BluetoothDeviceWrapper wrapper = BluetoothDeviceWrapper.fromDiscovery(device);
      onDevice(wrapper);
    });

    _discoveryStream.onDone(onDone);
  }

  // Stop discovery if underway
  static Future<void> stopDiscovery() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    _discoveryStream = null;
  }
}