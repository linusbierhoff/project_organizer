class Project {
  final List topics;
  final Map projectplan;
  final String title;
  final String subject;
  final DateTime date;
  final DateTime creationDate;
  final DateTime startDate;
  final String projectID;
  final bool open;
  final int workTime;

  Project(
      {this.title,
      this.projectplan,
      this.subject,
      this.date,
      this.projectID,
      this.open,
      this.creationDate,
      this.topics,
      this.workTime,
      this.startDate});
}

class UserModel {
  final String userID;
  final String name;
  final List projects;
  final List favorites;

  UserModel({this.userID, this.name, this.projects, this.favorites});
}

class TaskModel {
  final String topic;
  final List dependentTasks;
  final DateTime creationDate;
  final String title;
  final String notes;
  final Map members;
  final int duration;
  final String taskID;
  final bool open;

  TaskModel(
      {this.open,
      this.duration,
      this.members,
      this.taskID,
      this.title,
      this.notes,
      this.creationDate,
      this.topic,
      this.dependentTasks});
}

class ResearchModel {
  final String topic;

  final String title;
  final String source;
  final String userID;
  final DateTime date;
  final String informationID;
  final String text;

  ResearchModel(
      {this.date,
      this.userID,
      this.informationID,
      this.title,
      this.text,
      this.source,
      this.topic});
}
