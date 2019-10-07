import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'common.dart';
import 'pages/all.dart';
import 'utils/navigation_manager.dart';

class FrontendApp extends StatefulWidget {
  @override
  _FrontendAppState createState() => _FrontendAppState();
}

class _FrontendAppState extends State<FrontendApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationManager.key,
      title: 'mBot Patrol Frontend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => DevicesPage(),
        '/remote': (context) => RemotePage(ModalRoute.of(context).settings.arguments),
        '/tester': (context) => SerialTesterPage(ModalRoute.of(context).settings.arguments),
      },
    );
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }
}