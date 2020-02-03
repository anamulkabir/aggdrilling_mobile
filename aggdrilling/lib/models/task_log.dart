
import 'package:aggdrilling/models/task.dart';

class TaskLog{
  String empName;
  Task task;
  String startTime;
  String endTime;
  double startMeter;
  double endMeter;
  String hole;
  String shift;
  double workHours;
  TaskLog.fromDs(Map<dynamic,dynamic> ds){
    this.task = ds["taskName"];// find the task from the meta data
    Type taskType = this.task.type;
    if(taskType!=Type.HoursOnly || taskType !=Type.None)
      {
        this.empName = ds["empName"];
      }

    this.startTime = ds["startTime"];
    this.endTime = ds["endTime"];
    this.workHours = ds["workHours"];
    if(taskType == Type.EmpHoursWithMeasure){
      this.startMeter = ds["startMeter"];
      this.endMeter = ds["endMeter"];
      this.hole = ds["hole"];
    }
    this.shift = ds["shift"];

  }
  static List<TaskLog> fromDsList(List<dynamic> sizes)
  {
    List<TaskLog> taskLogList = sizes.map((entry) => TaskLog.fromDs(entry)).toList();
    return taskLogList;
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