import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String texto;
  final Color corTexto;
  final VoidCallback onPressed;

  CustomButton({
    @required this.texto,
    this.corTexto = Colors.white,
    this.onPressed
    });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6)
      ),
      child: Text(
        this.texto,
        style: TextStyle(
            color: corTexto,
            fontSize: 20
        ),
      ),
      color: Color(0xff9c27b0),
      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
      onPressed: this.onPressed
    );
  }
}
