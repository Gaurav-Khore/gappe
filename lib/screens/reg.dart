import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Reg extends StatefulWidget {
  @override
  _RegState createState() => _RegState();
}

class _RegState extends State<Reg> {
  File imagefilepath;
  var imgurl;
  var furl;
  var id;
  var name, photoURL;
  var passwd, cpass;
  var auth = FirebaseAuth.instance;
  var fstore = FirebaseFirestore.instance;
  var picker = ImagePicker();
  var otcp = true;
  var otp = true;
  bool sspin = false;
  var tc = TextEditingController();
  var nc = TextEditingController();
  var pc = TextEditingController();
  var cpc = TextEditingController();
  Future clickphoto() async {
    var picker = ImagePicker();
    var image = await picker.getImage(
      source: ImageSource.camera,
    );

    print(imagefilepath);
    print('photo clicked');

    setState(() {
      imagefilepath = File(image.path);
    });
    Reference fbstorage =
        FirebaseStorage.instance.ref().child("profile").child("$name.png");
    print("fbstorage $fbstorage");

    UploadTask tr = fbstorage.putFile(imagefilepath);
    print("tr = $tr");

    await tr.whenComplete(() async {
      imgurl = await fbstorage.getDownloadURL();
    });
    print("imgurl= $imgurl");

    setState(() {
      furl = imgurl;
    });
    print("furl = $furl");
  }

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
            image: ExactAssetImage("images/regbg.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.dstATop),
          )),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.75,
                    margin: EdgeInsets.only(top: 50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 50.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextField(
                            controller: nc,
                            decoration: InputDecoration(
                              labelText: "Name",
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            onChanged: (value) {
                              name = value;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextField(
                            controller: tc,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            onChanged: (value) {
                              id = value;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextField(
                            controller: pc,
                            obscureText: otp,
                            decoration: InputDecoration(
                              labelText: "Password",
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              suffixIcon: otp == true
                                  ? IconButton(
                                      icon: Icon(Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          otp = false;
                                        });
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          otp = true;
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextField(
                            controller: cpc,
                            obscureText: otcp,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              suffixIcon: otcp == true
                                  ? IconButton(
                                      icon: Icon(Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          otcp = false;
                                        });
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          otcp = true;
                                        });
                                      },
                                    ),
                            ),
                            onChanged: (value) {
                              cpass = value;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            child: Text(
                              "Sign UP",
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
                                if (id == null) {
                                  setState(() {
                                    sspin = false;
                                  });
                                  return Fluttertoast.showToast(
                                      msg: "Enter Email",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }

                                if (passwd != cpass) {
                                  setState(() {
                                    sspin = false;
                                  });
                                  return Fluttertoast.showToast(
                                      msg: "Passsword not matched",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                                if (passwd == null) {
                                  setState(() {
                                    sspin = false;
                                  });
                                  return Fluttertoast.showToast(
                                      msg: "Enter password",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                                if (furl == null) {
                                  setState(() {
                                    sspin = false;
                                  });
                                  return Fluttertoast.showToast(
                                      msg: "Add Profile Picture",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }

                                await auth.createUserWithEmailAndPassword(
                                    email: id, password: passwd);
                                tc.clear();
                                nc.clear();
                                pc.clear();
                                cpc.clear();

                                await fstore
                                    .collection("user")
                                    .doc("${auth.currentUser.uid}")
                                    .set({
                                  'name': '$name',
                                  'email': '${auth.currentUser.email}',
                                  'photoUrl': "$furl",
                                  'uid': '${auth.currentUser.uid}',
                                  'timestamp': FieldValue.serverTimestamp(),
                                });
                                var ty = await fstore
                                    .collection('user')
                                    .doc("${auth.currentUser.uid}")
                                    .get();

                                Navigator.pushNamed(context, "home",
                                    arguments: {
                                      'photoUrl': "${ty.data()['photoUrl']}"
                                    });
                              } catch (e) {
                                if (e.toString() ==
                                    "[firebase_auth/weak-password] Password should be at least 6 characters") {
                                  setState(() {
                                    sspin = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg:
                                          "Enter Password of atleast 6 characters",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              }
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Already have a Account..",
                                style: TextStyle(
                                  letterSpacing: -1,
                                  fontSize: 15.0,
                                  fontFamily: "ShortStack",
                                )),
                            TextButton(
                              child: Text("Sign In",
                                  style: TextStyle(
                                    color: Colors.cyan[200],
                                    fontSize: 20.0,
                                    fontFamily: "ShortStack",
                                    fontWeight: FontWeight.w900,
                                  )),
                              onPressed: () {
                                setState(() {
                                  sspin = true;
                                });
                                Navigator.pushNamed(context, "log");
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: name == null
                        ? () => Fluttertoast.showToast(
                            msg: "Enter Name",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.SNACKBAR,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0)
                        : clickphoto,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 5),
                      ),
                      child: CircleAvatar(
                        backgroundImage: furl == null
                            ? AssetImage("images/pro_pic.png")
                            : NetworkImage(furl),
                        maxRadius: 45.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
