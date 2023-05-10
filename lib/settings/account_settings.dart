import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/firebase_services.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool checkCurrentPasswordValid = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: DatabaseService(userID: _firebaseAuth.currentUser.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var currentUser = snapshot.data;
            return MultiProvider(
                providers: [
                  StreamProvider<List<Project>>.value(
                    value: DatabaseService(currentUser: currentUser).projects,
                    initialData: null,
                  ),
                  StreamProvider<List<UserModel>>.value(
                    value: DatabaseService().user,
                    initialData: null,
                  )
                ],
                child: Builder(builder: (BuildContext context) {
                  var databaseProjects = Provider.of<List<Project>>(context);
                  var databaseUser = Provider.of<List<UserModel>>(context);
                  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

                  while (databaseProjects == null || databaseUser == null) {
                    return Loading();
                  }

                  List<Widget> showClosedProjects() {
                    List<Widget> closedProjects = [];
                    for (int i = 0; i < databaseProjects.length; i++) {
                      if (!databaseProjects[i].open) {
                        closedProjects.add(Padding(
                          padding: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () async {
                              final RoundedLoadingButtonController
                                  _btnControllerReOpen =
                                  new RoundedLoadingButtonController();
                              final RoundedLoadingButtonController
                                  _btnControllerDelete =
                                  new RoundedLoadingButtonController();

                              await showDialog(
                                context: context,
                                builder: (_) => SimpleDialog(
                                    backgroundColor:
                                        Theme.of(context).canvasColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    title: Text(
                                        "Re-Open ${databaseProjects[i].title}"),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                            "What do you want to do with this project?"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 10.0,
                                            left: 20,
                                            right: 20),
                                        child: RoundedLoadingButton(
                                          controller: _btnControllerReOpen,
                                          color: Colors.green,
                                          child: Text("Re-Open",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .accentColor)),
                                          onPressed: () async {
                                            await DatabaseService(
                                                    projectID:
                                                        databaseProjects[i]
                                                            .projectID)
                                                .updateProject(
                                                    databaseProjects[i].title,
                                                    databaseProjects[i].subject,
                                                    databaseProjects[i].date,
                                                    true,
                                                    databaseProjects[i]
                                                        .projectID,
                                                    databaseProjects[i]
                                                        .creationDate,
                                                    databaseProjects[i].topics,
                                                    databaseProjects[i]
                                                        .projectplan,
                                                    databaseProjects[i]
                                                        .workTime,
                                                    databaseProjects[i]
                                                        .startDate);
                                            _btnControllerReOpen.success();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 10.0,
                                            left: 20,
                                            right: 20),
                                        child: RoundedLoadingButton(
                                          controller: _btnControllerDelete,
                                          color: Colors.red,
                                          child: Text("Delete",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .accentColor)),
                                          onPressed: () async {
                                            UserModel _user = DatabaseService()
                                                .getUserFromID(
                                                    databaseUser,
                                                    _firebaseAuth
                                                        .currentUser.uid);
                                            await DatabaseService()
                                                .deleteProject(
                                                    databaseProjects[i]
                                                        .projectID,
                                                    databaseUser,
                                                    _user);

                                            _btnControllerDelete.success();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      TextButton(
                                        style: ButtonStyle(
                                          overlayColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) =>
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
                                    ]),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    databaseProjects[i].title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                          color:
                                              Color.fromRGBO(77, 204, 240, 1),
                                        ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(databaseProjects[i].subject,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                ],
                              ),
                            ),
                          ),
                        ));
                      }
                    }

                    return closedProjects;
                  }

                  void changePassword() async {
                    final _formKey = GlobalKey<FormState>();
                    var _currentPassword = "";
                    var _newPassword;

                    final RoundedLoadingButtonController _btnController =
                        new RoundedLoadingButtonController();

                    await showDialog(
                      context: context,
                      builder: (_) => SimpleDialog(
                        backgroundColor: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        title: Text("Change your password"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                      validator: (value) {
                                        if (checkCurrentPasswordValid) {
                                          return null;
                                        } else {
                                          return "Wrong Password";
                                        }
                                      },
                                      onTap: () => _btnController.reset(),
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "Current password...",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 20,
                                            bottom: 11,
                                            top: 11,
                                            right: 20),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _currentPassword = val;
                                        });
                                      }),
                                  SizedBox(height: 40),
                                  TextFormField(
                                      onTap: () => _btnController.reset(),
                                      validator: (val) {
                                        if (val.length < 6) {
                                          return "Password is to short";
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "New password...",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 20,
                                            bottom: 11,
                                            top: 11,
                                            right: 20),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _newPassword = val;
                                        });
                                      }),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    onTap: () => _btnController.reset(),
                                    validator: (val) {
                                      if (val != _newPassword) {
                                        return "The passwords do not match";
                                      } else {
                                        return null;
                                      }
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "Confirm new password...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 20,
                                          bottom: 11,
                                          top: 11,
                                          right: 20),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 10, left: 20, right: 20),
                            child: RoundedLoadingButton(
                              controller: _btnController,
                              color: Colors.orange,
                              child: Text(
                                "Change",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).accentColor),
                              ),
                              onPressed: () async {
                                checkCurrentPasswordValid =
                                    await AuthenticateServices()
                                        .checkCurrentPassword(_currentPassword);
                                print(checkCurrentPasswordValid);

                                if (_formKey.currentState.validate() &&
                                    checkCurrentPasswordValid) {
                                  await _firebaseAuth.currentUser
                                      .updatePassword(_newPassword);
                                  Navigator.pop(context);
                                } else {
                                  _btnController.error();
                                }
                              },
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                            ),
                            child: Text(
                              "Dismiss",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  void changeEmail() async {
                    final _formKey = GlobalKey<FormState>();
                    var _currentPassword = "";
                    var _newEmail;

                    final RoundedLoadingButtonController _btnController =
                        new RoundedLoadingButtonController();

                    await showDialog(
                      context: context,
                      builder: (_) => SimpleDialog(
                         backgroundColor: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        title: Text("Change your password"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                      validator: (value) {
                                        if (checkCurrentPasswordValid) {
                                          return null;
                                        } else {
                                          return "Wrong Password";
                                        }
                                      },
                                      onTap: () => _btnController.reset(),
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "Current password...",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 20,
                                            bottom: 11,
                                            top: 11,
                                            right: 20),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _currentPassword = val;
                                        });
                                      }),
                                  SizedBox(height: 20),
                                  TextFormField(
                                      onTap: () => _btnController.reset(),
                                      validator: (val) {
                                        bool emailValid = RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(val);

                                        if (val.isEmpty || !emailValid) {
                                          return ("Invalid email");
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: "New E-Mail...",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 20,
                                            bottom: 11,
                                            top: 11,
                                            right: 20),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _newEmail = val;
                                        });
                                      }),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RoundedLoadingButton(
                              controller: _btnController,
                              color: Colors.orange,
                              child: Text("Change",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          color:
                                              Theme.of(context).accentColor)),
                              onPressed: () async {
                                checkCurrentPasswordValid =
                                    await AuthenticateServices()
                                        .checkCurrentPassword(_currentPassword);
                                print(checkCurrentPasswordValid);

                                if (_formKey.currentState.validate() &&
                                    checkCurrentPasswordValid) {
                                  await _firebaseAuth.currentUser
                                      .updateEmail(_newEmail);
                                  Navigator.pop(context);
                                } else {
                                  _btnController.error();
                                }
                              },
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                            ),
                            child: Text(
                              "Dismiss",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  // ignore: unused_element
                  void deleteAccount() async {
                    final _formKey = GlobalKey<FormState>();
                    var _currentPassword = "";

                    final RoundedLoadingButtonController _btnController =
                        new RoundedLoadingButtonController();

                    await showDialog(
                      context: context,
                      builder: (_) => SimpleDialog(
                         backgroundColor: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        title: Text("Delete your account"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                      validator: (value) {
                                        if (checkCurrentPasswordValid) {
                                          return null;
                                        } else {
                                          return "Wrong Password";
                                        }
                                      },
                                      onTap: () => _btnController.reset(),
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "Current Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        contentPadding: EdgeInsets.only(
                                            left: 15,
                                            bottom: 11,
                                            top: 11,
                                            right: 15),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _currentPassword = val;
                                        });
                                      }),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RoundedLoadingButton(
                              controller: _btnController,
                              color: Colors.red,
                              child: Text(
                                "Delete",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).accentColor),
                              ),
                              onPressed: () async {
                                checkCurrentPasswordValid =
                                    await AuthenticateServices()
                                        .checkCurrentPassword(_currentPassword);

                                if (_formKey.currentState.validate()) {
                                  print("Check");
                                  AuthenticateServices()
                                      .deleteAccount(currentUser, databaseUser);

                                  _btnController.success();
                                  Navigator.pop(context);
                                } else {
                                  _btnController.error();
                                }
                              },
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                            ),
                            child: Text(
                              "Dismiss",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return Scaffold(
                    key: _scaffoldKey,
                    appBar: AppBar(
                        title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Account',
                        ),
                        Icon(Icons.person)
                      ],
                    )),
                    body: ListView(
                     
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).canvasColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        DatabaseService()
                                                .getUserFromID(
                                                    databaseUser,
                                                    _firebaseAuth
                                                        .currentUser.uid)
                                                .name ??
                                            "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                              color: Color.fromRGBO(
                                                  77, 204, 240, 1),
                                            )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IconButton(
                                      onPressed: () async {
                                        final _formKey = GlobalKey<FormState>();
                                        String name = _firebaseAuth
                                            .currentUser.displayName;
                                        FocusNode myFocusNode = FocusNode();

                                        await showDialog(
                                          context: context,
                                          builder: (_) => SimpleDialog(
                                             backgroundColor: Theme.of(context).canvasColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                              title: Text("Edit Name"),
                                              children: [
                                                Form(
                                                  key: _formKey,
                                                  child: TextFormField(
                                                    focusNode: myFocusNode,
                                                    initialValue: name,
                                                    validator: (val) {
                                                      if (val.isEmpty) {
                                                        return "Can't be empty!";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    onChanged: (val) {
                                                      setState(() {
                                                        name = val;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: "Name...",
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey),
                                                      filled: true,
                                                      fillColor:
                                                          Colors.transparent,
                                                      border: InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              bottom: 11,
                                                              top: 11,
                                                              right: 20),
                                                    ),
                                                    onFieldSubmitted:
                                                        (value) async {
                                                      UserModel _user =
                                                          DatabaseService()
                                                              .getUserFromID(
                                                                  databaseUser,
                                                                  _firebaseAuth
                                                                      .currentUser
                                                                      .uid);
                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        await DatabaseService()
                                                            .updateUserData(
                                                                _firebaseAuth
                                                                    .currentUser
                                                                    .uid,
                                                                name,
                                                                _user.projects,
                                                                _user
                                                                    .favorites);
                                                        await _firebaseAuth
                                                            .currentUser
                                                            .updateProfile(
                                                                displayName:
                                                                    name);
                                                        Navigator.pop(context);

                                                        //myFocusNode.requestFocus();

                                                      } else {
                                                        myFocusNode
                                                            .requestFocus();
                                                      }
                                                    },
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
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ]),
                                        );
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).canvasColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Icon(
                                      Icons.vpn_key_rounded,
                                      size: 30,
                                    ),
                                  ),
                                  Expanded(
                                    child: SelectableText(
                                        _firebaseAuth.currentUser.uid,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: Color.fromRGBO(
                                                  77, 204, 240, 1),
                                            )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0)),
                                              backgroundColor:
                                                  Theme.of(context).canvasColor,
                                              context: context,
                                              builder: (_) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: QrImage(
                                                   // foregroundColor: Colors.white,
                                                    version: QrVersions.auto,
                                                    data: _firebaseAuth
                                                        .currentUser.uid,
                                                  ),
                                                );
                                              });
                                        },
                                        icon: Icon(Icons.qr_code)),
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).canvasColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text("Closed Projects: ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: showClosedProjects(),
                                      )),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).canvasColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text("Change password",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                    ),
                                    onTap: () => changePassword(),
                                  ),
                                  InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text("Change E-Mail",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                    ),
                                    onTap: () => changeEmail(),
                                  ),
                                  // InkWell(
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(20),
                                  //     child: Text(
                                  //       "Delete Account",
                                  //       style: Theme.of(context).textTheme.headline6
                                  //     ),
                                  //   ),
                                  //   onTap: () => deleteAccount(),
                                  // ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  );
                }));
          } else {
            return Loading();
          }
        });
  }
}
