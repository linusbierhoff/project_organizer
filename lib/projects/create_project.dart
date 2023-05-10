import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CreateProject extends StatefulWidget {
  @override
  _CreateProjectState createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  DateTime _newdate;
  String _newprojectname = "";
  String _newsubject = "";
  String _errorMessage = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void setDate(DateTime date) {
      setState(() {
        _errorMessage = "";
      });
      _newdate = date;
      _btnController.reset();
    }

    return StreamBuilder(
        stream: DatabaseService(userID: _firebaseAuth.currentUser.uid).userData,
        builder: (context, databaseUser) {
          if (databaseUser.hasData) {
            UserModel currentUser = databaseUser.data;
            return Scaffold(
                appBar: AppBar(
                    title: Text(
                  'Create new Project',
                )),
                body: Padding(
                  padding: EdgeInsets.all(30),
                  child: Form(
                      key: _formKey,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 700),
                          child: ListView(
                            children: [
                              SizedBox(height: 20),

                              //ProjectTitle
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text("Title:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color:
                                                Color.fromRGBO(77, 204, 240, 1),
                                          )),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                onTap: () => _btnController.reset(),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Can't be empty";
                                  } else {
                                    return null;
                                  }
                                },
                                style: TextStyle(fontWeight: FontWeight.bold),
                                onChanged: (val) {
                                  setState(() {
                                    _newprojectname = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Title...",
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
                              ),

                              SizedBox(height: 20),

                              //Fach
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text("Subject:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color:
                                                Color.fromRGBO(77, 204, 240, 1),
                                          )),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                  onTap: () => _btnController.reset(),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() {
                                      _newsubject = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Subject...",
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
                                        right: 15),
                                  )),
                              SizedBox(
                                height: 20,
                              ),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text("Date:",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                              color: Color.fromRGBO(
                                                  77, 204, 240, 1),
                                            ))),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              DateButton(_newdate, setDate),
                              Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(_errorMessage,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12))),
                              SizedBox(height: 60),

                              Center(
                                  child: RoundedLoadingButton(
                                controller: _btnController,
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    if (_newdate == null) {
                                      _btnController.error();
                                      setState(() {
                                        _errorMessage = "Can't be empty";
                                      });
                                    } else {
                                      await DatabaseService().createNewProject(
                                          _newprojectname,
                                          _newsubject,
                                          _newdate,
                                          currentUser);

                                      _btnController.success();
                                      Navigator.of(context).pop();
                                    }
                                  } else {
                                    if (_newdate == null) {
                                      setState(() {
                                        _errorMessage = "Can't be empty";
                                      });
                                    }
                                    _btnController.error();
                                  }
                                },
                                child: Text("Save",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color:
                                                Theme.of(context).accentColor)),
                                color: Color.fromRGBO(77, 204, 240, 1),
                              )),
                            ],
                          ),
                        ),
                      )),
                ));
          } else {
            return Loading();
          }
        });
  }
}

// ignore: must_be_immutable
class DateButton extends StatefulWidget {
  final Function setDate;
  DateTime _newdate;
  DateButton(this._newdate, this.setDate);
  @override
  _DateButtonState createState() => _DateButtonState();
}

class _DateButtonState extends State<DateButton> {
  var formatter = new DateFormat('dd.MM.yyyy');

  Text showCurrentDate() {
    if (widget._newdate != null) {
      return Text(formatter.format(widget._newdate).toString(),
          style: Theme.of(context).textTheme.bodyText1);
    } else {
      return Text("No Date", style: Theme.of(context).textTheme.bodyText1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          overlayColor:
              MaterialStateColor.resolveWith((states) => Colors.transparent),
        ),
        onPressed: () async {
          DateTime _dateTemp = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2050),
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme,
                ),
                child: child,
              );
            },
          );
          if (_dateTemp != null) {
            setState(() {
              widget._newdate = _dateTemp;
            });
            widget.setDate(widget._newdate);
          }
        },
        child: Center(child: Container(height: 70, child: showCurrentDate())));
  }
}
