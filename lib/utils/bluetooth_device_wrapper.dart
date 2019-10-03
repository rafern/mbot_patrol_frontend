import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// A wrapper for the BluetoothDevice class to allow easy connection creation
class BluetoothDeviceWrapper extends BluetoothDevice {
  BluetoothDevice _device;

  // Property wrappers
  String              get name => _device.name;
  String              get address => _device.address;
  BluetoothDeviceType get type => _device.type;
  bool                get isConnected => _device.isConnected;
  BluetoothBondState  get bondState => _device.bondState;

  // New optional properties
  // RSSI level (Signal strength); read-write
  int rssi;

  // Utilities
  // Human-readable RSSI level
  String get signalStrength {
    if(rssi == null)
      return "Unknown";
    else if(rssi == 0)
      return "No signal";
    else if(rssi > -50)
      return "Excellent";
    else if(rssi >= -60)
      return "Good";
    else if(rssi >= -70)
      return "Fair";
    else
      return "Weak";
  }

  // Constructor. Takes a BluetoothDevice and wraps around it
  BluetoothDeviceWrapper(this._device);

  // Alternative constructor that takes a BluetoothDiscoveryResult
  BluetoothDeviceWrapper.fromDiscovery(BluetoothDiscoveryResult result) :
        this._device = result.device,
        this.rssi = result.rssi;

  // Internal function. Updates the wrapped device by creating a new one. This
  // is because the class is final
  void _updateWrapped({
    String name,
    String address,
    BluetoothDeviceType type,
    bool isConnected,
    BluetoothBondState bondState
  }) {
    if(name == null)
      name = _device.name;
    if(address == null)
      address = _device.address;
    if(type == null)
      type = _device.type;
    if(isConnected == null)
      isConnected = _device.isConnected; // XXX does this work for booleans?
    if(bondState == null)
      bondState = _device.bondState;

    // Re-create wrapped class
    _device = BluetoothDevice(
        name: name,
        address: address,
        type: type,
        isConnected: isConnected,
        bondState: bondState
    );
  }

  // Create a connection with this device
  Future<BluetoothConnection> connect() async {
    return await BluetoothConnection.toAddress(_device.address);
  }

  // Try to pair (bond) with this device. Returns success as true, else, failure
  Future<bool> pair() async {
    // Attempt to pair with device
    bool bonded = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(address);

    // Update inner object
    _updateWrapped(
        bondState: bonded ? BluetoothBondState.bonded : BluetoothBondState.none
    );

    return bonded;
  }
}