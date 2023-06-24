import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  void getReceivedList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonValue = prefs.getString('@storage_login');
      final asyncData = jsonValue != null ? json.decode(jsonValue) : null;
      setIsLoaderOpen(true);

      // Connectivity().checkConnectivity().then((connectivityResult) {
      //   if (connectivityResult == ConnectivityResult.mobile ||
      //       connectivityResult == ConnectivityResult.wifi) {
          final usrid = asyncData['user']['id'];
          http.post(Uri.parse('https://matrimony.abhosting.co.in/api/api/auth/showReceived'),body : {'user_id': 207})
              .then((response) {
            if (response.statusCode == 200) {
              final responseData = json.decode(response.body);
              if (responseData['status'] == 'success') {
                setReceivedData(responseData['data']);
                setIsLoaderOpen(false);
                setRefreshing(false);
              }else {
                setReceivedData(responseData['data']);
                setResMsg(responseData['message']);
                setIsLoaderOpen(false);
                setRefreshing(false);
              }
            } else {
              setIsLoaderOpen(false);
              setRefreshing(false);
              // Handle server error
            }
          }).catchError((error) {
            setIsLoaderOpen(false);
            setRefreshing(false);
            // Handle error
          });
      //   }else {
      //     setIsLoaderOpen(false);
      //     showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //         title: Text('Network Error'),
      //         content: Text('You are not connected to the internet. Please check your internet connection.'),
      //         actions: [
      //           TextButton(
      //             onPressed: () => Navigator.pop(context),
      //             child: Text('OK'),
      //           ),
      //         ],
      //       ),
      //     );
      //   }
      // });
    }catch (error) {
      setIsLoaderOpen(false);
      setRefreshing(false);
    }
  }

  void setIsLoaderOpen(bool isOpen) {
    // Set the state variable 'isLoaderOpen' with the provided value
  }

  void setReceivedData(dynamic data) {
    // Set the state variable 'receivedData' with the provided data
  }

  void setResMsg(String message) {
    // Set the state variable 'resMsg' with the provided message
  }

  void setRefreshing(bool isRefreshing) {
    // Set the state variable 'isRefreshing' with the provided value
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
