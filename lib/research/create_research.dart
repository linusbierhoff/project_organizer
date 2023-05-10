import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AddResearch extends StatefulWidget {
  final Project project;
  AddResearch(this.project);
  @override
  _AddResearchState createState() => _AddResearchState();
}

class _AddResearchState extends State<AddResearch> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  void setTopic(String newTopic) {
    _topic = newTopic;
  }

  String _topic = "";
  String _source;
  String _information;
  String _title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Add research'), Icon(Icons.short_text)],
        )),
        body: Form(
            key: _formKey,
            child: ListView(
             
              children: [
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Text(
                      "Topic:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                       color: Color.fromRGBO(59, 217, 209, 1)
                      )
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TopicButton(setTopic, _topic, widget.project.topics),
                SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Text(
                      "Title:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                       color: Color.fromRGBO(59, 217, 209, 1)
                      )
                    
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    onTap: () => _btnController.reset(),
                    validator: (val) => val.isEmpty ? "Can't be empty" : null,
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
                    child: Text(
                      "Source:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                       color: Color.fromRGBO(59, 217, 209, 1)
                      )
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    onTap: () => _btnController.reset(),
                    validator: (val) => val.isEmpty ? "Can't be empty" : null,
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
                    child: Text(
                      "Information:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                       color: Color.fromRGBO(59, 217, 209, 1)
                      )
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    minLines: 5,
                    maxLines: null,
                    onTap: () => _btnController.reset(),
                    validator: (val) => val.isEmpty ? "Can't be empty" : null,
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
                      await DatabaseService(projectID: widget.project.projectID)
                          .createInformation(
                              _title,
                              _source,
                              _information,
                              _firebaseAuth.currentUser.uid,
                              DateTime.now(),
                              _topic);
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
                            .copyWith(color: Theme.of(context).accentColor)),
                  ),
                  color: Color.fromRGBO(59, 217, 209, 1),
                )),
                SizedBox(
                  height: 20,
                )
              ],
            )));
  }
}

//////////////Widgets//////////////

// ignore: must_be_immutable
class TopicButton extends StatefulWidget {
  final Function setTopic;
  final List topicList;
  String newTopic;
  TopicButton(this.setTopic, this.newTopic, this.topicList);
  @override
  _TopicButtonState createState() => _TopicButtonState();
}

class _TopicButtonState extends State<TopicButton> {
  String getTopicText() {
    if (widget.newTopic.isEmpty) {
      return "No topic";
    } else {
      return widget.newTopic;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 42, right: 50),
        child: TextButton(
          style: ButtonStyle(
            overlayColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
          ),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                getTopicText(),
                style: Theme.of(context).textTheme.bodyText1,
              )),
          onPressed: () {
            showModalBottomSheet(
               backgroundColor: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                context: context,
                builder: (context) {
                  return Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Select topic:",
                              style: Theme.of(context).textTheme.headline6)),
                      Expanded(
                        child: ListView.builder(
                       
                          itemCount: widget.topicList.length + 1,
                          itemBuilder: (context, i) {
                            if (i == widget.topicList.length) {
                              return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        widget.newTopic = "";
                                        widget.setTopic("");
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                          child: Text("No Topic",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontSize: 18,
                                                      color: Colors.grey))),
                                    ),
                                  ));
                            }
                            return Padding(
                                padding: EdgeInsets.all(10),
                                child: InkWell(
                                  onTap: () {
                                    print("tap");
                                    setState(() {
                                      widget.newTopic = widget.topicList[i];
                                      widget.setTopic(widget.topicList[i]);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                        child: Text(widget.topicList[i],
                                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                              fontSize: 18
                                            ))),
                                  ),
                                ));
                          },
                        ),
                      )
                    ],
                  );
                });
          },
        ));
  }
}
