import '../common.dart';
import '../utils/navigation_manager.dart';

// A popup with yes and no buttons, a title and a message.
// On yes, pops with true. On no, pops with false. On force close, returns null,
// since that's how the flutter engine handles it
class YesNoPopup extends StatelessWidget {
  final String title;
  final String message;

  YesNoPopup(this.title, this.message, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        FlatButton(
          child: Text('Yes'),
          onPressed: () => NavigationManager.pop(true)
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () => NavigationManager.pop(false)
        )
      ]
    );
  }
}