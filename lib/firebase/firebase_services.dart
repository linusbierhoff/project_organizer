import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project_organizer/firebase/model.dart';
import 'database.dart';

class AuthenticateServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //auth change user Stream

  Stream<User> get user {
    return _firebaseAuth.authStateChanges();
  }

  //Sign out

  Future signOut() async {
    try {
      String uid = _firebaseAuth.currentUser.uid;
      String fcmToken = await _firebaseMessaging.getToken();
  
      await _db
          .collection('user')
          .doc(uid)
          .collection('tokens')
          .doc(fcmToken)
          .delete();
      return await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

//Register with Email and Password
  Future registerEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      user.updateProfile(displayName: name);
      user.sendEmailVerification();
      await DatabaseService().createUser(user.uid.toString(), name);

      return user;
    } on FirebaseAuthException catch (e) {
      print("Error: " + e.toString());
      return null;
    }
  }

  Future loginEmail(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      return user;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> checkCurrentPassword(String _currentPassword) async {
    var firebaseUser = _firebaseAuth.currentUser;
    var authCredential = EmailAuthProvider.credential(
        email: firebaseUser.email, password: _currentPassword);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredential);
      return authResult.user != null;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future deleteAccount(UserModel _currentUser, List<UserModel> _allUser) async {
    var user = _firebaseAuth.currentUser;
    for (int i = 0; i < _currentUser.projects.length; i++) {
      print("Run");
      DatabaseService()
          .deleteProject(_currentUser.projects[i], _allUser, _currentUser);
    }
    await _firebaseAuth.signOut();

    user.delete();

    return "Succesfull";
  }

  Future resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseException catch (e) {
      print(e.toString());
      return null;
    }
  }
}
