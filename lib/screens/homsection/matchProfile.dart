import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchesRoute extends StatefulWidget {
  @override
  _MatchesRouteState createState() => _MatchesRouteState();
}

class _MatchesRouteState extends State<MatchesRoute> {
  bool isLoaderOpen = true;
  bool userVerified = false;
  String userVerifyStatus = '';
  List<dynamic> matchData = [];
  String resMsg = '';
  int totalLeftConnection = 0;
  bool showConnection = false;

  @override
  void initState() {
    super.initState();
    getProfileCompletion();
  }

  Future<void> getProfileCompletion() async {
    print("get profile completion");
    // Fetch data from API and update the state
    // try {
    //   // Make the API request
    //   http.Response response = await http.post(
    //     Uri.parse('/profileCompletion'),
    //     body: {
    //       'user_id': asyncData.user.id.toString(),
    //     },
    //   );
    //
    //   if (response.statusCode == 200) {
    //     // Parse the response data
    //     var data = json.decode(response.body);
    //     if (data['status'] == 'success') {
    //       setState(() {
    //         // Update the state with received data
    //         setProfileCompleted(int.parse(data['data']['complete']));
    //         setProfileInCompleted(int.parse(data['data']['incomplete']));
    //       });
    //       getMemberData();
    //     } else {
    //       print(data);
    //       setState(() {
    //         setIsLoaderOpen(false);
    //       });
    //     }
    //   } else {
    //     print(response.body);
    //     setState(() {
    //       setIsLoaderOpen(false);
    //     });
    //   }
    // } catch (error) {
    //   print(error);
    // }
  }

  Future<void> getMemberData() async {
    print("get member data");
    // Fetch data from API and update the state
    // try {
    //   // Make the API request
    //   http.Response response = await http.get(
    //     Uri.parse('/userProfiles?user_id=' + asyncData.user.id.toString()),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     // Parse the response data
    //     var data = json.decode(response.body);
    //     if (data['status'] == 'success') {
    //       setState(() {
    //         // Update the state with received data
    //         setUserVerified(false);
    //         if (data['data']['userData']['user_verification'] == null ||
    //             data['data']['userData']['user_verification'] == 0) {
    //           setUserVerified(true);
    //           setUserVerifyStatus('0');
    //         } else {
    //           setUserVerifyStatus(data['data']['userData']['user_verification']);
    //         }
    //         if (data['data']['photos'].length > 0) {
    //           setPhoto(data['data']['photos'][0]['file_name']);
    //         }
    //         getProfileMatches();
    //       });
    //     } else {
    //       print(data);
    //       setState(() {
    //         setIsLoaderOpen(false);
    //         setRefreshing(false);
    //       });
    //     }
    //   } else {
    //     print(response.body);
    //     setState(() {
    //       setIsLoaderOpen(false);
    //       setRefreshing(false);
    //     });
    //   }
    // } catch (error) {
    //   setState(() {
    //     setIsLoaderOpen(false);
    //     setRefreshing(false);
    //   });
    //   print(error);
    // }
  }

  // Future<void> getProfileMatches() async {
  //   print("get match data");
  //   // Fetch data from API and update the state
  //   try {
  //     // Make the API request
  //     http.Response response = await http.get(
  //       Uri.parse('profileMatches/get_match_profiles/' + asyncData.user.id.toString()),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Parse the response data
  //       var data = json.decode(response.body);
  //       if (data['status'] == 'success') {
  //         setState(() {
  //           // Update the state with received data
  //           setMatchData(data['data']);
  //           setTotalLeftConnection(int.parse(data['total_left_connection']));
  //           setShowConnection(false);
  //           setIsLoaderOpen(false);
  //         });
  //       } else {
  //         print(data);
  //         setState(() {
  //           setIsLoaderOpen(false);
  //         });
  //       }
  //     } else {
  //       print(response.body);
  //       setState(() {
  //         setIsLoaderOpen(false);
  //       });
  //     }
  //   } catch (error) {
  //     print(error);
  //     setState(() {
  //       setIsLoaderOpen(false);
  //     });
  //   }
  // }

  // void setProfileCompleted(int complete) {
  //   setState(() {
  //     profileComplete = complete;
  //   });
  // }

  // void setProfileInCompleted(int incomplete) {
  //   setState(() {
  //     profileIncomplete = incomplete;
  //   });
  // }

  void setUserVerified(bool verified) {
    setState(() {
      userVerified = verified;
    });
  }

  void setUserVerifyStatus(String status) {
    setState(() {
      userVerifyStatus = status;
    });
  }

  void setMatchData(List<dynamic> data) {
    setState(() {
      matchData = data;
    });
  }

  void setTotalLeftConnection(int total) {
    setState(() {
      totalLeftConnection = total;
    });
  }

  void setShowConnection(bool show) {
    setState(() {
      showConnection = show;
    });
  }

  void setIsLoaderOpen(bool isOpen) {
    setState(() {
      isLoaderOpen = isOpen;
    });
  }

  void setRefreshing(bool refreshing) {
    setState(() {
      isLoaderOpen = refreshing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
      ),
      body: isLoaderOpen
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            if (userVerified && userVerifyStatus == '0')
              Container(
                // Display verification message
                padding: EdgeInsets.all(16.0),
                color: Colors.yellow,
                child: Text('Your account is not verified.'),
              ),
            if (showConnection)
              Container(
                // Display connection message
                padding: EdgeInsets.all(16.0),
                color: Colors.green,
                child: Text('You have $totalLeftConnection connections left.'),
              ),
            ListView.builder(
              // Display match profiles
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: matchData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(matchData[index]['name']),
                  subtitle: Text(matchData[index]['description']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


