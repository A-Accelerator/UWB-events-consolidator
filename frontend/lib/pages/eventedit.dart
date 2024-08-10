import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/adminedit.dart';
import 'package:frontend/pages/eventcreate.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class EventEdit extends StatefulWidget {
  final int userId;
  EventEdit({Key? key, required this.userId}) : super(key: key);

  @override
  State<EventEdit> createState() => _EventEditState();
}

class _EventEditState extends State<EventEdit> {
  final int userId = 5;
  late int _eventID;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    fetchAllEvents(); // Fetch events when the widget initializes
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Console"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            final startDate = DateFormat.MMMd().format(DateTime.parse(event['startDate']));
            final eventName = event['eventName'];
            final eventId = event['id'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$startDate: $eventName',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _eventID = eventId;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AdminEventEdit(
                            eventName: eventName,
                            eventID: eventId,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.check_box_outlined),
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> fetchAllEvents() async {
    final url = Uri.parse('http://128.199.8.191:8080/event/allEvents');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> events = jsonDecode(response.body);
        setState(() {
          _events = events
              .map((event) => {
                    'id': event['id'],
                    'eventName': event['eventName'],
                    'startDate': event['startDate'],
                    'description': event['description'],
                    'endDate': event['endDate'],
                    'image': event['image'],
                    'createdAt': event['createdAt'],
                    'signedUpUsers': event['signedUpUsers'],
                  })
              .toList();
        });
      } else {
        print('Failed to fetch events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }
}
