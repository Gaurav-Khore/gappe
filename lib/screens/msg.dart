import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:rsaa_crypt/rsaa_crypt.dart';

class Msg extends StatefulWidget {
  @override
  _MsgState createState() => _MsgState();
}

class _MsgState extends State<Msg> {
  String key = '🐻🎌', cipher, decipher;
  var mg;
  var mc = TextEditingController();
  var auth = FirebaseAuth.instance;
  var fstore = FirebaseFirestore.instance;
  var count = 0;

  mydeco(cip) async {
    await RSAACrypt().decryptText(key, Util().textToBytes(cip)).then((value) {
      decipher = value;
    });
    return decipher;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    /*var formattedtime = DateFormat('kk:mm:ss').format(now);
    var formatteddate = DateFormat('M/d/y').format(now);*/
    final Map<String, Object> rData = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, "home",
                arguments: {'photoUrl': "${rData['cuurl']}"});
          },
        ),
        leadingWidth: 40.0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage("${rData['photoUrl']}"),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text("${rData['name']}"),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage("images/chatbg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: fstore
                      .collection("message")
                      .doc("${auth.currentUser.uid}")
                      .collection("${auth.currentUser.uid}")
                      .doc("${rData["uid"]}")
                      .collection("${rData["uid"]}")
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text("no data");
                    }
                    return Container(
                      child: ListView(
                          reverse: true,
                          children: snapshot.data.docs
                              .map((DocumentSnapshot document) {
                            return new ListTile(
                              title: document['msg'] != null
                                  ? ChatBubble(
                                      clipper: ChatBubbleClipper3(
                                          type: auth.currentUser.uid ==
                                                  document['sender']
                                              ? BubbleType.sendBubble
                                              : BubbleType.receiverBubble),
                                      alignment: auth.currentUser.uid ==
                                              document['sender']
                                          ? Alignment.bottomRight
                                          : Alignment.bottomLeft,
                                      margin: EdgeInsets.only(top: 20),
                                      backGroundColor: auth.currentUser.uid ==
                                              document['sender']
                                          ? Color.fromRGBO(225, 255, 199, 1.0)
                                          : Color.fromRGBO(212, 234, 244, 1.0),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        child: FutureBuilder(
                                          future: mydeco(document['msg']),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<dynamic> text) {
                                            return new Text(
                                              text.data == null
                                                  ? "nothing"
                                                  : text.data,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.cyanAccent),
                                            color:
                                                Colors.black.withOpacity(0.45),
                                            borderRadius:
                                                BorderRadius.circular(40.0)),
                                        padding: EdgeInsets.all(15.0),
                                        child: Text(
                                          "Data is end to end encrypted. RSAA 1024 bit symmetric text on-device encryption.1024 bit secure symmetric encryption",
                                          style: TextStyle(
                                              fontFamily: 'YuseiMagic',
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                            );
                          }).toList()),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: mc,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.25),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        labelText: "Enter text here...",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            mc.clear();
                            if (mg != null) {
                              setState(() {
                                count = count + 1;
                              });

                              await RSAACrypt()
                                  .encryptText(key, mg)
                                  .then((value) {
                                cipher = Util().bytesToText(value);
                              });
                              await fstore
                                  .collection("message")
                                  .doc("${auth.currentUser.uid}")
                                  .collection("${auth.currentUser.uid}")
                                  .doc("${rData["uid"]}")
                                  .collection("${rData["uid"]}")
                                  .add({
                                'sender': '${auth.currentUser.uid}',
                                'msg': '$cipher',
                                'receiver': '${rData["uid"]}',
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              await fstore
                                  .collection("message")
                                  .doc("${rData["uid"]}")
                                  .collection("${rData["uid"]}")
                                  .doc("${auth.currentUser.uid}")
                                  .collection("${auth.currentUser.uid}")
                                  .add({
                                'sender': '${auth.currentUser.uid}',
                                'msg': '$cipher',
                                'receiver': '${rData["uid"]}',
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              await fstore
                                  .collection("messinfo")
                                  .doc("${auth.currentUser.uid}")
                                  .collection("${auth.currentUser.uid}")
                                  .doc("${rData["uid"]}")
                                  .update({
                                'lastmsg': "$mg",
                              });
                              await fstore
                                  .collection("messinfo")
                                  .doc("${rData["uid"]}")
                                  .collection("${rData["uid"]}")
                                  .doc("${auth.currentUser.uid}")
                                  .update({
                                'countmsg': '$count',
                                'lastmsg': "$mg",
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        mg = value;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
