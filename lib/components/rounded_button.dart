import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  String? text;
  Color? color;
  VoidCallback? onpressed;

  RoundedButton({this.text, this.color,required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.all(15.0),
        elevation: 5.0,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(text!,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}