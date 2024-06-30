import 'package:flutter/material.dart';
import '../pages/event.dart';

class Event extends StatelessWidget {
  final name;
  final image;
  final date;
  final int userId;

  const Event({super.key, required this.name, required this.image, required this.date, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 13),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            // line below needs update
            MaterialPageRoute(builder: (context) => EventPage(title: name, image: image, navTo: 'userEvents', userId: userId,))
          );
        },
        child: Container(
          width: 343,
          height: 120,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF4B2E83),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]
          )
        )
      ),
    );
  }
}