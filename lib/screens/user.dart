import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  var newuser = false;
  var auth = FirebaseAuth.instance;
  var fstore = FirebaseFirestore.instance;
  var sv;
  var i = 0;
  var j = 0;
  var sc = TextEditingController();
  var l = [];
  myL() async {
    await for (var i in fstore
        .collection("details")
        .doc("${auth.currentUser.uid}")
        .collection("${auth.currentUser.uid}")
        .snapshots()) {
      for (var doc in i.docs) {
        setState(() {
          l.add(doc.data()['name']);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Friends"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage("images/bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration:
                new BoxDecoration(color: Colors.black.withOpacity(0.35)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: TextField(
                    cursorColor: Colors.black54,
                    style: TextStyle(color: Colors.black54),
                    controller: sc,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.35),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelStyle: TextStyle(color: Colors.black54),
                      labelText: "Search Here",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      suffixIcon: IconButton(
                        color: Colors.black54,
                        icon: Icon(
                          Icons.clear,
                        ),
                        onPressed: () {
                          sc.clear();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        sv = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: (sv == null || sv.trim() == null)
                        ? fstore
                            .collection("user")
                            .where('uid', isNotEqualTo: auth.currentUser.uid)
                            .snapshots()
                        : fstore
                            .collection("user")
                            .where('name', isEqualTo: sv)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        print("no data");
                        return Text(
                          "no data",
                          style: TextStyle(color: Colors.black),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          "Error ${snapshot.error}",
                          style: TextStyle(color: Colors.black),
                        );
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Text(
                            "waiting",
                            style: TextStyle(color: Colors.black),
                          );
                        case ConnectionState.none:
                          return Text(
                            "none",
                            style: TextStyle(color: Colors.black),
                          );
                        case ConnectionState.done:
                          return Text(
                            "done",
                            style: TextStyle(color: Colors.black),
                          );
                        default:
                          return new ListView(
                              children: snapshot.data.docs
                                  .map((DocumentSnapshot document) {
                            return new ListTile(
                              title: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.25),
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.black.withOpacity(0.25),
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5.0, top: 5.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              "${document['photoUrl']}"),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          document['name'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  print("l = ${l.length}");
                                  if (l.isNotEmpty) {
                                    for (var i in l) {
                                      if (sv == i) {
                                        Fluttertoast.showToast(
                                            msg: "Already Your Friend",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.SNACKBAR,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        break;
                                      } else {
                                        setState(() {
                                          j = j + 1;
                                        });
                                      }
                                    }
                                    if (j == l.length) {
                                      setState(() {
                                        newuser = true;
                                      });
                                    }
                                  } else if (l.isEmpty) {
                                    var ty = await fstore
                                        .collection("user")
                                        .doc("${auth.currentUser.uid}")
                                        .get();
                                    await fstore
                                        .collection("details")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .add({
                                      'uid': '${document['uid']}',
                                      'name': '${document['name']}',
                                      'photourl': '${document['photoUrl']}',
                                      'timestamp': FieldValue.serverTimestamp()
                                    });

                                    await fstore
                                        .collection("details")
                                        .doc("${document['uid']}")
                                        .collection("${document['uid']}")
                                        .add({
                                      'uid': '${auth.currentUser.uid}',
                                      'name': '${ty.data()['name']}',
                                      'photourl': '${ty.data()['photoUrl']}',
                                      'timestamp': FieldValue.serverTimestamp()
                                    });
                                    await fstore
                                        .collection("message")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .doc("${document['uid']}")
                                        .collection("${document["uid"]}")
                                        .add({
                                      'sender': '${auth.currentUser.uid}',
                                      'msg': null,
                                      'receiver': '${document['uid']}',
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    await fstore
                                        .collection("message")
                                        .doc("${document["uid"]}")
                                        .collection("${document["uid"]}")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .add({
                                      'sender': '${auth.currentUser.uid}',
                                      'msg': null,
                                      'receiver': '${document["uid"]}',
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    await fstore
                                        .collection("messinfo")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .doc("${document['uid']}")
                                        .set({
                                      'name': "${document['name']}",
                                      'lastmsg': "null",
                                      'countmsg': "0",
                                    });
                                    await fstore
                                        .collection("messinfo")
                                        .doc("${document['uid']}")
                                        .collection("${document['uid']}")
                                        .doc("${auth.currentUser.uid}")
                                        .set({
                                      'name': "${document['name']}",
                                      'lastmsg': "null",
                                      'countmsg': "0",
                                    });

                                    Navigator.pushNamed(context, "home",
                                        arguments: {
                                          'photoUrl': "${ty.data()['photoUrl']}"
                                        });
                                  }
                                  if (newuser) {
                                    var ty = await fstore
                                        .collection("user")
                                        .doc("${auth.currentUser.uid}")
                                        .get();
                                    await fstore
                                        .collection("details")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .add({
                                      'uid': '${document['uid']}',
                                      'name': '${document['name']}',
                                      'photourl': '${document['photoUrl']}',
                                      'timestamp': FieldValue.serverTimestamp()
                                    });
                                    await fstore
                                        .collection("message")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .doc("${document['uid']}")
                                        .collection("${document['uid']}")
                                        .add({
                                      'sender': '${auth.currentUser.uid}',
                                      'msg': null,
                                      'receiver': '${document['uid']}',
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    await fstore
                                        .collection("message")
                                        .doc("${document["uid"]}")
                                        .collection("${document["uid"]}")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .add({
                                      'sender': '${auth.currentUser.uid}',
                                      'msg': null,
                                      'receiver': '${document["uid"]}',
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });

                                    await fstore
                                        .collection("details")
                                        .doc("${document['uid']}")
                                        .collection("${document['uid']}")
                                        .add({
                                      'uid': '${auth.currentUser.uid}',
                                      'name': '${ty.data()['name']}',
                                      'photourl': '${ty.data()['photoUrl']}',
                                      'timestamp': FieldValue.serverTimestamp()
                                    });
                                    await fstore
                                        .collection("messinfo")
                                        .doc("${auth.currentUser.uid}")
                                        .collection("${auth.currentUser.uid}")
                                        .doc("${document['uid']}")
                                        .set({
                                      'name': "${document['name']}",
                                      'lastmsg': "null",
                                      'countmsg': "0",
                                    });
                                    await fstore
                                        .collection("messinfo")
                                        .doc("${document['uid']}")
                                        .collection("${document['uid']}")
                                        .doc("${auth.currentUser.uid}")
                                        .set({
                                      'name': "${document['name']}",
                                      'lastmsg': "null",
                                      'countmsg': "0",
                                    });
                                    Navigator.pushNamed(context, "home",
                                        arguments: {
                                          'photoUrl': "${ty.data()['photoUrl']}"
                                        });
                                  }
                                },
                              ),
                            );
                          }).toList());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
