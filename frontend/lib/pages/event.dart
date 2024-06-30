// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:frontend/api_service.dart';
import 'package:frontend/pages/calendar.dart';
import 'package:frontend/pages/user_events.dart';
import '../components/drawer.dart';
import './event.dart';
import './eventsearch.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import './home.dart';

/// Fetches an event by its name from a JSON string.
///
/// The JSON string is parsed into a list of dynamic objects, which are then
/// mapped to Event objects. The function returns the first event that matches
/// the given name.
///
/// Args:
///   jsonString (String): The JSON string containing event data.
///   name (String): The name of the event to fetch.
///
/// Returns:
///   Future<Event?>: A future that resolves to the matching event, or null if not found.
Future<Event?> _fetchEvent(String jsonString, String name) async {
  final List<dynamic> jsonData = jsonDecode(jsonString);

  Event? event;
  try {
    event = jsonData
        .map((json) => Event.fromJson(json))
        .firstWhere((event) => event.eventName == name);
  } catch (e) {
    print('Error fetching event: $e');
  }

  return event;
}

/// Stateful widget for displaying an event's details.
class EventPage extends StatefulWidget {
  final String title;
  final String image;
  final String navTo;
  final int userId;

  EventPage(
      {super.key,
      required this.title,
      required this.image,
      required this.navTo, required this.userId});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String description = '';
  DateTime date = DateTime.now();
  String time = '';
  bool _isLoading = false;
  String _error = "";

  final apiService = ApiService('http://192.168.86.234:8080');

  @override
  void initState() {
    super.initState();
    loadEvent();
  }

  /// Loads the event data from the API and updates the state.
  ///
  /// This method sets the loading state to true, fetches all events from the API,
  /// finds the event matching the title, and updates the state with the event's details.
  /// If an error occurs, it updates the error message in the state.

  void loadEvent() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });
    try {
      // Get the data string and pass it into fetchEvents
      final data = await apiService.getAllEvents();
      final event = await _fetchEvent(data, widget.title);
      setState(() {
        if (event != null) {
          description = event.description;
          date = event.startDate;
          final formattedStartTime = DateFormat.jm().format(event.startTime);
          final formattedEndTime = DateFormat.jm().format(event.endTime);
          time = '$formattedStartTime to $formattedEndTime';
        } else {
          _error = "Event not found";
        }
        _isLoading = false;
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d/yyyy');
    final formattedDate = dateFormat.format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () async {
                if (widget.navTo == 'home') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomePage(
                            isAdmin: false,
                            userId: widget.userId,
                          )));
                } else if (widget.navTo == 'userEvents') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserEventsPage(userId: widget.userId)));
                } else if (widget.navTo == 'calendar') {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CalendarPage(userId: widget.userId)));
                }
              },
            );
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 343,
                      height: 360,
                      decoration: const BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(formattedDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 17,
                        )),
                  ),
                  Text(time,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 17,
                      )),
                  Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 17,
                        )),
                  ),
                ],
              ),
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
    required this.image,
    required this.createdAt,
    required this.signedUpUsers,
  });

  /// Creates an Event object from a JSON map.
  ///
  /// The method attempts to parse the JSON map into an Event object.
  /// If parsing fails, it prints an error and returns an Event object
  /// with default values.
  ///
  /// Args:
  ///   json (Map<String, dynamic>): The JSON map containing event data.
  ///
  /// Returns:
  ///   Event: An Event object created from the JSON map.
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
        image: json['image'] ?? '', // Adjusted for null images
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
