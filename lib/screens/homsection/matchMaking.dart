import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'messageScreen.dart';
import 'matchProfile.dart';
import 'recievedRoute.dart';
import 'sentRoute.dart';

class MatchmakingScreen extends StatefulWidget {
  @override
  _MatchmakingScreenState createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoaderOpen = false;
  int _index = 0;
  String _service = 'MATCHMAKING';
  String _photo = '';
  List<Widget> _screens = [];

  List<String> _tabTitles = [
    'Matches',
    'Received',
    'Sent',
    'Messages',
  ];

  List<dynamic> _received = [];
  bool _showReceivedNoti = false;
  bool _showMsgNoti = false;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data['action'] == 'Received') {
        setState(() {
          _showReceivedNoti = true;
        });
        _getMemberData();
      } else if (message.data['action'] == 'SenderAccept' ||
          message.data['action'] == 'Accept' ||
          message.data['action'] == 'Message') {
        setState(() {
          _showMsgNoti = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildTabView(),
            if (_isLoaderOpen) _buildLoaderDialog(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            'assets/images/ring.png',
            height: 14,
            width: 20,
          ),
          SizedBox(width: 8),
          Text(
            'MATCHMAKING',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
      actions: [
        IconButton(
          icon: Image.asset(
            _photo == '' ? 'assets/images/user.png' : _photo,
            width: 30,
            height: 30,
          ),
          onPressed: () {
            // Handle profile button press
          },
        ),
      ],
    );
  }

  Widget _buildTabView() {
    _screens =  [
      MatchesRoute(),
      ReceivedRoute(),
      SentRoute(),
      MessageRoute(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CupertinoSegmentedControl(
            children: {
              0: _buildTabTitle('Matches'),
              1: _buildTabTitle('Received'),
              2: _buildTabTitle('Sent'),
              3: _buildTabTitle('Messages'),
            },
            onValueChanged: (value) {
              setState(() {
                _index = value;
                _service = _tabTitles[_index].toUpperCase();
              });
            },
            groupValue: _index,
            // selectedColor: CustomColors.primaryColor,
            // borderColor: CustomColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _index,
            children: _screens,
          ),
        ),
      ],
    );
  }

  Widget _buildTabTitle(String title) {
    bool showNotification = false;
    switch (title) {
      case 'Matches':
        showNotification = _showMsgNoti;
        break;
      case 'Received':
        showNotification = _showReceivedNoti;
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showNotification)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: CustomColors.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoaderDialog() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _getMemberData() async {
    setState(() {
      _isLoaderOpen = true;
    });

    // User user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   String userId = user.uid;
    //   MemberData memberData = Provider.of<MemberData>(context, listen: false);
    //   memberData.clearData();
    //
    //   ApiService apiService = ApiService();
    //   await apiService.getMemberData(userId);
    //
    //   setState(() {
    //     _isLoaderOpen = false;
    //     _showReceivedNoti = false;
    //   });
    // }
  }
}
