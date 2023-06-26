import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String uuid;
  final String username;
  final String image;
  final String userManage;
  final int deactivated;

  ChatScreen({
    required this.uuid,
    required this.username,
    required this.image,
    required this.userManage,
    required this.deactivated, required user_id,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late User _currentUser;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
    _subscribeToMessages();
  }

  Future<void> _initializeCurrentUser() async {
    final auth = FirebaseAuth.instance;
    final currentUser = await auth.currentUser!;
    setState(() {
      _currentUser = currentUser;
    });
  }

  void _subscribeToMessages() {
    final docId = getChatRoomDocId(widget.uuid, 'nK9hXmVvE7eRPlgLeNGgSDvDc0k2');
    final collectionRef =
    FirebaseFirestore.instance.collection('chats/$docId/msg');
    _messagesStream = collectionRef.orderBy('createdAt', descending: true).snapshots();
  }

  String getChatRoomDocId(String uuid1, String uuid2) {
    return uuid1.compareTo(uuid2) < 0 ? '$uuid1-$uuid2' : '$uuid2-$uuid1';
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final docId = getChatRoomDocId(widget.uuid, 'nK9hXmVvE7eRPlgLeNGgSDvDc0k2');
    final collectionRef =
    FirebaseFirestore.instance.collection('chats/$docId/msg');
    final messageData = {
      'text': text,
      'sentBy': 'dyvhfTMaCPhfGcxiGXwjVJzYyjG3',
      'sentTo': widget.uuid,
      'createdAt': DateTime.now(),
      'sent': true,
      'received': false,
      'pending': false,
    };

    setState(() {
      _isSendingMessage = true;
    });

    try {
      await collectionRef.add(messageData);
      sendNotification('207');
    } catch (error) {
      print('Error sending message: $error');
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }
  void sendNotification(String userId) async {
    print("user_id: $userId");
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        var response = await http.post(
          Uri.parse('/chatnotify'),
          body: jsonEncode({'user_id': userId}),
        );
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print("notify: $data");
          // if (data['status'] == 'success') {
          //   // Handle success case here
          //   // setIsLoaderOpen(false);
          //   // showDialog(...);
          //   // getMemberData();
          // } else {
          //   print(data['status']);
          //   // Handle other status cases here
          //   // setIsLoaderOpen(false);
          //   // showDialog(...);
          //   // showErrorAlert(data['status']);
          // }
        } else {
          print(response.statusCode);
          // Handle server error here
          // setIsLoaderOpen(false);
          // showDialog(...);
          // showErrorAlert("Server Error");
        }
      } catch (error) {
        print(error);
        // Handle error here
        // setIsLoaderOpen(false);
        // showDialog(...);
        // showErrorAlert("Server Error");
      }
    } else {
      print("Network Error");
      // Handle network error here
      // setIsLoaderOpen(false);
      // showDialog(...);
      // showErrorAlert("Network Error");
    }
  }
  Widget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.image),
          ),
          SizedBox(width: 8),
          Text(widget.username),
        ],
      ),
      actions: [
        Badge(
          child: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options button tap
            },
          ),
          badgeContent: Text(
            widget.userManage,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(DocumentSnapshot<Map<String, dynamic>> doc) {
    final message = doc.data()!;
    final isSentByCurrentUser = message['sentBy'] == 'dyvhfTMaCPhfGcxiGXwjVJzYyjG3';
    final bubbleColor = isSentByCurrentUser ? Colors.white : Color(0xFFEFEAF9);
    final textColor = isSentByCurrentUser ? Colors.black : Colors.black;
    final isPending = message['pending'];
    final isReceived = message['received'];

    return Container(
      alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'],
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            if (isPending) Text('Sending...', style: TextStyle(fontSize: 12)),
            if (isReceived) Text('Sent', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    return ListView(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: docs.map((doc) => _buildMessageBubble(doc)).toList(),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration.collapsed(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isSendingMessage
                ? null
                : () {
              _sendMessage(_textController.text);
              _textController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _messagesStream,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              return Expanded(
                child: _buildMessagesList(docs),
              );
            },
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final Widget child;
  final Widget badgeContent;

  Badge({
    required this.child,
    required this.badgeContent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        child,
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          constraints: BoxConstraints(
            minWidth: 18,
            minHeight: 18,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: badgeContent,
            ),
          ),
        ),
      ],
    );
  }
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(
        user_id: '207',
        uuid: 'sample_uuid',
        username: 'Sample User',
        image: 'https://sampleimage.com/image.jpg',
        userManage: '1',
        deactivated: 0,
      ),
    );
  }
}
