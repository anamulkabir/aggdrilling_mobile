import 'package:firebase_database/firebase_database.dart';
class Worker{
  String name;
  String designation;
  String type;
  Worker(this.name,this.designation);
  Worker.fromSnapShot(DataSnapshot snapshot)
  {
    this.name = snapshot.value["name"];
    this.designation = snapshot.value["designation"];
  }
  Worker.fromDs(Map<dynamic,dynamic> worker)
  {
    this.name  = worker["name"];
    this.designation = worker["designation"];
  }
  static List<Worker> fromDsList(List<dynamic> workers){
    List<Worker> workerList = workers.map((entry) => Worker.fromDs(entry)).toList();
    return workerList;
  }
}