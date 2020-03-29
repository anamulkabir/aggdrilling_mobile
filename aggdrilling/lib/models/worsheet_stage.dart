import 'package:cloud_firestore/cloud_firestore.dart';
class WorkSheetStage{
  String name;
  List<String> nextStages;
  List<String> actions;
  WorkSheetStage(this.name);

  WorkSheetStage.fromDocumentSnapShot(DocumentSnapshot snapshot):
        name = snapshot.data["name"],
        nextStages = List.from(snapshot.data["nextStages"]),
        actions = List.from(snapshot.data["actions"]);
  WorkSheetStage.fromDs(Map<dynamic,dynamic> stage)
  {
    this.name = stage["name"];
    this.nextStages = List.from(stage["nextStages"]);
    this.actions = List.from(stage["actions"]);
  }
  static List<WorkSheetStage> fromDsList(List<dynamic> values){
    List<WorkSheetStage> stageList = values.map((entry) => WorkSheetStage.fromDs(entry)).toList();
    return stageList;
  }
}