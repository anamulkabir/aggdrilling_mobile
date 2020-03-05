import 'package:cloud_firestore/cloud_firestore.dart';
class Stage{
  String name;
  List<String> nextStages;
  List<String> actions;
  Stage(this.name);
  Stage.fromSnapShot(DocumentSnapshot snapshot):
        name = snapshot.data["name"],
        nextStages = snapshot.data["nextSteps"],
        actions = snapshot.data["actions"];
  Stage.fromDs(Map<dynamic,dynamic> stage)
  {
    this.name = stage["name"];
    this.nextStages = List.from(stage["nextSteps"]);
    this.actions = List.from(stage["actions"]);
  }
  static List<Stage> fromDsList(List<dynamic> stages){
    List<Stage> stageList = stages.map((entry) => Stage.fromDs(entry)).toList();
    return stageList;
  }
}