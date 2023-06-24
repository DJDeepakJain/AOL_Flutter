import 'package:aol_matrimony_flutter/screens/homsection/matchMaking.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoaderOpen = false;
  bool isInvalid = false;
  bool showPassword = false;
  String usrEmail = '';
  String usrPassword = '';
  bool showLogin = false;
  bool showLoginView = false;
  List<Map<String, String>> slideData = [
    {
      "id": "1",
      "title": "Find your partner on the path",
      "content": "We protect our community by making sure everyone on the platform is real",
      "file": "slide_1.png"
    },
    {
      "id": "2",
      "title": "Connect with verified premium profiles",
      "content": "Get a safe and reliable experience with a platform for verified profiles only",
      "file": "slide_2.png"
    },
    {
      "id": "3",
      "title": "Simple & reasonable pricing",
      "content": "All our plans are valid for 1 year and start at INR 999 onwards.",
      "file": "slide_3.png"
    }
  ];
  int currentIndex = 0;

  get asyncData => retrieveData();

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  void retrieveData() async {
    setState(() {
      isLoaderOpen = true;
    });

    // Retrieve data from AsyncStorage or any other storage

    if (asyncData == null || asyncData.length == 0) {
      setState(() {
        isLoaderOpen = false;
        showLogin = true;
      });
    } else {
      setState(() {
        isLoaderOpen = false;
      });
      checkNotification();
    }
  }

  void checkNotification() {
    // Perform necessary operations for notifications

    setState(() {
      isLoaderOpen = false;
    });

    Navigator.pushReplacementNamed(context, 'Matchmaking');
  }

  void getDeviceToken() {
    setState(() {
      isLoaderOpen = true;
    });

    // Get device token

    // userLogin(deviceToken);
  }

  void userLogin(String deviceToken) {
    setState(() {
      isLoaderOpen = true;
    });

    if (usrEmail.isEmpty || usrPassword.isEmpty) {
      setState(() {
        isLoaderOpen = false;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Warning"),
            content: Text("Please fill email and password !!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      });
    } else {
      // Perform login API call
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background and other widgets
          // ...

          if (showLogin)
            Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and other widgets
                    // ...

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          suffixIcon: Icon(Icons.email),
                        ),
                        onChanged: (value) {
                          setState(() {
                            usrEmail = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            child: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        obscureText: !showPassword,
                        onChanged: (value) {
                          setState(() {
                            usrPassword = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => getDeviceToken(),
                      child: Text("Login"),
                    ),
                    // Other buttons and widgets
                    // ...
                  ],
                ),
              ),
            ),

          if (isLoaderOpen)
            Center(child: CircularProgressIndicator()),

          if (isInvalid)
            Center(
              child: AlertDialog(
                title: Text("Error"),
                content: Text("Invalid email or password"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(MatchmakingScreen() as String);
                      setState(() {
                        isInvalid = false;
                      });
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


