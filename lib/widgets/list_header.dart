import '../common.dart';

class ListHeader extends StatelessWidget {
  final String _text;

  ListHeader(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: TextStyle(
        fontWeight: FontWeight.bold
      ),
    );
  }
}