import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var auth = FirebaseAuth.instance;
  var fstore = FirebaseFirestore.instance;
  mymsg(u) async {
    var x = await fstore
        .collection("messinfo")
        .doc("${auth.currentUser.uid}")
        .collection("${auth.currentUser.uid}")
        .doc("$u")
        .get();
    return x.data()['lastmsg'];
  }

  mycout(u) async {
    var x = await fstore
        .collection("messinfo")
        .doc("${auth.currentUser.uid}")
        .collection("${auth.currentUser.uid}")
        .doc("$u")
        .get();
    return x.data()['countmsg'];
  }

  countupdate(u) async {
    await fstore
        .collection("messinfo")
        .doc("${auth.currentUser.uid}")
        .collection("${auth.currentUser.uid}")
        .doc("$u")
        .update({'countmsg': "0"});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> pUrl = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 50.0,
        backgroundColor: Colors.blue[100],
        child: Icon(
          Icons.message_rounded,
        ),
        onPressed: () {
          Navigator.pushNamed(context, "adduser");
        },
      ),
      appBar: AppBar(
        leading: Icon(Icons.home),
        title: Text("Gappe"),
        actions: [
          GestureDetector(
            onTap: () async {
              var ty = await fstore
                  .collection("user")
                  .doc("${auth.currentUser.uid}")
                  .get();
              Navigator.pushNamed(context, "pro", arguments: {
                'name': "${ty.data()['name']}",
                'phtoUrl': "${ty.data()['photoUrl']}"
              });
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage("${pUrl['photoUrl']}"),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: ExactAssetImage("images/homebg.jpg"),
              fit: BoxFit.fitHeight),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.285),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: fstore
                      .collection("details")
                      .doc("${auth.currentUser.uid}")
                      .collection("${auth.currentUser.uid}")
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      print("no data");
                      return Text("no data");
                    }
                    return ListView(
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                      return Column(
                        children: [
                          GestureDetector(
                            child: new ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      NetworkImage("${document['photourl']}"),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      document['name'],
                                      style: TextStyle(
                                        fontFamily: 'ShortStack',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    FutureBuilder(
                                      future: mymsg(document['uid']),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> text) {
                                        return new Text(text.data == "null"
                                            ? "new conversation"
                                            : "${text.data}");
                                      },
                                    ),
                                    Spacer(),
                                    FutureBuilder(
                                      future: mycout(document['uid']),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> text) {
                                        return new Text(text.data == "0"
                                            ? " "
                                            : "+${text.data} meassages");
                                      },
                                    ),
                                  ],
                                )),
                            onTap: () async {
                              countupdate(document['uid']);
                              Navigator.pushNamed(context, "msg", arguments: {
                                'uid': "${document['uid']}",
                                'photoUrl': "${document['photourl']}",
                                'name': "${document['name']}",
                                'cuurl': "${pUrl['photoUrl']}"
                              });
                            },
                          ),
                          Divider(
                            indent: 5.0,
                            endIndent: 5.0,
                            height: 0.5,
                            color: Colors.grey[350],
                            thickness: 2.0,
                          )
                        ],
                      );
                    }).toList());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
