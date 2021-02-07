import 'package:example/sidemenu_builder_screen.dart';
import 'package:example/sidemenu_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SideMenuAnimation-Example',
      home: SampleScreen(),
    );
  }
}

class SampleScreen extends StatelessWidget {
  void _goToExample(BuildContext context, Widget newPage) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => newPage));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SideMenuAnimation-Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoButton(
              color: Colors.blueAccent,
              pressedOpacity: .75,
              child: Text('SideMenuAnimation'),
              onPressed: () => _goToExample(context, SideMenuScreen()),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: Colors.blueAccent,
              pressedOpacity: .75,
              child: Text('SideMenuAnimation.builder'),
              onPressed: () => _goToExample(context, SideMenuBuilderScreen()),
            ),
          ],
        ),
      ),
      drawer: Drawer(),
    );
  }
}
