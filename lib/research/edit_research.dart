import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/research/create_research.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditResearch extends StatefulWidget {
  final ResearchModel research;
  final Project project;
  EditResearch(this.research, this.project);
  @override
  EditResearchState createState() => EditResearchState();
}

class EditResearchState extends State<EditResearch> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  String _source;
  String _information;
  String _title;
  String _newTopic;

  void setTopic(String newTopic) {
    _newTopic = newTopic;
  }

  @override
  Widget build(BuildContext context) {
    _newTopic = widget.research.topic;
    return StreamBuilder(
        stream: DatabaseService(userID: widget.research.userID).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserModel userData = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.research.title,
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.notification_important_outlined,
                    ),
                    onPressed: () async {
                      HttpsCallable callable = FirebaseFunctions.instance
                          .httpsCallable('notificationWhenInformationIsPinged');
                      final results = await callable({
                        'projectID': widget.project.projectID,
                        'informationID': widget.research.informationID,
                        'username': userData.name
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext builder) {
                            return SimpleDialog(
                                backgroundColor: Theme.of(context).canvasColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text("You pinged this research!"),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "The member who created this research got an notification!",
                                    ),
                                  ),
                                ]);
                          });
                      print(results.toString());
                    },
                  )
                ],
              ),
              body: Form(
                  key: _formKey,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: ListView(
                      children: [
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: Text("Topic:",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color:
                                            Color.fromRGBO(59, 217, 209, 1))),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TopicButton(setTopic, _newTopic, widget.project.topics),
                        SizedBox(
                          height: 40,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: Text("Title",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color:
                                            Color.fromRGBO(59, 217, 209, 1))),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            onTap: () => _btnController.reset(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            initialValue: widget.research.title,
                            validator: (val) =>
                                val.isEmpty ? "Can't be empty" : null,
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
                                  left: 50, bottom: 11, top: 11, right: 50),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _title = val;
                              });
                            }),
                        SizedBox(height: 40),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: Text("Source:",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color:
                                            Color.fromRGBO(59, 217, 209, 1))),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            onTap: () => _btnController.reset(),
                            initialValue: widget.research.source,
                            validator: (val) =>
                                val.isEmpty ? "Can't be empty" : null,
                            decoration: InputDecoration(
                              hintText: "Source...",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 50, bottom: 11, top: 11, right: 50),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _source = val;
                              });
                            }),
                        SizedBox(height: 40),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: Text("Information:",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color:
                                            Color.fromRGBO(59, 217, 209, 1))),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            initialValue: widget.research.text,
                            minLines: 5,
                            maxLines: null,
                            onTap: () => _btnController.reset(),
                            validator: (val) =>
                                val.isEmpty ? "Can't be empty" : null,
                            decoration: InputDecoration(
                              hintText: "Information...",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 50, bottom: 11, top: 11, right: 50),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _information = val;
                              });
                            }),
                        SizedBox(height: 20),
                        Center(
                            child: RoundedLoadingButton(
                          controller: _btnController,
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              await DatabaseService(
                                      projectID: widget.project.projectID)
                                  .updateInformation(
                                      widget.research.informationID,
                                      _title ?? widget.research.title,
                                      _source ?? widget.research.source,
                                      _information ?? widget.research.text,
                                      widget.research.userID,
                                      widget.research.date,
                                      _newTopic ?? widget.research.topic);
                              _btnController.success();
                              Navigator.pop(context);
                            } else {
                              _btnController.error();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("Save",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).accentColor)),
                          ),
                          color: Color.fromRGBO(59, 217, 209, 1),
                        )),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  )),
            );
          } else {
            return Loading();
          }
        });
  }
}
