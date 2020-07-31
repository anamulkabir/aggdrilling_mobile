import 'package:aggdrilling/utils/input_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Worker{
  String firstName;
  String lastName;
  String designation;
  String skills;
  String type;
  String workerId;
  String employeeId;
  Worker(this.firstName,this.lastName, this.designation);
  Worker.fromDocumentSnapShot(DocumentSnapshot snapshot)
  {
    this.firstName = snapshot.data["firstName"];
    this.lastName = snapshot.data["lastName"];
    this.designation = snapshot.data["designation"];
    this.workerId = snapshot.data["workerId"];
    this.employeeId = snapshot.data["employeeId"];
    this.type = snapshot.data["type"];
  }
  Worker.fromDs(Map<dynamic,dynamic> worker)
  {
      this.firstName = worker["firstName"];
      this.lastName = worker["lastName"];
      this.type = worker["type"];
      this.designation = worker["designation"];
      this.workerId = worker["workerId"];
      this.employeeId = worker["employeeId"];

  }
  static List<Worker> fromDsList(List<dynamic> workers){
    List<Worker> workerList = workers.map((entry) => Worker.fromDs(entry)).toList();
    return workerList;
  }
  Map<String, dynamic> toJson()=>{
    'firstName':this.firstName,
    'lastName': this.lastName,
    'type': this.type,
    'workerId':this.workerId,
    'employeeId':this.employeeId,
    'designation': this.designation
  };
}