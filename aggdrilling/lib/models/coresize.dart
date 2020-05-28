
import 'package:cloud_firestore/cloud_firestore.dart';

class CoreSize{
  String core;
  CoreSize(this.core);
  CoreSize.fromDocumentSnapshot(DocumentSnapshot snapshot){
    try {
      this.core = snapshot.data["core"].toString();
    }catch(error){
      throw error;
    }
  }
  CoreSize.fromDS(Map<dynamic,dynamic> ds){
    this.core = ds["core"];
  }
  Map<String, dynamic> toJson()=>{
    'core': this.core,
  };

}