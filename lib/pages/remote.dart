import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:control_pad/control_pad.dart';

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
  bool _alarmEnabled = false;
  bool _rcEnabled = false;
  bool _detected = false;
  int _lastDir = 9;

  void _toggleAlarm() async {
    if(_alarmEnabled)
      _transcoder.write(SerialPacketType.Command, Uint8List.fromList([2])); // Alarm off
    else
      _transcoder.write(SerialPacketType.Command, Uint8List.fromList([1])); // Alarm on
  }

  void _toggleRC() async {
    if(_rcEnabled)
      _transcoder.write(SerialPacketType.Command, Uint8List.fromList([4])); // RC off
    else
      _transcoder.write(SerialPacketType.Command, Uint8List.fromList([3])); // RC on
  }

  void _joystickSend(int dir) {
    if(dir != _lastDir) {
      _lastDir = dir;
      _transcoder.write(SerialPacketType.Command, Uint8List.fromList([_lastDir]));
    }
  }

  void _joystickUpdate(double angle, double distance) {
    if(distance < 0.8)
      _joystickSend(9); // Stop
    else if(angle <= 45 || angle > 315)
      _joystickSend(7); // Forwards
    else if(angle <= 135 && angle > 45)
      _joystickSend(6); // Right
    else if(angle <= 225 && angle > 135)
      _joystickSend(8); // Backwards
    else if(angle <= 315 && angle > 225)
      _joystickSend(5); // Left
  }

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

    // Send get state command
    _transcoder.write(SerialPacketType.Command, Uint8List.fromList([0])); // Get state
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
      switch(data[0]) {
        case 65: // A
          setState(() {
            _alarmEnabled = true;
          });
          break;
        case 97: // a
          setState(() {
            _alarmEnabled = false;
          });
          break;
        case 67: // C
          setState(() {
            _rcEnabled = true;
          });
          break;
        case 99: // c
          setState(() {
            _rcEnabled = false;
          });
          break;
      }
    }
    else if(type == SerialPacketType.Face) {
      setState(() {
        _detected = true;
      });
      Timer(Duration(seconds: 3), () {
        setState(() {
          _detected = false;
        });
      });
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
    Row controlRow;
    List<Widget> buttons = <Widget>[
      RaisedButton(
        child: Text((_alarmEnabled ? 'Disable' : 'Enable') + ' Alarm'),
        onPressed: _toggleAlarm,
      ),
      RaisedButton(
        child: Text((_rcEnabled ? 'Disable' : 'Enable') + ' RC Mode'),
        onPressed: _toggleRC,
      ),
    ];

    if(_rcEnabled) {
      controlRow = Row(
        children: <Widget>[
          Column(
            children: buttons
          ),
          JoystickView(
            onDirectionChanged: _joystickUpdate,
            showArrows: false,
          ),
        ]
      );
    }
    else {
      controlRow = Row(
        children: buttons
      );
    }

    return WillPopScope(
      onWillPop: _canExit,
      child: Scaffold(
        backgroundColor: Colors.black,
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
            Expanded(
              child: _imageData == null
                  ? Text('No camera frame received yet')
                  : Image.memory(
                _imageData,
                gaplessPlayback: true,
              ),
            ),
            Text(
              _detected ? 'A face has been detected!' : '...',
              style: TextStyle(
                color: Colors.white
              ),
            ),
            controlRow,
          ],
        )
      )
    );
  }
}