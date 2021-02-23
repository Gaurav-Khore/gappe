import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var fstore = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;
  bool sspin = false;

  myPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Fluttertoast.showToast(
          msg: "Location services are disabled",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    var e = await Geolocator.getCurrentPosition();
    print("location = $e");
    print(e.latitude);
    print(e.longitude);

    Navigator.pushNamed(context, "map", arguments: {
      'lat': e.latitude,
      'long': e.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> info = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
        inAsyncCall: sspin,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage("images/profilebg.jpg"),
                fit: BoxFit.fill),
          ),
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.all(40.0),
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  width: 250,
                  height: 250,
                  margin: EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.deepOrange[50],
                      width: 5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("${info['name']}",
                          style: TextStyle(
                              fontFamily: 'YuseiMagic',
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.mail),
                            Text("${auth.currentUser.email}",
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontFamily: 'DancingScript',
                                )),
                          ]),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.deepOrange[50],
                      width: 5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("${info['phtoUrl']}"),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          sspin = true;
                        });
                        await auth.signOut();

                        Navigator.pushNamed(context, "log");
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(top: 270.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: Colors.deepOrange[50],
                            width: 4,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: ExactAssetImage("images/logout.png"),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        myPosition();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(top: 270.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: Colors.deepOrange[50],
                            width: 4,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: ExactAssetImage("images/map.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
