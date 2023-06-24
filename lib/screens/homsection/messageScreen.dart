import 'package:aol_matrimony_flutter/screens/homsection/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageRoute extends StatefulWidget {
  @override
  _MessageRouteState createState() => _MessageRouteState();
}

class _MessageRouteState extends State<MessageRoute> {
  bool isLoaderOpen = false;
  List<dynamic> messagesList = [];
  String resmsg = '';
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    getMessages();
  }

  Future<void> getMessages() async {
    try {
      // Perform network requests using http package
      var response = await http.get(Uri.parse('https://matrimony.abhosting.co.in/api/api/auth/user_chat_threads/207'));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            messagesList = responseData['data']['data'];
          });
        } else {
          setState(() {
            resmsg = responseData['message'];
          });
        }
      } else {
        setState(() {
          resmsg = 'Error occurred while fetching messages';
        });
      }
    } catch (error) {
      setState(() {
        resmsg = 'Network Error: Please check your internet connection';
      });
    } finally {
      setState(() {
        refreshing = false;
        isLoaderOpen = false;
      });
    }
  }

  Future<void> onRefresh() async {
    setState(() {
      refreshing = true;
    });
    await getMessages();
  }

  Widget renderItem(dynamic item, int index) {
    final birthDate = DateTime.parse(item['dob']);
    final curDate = DateTime.now();
    final age = curDate.year - birthDate.year;

    return GestureDetector(
      onTap: () {
        // Navigate to chat screen
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatScreen(
                user_id:item['user_id'],
                uuid: item['uuid'],
                username: item['member_name'],
                image: 'https://matrimony.abhosting.co.in/public/${item['user_profile_picture']}',
                userManage: item['profile_managed'],
                deactivated: item['deactivated'],
            )));

        // Navigator.pushNamed(context, '/chat', arguments: {
        //   'user_id': item['user_id'],
        //   'uuid': item['uuid'],
        //   'username': item['member_name'],
        //   'image': 'https://matrimony.abhosting.co.in/public/${item['user_profile_picture']}',
        //   'userManage': item['profile_managed'],
        //   'deactivated': item['deactivated'],
        // });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
        ),
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.0,
              backgroundImage: NetworkImage(
                'https://matrimony.abhosting.co.in/public/${item['user_profile_picture']}',
              ),
              // backgroundColor: item['deactivated'] ? Colors.grey : null,
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${item['member_name']}, $age',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          // color: item['deactivated'] ? Colors.grey : Colors.black,
                        ),
                      ),
                      // if (item['deactivated'])
                        Container(
                          margin: EdgeInsets.only(left: 5.0),
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'DEACTIVATED',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    '${item['last_message']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: messagesList.length,
          itemBuilder: (BuildContext context, int index) {
            return renderItem(messagesList[index], index);
          },
        ),
      ),
    );
  }
}
