import 'package:flutter/material.dart';
import 'firebase/firebase_services.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LogInScreen extends StatefulWidget {
  final Function toggleView;
  LogInScreen(this.toggleView);
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthenticateServices _auth = AuthenticateServices();
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          TextButton.icon(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              onPressed: () {
                widget.toggleView();
              },
              icon: Icon(
                Icons.person,
                color: Theme.of(context).textTheme.bodyText2.color,
              ),
              label: Text(
                "Register",
                style: Theme.of(context).textTheme.bodyText2,
              ))
        ], title: Text('Log In')),
        body: Padding(
          padding: EdgeInsets.all(30),
          child: Form(
              key: _formKey,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: ListView(
                   
                    children: [
                      SizedBox(height: 20),

                      //E-Mail
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text("E-Mail:",
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
                      TextFormField(
                          onTap: () => _btnController.reset(),
                          validator: (val) =>
                              val.isEmpty ? "Can't be empty" : null,
                          decoration: InputDecoration(
                            hintText: "E-Mail...",
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
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          }),
                      SizedBox(height: 40),

                      //Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text("Password:",
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
                      TextFormField(
                        onTap: () => _btnController.reset(),
                        onFieldSubmitted: (value) async {
                          _btnController.start();
                          setState(() {
                            error = "";
                          });
                          // check the form for empty spots and validity
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email);

                          if (_formKey.currentState.validate()) {
                            if (emailValid) {
                              dynamic result =
                                  await _auth.loginEmail(email, password);

                              if (result == null) {
                                _btnController.error();
                                setState(() => error = "Invalid Account");
                              }
                            } else {
                              _btnController.error();
                              setState(() {
                                error = "Your email is invalid";
                              });
                            }
                          } else {
                            _btnController.error();
                          }
                        },
                        validator: (val) =>
                            val.length < 6 ? "Wrong password" : null,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password...",
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

                      //Button
                      Center(
                          child: RoundedLoadingButton(
                        controller: _btnController,
                        onPressed: () async {
                          setState(() {
                            error = "";
                          });
                          // check the form for empty spots and validity
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email);

                          if (_formKey.currentState.validate()) {
                            if (emailValid) {
                              dynamic result =
                                  await _auth.loginEmail(email, password);

                              if (result == null) {
                                _btnController.error();
                                setState(() => error = "Invalid Account");
                              }
                            } else {
                              _btnController.error();
                              setState(() {
                                error = "Your email is invalid";
                              });
                            }
                          } else {
                            _btnController.error();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Log In",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      color: Theme.of(context).accentColor)),
                        ),
                        color: Color.fromRGBO(77, 204, 240, 1),
                      )),

                      SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                      SizedBox(height: 20),

                      Center(
                          child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) {
                                String _mailToReset = "";
                                RoundedLoadingButtonController _btnController =
                                    RoundedLoadingButtonController();
                                return SimpleDialog(
                                  backgroundColor:
                                      Theme.of(context).canvasColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  contentPadding: EdgeInsets.all(20),
                                  title: Text("Reset Password"),
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText: "E-Mail...",
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
                                            right: 15),
                                      ),
                                      onTap: () {
                                        _btnController.reset();
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          _mailToReset = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    RoundedLoadingButton(
                                      controller: _btnController,
                                      onPressed: () async {
                                        var result =
                                            await AuthenticateServices()
                                                .resetPassword(_mailToReset);
                                        if (result == true) {
                                          _btnController.success();
                                          Navigator.pop(context);
                                        } else {
                                          _btnController.error();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text("Send Mail",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .accentColor)),
                                      ),
                                      color: Color.fromRGBO(77, 204, 240, 1),
                                    )
                                  ],
                                );
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Forgot password",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              )),
        ));
  }
}

class RegisterScreen extends StatefulWidget {
  final Function toggleView;
  RegisterScreen(this.toggleView);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AuthenticateServices _auth = AuthenticateServices();
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  String email = "";
  String password = "";
  String displayname = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                  ),
                  onPressed: () {
                    widget.toggleView();
                  },
                  icon: Icon(
                    Icons.person,
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  label: Text(
                    "Log In",
                    style: Theme.of(context).textTheme.bodyText2,
                  ))
            ],
            title: Text(
              'Register',
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

                      //Displayname
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text("Name:",
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
                      TextFormField(
                        onTap: () => _btnController.reset(),
                        validator: (val) =>
                            val.isEmpty ? "Can't be empty" : null,
                        onChanged: (val) {
                          setState(() {
                            displayname = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Name...",
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

                      //E-Mail
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text("E-Mail:",
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
                      TextFormField(
                        onTap: () => _btnController.reset(),
                        validator: (val) =>
                            val.isEmpty ? "Can't be empty" : null,
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "E-Mail...",
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

                      //Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Password:",
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
                      TextFormField(
                        onTap: () => _btnController.reset(),
                        onFieldSubmitted: (value) async {
                          _btnController.start();
                          setState(() {
                            error = "";
                          });
                          // check the form for empty spots and validity
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email);

                          if (_formKey.currentState.validate()) {
                            if (emailValid) {
                              dynamic result = await _auth.registerEmail(
                                  email, password, displayname);

                              if (result == null) {
                                _btnController.error();
                                setState(() => error = "Invalid Account");
                              }
                            } else {
                              _btnController.error();
                              setState(() {
                                error = "Your email is invalid";
                              });
                            }
                          } else {
                            _btnController.error();
                          }
                        },
                        validator: (val) =>
                            val.length < 6 ? "Password is to short" : null,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password...",
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

                      //Button
                      Center(
                          child: RoundedLoadingButton(
                        controller: _btnController,
                        onPressed: () async {
                          setState(() {
                            error = "";
                          });
                          // check the form for empty spots and validity
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email);

                          if (_formKey.currentState.validate()) {
                            if (emailValid) {
                              dynamic result = await _auth.registerEmail(
                                  email, password, displayname);

                              if (result == null) {
                                _btnController.error();
                                setState(() => error = "Invalid Account");
                              }
                            } else {
                              _btnController.error();
                              setState(() {
                                error = "Your email is invalid";
                              });
                            }
                          } else {
                            _btnController.error();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Register",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
                        ),
                        color: Color.fromRGBO(77, 204, 240, 1),
                      )),
                      SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      )
                    ],
                  ),
                ),
              )),
        ));
  }
}

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showLogIn = true;
  void toggleView() {
    setState(() => showLogIn = !showLogIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showLogIn) {
      return LogInScreen(toggleView);
    } else {
      return RegisterScreen(toggleView);
    }
  }
}
