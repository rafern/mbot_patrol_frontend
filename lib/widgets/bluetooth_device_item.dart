import '../common.dart';
import '../utils/bluetooth_device_wrapper.dart';

class BluetoothDeviceItem extends StatelessWidget {
  final BluetoothDeviceWrapper _wrapper;
  final Function(BluetoothDeviceWrapper) _onPressed;
  final Function(BluetoothDeviceWrapper) _onDebugPressed;

  BluetoothDeviceItem(this._wrapper, this._onPressed, this._onDebugPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () => _onPressed(_wrapper),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _wrapper.name ?? _wrapper.address,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.code),
                  onPressed: () => _onDebugPressed(_wrapper),
                ),
              ],
            )
          ),
          Divider(),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              _wrapper.signalStrength,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.normal
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool operator ==(Object o) => o is BluetoothDeviceItem && o._wrapper.address == _wrapper.address;

  @override
  int get hashCode => _wrapper.address.hashCode;
}