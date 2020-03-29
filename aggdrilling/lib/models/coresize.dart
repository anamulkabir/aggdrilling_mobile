
import 'package:cloud_firestore/cloud_firestore.dart';

class CoreSize{
  String core;
  String size;
  String hole;
  CoreSize(this.core, this.size, this.hole);
  CoreSize.fromDocumentSnapshot(DocumentSnapshot snapshot){
    try {
      this.core = snapshot.data["core"].toString();
      this.size = snapshot.data["size"];
      this.hole = snapshot.data["hole"].toString();
    }catch(error){
      throw error;
    }

  }

}