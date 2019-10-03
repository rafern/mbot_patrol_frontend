import 'common.dart';
import 'pages/all.dart';
import 'utils/navigation_manager.dart';

class FrontendApp extends StatelessWidget {
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
}