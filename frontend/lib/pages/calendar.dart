import 'package:flutter/material.dart';
import 'package:frontend/components/drawer.dart';
import '../components/admindrawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/api_service.dart'; // Import your ApiService
import './event.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch events from the API and return them as a map of DateTime to a list of events.
Future<Map<DateTime, List<Event>>> _fetchEvents() async {
  final apiService = ApiService(
      'http://192.168.1.45:8080'); // Initialize ApiService with base URL
  try {
    final data =
        await apiService.getAllEvents(); // Fetch all events from the API
    final List<dynamic> jsonData =
        jsonDecode(data); // Decode JSON data from the response
    Map<DateTime, List<Event>> eventsMap =
        {}; // Initialize an empty map to store events
    for (var json in jsonData) {
      Event? event;
      try {
        event =
            Event.fromJson(json); // Parse each event JSON into an Event object
      } catch (e) {
        print('Error parsing event: $e'); // Error handling for JSON parsing
      }
      if (event != null && event.startDate != null) {
        // Check if the event and its start date are not null
        DateTime dateOnly = DateTime(event.startDate!.year,
            event.startDate!.month, event.startDate!.day);
        if (eventsMap.containsKey(dateOnly)) {
          eventsMap[dateOnly]!.add(event); // Add event to existing date entry
        } else {
          eventsMap[dateOnly] = [
            event
          ]; // Create a new date entry with the event
        }
      }
    }
    return eventsMap; // Return the map of events
  } catch (e) {
    print('Error fetching events: $e'); // Error handling for API fetch
    return {}; // Return an empty map if an error occurs
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat
      _calendarFormat; // Format of the calendar (month, week, etc.)
  late DateTime _focusedDay; // Currently focused day
  late DateTime _selectedDay; // Currently selected day
  Map<DateTime, List<Event>> _events = {}; // Map of events to display
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
    final now = DateTime.now(); // Get current date and time
    _focusedDay = DateTime(
        now.year, now.month, now.day); // Set initial focused day to today
    _selectedDay = _focusedDay; // Set initial selected day to today
    _calendarFormat =
        CalendarFormat.month; // Set initial calendar format to month
    _fetchAndSetEvents(); // Fetch and set events on initialization
  }

  // Load the admin status from SharedPreferences
  Future<void> _loadAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdmin =
          prefs.getBool('isAdmin') ?? false; // Default to false if not found
    });
  }

  // Fetch events and update the state
  Future<void> _fetchAndSetEvents() async {
    final events = await _fetchEvents(); // Fetch events from the API
    setState(() {
      _events = events; // Update the state with fetched events
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'), // Title of the app bar
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Menu icon button
              onPressed: () {
                Scaffold.of(context)
                    .openDrawer(); // Open drawer on button press
              },
            );
          },
        ),
      ),
      drawer: _isAdmin ? AdminDrawer() : AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1), // First day of the calendar
            lastDay: DateTime.utc(2030, 12, 31), // Last day of the calendar
            focusedDay: _focusedDay, // Focused day of the calendar
            calendarFormat: _calendarFormat, // Format of the calendar
            selectedDayPredicate: (day) => isSameDay(
                _selectedDay, day), // Predicate to determine the selected day
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // Update selected day
                _focusedDay = focusedDay; // Update focused day
              });
            },
            eventLoader: (day) {
              final dateOnly = DateTime(
                  day.year, day.month, day.day); // Normalize day to date only
              return _events[dateOnly] ??
                  []; // Load events for the selected day
            },
          ),
          Expanded(
              child: _buildEvents()), // Expanded widget to build event list
        ],
      ),
    );
  }

  // Build the list of events for the selected day
  Widget _buildEvents() {
    final selectedDay = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day); // Normalize selected day to date only
    final events =
        _events[selectedDay] ?? []; // Get events for the selected day

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Events on ${DateFormat('MM/dd/yyyy').format(selectedDay)}', // Display the selected date
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // ListView to display the list of events
        if (events.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: events.length, // Number of events
              itemBuilder: (context, index) {
                final event = events[index]; // Event at the current index
                return ListTile(
                  leading: Icon(Icons.event,
                      color: Colors.green), // Icon for the event
                  title: Text(
                    event.eventName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat('MMM dd, yyyy').format(event.startDate!)} at ${DateFormat('h:mm a').format(event.startTime!)}',
                  ), // Event description and date/time
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventPage(
                          title:
                              event.eventName, // Pass event name to EventPage
                          image: event.image ??
                              '', // Pass event image to EventPage
                          navTo: 'calendar',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No events on ${DateFormat('MM/dd/yyyy').format(selectedDay)}', // Message for no events
              style: TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
