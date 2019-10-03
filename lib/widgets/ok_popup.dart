import '../common.dart';
import '../utils/navigation_manager.dart';

// A popup with an OK button, a title and a message
class OkPopup extends StatelessWidget {
  final String title;
  final String message;

  OkPopup(this.title, this.message, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        FlatButton(
          child: Text('Ok'),
          onPressed: () => NavigationManager.pop()
        )
      ]
    );
  }
}