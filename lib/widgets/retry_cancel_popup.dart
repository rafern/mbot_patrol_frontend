import '../common.dart';
import '../utils/navigation_manager.dart';

// A dialog with retry and cancel buttons, a title and a message.
// On retry, pops with true. On cancel, pops with false. On force close, returns
// null, since that's how the flutter engine handles it
class RetryCancelPopup extends StatelessWidget {
  final String title;
  final String message;

  RetryCancelPopup(this.title, this.message, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        FlatButton(
          child: Text('Retry'),
          onPressed: () => NavigationManager.pop(true)
        ),
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => NavigationManager.pop(false)
        )
      ]
    );
  }
}