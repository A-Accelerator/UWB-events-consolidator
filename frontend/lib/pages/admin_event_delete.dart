import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/api_service.dart'; // Import your ApiService
import 'package:intl/intl.dart'; // For date formatting
import 'eventedit.dart';
import 'admin_event_delete.dart';
import 'home.dart';

// Import your ApiService

class AdminEventDeletePage extends StatefulWidget {
  @override
  _AdminEventDeletePageState createState() => _AdminEventDeletePageState();
}

class _AdminEventDeletePageState extends State<AdminEventDeletePage> {
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

  Future<void> _deleteEvent(int id) async {
    try {
      await apiService.deleteEvent(id);
      setState(() {
        _events.removeWhere((event) => event.id == id);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to delete event: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Console', textAlign: TextAlign.center),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return ListTile(
                      title: Text(
                        '${DateFormat.MMMd().format(event.startDate)}: ${event.eventName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEvent(event.id);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // button logic/ implementation
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
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
