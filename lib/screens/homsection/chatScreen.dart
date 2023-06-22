import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MessageRoute extends StatefulWidget {
  @override
  _MessageRouteState createState() => _MessageRouteState();
}

class _MessageRouteState extends State<MessageRoute> {
  bool _isLoaderOpen = false;
  String _resMsg = '';
  List<dynamic> _messagesList = [];
  List<dynamic> _messages = [];
  String _fromuid = '';
  String _fromuuid = '';

  @override
  void initState() {
    super.initState();
    // Get messages when the screen is first loaded
    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: _isLoaderOpen
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _resMsg.isNotEmpty
          ? Center(
        child: Text(_resMsg),
      )
          : RefreshIndicator(
        onRefresh: () => onRefresh(),
        child: ListView.builder(
          itemCount: _messagesList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_messagesList[index]['member_name']),
              subtitle: Text(_messagesList[index]['text']),
            );
          },
        ),
      ),
    );
  }

  Future<void> getMessages() async {
    setState(() {
      _isLoaderOpen = true;
    });

    try {
      // Retrieve user data from storage
      // final jsonValue = await AsyncStorage.getItem('@storage_login');
      // final asyncData = jsonValue != null ? json.decode(jsonValue) : null;
      // final usrid = asyncData['user']['id'];
      final usrid = 76; // Replace with actual user ID

      // Make API request to get messages
      final response = await http.get(Uri.parse('/user_chat_threads/$usrid'));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        setState(() {
          _messagesList = jsonData['data']['data'];
          _resMsg = '';
          _isLoaderOpen = false;
        });
      } else {
        setState(() {
          _messagesList = [];
          _resMsg = jsonData['message'];
          _isLoaderOpen = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoaderOpen = false;
      });
    }
  }

  Future<void> onRefresh() async {
    await getMessages();
  }
}
