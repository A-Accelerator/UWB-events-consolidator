import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminEventEdit extends StatefulWidget {
  String eventName;
  final int eventID;
  final int userId;

  AdminEventEdit({Key? key, required this.eventName, required this.eventID, required int this.userId})
      : super(key: key);

  @override
  State<AdminEventEdit> createState() => _AdminEventEditState();
}

class _AdminEventEditState extends State<AdminEventEdit> {
  String _title = "Editing";

  String _selectedEventName = 'Select Event To Edit';
  String _eventImage =
      'https://www.investopedia.com/thmb/_EUeiZWojyM4VEYLSfQ5AMbrzf4=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/GettyImages-1503239849-0dc8617d35594774b51c998694997431.jpg';
  String _description =
      "Yo this event is so lit brah if I were the event people I would tots put a description here like no cap brah";
  String _startDate = "2024-06-09";
  String _endDate = "2024-06-15";
  String _startTime = "08:30:00";
  String _endTime = "12:00:00";
  final String _ip =
      '192.168.1.45'; //// REPLACE WITH YOUR IP / IP OF HOST WHEN IN DEPLOYMENT

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    final url = Uri.parse('http://192.168.1.45:8080/event/byId/${widget.eventID}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final eventData = jsonDecode(response.body);
        setState(() {
          _description = eventData['description'];
          _startDate = eventData['startDate'];
          _endDate = eventData['endDate'];
          _eventImage = eventData['image'];
          _startTime = eventData['startTime'].split('T')[1];
          _endTime = eventData['endTime'].split('T')[1];
        });
      } else {
        print(
            'Failed to load event details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing Event"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  child: TextButton(
                    onPressed: () async {
                      final name = await openDialogName();
                      if (name == null || name.isEmpty) return;
                      setState(() => widget.eventName = name);
                      // Call API to update event name
                      await editEventName(widget.eventID, name);
                    },
                    child: Text(
                      widget.eventName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: "Inter",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final eventImage = await openDialogImage();
                if (eventImage == null || eventImage.isEmpty) return;
                setState(() => _eventImage = eventImage);
                await editEventImage(widget.eventID, eventImage);
              },
              child: Image.network(_eventImage, height: 300, fit: BoxFit.cover),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final date = await openDialogDate();
                    if (date == null || date.isEmpty) return;
                    setState(() => _startDate = date);
                    await editStartDate(widget.eventID, date);
                  },
                  child: Text(
                    _startDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  "-",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: "Inter",
                  ),
                ),
                SizedBox(width: 4),
                TextButton(
                  onPressed: () async {
                    final date = await openDialogDate();
                    if (date == null || date.isEmpty) return;
                    setState(() => _endDate = date);
                    await editEndDate(widget.eventID, date);
                  },
                  child: Text(
                    _endDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final time = await openDialogTime();
                    if (time == null || time.isEmpty) return;
                    setState(() => _startTime = time);
                    await editStartTime(widget.eventID, time);
                  },
                  child: Text(
                    _startTime,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  "-",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: "Inter",
                  ),
                ),
                SizedBox(width: 4),
                TextButton(
                  onPressed: () async {
                    final time = await openDialogTime();
                    if (time == null || time.isEmpty) return;
                    setState(() => _endTime = time);
                    await editEndTime(widget.eventID, time);
                  },
                  child: Text(
                    _endTime,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () async {
                  final description = await openDialogDescription();
                  if (description == null || description.isEmpty) return;
                  setState(() => _description = description);
                  await editEventDescription(widget.eventID, description);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _description,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: "Inter",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              // SAVE EVENT WITH POST REQUEST
              Navigator.pop(context);
            },
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              size: 50,
            ),
            backgroundColor: Color(0xFF4B2E83),
            foregroundColor: Color.fromARGB(255, 153, 115, 227),
          ),
        ],
      ),
    );
  }

  Future<String?> openDialogImage() {
    TextEditingController imageController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Image"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter image URL"),
          controller: imageController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(imageController.text),
            child: const Text("SAVE"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> editStartDate(int id, String newDate) async {
    final String url =
        'http://192.168.1.45:8080/event/editStartDate/$id'; //// CHNAGE WITH YOUR IP

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'startDate': newDate,
        },
      );
    } catch (e) {
      print("CHECK THAT YOU CHNAGED TO YOUR IP");
    }
  }

  Future<void> editEndDate(int id, String endDate) async {
    final String url =
        'http://192.168.1.45:8080/event/editEndDate/$id'; //// CHNAGE WITH YOUR IP

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'endDate': endDate,
        },
      );
    } catch (e) {
      print("CHECK THAT YOU CHNAGED TO YOUR IP");
    }
  }

  Future<void> editEndTime(int id, String endTime) async {
    final String url =
        'http://192.168.1.45:8080/event/editEndTime/$id'; //// CHNAGE WITH YOUR IP

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'endTime': endTime,
        },
      );
    } catch (e) {
      print("CHECK THAT YOU CHNAGED TO YOUR IP");
    }
  }

  Future<String?> openDialogDescription() {
    TextEditingController descriptionController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Description"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter Description"),
          controller: descriptionController,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(descriptionController.text),
            child: const Text("SAVE"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<String?> openDialogDate() {
    TextEditingController dateController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Date (yyyy-mm-dd)"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter New Date"),
          controller: dateController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(dateController.text),
            child: const Text("SAVE"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<String?> openDialogTime() {
    TextEditingController timeController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Time (hh:mm:ss)"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter New Time"),
          controller: timeController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(timeController.text),
            child: const Text("SAVE"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<String?> openDialogName() {
    TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Name"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter New Name"),
          controller: nameController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text("SAVE"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

Future<void> editStartTime(int id, String startTime) async {
  final String url =
      'http://192.168.1.45:8080/event/editStartTime/$id'; //// CHNAGE WITH YOUR IP

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'startTime': startTime,
      },
    );
  } catch (e) {
    print("CHECK THAT YOU CHNAGED TO YOUR IP");
  }
}

Future<void> editEventDescription(int id, String description) async {
  final String url =
      'http://192.168.1.45:8080/event/editDescription/$id'; //// CHNAGE WITH YOUR IP

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'description': description,
      },
    );
  } catch (e) {
    print("CHECK THAT YOU CHNAGED TO YOUR IP");
  }
}

Future<void> editEventName(int id, String newName) async {
  final String url =
      'http://0.0.0.0:8080/event/editEventName/$id'; //// CHNAGE WITH YOUR IP

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'eventName': newName,
      },
    );
  } catch (e) {
    print("CHECK THAT YOU CHNAGED TO YOUR IP");
  }
}

Future<void> editEventImage(int id, String newImage) async {
  final String url =
      'http://192.168.1.45:8080/event/editImage/$id'; //// CHNAGE WITH YOUR IP

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'newImage': newImage,
      },
    );
  } catch (e) {
    print("CHECK THAT YOU CHNAGED TO YOUR IP");
  }
}
