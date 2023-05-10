import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/methods.dart';
import 'package:project_organizer/projects/create_project.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditProject extends StatefulWidget {
  final Project project;
  EditProject(this.project);

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  String _newprojectname;
  String _newsubject;
  DateTime _newEndDate;
  DateTime _newStartDate;

  final _formKey = GlobalKey<FormState>();

  void setEndDate(DateTime date) {
    _newEndDate = date;
  }

  void setStartDate(DateTime date) {
    _newStartDate = date;
  }

  @override
  Widget build(BuildContext context) {
    _newEndDate = widget.project.date;
    _newStartDate = widget.project.startDate;

    return Scaffold(
        appBar: AppBar(
            title: Text(
          widget.project.title,
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

                      //Projektname
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            "Title:",
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(
                                    color: Color.fromRGBO(77, 204, 240, 1),
                                    fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onTap: () => _btnController.reset(),
                        initialValue: widget.project.title,
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
                                      color: Color.fromRGBO(77, 204, 240, 1))),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Can't be empty";
                            } else {
                              return null;
                            }
                          },
                          onTap: () => _btnController.reset(),
                          initialValue: widget.project.subject,
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
                                left: 20, bottom: 11, top: 11, right: 15),
                          )),
                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text("Start-Date:",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                      color: Color.fromRGBO(77, 204, 240, 1),
                                    ))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DateButton(_newStartDate, setStartDate),
                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text("End-Date:",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    color: Color.fromRGBO(77, 204, 240, 1),
                                  )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DateButton(_newEndDate, setEndDate),

                      SizedBox(height: 60),
                      Center(
                          child: RoundedLoadingButton(
                        controller: _btnController,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            await DatabaseService().updateProject(
                                _newprojectname ?? widget.project.title,
                                _newsubject ?? widget.project.subject,
                                _newEndDate ?? widget.project.date,
                                widget.project.open,
                                widget.project.projectID,
                                widget.project.creationDate,
                                widget.project.topics,
                                widget.project.projectplan,
                                widget.project.workTime,
                                _newStartDate ?? widget.project.startDate);
                            _btnController.success();
                            await Methods()
                                .fillProjectPlan(widget.project.projectID);
                            Navigator.of(context).pop();
                          } else {
                            _btnController.error();
                          }
                        },
                        child: Text("Save",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context).accentColor)),
                        color: Color.fromRGBO(77, 204, 240, 1),
                      )),
                    ],
                  ),
                ),
              )),
        ));
  }
}
