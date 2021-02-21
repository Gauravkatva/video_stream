import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../utils/settings.dart' as settings;

class CallScreen extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const CallScreen({Key key, this.channelName, this.role}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (settings.APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(settings.Token, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(settings.APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  List<Widget> _headerWidgets() {
    Widget _closeButton = IconButton(
      iconSize: 30,
      color: Colors.white,
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(Icons.cancel_rounded),
    );
    return [
      Expanded(
        child: Container(
          width: 125,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: CircleAvatar(
                        backgroundImage: AssetImage("assets/person1.jpg"),
                      ),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.yellow[800],
                      size: 15,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {},
                    icon: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 10,
      ),
      Expanded(
        child: Row(
          children: [
            Container(
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/person2.jpg"),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/person3.jpg"),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/person4.jpg"),
              ),
            ),
            Expanded(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(left: 15),
              ),
            ),
          ],
        ),
      ),
      _closeButton,
    ];
  }

  List<Widget> _footerWidgets() {
    Widget giftButton = Padding(
      padding: const EdgeInsets.all(5.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.yellow[800],
        child: IconButton(
          color: Colors.grey[200],
          onPressed: () {},
          icon: Icon(Icons.card_giftcard),
        ),
      ),
    );

    Widget shareButton = Padding(
      padding: const EdgeInsets.all(5.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          color: Colors.white,
          onPressed: () {},
          icon: Icon(Icons.share),
        ),
      ),
    );

    Widget sendMail = Padding(
      padding: const EdgeInsets.all(5.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          color: Colors.white,
          onPressed: () {},
          icon: Icon(Icons.mail_outlined),
        ),
      ),
    );

    Widget chatTextField = Expanded(
      child: Container(
        height: 40,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );

    // Widget shareButton =

    // Returning the list
    return [
      chatTextField,
      sendMail,
      shareButton,
      giftButton,
    ];
  }

  /// Toolbar layout
  Widget _toolbar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _headerWidgets(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _footerWidgets(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> fansList = [
    "assets/person_image.jpg",
    "assets/person4.jpg",
    "assets/person5.jpg",
  ];

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            reverse: true,
            itemCount: fansList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(fansList[index]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // void _onCallEnd(BuildContext context) {
  //   Navigator.pop(context);
  // }

  // void _onToggleMute() {
  //   setState(() {
  //     muted = !muted;
  //   });
  //   _engine.muteLocalAudioStream(muted);
  // }

  // void _onSwitchCamera() {
  //   _engine.switchCamera();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
