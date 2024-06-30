import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/api_service.dart'; // Import your ApiService
import 'package:frontend/pages/viewevent.dart';
import 'dart:convert';
import './event.dart'; // Import your Event model here

// This allows the user to search for events from a predefined list and navigate to the event details page.
class EventSearchPage extends StatefulWidget {
  final int userID;

  EventSearchPage({required this.userID});

  @override
  _EventSearchPageState createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _allEvents = []; // List to store all events from the API
  List<Event> _filteredEvents = []; // List to store filtered events based on the search query

  @override
  void initState() {
    super.initState();
    _fetchAndSetEvents(); // Fetch and set events on initialization
  }

  // Method to fetch events from the API and set the state
  Future<void> _fetchAndSetEvents() async {
    final apiService = ApiService('http://192.168.86.234:8080'); // Initialize ApiService with base URL
    try {
      final data = await apiService.getAllEvents(); // Fetch all events from the API
      final List<dynamic> jsonData = jsonDecode(data); // Decode JSON data from the response
      List<Event> events = []; // Initialize an empty list to store events
      for (var json in jsonData) {
        try {
          events.add(Event.fromJson(json)); // Parse each event JSON into an Event object and add to the list
        } catch (e) {
          print('Error parsing event: $e'); // Error handling for JSON parsing
        }
      }
      setState(() {
        _allEvents = events; // Update the state with fetched events
        _filteredEvents = _allEvents; // Initially, show all events
      });
    } catch (e) {
      print('Error fetching events: $e'); // Error handling for API fetch
    }
  }

  // Method to filter events based on the search query
  void _filterEvents(String query) {
    List<Event> filtered = _allEvents
        .where((event) => event.eventName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredEvents = filtered; // Update the filtered events list
    });
  }

  @override
  // Builds the UI of the Event Search page
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // Search input field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterEvents, // Call the _filterEvents method to update the filtered events upon a change in the search field
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEvents.length, // Number of filtered events
                itemBuilder: (context, index) {
                  final event = _filteredEvents[index]; // Event at the current index
                  return ListTile(
                    title: Text(event.eventName),
                    onTap: () {
                      // Navigate to the EventPage when an event is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventPageStatic(
                            userId: widget.userID,
                            eventId: event.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
