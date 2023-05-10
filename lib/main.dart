import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_organizer/drawer.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/projects/create_project.dart';
import 'package:project_organizer/themes.dart';
import 'projects/project.dart';
import 'tasks/tasks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authenticate_screens.dart';
import 'package:flutter/services.dart';

int acurrentIndex = 0;
NotificationSettings settings;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthenticateServices().user,
      initialData: null,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Project Organizer',
          themeMode: ThemeMode.system,
        theme: CustomThemes().lightTheme,
        darkTheme: CustomThemes().darkTheme,
          home: Wrapper()),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void initState() {
    super.initState();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _saveDeviceToken();
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      final snackbar = SnackBar(
        content: Text(message.notification.title),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: DatabaseService(userID: _firebaseAuth.currentUser.uid).userData,
      initialData: null,
      child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [
              IndexedStack(
                children: [Projects(), Tasks()],
                index: acurrentIndex,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        child: BottomNavigationBar(
                            showSelectedLabels: false,
                            showUnselectedLabels: false,
                            backgroundColor: Theme.of(context).canvasColor,
                            type: BottomNavigationBarType.fixed,
                            onTap: onTabTapped,
                            currentIndex: acurrentIndex,
                            selectedItemColor: Theme.of(context).primaryColor,
                            unselectedItemColor: Theme.of(context).textTheme.bodyText1.color,
                            unselectedFontSize: 15,
                            selectedFontSize: 15,
                            items: [
                              BottomNavigationBarItem(
                                  icon:
                                      Icon(Icons.auto_awesome_motion, size: 30),
                                  label: "Projekte"),
                              BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.format_list_bulleted,
                                    size: 30,
                                  ),
                                  label: "Aufgaben"),
                            ]))),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    tooltip: "Add Project",
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CreateProject())),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              )
            ],
          ),
          drawer: CustomDrawer()),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      acurrentIndex = index;
    });
  }

  _saveDeviceToken() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String uid = _firebaseAuth.currentUser.uid;
    String fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken != null) {
      var tokenRef =
          _db.collection('user').doc(uid).collection('tokens').doc(fcmToken);
      await tokenRef.set({
        'token': fcmToken,
        'creationDate': DateTime.now(),
        'platform': Platform.operatingSystem
      });
    }
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
