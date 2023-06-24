import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchesRoute extends StatefulWidget {
  @override
  _MatchesRouteState createState() => _MatchesRouteState();
}

class _MatchesRouteState extends State<MatchesRoute> {
  bool isLoaderOpen = true;
  int profileCompleted = 0;
  int profileInCompleted = 0;
  String photo = '';
  bool userVerified = false;
  String userVerifyStatus = '';
  List<dynamic> matchData = [];
  String resmsg = '';
  int totalLeftConnection = 0;
  bool showConnection = false;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    getProfileCompletion();
  }

  Future<void> getProfileCompletion() async {
    setState(() {
      isLoaderOpen = true;
    });

    // Make the API call using http package or your preferred http library
    // Replace the API endpoint with your actual endpoint
    final response = await http.post(Uri.parse('https://matrimony.abhosting.co.in/api/api/auth/profileCompletion'), body: {
      'user_id': '207',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final completed = int.parse(data['data']['complete']);
        final incompleted = int.parse(data['data']['incomplete']);
        setState(() {
          profileCompleted = completed;
          profileInCompleted = incompleted;
        });

        getMemberData();
      } else {
        print('data from profile Completion'+data);
        setState(() {
          isLoaderOpen = false;
        });
      }
    } else {
      print(response.body);
      setState(() {
        isLoaderOpen = false;
      });
    }
  }

  Future<void> getMemberData() async {
    setState(() {
      isLoaderOpen = true;
    });

    // Make the API call using http package or your preferred http library
    // Replace the API endpoint with your actual endpoint
    final response = await http.get(
      Uri.parse('https://matrimony.abhosting.co.in/api/api/auth/userProfiles?user_id=207'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          userVerified = false;
          if (data['data']['userData']['user_verification'] == null ||
              data['data']['userData']['user_verification'] == 0) {
            userVerified = true;
            userVerifyStatus = '0';
          } else {
            userVerifyStatus = data['data']['userData']['user_verification'];
          }

          if (data['data']['photos'].length > 0) {
            photo = data['data']['photos'][0]['file_name'];
          }

          getProfileMatches();
        });
      } else {
        print('data from memberdata'+data);
        setState(() {
          isLoaderOpen = false;
          refreshing = false;
        });
      }
    } else {
      print('404 from memberdata'+response.body);
      setState(() {
        isLoaderOpen = false;
        refreshing = false;
      });
    }
  }

  Future<void> getProfileMatches() async {
    setState(() {
      isLoaderOpen = true;
    });

    // Make the API call using http package or your preferred http library
    // Replace the API endpoint with your actual endpoint
    final response =
    await http.get(Uri.parse('https://matrimony.abhosting.co.in/api/api/auth/profileMatches/get_match_profiles/207'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          matchData = data['data'];
        });
      } else {
        print('data'+data);
      }
    } else {
      print('res'+ response.body);
    }

    setState(() {
      isLoaderOpen = false;
      refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: matchData.length,
          itemBuilder: (context, index) {
            final match = matchData[index];
            return ListTile(
              title: Text(match['name']),
              subtitle: Text(match['description']),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(match['photo']),
              ),
              onTap: () {
                // Handle match item tap
              },
            );
          },
        ),
      ),
    );
  }
}
