import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventPageStatic extends StatefulWidget {
  final int eventId;
  final int userId;

  EventPageStatic({required int this.eventId, required int this.userId});

  @override
  _EventPageStaticState createState() => _EventPageStaticState();
}

class _EventPageStaticState extends State<EventPageStatic> {
  String _name = "Event Name";
  String _image =
      "https://www.investopedia.com/thmb/_EUeiZWojyM4VEYLSfQ5AMbrzf4=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/GettyImages-1503239849-0dc8617d35594774b51c998694997431.jpg";
  String _description =
      "Description of the event goes here. It can be long or short.";
  String _startDate = "2024-06-09";
  String _endDate = "2024-06-15";
  String _startTime = "08:30:00";
  String _endTime = "12:00:00";

  late Future<Map<String, dynamic>> _eventDetails;

  @override
  void initState() {
    super.initState();
    _eventDetails = fetchEventDetails();
  }

  Future<Map<String, dynamic>> fetchEventDetails() async {
    print({widget.eventId});
    final url =
        Uri.parse('http://192.168.86.234:8080/event/byId/${widget.eventId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final eventData = jsonDecode(response.body);
        setState(() {
          _name = eventData['eventName'];
          _description = eventData['description'];
          _startDate = eventData['startDate'];
          _endDate = eventData['endDate'];
          _image = eventData['image'];
          _startTime = eventData['startTime'].split('T')[1];
          _endTime = eventData['endTime'].split('T')[1];
        });
        return eventData;
      } else {
        print(
            'Failed to load event details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _name,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _eventDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            // Data successfully loaded, build UI
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, // Specify the border color here
                              width: 2, // Specify the border width here
                            ),
                          ),
                          child: Image.network(
                            _image,
                            height:
                                200, // Set a fixed height for the image container
                            width: double.infinity, // Take full width of parent
                            fit: BoxFit.cover, // Cover the container
                          ),
                        ),
                      ),
                      Text(
                        '$_startDate - $_endDate',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text('$_startTime - $_endTime'),
                      SizedBox(height: 20),
                      Text(
                        _description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  bottom: 32.0,
                  right: 80.0,
                  child: Text(
                    "Cick to add event!",
                    style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                        ),
                  ),
                
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      sendPostRequest();
                    },
                    shape: CircleBorder(), // Make it circular
                    child: Icon(Icons.add),
                    backgroundColor: Colors.purple,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
  void sendPostRequest() async {
    final url = Uri.parse('http://192.168.86.234:8080/user/addUserToEvent/${widget.userId}/${widget.eventId}');
    print('${widget.userId}/${widget.eventId}');
    try {
      final response = await http.post(
        url,
      );
      if (response.statusCode == 200) {
      } else {
        print('Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending post request: $e');
    }
  }
}
