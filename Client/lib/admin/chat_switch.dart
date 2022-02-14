import 'package:flutter/material.dart';

enum Chat {
  testo,
  vocale,
  video,
}

class ChatSwitch extends StatefulWidget {
  ChatSwitch({
    required this.onToggle,
    this.initialState = Chat.testo,
    this.backgroundColor = Colors.black38,
    this.selectedColor = Colors.blue,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black87,
  });

  final ValueChanged<Chat> onToggle;
  final Chat initialState;
  final Color backgroundColor;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  @override
  _ChatSwitch createState() => _ChatSwitch();
}

class _ChatSwitch extends State<ChatSwitch> {
  late Chat _chat;

  @override
  void initState() {
    super.initState();
    _chat = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildButton(Chat.testo, Icons.message, ''),
        const SizedBox(width: 12),
        _buildButton(Chat.vocale, Icons.call, ''),
        const SizedBox(width: 12),
        _buildButton(Chat.video, Icons.video_call, ''),
      ],
    );
  }

  Widget _buildButton(
    Chat value,
    IconData icon,
    String text,
  ) =>
      FlatButton(
        onPressed: () {
          setState(() => _chat = value);
          widget.onToggle(value);
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(
            color: Colors.black45,
            width: 1,
          ),
        ),
        color: _chat == value ? widget.selectedColor : null,
        child: Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: _chat == value
                    ? widget.selectedTextColor
                    : widget.unselectedTextColor,
              ),
            ),
          ],
        ),
      );
}
