import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/api_service.dart'; // Import your ApiService
import 'package:frontend/pages/eventcreate.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'eventedit.dart';
import 'admin_event_delete.dart';
import 'home.dart'; // Import the AdminHomePage

class AdminConsolePage extends StatefulWidget {
  final int userId;
  AdminConsolePage({Key? key, required this.userId, required}) : super(key: key);

  @override
  _AdminConsolePageState createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  bool _showButtonsOnPage = false;
  bool _isLoading = true;
  String _error = '';
  List<Event> _events = [];

  // Initialize the ApiService with the base URL
  final ApiService apiService = ApiService('http://192.168.86.234:8080');

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final data = await apiService.getAllEvents();
      final List<dynamic> eventList = json.decode(data);
      setState(() {
        _events = eventList.map((json) => Event.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Console'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(isAdmin: false, userId: widget.userId)),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_error.isNotEmpty)
            Center(child: Text(_error))
          else if (_events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "There's no events - Add some with the button below.",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event.eventName),
                  subtitle: Text(event.description),
                  onTap: () {
                    // You can navigate to a detailed event page if needed
                  },
                );
              },
            ),
          if (_showButtonsOnPage)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventEdit(userId: widget.userId)),
                      ).then((_) {
                        setState(() {
                          _showButtonsOnPage = false;
                        });
                      });
                    },
                    child: Text('Edit'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminEventCreate()),
                      ).then((_) {
                        setState(() {
                          _showButtonsOnPage = false;
                        });
                      });
                    },
                    child: Text('Add'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminEventDeletePage()),
                      ).then((_) {
                        setState(() {
                          _showButtonsOnPage = false;
                        });
                      });
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showButtonsOnPage = !_showButtonsOnPage;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Event {
  final int id;
  final String eventName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime startDate;
  final DateTime endDate;
  final String? image;
  final DateTime createdAt;
  final List<dynamic> signedUpUsers;

  Event({
    required this.id,
    required this.eventName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
    this.image,
    required this.createdAt,
    required this.signedUpUsers,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'] ?? 0,
        eventName: json['eventName'] ?? 'Event Name',
        description: json['description'] ?? 'Description',
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : DateTime.now(),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'])
            : DateTime.now(),
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'])
            : DateTime.now(),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : DateTime.now(),
        image: json['image'], // Allows null
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        signedUpUsers: json['signedUpUsers'] ?? [],
      );
    } catch (e) {
      print('Error parsing event: $e');
      return Event(
        id: 0,
        eventName: 'Error Event',
        description: 'Error Description',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        image: '',
        createdAt: DateTime.now(),
        signedUpUsers: [],
      );
    }
  }
}
