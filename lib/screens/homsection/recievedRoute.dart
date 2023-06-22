import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceivedRoute extends StatefulWidget {
  @override
  _ReceivedRouteState createState() => _ReceivedRouteState();
}

class _ReceivedRouteState extends State<ReceivedRoute> {
  bool isLoaderOpen = false;
  List<dynamic> receivedData = [];
  String resmsg = '';

  @override
  void initState() {
    super.initState();
    getReceivedList();
  }

  Future<void> getReceivedList() async {
    try {
      setState(() {
        isLoaderOpen = true;
      });

      // Check network connectivity
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.none) {
      //   setState(() {
      //     isLoaderOpen = false;
      //   });
      //   showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: Text('Network Error'),
      //       content: Text('You are not connected to the internet. Please check your connection.'),
      //       actions: [
      //         TextButton(
      //           child: Text('OK'),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     ),
      //   );
      //   return;
      // }

      // Make API request
      final response = await http.post(
        Uri.parse('/showReceived'),
        // body: {'user_id': userId}, // Replace with your API endpoint and data
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            receivedData = data['data'];
            isLoaderOpen = false;
          });
        } else {
          setState(() {
            receivedData = data['data'];
            resmsg = data['message'];
            isLoaderOpen = false;
          });
        }
      } else {
        setState(() {
          isLoaderOpen = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Server Error'),
            content: Text('An error occurred while communicating with the server.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (error) {
      setState(() {
        isLoaderOpen = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $error'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void storeAcceptDecline(String itemId, String statusId) {
    // Implement your accept/decline logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Route Screen'),
      ),
      body: isLoaderOpen
          ? Center(
        child: CircularProgressIndicator(),
      )
          : receivedData.isEmpty
          ? Center(
        child: Text(resmsg),
      )
          : ListView.builder(
        itemCount: receivedData.length,
        itemBuilder: (context, index) {
          final item = receivedData[index];
          // Implement your item rendering logic here
          return ListTile(
            title: Text(item['first_name']),
            subtitle: Text(item['job_title']),
            // Implement other item UI components
          );
        },
      ),
    );
  }
}
