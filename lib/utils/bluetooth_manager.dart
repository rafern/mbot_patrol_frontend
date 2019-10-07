import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'dart:async';

import 'bluetooth_device_wrapper.dart';

// The bluetooth manager is a static class that manages the bluetooth adapter.
// Bluetooth devices are abstracted by the BluetoothDeviceWrapper class. A new
// connection can be made and is represented by the BluetoothConnection class
class BluetoothManager {
  static StreamSubscription<BluetoothDiscoveryResult> _discoveryStream;

  // Make sure the bluetooth adapter is enabled
  static Future<bool> setEnabled(bool enable) async {
    if(enable != await FlutterBluetoothSerial.instance.isEnabled) {
      if(enable)
        return await FlutterBluetoothSerial.instance.requestEnable();
      else
        return await FlutterBluetoothSerial.instance.requestDisable();
    }

    return true;
  }

  // (Re)start discovery. Needs to have a callback for when a device is
  // discovered and can have a callback for when discovery stops
  static Future<bool> startDiscovery(Function(BluetoothDeviceWrapper) onDevice, [Function onDone, Function(String) onError]) async {
    if(!await stopDiscovery(onError))
      return false;

    _discoveryStream = FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      BluetoothDeviceWrapper wrapper = BluetoothDeviceWrapper.fromDiscovery(device);
      onDevice(wrapper);
    });

    _discoveryStream.onDone(onDone);

    return true;
  }

  // Stop discovery if underway
  static Future<bool> stopDiscovery([Function(String) onError]) async {
    if(!await setEnabled(true)) {
      onError('Failed to enable bluetooth adapter');
      return false;
    }

    await FlutterBluetoothSerial.instance.cancelDiscovery();
    _discoveryStream = null;

    return true;
  }
}