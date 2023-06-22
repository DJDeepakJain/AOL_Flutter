import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SentRoute extends StatefulWidget {
  @override
  _SentRouteState createState() => _SentRouteState();
}

class _SentRouteState extends State<SentRoute> {
  bool isLoaderOpen = false;
  List<dynamic> sentData = [];
  String resmsg = '';

  @override
  void initState() {
    super.initState();
    getSentList();
  }

  Future<void> getSentList() async {
    setState(() {
      isLoaderOpen = true;
    });

    try {
      // Make sure to replace the URL with your API endpoint
      final response = await http.post(
        Uri.parse('https://example.com/showSentRequests'),
        body: {'user_id': 'usrid'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            sentData = data['data'];
            resmsg = '';
          });
        } else {
          setState(() {
            sentData = data['data'];
            resmsg = data['message'];
          });
        }
      } else {
        print(response.statusCode);
      }
    } catch (error) {
      print(error);
    }

    setState(() {
      isLoaderOpen = false;
    });
  }

  Future<void> withdrawRequest(String fromUser, String toUser) async {
    setState(() {
      isLoaderOpen = true;
    });

    try {
      // Make sure to replace the URL with your API endpoint
      final response = await http.post(
        Uri.parse('https://example.com/withdrawRequest'),
        body: {'from_user': fromUser, 'to_user': toUser},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Success'),
              content: Text(data['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    getSentList();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          print(data['status']);
        }
      } else {
        print(response.statusCode);
      }
    } catch (error) {
      print(error);
    }

    setState(() {
      isLoaderOpen = false;
    });
  }

  Widget buildItem(BuildContext context, int index) {
    final item = sentData[index];
    final birthDate = DateTime.parse(item['birthday']);
    final curDate = DateTime.now();
    final age = curDate.year - birthDate.year;

    return Column(
      children: [
        if (item['accept_decline_status'] < 2) ...[
          GestureDetector(
            onTap: () {
              // Navigate to chat screen
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Center(
                    child: item['photo'] == ''
                        ? Image.asset(
                      'images/user.png',
                      width: 112,
                      height: 70,
                    )
                        : Image.network(
                      'https://matrimony.abhosting.co.in/public/${item['photo']}',
                      width: 112,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Age: $age',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Job Title: ${item['job_title']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Company: ${item['company_name']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Location: ${item['city']}, ${item['state']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item['accept_decline_status'] == 0) ...[
                    ElevatedButton(
                      onPressed: () {
                        withdrawRequest(item['from_user'], item['to_user']);
                      },
                      child: Text('Withdraw'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sent Requests'),
      ),
      body: isLoaderOpen
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: getSentList,
        child: ListView.builder(
          itemCount: sentData.length,
          itemBuilder: buildItem,
        ),
      ),
    );
  }
}
