import 'package:flutter/material.dart';
import 'package:flutter_assignment/screen/home_screen.dart';
import 'package:flutter_assignment/screen/input_screen.dart';

import 'common/constant.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: HOME_SCREEN,
    /*theme: ThemeData.dark().copyWith(backgroundColor: Colors.white),*/
    routes: {
      HOME_SCREEN: (context) => HomeScreen(),
      INPUT_SCREEN: (context) => InputScreen(),
    },
  ));
}
