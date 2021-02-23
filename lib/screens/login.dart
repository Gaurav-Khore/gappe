import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Log extends StatefulWidget {
  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {
  var id;
  var passwd;
  var auth = FirebaseAuth.instance;
  var fstore = FirebaseFirestore.instance;
  bool sspin = false;

  var ot = true;
  var tc = TextEditingController();
  var pc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
        inAsyncCall: sspin,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage("images/logbg.jpg"), fit: BoxFit.cover),
          ),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.5,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.925,
                          child: TextField(
                            controller: tc,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                              labelText: "Email",
                              labelStyle: TextStyle(fontSize: 20.0),
                            ),
                            style: TextStyle(fontSize: 20.0),
                            onChanged: (value) {
                              id = value;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.925,
                        child: TextField(
                          controller: pc,
                          style: TextStyle(fontSize: 20.0),
                          obscureText: ot,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.35),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Password",
                            suffixIcon: ot == true
                                ? IconButton(
                                    icon: Icon(Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        ot = false;
                                      });
                                    },
                                  )
                                : IconButton(
                                    icon: Icon(Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        ot = true;
                                      });
                                    },
                                  ),
                          ),
                          onChanged: (value) {
                            passwd = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      RaisedButton(
                        highlightElevation: 10.0,
                        color: Colors.blueAccent[400],
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        child: Text(
                          "SIGN IN",
                          style: TextStyle(
                              fontSize: 25.0,
                              fontFamily: "ShortStack",
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          setState(() {
                            sspin = true;
                          });
                          try {
                            await auth.signInWithEmailAndPassword(
                                email: id, password: passwd);
                            tc.clear();
                            pc.clear();
                            var x = auth.currentUser == null
                                ? "test"
                                : "${auth.currentUser.uid}";
                            var ty =
                                await fstore.collection('user').doc(x).get();
                            Navigator.pushNamed(context, "home", arguments: {
                              'photoUrl': "${ty.data()['photoUrl']}"
                            });
                          } catch (e) {
                            if (id == null) {
                              setState(() {
                                sspin = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Enter Email",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (passwd == null) {
                              setState(() {
                                sspin = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Enter Password",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (e.toString() ==
                                "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
                              setState(() {
                                sspin = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Wrong Password",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (e.toString() ==
                                "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                              setState(() {
                                sspin = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "User Not Found",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (e.toString() ==
                                "[firebase_auth/unknown] Given String is empty or null") {
                              setState(() {
                                sspin = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Enter the values",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      right: MediaQuery.of(context).size.width * 0.1),
                  child: Image.asset(
                    "images/chat.png",
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.435),
                  child: SizedBox(
                    height: 40.0,
                    child: WavyAnimatedTextKit(
                      textStyle: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow[200]),
                      text: [
                        "GAPPE",
                        "....",
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.78,
                      left: 20.0),
                  child: Row(
                    children: [
                      Text("Don't have account",
                          style: TextStyle(
                            letterSpacing: -1,
                            fontSize: 15.0,
                            fontFamily: "ShortStack",
                          )),
                      TextButton(
                        child: Text("Sign Up",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "ShortStack",
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            sspin = true;
                          });
                          Navigator.pushNamed(context, "reg");
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
