
import 'package:cloud_firestore/cloud_firestore.dart';

class Task
{
  String name;
  String description;
  String taskType;
  String logType;
  String taskId;
  bool   isActive;
  Task(this.name,this.taskType,this.logType);
  Task.fromDocumentSnapShot(DocumentSnapshot snapshot){
    this.name = snapshot.data["name"];
    this.taskType = snapshot.data["taskType"];
    this.logType = snapshot.data["logType"];
    this.taskId = snapshot.data["taskId"];
//    this.isActive = ds["isActive"];
  }
}
