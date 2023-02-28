import 'package:flutter/material.dart';



class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: const [Text("Couldn not fetch data")],
        ),
      ),
    );
  }
}
