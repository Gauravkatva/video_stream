import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Lending extends StatefulWidget {
  @override
  _LendingState createState() => _LendingState();
}

class _LendingState extends State<Lending> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          "Video Stream",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/person_image.jpg"),
                radius: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "John Smith",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Celebrity",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: FlatButton(
                splashColor: Colors.black,
                onPressed: () {},
                child: Text(
                  "JOIN",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.indigoAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
