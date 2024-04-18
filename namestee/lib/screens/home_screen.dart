//import 'dart:convert';
//import 'dart:developer';

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:hiichat/api/api.dart';
import 'package:hiichat/helper/dialogs.dart';
import 'package:hiichat/main.dart';
import 'package:hiichat/models/chat_user.dart';
//import 'package:hiichat/screens/auth/login_screen.dart';
import 'package:hiichat/screens/profile_screen.dart';
import 'package:hiichat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchlist = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resumed'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('inactive'))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      onChanged: (val) {
                        _searchlist.clear();
                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchlist.add(i);
                          }
                          setState(() {
                            _searchlist;
                          });
                        }
                      },
                      autofocus: true,
                      style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name ,Email....'),
                    )
                  : Text(
                      'Namastee!',
                    ),
              leading: Icon(CupertinoIcons.home, size: 30),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  //search Button
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search),
                  iconSize: 35,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  //more feature button
                  icon: Icon(Icons.more_vert),
                  iconSize: 35,
                )
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              //floating Action but ton to add new user
              child: FloatingActionButton(
                  onPressed: () {
                    _showAddUserDialog();
                  },
                  child: Icon(
                    Icons.add_circle_sharp,
                    color: Color.fromARGB(255, 210, 134, 2),
                  )),
            ),
            body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {}
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  // return const Center(
                  //   child: CircularProgressIndicator(),
                  // );
                  //if data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                      ),
                      builder: ((context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          //if data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchlist.length
                                      : list.length,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: mq.height * 0.005),
                                      child: ChatUserCard(
                                        user: _isSearching
                                            ? _searchlist[index]
                                            : list[index],
                                      ),
                                    );
                                  });
                            } else {
                              return Center(
                                child: Text(
                                  'No connections Found!',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      }),
                    );
                }
              },
            )),
      ),
    );
  }

  void _showAddUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 5),
              title: Row(
                children: [
                  Icon(
                    Icons.person_add_alt,
                    color: Colors.orange,
                    size: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Add Email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.red,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'User not Exist');
                        }
                      });
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ));
  }
}
