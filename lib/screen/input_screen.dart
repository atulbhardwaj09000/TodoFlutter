import 'package:flutter/material.dart';

class InputScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Opacity(
          opacity: .25,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.transparent,
            child: TextField(
              decoration: InputDecoration(),
              onSubmitted: (result) {
                Navigator.pop(context, result);
              },
            ),
          ),
        ),
      ),
    );
  }
}
