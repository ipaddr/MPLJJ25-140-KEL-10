import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // Import this for Visibility

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Make children take full width
      children: [
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email), // Email icon
            hintText: 'Email',
            filled: true,
            fillColor: Colors.white.withOpacity(0.8), // Light background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded borders
              borderSide: BorderSide.none, // No visible border line
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            isDense: true, // Reduces the overall height of the input field
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock), // Lock icon
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            hintText: 'Password',
            filled: true,
            fillColor: Colors.white.withOpacity(0.8), // Light background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded borders
              borderSide: BorderSide.none, // No visible border line
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            isDense: true, // Reduces the overall height of the input field
          ),
          obscureText: !_isPasswordVisible, // Toggle visibility
        ),
        SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement login logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Blue background
            foregroundColor: Colors.white, // White text color
            padding: EdgeInsets.symmetric(vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                30.0,
              ), // Rounded corners for button
            ),
          ),
          child: Text('Masuk'),
        ),
      ],
    );
  }
}
