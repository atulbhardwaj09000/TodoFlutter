import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewTaskWidget extends StatelessWidget {
  final Function onTaskSubmitted;

  NewTaskWidget({this.onTaskSubmitted});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.deepOrange[300].withOpacity(0.60),
          body: Container(
            height: double.infinity,
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Colors.deepOrange[300],
              autofocus: true,
              style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.deepOrange[400],
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.deepOrange[100],
                hintText: 'Enter task',
                contentPadding:
                    EdgeInsets.only(left: 14.0, bottom: 20.0, top: 20.0),
              ),
              onSubmitted: (String text) {
                onTaskSubmitted(text);
              },
            ),
          ),
        ),
      ),
    );
  }
}
