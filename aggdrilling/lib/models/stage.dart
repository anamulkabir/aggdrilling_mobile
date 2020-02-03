import 'package:firebase_database/firebase_database.dart';
class Stage{
  String name;
  List<String> nextStages;
  List<String> actions;
  Stage(this.name);
  Stage.fromSnapShot(DataSnapshot snapshot):
        name = snapshot.value["name"],
        nextStages = snapshot.value["nextSteps"],
        actions = snapshot.value["actions"];
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