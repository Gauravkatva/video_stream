import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_stream/screen/call_screen.dart';
import 'package:video_stream/utils/settings.dart' as settings;

class Lending extends StatefulWidget {
  @override
  _LendingState createState() => _LendingState();
}

class _LendingState extends State<Lending> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                radius: 150,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                child: FlatButton(
                  splashColor: Colors.white,
                  onPressed: () {
                    onJoin();
                  },
                  child: Text(
                    "JOIN",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;
    // push video page with given channel name
    EasyLoading.show(status: "Please wait...");
    if (cameraStatus.isGranted && micStatus.isGranted) {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => CallScreen(
                role: ClientRole.Broadcaster,
                channelName: settings.Channel_Name,
              )));
    }
    EasyLoading.dismiss();
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
