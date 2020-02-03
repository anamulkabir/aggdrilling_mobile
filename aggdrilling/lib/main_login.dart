import 'package:aggdrilling/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:aggdrilling/services/authentication.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Aggressive Drilling',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth() )
    );
  }

}