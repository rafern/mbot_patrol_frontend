import 'dart:collection';

import '../common.dart';
import '../utils/navigation_manager.dart';
import '../utils/bluetooth_manager.dart';
import '../utils/bluetooth_device_wrapper.dart';
import '../widgets/list_header.dart';
import '../widgets/bluetooth_device_item.dart';
import '../widgets/ok_popup.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  bool discovering = false;
  HashSet<BluetoothDeviceItem> items = HashSet();

  void _startDiscovery() {
    setState(() {
      items.clear();
      discovering = true;
      BluetoothManager.startDiscovery(_addDevice, () => setState(() {
        discovering = false;
      }), (String message) => NavigationManager.alert(
        OkPopup('Failed to start discovery', message)
      ));
    });
  }

  Future<void> _stopDiscovery() async {
    await BluetoothManager.stopDiscovery((String message) => NavigationManager.alert(
      OkPopup('Failed to stop discovery', message)
    ));
  }

  void _addDevice(BluetoothDeviceWrapper device) {
    setState(() {
      BluetoothDeviceItem item = BluetoothDeviceItem(device, _connect, _connectTester);
      items.remove(item);
      items.add(item);
    });
  }

  Future<void> _connect(BluetoothDeviceWrapper device) async {
    await _stopDiscovery();
    NavigationManager.push('/remote', arguments: device);
  }

  Future<void> _connectTester(BluetoothDeviceWrapper device) async {
    await _stopDiscovery();
    NavigationManager.push('/tester', arguments: device);
  }

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available devices'),
        actions: <Widget>[
          IconButton(
            icon: Icon(discovering ? Icons.cancel : Icons.refresh),
            onPressed: discovering ? _stopDiscovery : _startDiscovery,
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: ListHeader('Device name'),
                ),
                Divider(),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: ListHeader('Signal'),
                ),
              ],
            ),
          ),
          Divider(),
        ]..addAll(items),
      ),
    );
  }
}