// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:frontend/pages/admin_console.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/authentication_service.dart';
import 'package:frontend/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for the username and password text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Instance of the authentication service to handle login and registration
  final AuthenticationService _authService = AuthenticationService();
  
  // Boolean to indicate whether a loading indicator should be shown
  bool _isLoading = false;

  // Function to handle the login process
  void _login() async {
    // Check if the username or password fields are empty
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and Password cannot be empty')),
      );
      return; // Exit the function if any field is empty
    }

    // Set loading indicator to true
    setState(() {
      _isLoading = true;
    });

    // Attempt to login with the provided username and password
    var loginResult = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    // Set loading indicator to false
    setState(() {
      _isLoading = false;
    });

    // Handle the result of the login attempt
    if (loginResult?['status'] == 'success') {
      // If login is successful, check if the user is an admin
      int userId = loginResult?['userId'];
      bool isAdmin = await _authService.isAdmin(userId);
      // Navigate to the HomePage, passing the isAdmin status
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(isAdmin: isAdmin,userId: userId,),
        ),
      );
    } else if (loginResult?['status'] == 'invalid_password') {
      // If the password is invalid, show a SnackBar with a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Password')),
      );
    } else if (loginResult?['status'] == 'username_not_exist') {
      // If the username does not exist, show a SnackBar with a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Username doesn't exist. Don't have an account? Register",
          ),
        ),
      );
    } else {
      // If the login fails for any other reason, show a generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  // Function to handle the registration process
  void _register() async {
    // Check if the username or password fields are empty
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and Password cannot be empty')),
      );
      return; // Exit the function if any field is empty
    }

    // Set loading indicator to true
    setState(() {
      _isLoading = true;
    });

    // Attempt to register with the provided username and password
    String registerResult = await _authService.register(
      _usernameController.text,
      _passwordController.text,
    );

    // Set loading indicator to false
    setState(() {
      _isLoading = false;
    });

    // Handle the result of the registration attempt
    if (registerResult == 'success') {
      _login();
      // If registration is successful, Log in
    
    } else if (registerResult == 'username_exists') {
      // If the username already exists, show a SnackBar with a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username already exists. Login')),
      );
    } else {
      // If the registration fails for any other reason, show a generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display a logo or image
              Image.network(
                "https://images.credly.com/size/400x400/images/1ca468d1-f8fb-41be-856d-dd0fb19750e6/blob.png",
                width: 200,
                height: 200,
              ),
              // TextField for the username input
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // TextField for the password input
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                obscureText: true, // Hide the password input
              ),
              SizedBox(height: 10),
              // Show a loading indicator or a login button
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Log In'),
                    ),
              SizedBox(height: 10),
              // Show a register button
              _isLoading
                  ? SizedBox()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
