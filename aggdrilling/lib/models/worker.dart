import 'package:cloud_firestore/cloud_firestore.dart';
class Worker{
  String firstName;
  String middleName;
  String lastName;
  String designation;
  String skills;
  String type;
  Worker(this.firstName,this.middleName, this.lastName, this.designation);
  Worker.fromDocumentSnapShot(DocumentSnapshot snapshot)
  {
    this.firstName = snapshot.data["firstName"];
    this.middleName = snapshot.data["middleName"];
    this.lastName = snapshot.data["lastName"];
    this.designation = snapshot.data["designation"];
    this.type = snapshot.data["type"];
  }
  Worker.fromDs(Map<dynamic,dynamic> worker)
  {
    this.firstName  = worker["firstName"];
    this.middleName  = worker["middleName"];
    this.lastName  = worker["lastName"];
    this.type  = worker["type"];
    this.designation = worker["designation"];
  }
  static List<Worker> fromDsList(List<dynamic> workers){
    List<Worker> workerList = workers.map((entry) => Worker.fromDs(entry)).toList();
    return workerList;
  }
  Map<String, dynamic> toJson()=>{
    'firstName':this.firstName,
    'middleName': this.middleName,
    'lastName': this.lastName,
    'type': this.type,
    'designation': this.designation
  };
}