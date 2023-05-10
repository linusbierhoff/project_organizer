import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:project_organizer/firebase/firebase_services.dart';
import 'package:project_organizer/friends.dart';
import 'package:project_organizer/settings/account_settings.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final AuthenticateServices _auth = AuthenticateServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(40), bottomRight: Radius.circular(40)),
        child: Drawer(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(border: null, boxShadow: null),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "Hallo ",
                                  style: Theme.of(context).textTheme.headline6),
                              TextSpan(
                                  text: _firebaseAuth.currentUser.displayName
                                      .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Color.fromRGBO(77, 204, 240, 1),
                                        fontWeight: FontWeight.bold,
                                      )),
                              TextSpan(
                                  text: "!",
                                  style: Theme.of(context).textTheme.headline6),
                            ])),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      title: Text("Account"),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Account())),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.people,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      title: Text("Friends"),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Friends())),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      title: Text("Help"),
                      onTap: () async {
                        if (await canLaunch(
                            "https://www.notion.so/Project-Organizer-100aae45115145e79dad6d2376765aa2")) {
                          await launch(
                              "https://www.notion.so/Project-Organizer-100aae45115145e79dad6d2376765aa2");
                        } else {
                          throw 'Could not launch "https://www.notion.so/Project-Organizer-100aae45115145e79dad6d2376765aa2"k';
                        }
                      },
                    ),
                    ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                        title: Text("About"),
                        onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: Theme.of(context).canvasColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text("About"),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        "If you have problems with this app or if you want to give me feddback conatct me at this email adress: "),
                                    Linkify(
                                      onOpen: (link) async {
                                        await _onOpen(link);
                                      },
                                      text: "project_organizer@icloud.com",
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      style: ButtonStyle(
                                   overlayColor:
                                       MaterialStateColor.resolveWith(
                                           (states) => Colors.transparent),
                                      ),
                                      child: Text(
                                   "View Licenses",
                                   style: Theme.of(context).textTheme.bodyText2
                                      ),
                                      onPressed: () {
                                   showLicensePage(context: context);
                                      },
                                    ),
                                  TextButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateColor.resolveWith(
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
                            )),
                  ]),
              Padding(
                padding: EdgeInsets.all(50),
                child: RoundedLoadingButton(
                    color: Color.fromRGBO(77, 204, 240, 1),
                    child: Text(
                      "Sign out ",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    controller: _btnController,
                    onPressed: () async {
                      await _auth.signOut();
                      _btnController.success();
                    }),
              ),
            ])));
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
