
import 'package:aggdrilling/models/coresize.dart';
import 'package:aggdrilling/models/task.dart';
import 'package:aggdrilling/models/worker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskLog{
  Task task;
  String startTime;
  String endTime;
  double startMeter;
  double endMeter;
  String shift;
  double workHours;
  String remarks;
  DateTime entryDate;
  String entryBy;
  Worker worker;
  CoreSize coreSize;
  TaskLog({this.task,this.startTime,this.endTime});
  TaskLog.fromDs(Map<dynamic,dynamic> ds){
    this.task = ds["taskName"];// find the task from the meta data
    if(this.task.logType.contains("E"))
      {
        this.worker = Worker.fromDs(ds);
      }
    this.shift = ds["shift"];
    this.workHours = ds["hoursWork"];
    if(this.task.logType.contains("P")){
      this.startMeter = ds["mFrom"];
      this.endMeter = ds["mTo"];
    }
    if(this.task.logType.contains("C")){
      this.remarks = ds["remarks"];
    }
  }
  TaskLog.fromDocumentSnapShot(DocumentSnapshot document){
    try{
      this.task = document.data["taskName"];// find the task from the meta data
      if(this.task.logType.contains("E"))
      {
        this.worker = Worker.fromDocumentSnapShot(document);
      }
      this.shift = document.data["shift"];
      this.workHours = document.data["hoursWork"];
      if(this.task.logType.contains("P")){
        this.startMeter = document.data["mFrom"];
        this.endMeter = document.data["mTo"];
      }
      if(this.task.logType.contains("C")){
        this.remarks = document.data["remarks"];
      }
      if(this.task.taskType.contains("coring")){
        this.coreSize = CoreSize.fromDocumentSnapshot(document);
      }
    }catch(error){
      error.toString();
    }
  }

}
class UpdateHistory{
  String userName;
  String action;
  String entryDate;
  UpdateHistory.fromDs(Map<dynamic,dynamic> ds){
    this.userName = ds["username"];
    this.entryDate = ds["entrydate"];
    this.action = ds["action"];
  }
  static List<UpdateHistory> fromDsList(List<dynamic> sizes)
  {
    List<UpdateHistory> updateHistoryList = sizes.map((entry) => UpdateHistory.fromDs(entry)).toList();
    return updateHistoryList;
  }
}