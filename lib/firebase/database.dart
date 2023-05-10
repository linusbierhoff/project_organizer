import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_organizer/methods.dart';
import 'model.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  String taskID;
  String projectID;
  String userID;
  String researchID;
  UserModel currentUser;

  DatabaseService(
      {this.projectID,
      this.taskID,
      this.userID,
      this.currentUser,
      this.researchID});

  //-------------Projects-------------

  final CollectionReference projectCollection =
      FirebaseFirestore.instance.collection('projects');

  Stream<Project> get projectData {
    return projectCollection
        .doc(projectID)
        .snapshots()
        .map(_projectFromSnapshot);
  }

  Stream<List<Project>> get projects {
    Stream<List<Project>> projectStream;
    List<Stream<Project>> streams = [];

    for (int i = 0; i < currentUser.projects.length; i++) {
      try {
        streams.add(
            DatabaseService(projectID: currentUser.projects[i]).projectData);
      } catch (e) {
        print(e.toString());
      }
    }

    if (streams.length == 0) {
      StreamController<List<Project>> controller =
          StreamController<List<Project>>();
      controller.add([]);
      projectStream = controller.stream;
      controller.close();
    } else {
      projectStream = CombineLatestStream.list(streams);
    }

    return projectStream;
  }



  Project _projectFromSnapshot(DocumentSnapshot snapshot) {
    return Project(
        title: snapshot.data()['name'],
        topics: snapshot.data()['topics'] ?? [],
        subject: snapshot.data()['subject'],
        creationDate: snapshot.data()['creationDate'].toDate(),
        date: snapshot.data()['date'].toDate(),
        projectID: snapshot.id,
        open: snapshot.data()['open'],
        projectplan: snapshot.data()['projectplan'] ?? {},
        workTime: snapshot.data()['workTime'] ?? 1,
        startDate: snapshot.data()['startDate'].toDate());
  }

  Future createNewProject(
    String name,
    String subject,
    DateTime date,
    UserModel member,
  ) async {
    String projectId = await _createProjectDocument(
      name,
      subject,
      date,
    );

    List newProjects = member.projects;
    if (newProjects != null) {
      newProjects.add(projectId);
    } else {
      newProjects = [projectId];
    }

    await DatabaseService().updateUserData(
        member.userID, member.name, newProjects, member.favorites);

    return projectId;
  }

  Future _createProjectDocument(
      String name, String subject, DateTime date) async {
    String id;
    DateTime now = new DateTime.now();
    await projectCollection.add({
      'creationDate': DateTime(now.year, now.month, now.day),
      'startDate': DateTime(now.year, now.month, now.day),
      'name': name,
      'subject': subject,
      'date': date,
      'open': true,
      'topics': [],
      'workTime': 1
    }).then((doc) {
      id = doc.id;
    });
    return id;
  }

  Future deleteProject(
      String projectId, List<UserModel> userList, UserModel user) async {
    if (getUserFromProject(projectId, userList).length == 1) {
      await DatabaseService(projectID: projectId).deleteAllTasks();
      await DatabaseService(projectID: projectId).deleteAllResearches();
      projectCollection.doc(projectId).delete();
    }
    await deleteProjectFromList(user, projectId);
    return projectId;
  }

  Future deleteProjectFromList(UserModel user, String projectId) async {
    //TO-DO: Remove User from all tasks and reload projectplan
    List newProjects = user.projects;
    newProjects.remove(projectId);
    await updateUserData(user.userID, user.name, newProjects, user.favorites);
    return projectId;
  }

  Future updateProject(
      String name,
      String subject,
      DateTime date,
      bool open,
      String projectId,
      DateTime creationDate,
      List topics,
      Map projectplan,
      int workTime,
      DateTime startDate) async {
    var _result = await projectCollection.doc(projectId).set({
      'name': name,
      'subject': subject,
      'date': date,
      'open': open,
      'creationDate': creationDate,
      'topics': topics,
      'projectplan': projectplan,
      'workTime': workTime,
      'startDate': startDate,
    });
    return _result;
  }

  Future updateProjectMember(String projectId, List<UserModel> newUser) async {
    for (int i = 0; i < newUser.length; i++) {
      List newProjects = newUser[i].projects;
      if (newProjects != null) {
        newProjects.add(projectId);
      } else {
        newProjects = [projectId];
      }
      await updateUserData(newUser[i].userID, newUser[i].name, newProjects,
          newUser[i].favorites);
    }
    return projectId;
  }

  //-------------user-------------

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  Stream<List<UserModel>> get user {
    return userCollection.snapshots().map(_userListFromSnapshot);
  }

  List<UserModel> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModel(
        userID: doc.id,
        name: doc.data()['displayname'] ?? '',
        projects: doc.data()['projects'] ?? [],
        favorites: doc.data()['favorites'] ?? [],
      );
    }).toList();
  }

  Stream<List<UserModel>> get friends {
    Stream<List<UserModel>> friendsStream;
    List<Stream<UserModel>> streams = [];

    for (int i = 0; i < currentUser.favorites.length; i++) {
      streams.add(DatabaseService(userID: currentUser.favorites[i]).userData);
    }

    if (streams.length == 0) {
      StreamController<List<UserModel>> controller =
          StreamController<List<UserModel>>();
      controller.add([]);
      friendsStream = controller.stream;
      controller.close();
    } else {
      friendsStream = CombineLatestStream.list(streams);
    }

    return friendsStream;
  }

  Stream<UserModel> get userData {
    return userCollection.doc(userID).snapshots().map(_userFormSnapshot);
  }

  UserModel _userFormSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
      userID: snapshot.id,
      name: snapshot.data()['displayname'] ?? '',
      projects: snapshot.data()['projects'] ?? [],
      favorites: snapshot.data()['favorites'] ?? [],
    );
  }

  Future createUser(String userId, String name) async {
    return await userCollection.doc(userId).set({
      'displayname': name,
      'projects': [],
      'favorites': [],
    });
  }

  Future updateUserData(
      String userId, String name, List projects, List favorites) async {
    return await userCollection.doc(userId).set({
      'displayname': name,
      'projects': projects,
      'favorites': favorites,
    });
  }

  List<UserModel> getUserFromProject(String projectId, List<UserModel> user) {
    List<UserModel> correctUser = [];
    for (int i = 0; i < user.length; i++) {
      if (user[i].projects.contains(projectId)) {
        correctUser.add(user[i]);
      }
    }
    return correctUser;
  }

  UserModel getUserFromID(List<UserModel> user, String id) {
    for (int i = 0; i < user.length; i++) {
      if (user[i].userID == id) {
        return user[i];
      }
    }
    return null;
  }

  List<String> getUserNameFromProject(String projectId, List<UserModel> user) {
    List<String> correctUser = [];
    for (int i = 0; i < user.length; i++) {
      if (user[i].projects.contains(projectId)) {
        correctUser.add(user[i].name);
      }
    }
    return correctUser;
  }

  bool userExists(List<UserModel> user, String uid) {
    bool exists = false;
    for (int i = 0; i < user.length; i++) {
      if (user[i].userID == uid) {
        exists = true;
      }
    }
    return exists;
  }

  //-------------tasks-------------

  CollectionReference taskCollection() {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectID)
        .collection('tasks');
  }

  Stream<TaskModel> get taskData {
    return taskCollection().doc(this.taskID).snapshots().map(_taskFromSnapshot);
  }

  TaskModel _taskFromSnapshot(DocumentSnapshot snapshot) {
    return TaskModel(
      creationDate: snapshot.data()['creationDate'].toDate(),
      taskID: snapshot.id,
      topic: snapshot.data()['topic'] ?? "",
      title: snapshot.data()['title'],
      notes: snapshot.data()['notes'] ?? '',
      members: snapshot.data()['members'] ?? [],
      duration: snapshot.data()['duration'] ?? 0,
      open: snapshot.data()['open'],
      dependentTasks: snapshot.data()['dependentTasks'] ?? [],
    );
  }

  Stream<List<TaskModel>> get tasks {
    return taskCollection().snapshots().map(_taskListFromSnapshot);
  }

  List<TaskModel> _taskListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TaskModel(
        creationDate: doc.data()['creationDate'].toDate() ?? '',
        taskID: doc.id,
        topic: doc.data()['topic'] ?? "",
        title: doc.data()['title'],
        notes: doc.data()['notes'] ?? '',
        members: doc.data()['members'] ?? [],
        duration: doc.data()['duration'] ?? 0,
        open: doc.data()['open'],
        dependentTasks: doc.data()['dependentTasks'] ?? [],
      );
    }).toList();
  }

  Future updateTask(
      String taskID,
      String title,
      String notes,
      Map members,
      int duration,
      bool open,
      DateTime creationDate,
      String topic,
      List dependentTasks) async {
    var _return = await taskCollection().doc(taskID).set({
      'creationDate': creationDate,
      'title': title,
      'notes': notes,
      'members': members,
      'duration': duration,
      'open': open,
      'topic': topic,
      'dependentTasks': dependentTasks,
    });
    return _return;
  }

  Future createTask(String title, String topic) async {
    DateTime now = new DateTime.now();
    var _result = await taskCollection().doc().set({
      'creationDate': DateTime(now.year, now.month, now.day),
      'title': title,
      'notes': '',
      'members': {},
      'duration': 0,
      'open': true,
      'topic': topic,
      'dependentTasks': [],
    });
    await Methods().fillProjectPlan(projectID);
    return _result;
  }

  Future deleteTask(String taskId) async {
    List<TaskModel> allTasks =
        await DatabaseService(projectID: projectID).tasks.first;

    for (TaskModel _task in allTasks) {
      if (_task.dependentTasks.contains(taskId)) {
        _task.dependentTasks.remove(taskId);
        DatabaseService(projectID: projectID).updateTask(
            _task.taskID,
            _task.title,
            _task.notes,
            _task.members,
            _task.duration,
            _task.open,
            _task.creationDate,
            _task.topic,
            _task.dependentTasks);
      }
    }

    await taskCollection().doc(taskId).delete();
    return taskId;
  }

  Future deleteAllTasks() async {
    await taskCollection().get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    return "finish";
  }

  TaskModel getTaskFromId(String _taskId, List<TaskModel> tasks) {
    for (TaskModel i in tasks) {
      if (i.taskID == _taskId) {
        return i;
      }
    }
    return null;
  }

  //-------------information-------------

  CollectionReference informationCollection() {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectID)
        .collection('information');
  }

  Stream<List<ResearchModel>> get information {
    return informationCollection()
        .snapshots()
        .map(_informationListFromSnapshot);
  }

  Stream<ResearchModel> get informationData {
    return informationCollection()
        .doc(projectID)
        .snapshots()
        .map(_informationFromSnapshot);
  }

  ResearchModel _informationFromSnapshot(DocumentSnapshot snapshot) {
    return ResearchModel(
      informationID: snapshot.id,
      topic: snapshot.data()['topic'] ?? "",
      title: snapshot.data()['title'] ?? '',
      source: snapshot.data()['source'] ?? '',
      userID: snapshot.data()['userID'] ?? '',
      date: snapshot.data()['date'].toDate(),
      text: snapshot.data()['text'] ?? '',
    );
  }

  List<ResearchModel> _informationListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ResearchModel(
        informationID: doc.id,
        topic: doc.data()['topic'] ?? "",
        title: doc.data()['title'] ?? '',
        source: doc.data()['source'] ?? '',
        userID: doc.data()['userID'] ?? '',
        date: doc.data()['date'].toDate(),
        text: doc.data()['text'] ?? '',
      );
    }).toList();
  }

  Future createInformation(String title, String source, String text,
      String userID, DateTime date, String topic) async {
    return await informationCollection().doc().set({
      'title': title,
      'source': source,
      'userID': userID,
      'date': date,
      'text': text,
      'topic': topic,
    });
  }

  Future updateInformation(String informationID, String title, String source,
      String text, String userID, DateTime date, String topic) async {
    return await informationCollection().doc(informationID).set({
      'title': title,
      'source': source,
      'userID': userID,
      'date': date,
      'text': text,
      'topic': topic,
    });
  }

  Future deleteAllResearches() async {
    await informationCollection().get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    return "finish";
  }
}
