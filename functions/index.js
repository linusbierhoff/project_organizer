const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.userDeleted = functions.auth.user().onDelete((user) => {
  console.log("user deleted");
  const doc = admin.firestore().collection("user").doc(user.uid);
  return doc.delete();
});

exports.notificationWhenDocumenetAddedOrDeleted =
  // eslint-disable-next-line max-len
  functions.firestore.document("/user/{userId}").onWrite(async (change, context) => {
    const oldValue = change.before.data();
    const newValue = change.after.data();
    const userId = context.params.userId;
    // eslint-disable-next-line max-len
    const querySnapshot = await admin.firestore().collection("user").doc(userId).collection("tokens").get();
    // eslint-disable-next-line max-len
    const tokens = querySnapshot.docs.map((snap) => snap.id);
    // eslint-disable-next-line max-len
    if (newValue.projects.length > oldValue.projects.length && tokens.length !== 0) {
      console.log(tokens);
      const payload = admin.messaging.MessagingPayload = {
        notification: {
          title: "New Project",
          body: "You have been added to a new project",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      return admin.messaging().sendToDevice(tokens, payload);
    }
    // eslint-disable-next-line max-len
    if (newValue.projects.length < oldValue.projects.length && tokens.length !== 0) {
      const payload = admin.messaging.MessagingPayload = {
        notification: {
          title: "Project deleted",
          body: "A project you was part of have been deleted",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      return admin.messaging().sendToDevice(tokens, payload);
    }
  });

exports.notificationWhenNewTaskAdded =
  // eslint-disable-next-line max-len
  functions.firestore.document("projects/{projectId}/tasks/{taskId}").onWrite(async (change, context) =>{
    const projectId = context.params.projectId;
    //  eslint-disable-next-line max-len
    const querySnapshot = await admin.firestore().collection("projects").doc(projectId).get();
    const projectName = querySnapshot.data().name;
    // eslint-disable-next-line max-len
    if (Object.keys(change.after.data().members).length > Object.keys(change.before.data().members).length) {
      // eslint-disable-next-line max-len
      const newMemberId = Object.keys(change.after.data().members).pop();
      console.log(newMemberId);
      // eslint-disable-next-line max-len
      const querySnapshot = await admin.firestore().collection("user").doc(newMemberId).collection("tokens").get();
      const tokens = querySnapshot.docs.map((snap) => snap.id);
      if (tokens.length !== 0) {
        console.log("Member is logged in");
        const payload = admin.messaging.MessagingPayload = {
          notification: {
            title: projectName,
            body: "You have been added to a new task",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        return admin.messaging().sendToDevice(tokens, payload);
      }
    }
  });

// eslint-disable-next-line max-len
exports.notificationWhenTaskedIsPinged = functions.https.onCall(async (data, context) => {
  // eslint-disable-next-line max-len
  const querySnapshot = await admin.firestore().collection("projects").doc(data.projectID).collection("tasks").doc(data.taskID).get();
  const task = querySnapshot.data();
  const taskMembers = Object.keys(task.members);
  // eslint-disable-next-line guard-for-in
  for (const index in taskMembers) {
    // eslint-disable-next-line max-len
    const querySnapshot = await admin.firestore().collection("user").doc(taskMembers[index]).collection("tokens").get();
    const tokens = querySnapshot.docs.map((snap) => snap.id);
    if (tokens.length !== 0) {
      console.log("Member is logged in");
      const payload = admin.messaging.MessagingPayload = {
        notification: {
          title: task.title,
          body: data.username+" pinged your task",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      return admin.messaging().sendToDevice(tokens, payload);
    }
  }
});

// eslint-disable-next-line max-len
exports.notificationWhenInformationIsPinged = functions.https.onCall(async (data, context) => {
  // eslint-disable-next-line max-len
  const querySnapshot = await admin.firestore().collection("projects").doc(data.projectID).collection("information").doc(data.informationID).get();
  const information = querySnapshot.data();
  const informationMember = information.userID;
  // eslint-disable-next-line max-len
  const querySnapshotTokens = await admin.firestore().collection("user").doc(informationMember).collection("tokens").get();
  const tokens = querySnapshotTokens.docs.map((snap) => snap.id);
  if (tokens.length !== 0) {
    console.log("Member is logged in");
    const payload = admin.messaging.MessagingPayload = {
      notification: {
        title: information.title,
        // eslint-disable-next-line max-len
        body: data.username+" pinged your research. Please check if everything is correct",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    };
    return admin.messaging().sendToDevice(tokens, payload);
  }
});
