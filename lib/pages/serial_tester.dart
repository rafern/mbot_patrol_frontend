import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'dart:typed_data';
import 'dart:convert';

import '../common.dart';
import '../utils/navigation_manager.dart';
import '../utils/bluetooth_device_wrapper.dart';
import '../widgets/yes_no_popup.dart';
import '../widgets/ok_popup.dart';

class SerialTesterPage extends StatefulWidget {
  final BluetoothDeviceWrapper _device;

  SerialTesterPage(this._device);

  @override
  _SerialTesterPageState createState() => _SerialTesterPageState();
}

class _SerialTesterPageState extends State<SerialTesterPage> {
  BluetoothConnection _connection;
  TextEditingController _controller = TextEditingController();
  String _received = "";
  bool _binaryReceived = false;

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

    // Setup input stream
    _connection.input.listen((Uint8List data) {
      setState(() {
        try {
          _received += utf8.decode(data);
        }
        catch(_) {
          _binaryReceived = true;
          _received = "";
        }
      });
    }).onDone(_disconnect);
  }

  void _disconnect() {
    if(_connection != null) {
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

  void _sendData() async {
    if(_connection == null) {
      NavigationManager.alert(OkPopup(
          'Not connected',
          'Reconnect to the device before sending data'
      ));
      return;
    }

    // Output data to serial connection stream
    _connection.output.add(
      utf8.encode(_controller.text)
    );
  }

  void _clearReceived() {
    setState(() {
      _binaryReceived = false;
      _received = "";
    });
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
          title: Text('Serial tester'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearReceived,
            ),
            IconButton(
              icon: Icon(_connection == null ? Icons.bluetooth_disabled : Icons.bluetooth_connected),
              onPressed: _connection == null ? _connect : _askDisconnect,
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            _binaryReceived ?
            Text(_received) :
            Text(
              '<Binary data received>',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                  )
                ),
                FlatButton(
                  onPressed: _sendData,
                  child: Text('Send'),
                ),
              ],
            )
          ],
        )
      )
    );
  }
}