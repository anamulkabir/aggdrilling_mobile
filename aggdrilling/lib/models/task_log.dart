
import 'package:aggdrilling/models/coresize.dart';
import 'package:aggdrilling/models/task.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/models/worker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskLog{
  Task task;
  String startTime;
  String endTime;
  double startMeter;
  double endMeter;
  String shift;
  double workHours;
  String comment;
  DateTime entryDate;
  User entryBy;
  Worker worker1;
  Worker worker2;
  Worker driller;
  Worker helper;
  CoreSize coreSize;
  final formatDate = DateFormat("yyyy-MM-dd");
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  TaskLog({this.task,this.startTime,this.endTime});
  TaskLog.fromDs(Map<dynamic,dynamic> ds){
    this.task = ds["taskName"];// find the task from the meta data
    if(this.task.logType.contains("E"))
      {
        this.worker1 = Worker.fromDs(ds["worker1"]);
        this.worker2 = Worker.fromDs(ds["worker2"]);
      }
    if(this.task.logType.contains("X")){
      this.driller = Worker.fromDs(ds["driller"]);
      this.helper = Worker.fromDs(ds["helper"]);
    }
    this.shift = ds["shift"];
    this.workHours = ds["hoursWork"];
    if(this.task.logType.contains("P")){
      this.startMeter = ds["mFrom"];
      this.endMeter = ds["mTo"];
    }
    if(this.task.logType.contains("C")){
      this.comment = ds["remarks"];
    }
  }
  TaskLog.fromDocumentSnapShot(DocumentSnapshot document){
    try{
      this.task = Task.fromDs(document.data["task"]);// find the task from the meta data
      if(this.task.logType.contains("E"))
      {
        this.worker1 = document.data["worker1"]!=null?Worker.fromDs(document.data["worker1"]):null;
        this.worker2 = document.data["worker2"]!=null?Worker.fromDs(document.data["worker2"]):null;
      }
      if(this.task.logType.contains("X")){
        this.driller = document.data["driller"]!=null?Worker.fromDs(document.data["driller"]):null;
        this.helper = document.data["helper"]!=null?Worker.fromDs(document.data["helper"]):null;
      }
      this.startTime = document.data["startTime"];
      this.endTime = document.data["endTime"];
      this.shift = document.data["shift"];
      this.workHours = document.data["hoursWork"];
      if(this.task.logType.contains("P")){
        this.startMeter = double.parse(document.data["startMeter"].toString());
        this.endMeter = double.tryParse(document.data["endMeter"].toString());
      }
      this.comment = document.data["comment"];
      if(this.task.taskType.toLowerCase().contains('drilling') && document.data["coreSize"]!=null){
        this.coreSize = CoreSize.fromDS(document.data["coreSize"]);
      }
      this.entryBy = User.fromDs(document.data["entryBy"]);
      this.entryDate = formatDateTime.parse(document.data["entryDate"]);
    }catch(error){
      error.toString();
    }
  }
  Map<String,dynamic> toJson()=>{
    'task':this.task.toJson(),
    'startTime': this.startTime,
    'endTime': this.endTime,
    'startMeter': this.startMeter,
    'endMeter': this.endMeter,
    'shift': this.shift,
    'workHours': this.workHours,
    'comment': this.comment!=null?this.comment:"",
    'entryDate': formatDateTime.format(this.entryDate),
    'entryBy': this.entryBy.toJson(),
    'coreSize': this.coreSize!=null?this.coreSize.toJson():null,
    'worker1': this.worker1 !=null?this.worker1.toJson():null,
    'worker2': this.worker2 !=null?this.worker2.toJson():null,
    'driller':this.driller != null? this.driller.toJson():null,
    'helper':this.helper != null? this.helper.toJson():null,
  };

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