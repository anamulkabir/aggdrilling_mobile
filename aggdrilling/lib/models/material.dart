import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialItems{
  String name;
  String description;
  String group;
  String unit;
  String unitPrice;
  MaterialItems(this.name,this.description);
  MaterialItems.fromDs(Map<dynamic,dynamic> ds){
    this.name = ds["name"];
    this.description = ds["description"];
  }
  MaterialItems.fromDocument(DocumentSnapshot snapshot){

      this.name = snapshot.data["name"];
      this.description = snapshot.data["description"];
      this.group = snapshot.data["group"];
      this.unit = snapshot.data["unit"];
  }
  Map<String, dynamic> toJson()=>{
    'name': this.name,
    'decription': this.description,
    'group': this.group,
    'unit': this.unit
  };
}