import 'package:flutter/material.dart';

enum Gender {
  M,
  F,
}

class GenderSwitch extends StatefulWidget {
  GenderSwitch({
    required this.onToggle,
    this.initialState = Gender.M,
    this.backgroundColor = Colors.black38,
    this.selectedColor = Colors.blue,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black87,
  });

  final ValueChanged<Gender> onToggle;
  final Gender initialState;
  final Color backgroundColor;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  @override
  _GenderSwitch createState() => _GenderSwitch();
}

class _GenderSwitch extends State<GenderSwitch> {
  late Gender _gender;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildButton(Gender.M, Icons.male, 'Maschio  '),
        const SizedBox(width: 12),
        _buildButton(Gender.F, Icons.female, 'Femmina  '),
      ],
    );
  }

  Widget _buildButton(
    Gender value,
    IconData icon,
    String text,
  ) =>
      FlatButton(
        onPressed: () {
          setState(() => _gender = value);
          widget.onToggle(value);
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(
            color: Colors.black45,
            width: 1,
          ),
        ),
        color: _gender == value ? widget.selectedColor : null,
        child: Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: _gender == value
                    ? widget.selectedTextColor
                    : widget.unselectedTextColor,
              ),
            ),
          ],
        ),
      );
}
