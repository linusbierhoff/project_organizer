import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  String qrCode = "";
  Future scanQrCode() async {
    try {
      qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ffffff', 'Cancel', false, ScanMode.QR);
    } catch (e) {
      print(e);
    }

    return qrCode;
  }

  RoundedLoadingButtonController _btnControllerDelete =
      new RoundedLoadingButtonController();

  TextEditingController _controller = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService(userID: _firebaseAuth.currentUser.uid).userData,
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          UserModel currentUser = userSnapshot.data;
          return StreamBuilder(
              stream: DatabaseService(currentUser: currentUser).friends,
              builder: (context, friendsSnapshot) {
                if (friendsSnapshot.hasData) {
                  List<UserModel> friends = friendsSnapshot.data;

                  return Scaffold(
                    floatingActionButton: FloatingActionButton(
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        final _formKey = GlobalKey<FormState>();
                        FocusNode myFocusNode = FocusNode();
                        showDialog(
                            context: context,
                            builder: (_) {
                              return StreamBuilder<Object>(
                                  stream: DatabaseService().user,
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.hasData) {
                                      List<UserModel> databseUser =
                                          userSnapshot.data;

                                      return SimpleDialog(
                                        backgroundColor:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Add friend"),
                                            IconButton(
                                              icon: Icon(Icons.qr_code),
                                              onPressed: () async {
                                                String _uid =
                                                    await scanQrCode();
                                                _controller.text = _uid;
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  List newFavorites =
                                                      currentUser.favorites;
                                                  newFavorites.add(_uid);
                                                  DatabaseService()
                                                      .updateUserData(
                                                          currentUser.userID,
                                                          currentUser.name,
                                                          currentUser.projects,
                                                          newFavorites);
                                                  _controller.clear();
                                                  Navigator.pop(context);
                                                } else {
                                                  _controller.clear();
                                                  myFocusNode.requestFocus();
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Form(
                                              key: _formKey,
                                              child: TextFormField(
                                                controller: _controller,
                                                focusNode: myFocusNode,
                                                decoration: InputDecoration(
                                                  hintText: "User-ID...",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 20,
                                                          bottom: 11,
                                                          top: 11,
                                                          right: 20),
                                                ),
                                                validator: (val) {
                                                  if (DatabaseService()
                                                      .userExists(
                                                          databseUser, val)) {
                                                    if (currentUser.favorites
                                                            .contains(val) ||
                                                        val ==
                                                            _firebaseAuth
                                                                .currentUser
                                                                .uid) {
                                                      return "User is already your friend";
                                                    } else {
                                                      return null;
                                                    }
                                                  } else {
                                                    return "User doesn't exists";
                                                  }
                                                },
                                                onFieldSubmitted:
                                                    (value) async {
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    List newFavorites =
                                                        currentUser.favorites;
                                                    newFavorites.add(value);
                                                    DatabaseService()
                                                        .updateUserData(
                                                            currentUser.userID,
                                                            currentUser.name,
                                                            currentUser
                                                                .projects,
                                                            newFavorites);
                                                    Navigator.pop(context);
                                                  } else {
                                                    myFocusNode.requestFocus();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: ButtonStyle(
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      Colors.transparent),
                                            ),
                                            child: Text(
                                              "Dismiss",
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    } else {
                                      return LoadingContainer();
                                    }
                                  });
                            });
                      },
                    ),
                    appBar: AppBar(
                        title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Friends',
                        ),
                        Icon(Icons.people)
                      ],
                    )),
                    body: ListView.builder(
                      
                        itemCount: friends.length,
                        itemBuilder: (context, i) {
                          return Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10, top: 10, left: 20, right: 20),
                              child: InkWell(
                                onLongPress: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40.0)),
                                      backgroundColor:
                                          Theme.of(context).canvasColor,
                                      context: context,
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(friends[i].name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6)),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 35),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            35)),
                                                width: double.infinity,
                                                padding: EdgeInsets.all(10),
                                                child: TextButton.icon(
                                                    style: ButtonStyle(
                                                      overlayColor: MaterialStateColor
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .transparent),
                                                    ),
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    label: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    onPressed: () async {
                                                      await showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            SimpleDialog(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .canvasColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20.0))),
                                                          title: Text(
                                                              "Delete " +
                                                                  friends[i]
                                                                      .name),
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                      "Do you want to remove this friend from yout list")),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          10.0,
                                                                      left: 20,
                                                                      right:
                                                                          20),
                                                              child:
                                                                  RoundedLoadingButton(
                                                                controller:
                                                                    _btnControllerDelete,
                                                                color:
                                                                    Colors.red,
                                                                child: Text(
                                                                    "Delete",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText1
                                                                        .copyWith(
                                                                            color:
                                                                                Theme.of(context).accentColor)),
                                                                onPressed:
                                                                    () async {
                                                                  List
                                                                      newFavorites =
                                                                      currentUser
                                                                          .favorites;
                                                                  newFavorites.remove(
                                                                      friends[i]
                                                                          .userID);
                                                                  DatabaseService().updateUserData(
                                                                      currentUser
                                                                          .userID,
                                                                      currentUser
                                                                          .name,
                                                                      currentUser
                                                                          .projects,
                                                                      newFavorites);

                                                                  _btnControllerDelete
                                                                      .success();
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ),
                                                            TextButton(
                                                              style:
                                                                  ButtonStyle(
                                                                overlayColor: MaterialStateColor
                                                                    .resolveWith(
                                                                        (states) =>
                                                                            Colors.transparent),
                                                              ),
                                                              child: Text(
                                                                "Dismiss",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        700]),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Text(friends[i].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(fontSize: 18)),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Theme.of(context).canvasColor),
                                ),
                              ));
                        }),
                  );
                } else {
                  return Loading();
                }
              });
        } else {
          return Loading();
        }
      },
    );
  }
}
