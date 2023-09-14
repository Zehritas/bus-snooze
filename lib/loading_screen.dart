import 'package:flutter/material.dart';

class ModernLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors
                  .purple), // Customize the color of the loading indicator
            ),
            SizedBox(
                height: 16), // Add some space between the indicator and text
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.purple, // Customize the color of the text
                fontSize: 16, // Customize the font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
