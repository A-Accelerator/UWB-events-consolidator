import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthenticationService {
  static const String baseUrl = 'http://192.168.86.234:8080'; // Connecting to URL

  /**
   * Registers a new user or logs in if the user already exists.
   * @param username The username of the user.
   * @param password The password of the user.
   * @return A boolean indicating success or failure.
   */
  Future<String> register(String username, String password) async {
    // Check if the username and password match a record in the database
    bool loginResult = await login(username, password) == 'success';
    if (loginResult) {
      // If login successful, return true to indicate successful login without registration
      return 'success';
    }

    // Fetch all users from the database
    final response = await http.get(
      Uri.parse('$baseUrl/user/allUsers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);

      // Check if the username already exists
      bool usernameExists = users.any((user) => user['userName'] == username);
      if (usernameExists) {
        return 'username_exists'; // Username already exists
      } else {
        // Username doesn't exist, proceed with registration
        final response = await http.post(
          Uri.parse('$baseUrl/user/addUser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'userName': username,
            'password': password,
            'adminPowers': false,
          }),
        );

        if (response.statusCode == 200) {
          // Registration successful
          return 'success';
        } else {
          // Registration failed
          return 'registration_failed';
        }
      }
    } else {
      // Failed to fetch users from the database
      return 'request_failed';
    }
  }

  /**
   * Logs in a user by checking the username and password.
   * @param username The username of the user.
   * @param password The password of the user.
   * @return A string indicating the result of the login attempt.
   */
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/allUsers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      for (var user in users) {
        if (user['userName'] == username) {
          if (user['password'] == password) {
            return {
              'status': 'success',
              'userId': user['id'] // Return user ID along with success status
            };
          } else {
            return {'status': 'invalid_password'};
          }
        }
      }
      return {'status': 'username_not_exist'};
    } else {
      return {'status': 'request_failed'};
    }
  }

  /**
   * Retrieves user data for a given username.
   * @param username The username of the user.
   * @return A map containing user data.
   * @throws Exception if the request fails.
   */
  Future<Map<String, dynamic>> getUserData(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$username'), // Endpoint to get user data
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<bool> isAdmin(int userId) async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/user/isAdmin/$userId'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to check admin status');
      }
    } catch (e) {
      throw Exception('Failed to check admin status: $e');
    }
  }
}
