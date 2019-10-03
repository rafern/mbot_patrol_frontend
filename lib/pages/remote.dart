import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'dart:typed_data';

import '../common.dart';
import '../utils/navigation_manager.dart';
import '../utils/bluetooth_device_wrapper.dart';
import '../utils/serial_stream_transcoder.dart';
import '../widgets/yes_no_popup.dart';
import '../widgets/ok_popup.dart';

class RemotePage extends StatefulWidget {
  final BluetoothDeviceWrapper _device;

  RemotePage(this._device);

  @override
  _RemotePageState createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  BluetoothConnection _connection;
  SerialStreamTranscoder _transcoder;
  Uint8List _imageData;

  void _connect() async {
    // Connect
    BluetoothConnection newConnection;

    try {
      newConnection = await widget._device.connect();
    }
    catch(_) {}

    setState(() {
      _connection = newConnection;
    });

    if(_connection == null) {
      NavigationManager.alert(OkPopup(
          'Connection failed',
          'Failed to create connection with device'
      ));
      return;
    }

    // Setup transcoder
    _transcoder = SerialStreamTranscoder(_connection.input, _connection.output, _onData, _disconnect);
  }

  void _disconnect() {
    if(_connection != null) {
      _transcoder = null;

      try {
        _connection.close();
      }
      catch (_){}

      setState(() {
        _connection = null;
      });
    }
  }

  Future<bool> _askDisconnect() async {
    bool disconnect = await NavigationManager.alert<bool>(YesNoPopup(
      'Disconnect',
      'Are you sure you want to disconnect from this device?',
    ));

    if(disconnect == true) // (...) == true because it can be null
      _disconnect();

    return disconnect ?? false;
  }

  Future<bool> _canExit() async {
    if(_connection == null)
      return true;
    else
      return await _askDisconnect();
  }

  Future<void> _onData(SerialPacketType type, Uint8List data) async {
    if(type == SerialPacketType.Frame) {
      setState(() {
        _imageData = data;
      });
    }
    else if(type == SerialPacketType.Event) {
      // TODO handle events
    }
  }

  @override
  void initState() {
    super.initState();

    // Try to connect
    _connect();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _canExit,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Remote'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(_connection == null ? Icons.bluetooth_disabled : Icons.bluetooth_connected),
                  onPressed: _connection == null ? _connect : _askDisconnect,
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                _imageData == null
                ? Text('No camera frame received yet')
                : Image.memory(
                  _imageData,
                  gaplessPlayback: true,
                ),
              ],
            )
        )
    );
  }
}