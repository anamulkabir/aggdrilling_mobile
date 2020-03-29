
import 'package:cloud_firestore/cloud_firestore.dart';

class Geologist{
  String name;
  String phone;
  String address;
  String email;
  String contactPerson;
  bool isActive;
  Geologist(this.name,this.phone,this.address,this.email);
  Geologist.fromDocumentSnapShot(DocumentSnapshot snapshot){
    this.name = snapshot.data["name"];
    this.phone = snapshot.data["phone"];
    this.address = snapshot.data["address"];
    this.email = snapshot.data["email"];
    this.contactPerson = snapshot.data["contactPerson"];
    this.isActive = snapshot.data["isActive"];
  }
}