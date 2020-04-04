import 'package:aggdrilling/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:aggdrilling/services/authentication.dart';

void main() => runApp(new DrillingTaskTrackingApp());

class DrillingTaskTrackingApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Aggressive Drilling',
      debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth() )
    );
  }

}