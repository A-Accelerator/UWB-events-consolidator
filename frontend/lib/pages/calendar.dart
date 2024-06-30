import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/api_service.dart';
import './event.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CalendarPage extends StatefulWidget {
  final int userId;

  CalendarPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat.month;
    _fetchAndSetEvents();
  }

  Future<void> _fetchAndSetEvents() async {
    final events = await _fetchUserEvents();
    setState(() {
      _events = events;
    });
  }

  Future<Map<DateTime, List<Event>>> _fetchUserEvents() async {
    final apiService = ApiService('http://192.168.86.234:8080');
    try {
      final url = Uri.parse('http://192.168.86.234:8080/user/userEvents/${widget.userId}');
      final response = await http.get(url);
      final List<dynamic> jsonData = jsonDecode(response.body);
      Map<DateTime, List<Event>> eventsMap = {};
      for (var json in jsonData) {
        Event? event;
        try {
          event = Event.fromJson(json);
        } catch (e) {
          print('Error parsing event: $e');
        }
        if (event != null && event.startDate != null) {
          DateTime dateOnly = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
          if (eventsMap.containsKey(dateOnly)) {
            eventsMap[dateOnly]!.add(event);
          } else {
            eventsMap[dateOnly] = [event];
          }
        }
      }
      return eventsMap;
    } catch (e) {
      print('Error fetching events: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: AppDrawer(userId: widget.userId),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final dateOnly = DateTime(day.year, day.month, day.day);
              return _events[dateOnly] ?? [];
            },
          ),
          Expanded(
            child: _buildEvents(),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents() {
    final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final events = _events[selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Events on ${DateFormat('MM/dd/yyyy').format(selectedDay)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (events.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: Icon(Icons.event, color: Colors.green),
                  title: Text(
                    event.eventName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat('MMM dd, yyyy').format(event.startDate!)} at ${DateFormat('h:mm a').format(event.startTime!)}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventPage(
                          title: event.eventName,
                          image: event.image ?? '',
                          navTo: 'calendar',
                          userId: widget.userId,
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
              'No events on ${DateFormat('MM/dd/yyyy').format(selectedDay)}',
              style: TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
