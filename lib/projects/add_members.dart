import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../firebase/model.dart';

class AddMembers extends StatefulWidget {
  final String projectId;
  final List<UserModel> user;

  AddMembers(this.user, this.projectId);

  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  List<UserModel> currentUsr;

  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  List<String> activeUserIDs = [];
  List<UserModel> activeUsers = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _newUser;
  final _formKey = GlobalKey<FormState>();
  bool selectionStatus(UserModel user) {
    if (activeUsers.contains(user)) {
      return true;
    } else {
      return false;
    }
  }

  List<UserModel> getNewUser() {
    List<UserModel> _newUser = [];
    for (int i = 0; i < activeUsers.length; i++) {
      if (currentUsr.contains(activeUsers[i])) {
      } else {
        _newUser.add(activeUsers[i]);
      }
    }
    return _newUser;
  }

  void addUser(String uid) {
    if (activeUserIDs.contains(uid)) {
      print("User is part of the project");
    } else {
      setState(() {
        activeUserIDs.add(uid);
        activeUsers.add(DatabaseService().getUserFromID(widget.user, uid));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentUsr =
        DatabaseService().getUserFromProject(widget.projectId, widget.user);
    for (int i = 0; i < currentUsr.length; i++) {
      activeUsers.add(currentUsr[i]);
    }

    for (int i = 0; i < currentUsr.length; i++) {
      activeUserIDs.add(currentUsr[i].userID);
    }
  }

  Widget build(BuildContext context) {
    UserModel currentUser = DatabaseService()
        .getUserFromID(widget.user, _firebaseAuth.currentUser.uid);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            elevation: 0.0,
            title: Text(
              'Select your Members',
            )),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) {
                            if (DatabaseService()
                                .userExists(widget.user, value)) {
                              return null;
                            } else {
                              return "User does not exist";
                            }
                          },
                          style: TextStyle(fontWeight: FontWeight.bold),
                          onChanged: (val) {
                            setState(() {
                              _newUser = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "User-ID...",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 20, bottom: 11, top: 11, right: 15),
                          ),
                        )),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        addUser(_newUser);
                      }
                    },
                  )
                ],
              ),
              Expanded(
                  flex: 2,
                  child: ListView.builder(
                    
                      itemCount: activeUsers.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(77, 204, 240, 1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(activeUsers[i].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          fontSize: 18,
                                            color:
                                                Theme.of(context).accentColor)),
                              )),
                        );
                      })),
              Center(
                  child: Text("Select a favorite: ",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                         fontSize: 18,
                            
                          ))),
              Expanded(
                  flex: 1,
                  child: ListView.builder(
                    
                      itemCount: currentUser.favorites.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: InkWell(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                      DatabaseService()
                                          .getUserFromID(widget.user,
                                              currentUser.favorites[i])
                                          .name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                             fontSize: 18,
                                              )),
                                )),
                            onTap: () {
                              addUser(currentUser.favorites[i]);
                            },
                          ),
                        );
                      })),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: RoundedLoadingButton(
                      
                      controller: _btnController,
                      onPressed: () async {
                        await DatabaseService().updateProjectMember(
                            widget.projectId, getNewUser());
                        _btnController.error();
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.save,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 10,),
                            Text(
                              "Save",
                              style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).accentColor)
                            ),
                          ],
                        ),
                      ),
                      color: Color.fromRGBO(77, 204, 240, 1),
                    ),
                  )),
            ],
          ),
        ));
  }
}
