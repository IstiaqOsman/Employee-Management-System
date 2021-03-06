import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_manegement/national/flutter_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Firebasedemo extends StatefulWidget {
  // String? userId = FirebaseFirestore.instance.doc("Employee Table").id;
  String? userId;
  @override
  State<Firebasedemo> createState() => _FirebasedemoState();
}

class _FirebasedemoState extends State<Firebasedemo> {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  loaddata() async {
    SharedPreferences preferences = await prefs;
    setState(() {
      s = preferences.getInt("value");
    });
  }

  var s;
  var userid;

  @override
  void initState() {
    this.loaddata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot?> stream =
        FirebaseFirestore.instance.collection("Employee Table").snapshots();

    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();

    TextEditingController usernameController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController genderController = TextEditingController();

    CollectionReference users =
        FirebaseFirestore.instance.collection("Employee Table");

    userid = FirebaseAuth.instance.currentUser!.uid.toString();
    return WillPopScope(
      onWillPop: () async {
        final shd = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  actions: [
                    OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text("cancel")),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text("no")),
                  ],
                ));
        return shd ?? false;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  label: Text("User name"),
                ),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  label: Text("User age"),
                ),
              ),
              TextField(
                controller: genderController,
                decoration: InputDecoration(
                  label: Text("Gender"),
                ),
              ),
              Row(
                children: [
                  OutlinedButton(
                      onPressed: () {
                        users
                            .doc(userid)
                            .collection("extra info")
                            .add({
                              "name": usernameController.text,
                              "age": ageController.text,
                              "gender": genderController.text
                            })
                            .whenComplete(() => Common_Toast().customtoast(
                                "Uploaded", Duration(milliseconds: 400)))
                            .then((value) => Text("Successful"))
                            .onError((error, stackTrace) => Text("${error}"));
                      },
                      child: Text("Send")),
                  OutlinedButton(
                      onPressed: () {
                        users.doc(userid).delete();
                      },
                      child: Text("Delete")),
                  OutlinedButton(
                      onPressed: () {
                        users.doc("HqXAMtGY5LWpBGiTwN6C").set({
                          "name": usernameController.text,
                          "age": ageController.text,
                          "gender": genderController.text
                        });
                      },
                      child: Text("Set")),
                  OutlinedButton(
                      onPressed: () {
                        users.doc(userid).update({
                          "name": usernameController.text,
                          "age": ageController.text,
                          "gender": genderController.text
                        });
                      },
                      child: Text("Update")),
                ],
              ),
              StreamBuilder(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done || snapshot.hasData) {
                    return Container(
                      height: 350,
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                userid = snapshot.data!.docs[index].id;
                              },
                              child: Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                          snapshot.data!.docs[index]["name"]),
                                    ),
                                    ListTile(
                                      title: Text(
                                          snapshot.data!.docs[index]["age"]),
                                    ),
                                    ListTile(
                                      title: Text(
                                          snapshot.data!.docs[index]["gender"]),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                userid =
                                                    snapshot.data!.docs[index].id;
                                              });

                                              users
                                                  .doc(userid)
                                                  .delete()
                                                  .then((value) =>
                                                  print("Succecful"))
                                                  .onError((error, stackTrace) =>
                                                  Text("$error"));
                                            },
                                            child: Text("Delete")),
                                        OutlinedButton(
                                            onPressed: () {
                                              userid =
                                                  snapshot.data!.docs[index].id;

                                              usernameController.text = snapshot
                                                  .data!.docs[index]["name"];
                                              ageController.text = snapshot
                                                  .data!.docs[index]["age"];
                                              genderController.text = snapshot
                                                  .data!.docs[index]["gender"];
                                            },
                                            child: Text("Edit")),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  else {
                    return CircularProgressIndicator();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
