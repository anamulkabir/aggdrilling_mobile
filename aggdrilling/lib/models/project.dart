import 'package:firebase_database/firebase_database.dart';

class Project{
  String key;
  String projectCode;
  String projectName;
  DateTime startDate;
  DateTime entryDate;
  DateTime endDate;
  String enteredBy;
  String userId;
  String status;
  List<String> actions;
//  List<CoreSize> coreSizes;
//  List<Stage> projectStages;
  Project(this.projectCode,this.projectName,this.userId);
  Project.fromSnapshot(DataSnapshot snapshot):
        userId = snapshot.value["userId"],
        projectCode = snapshot.value["projectCode"],
        projectName = snapshot.value["projectName"],
        startDate = DateTime.parse(snapshot.value["startDate"]),
        actions = snapshot.value["actions"]==null?null: List.from(snapshot.value["actions"]),
        status = snapshot.value["status"];

//        coreSizes = CoreSize.fromDsList(snapshot.value["coreSizes"]),
//        projectStages = Stage.fromDsList(snapshot.value["projectSteps"]);
}



