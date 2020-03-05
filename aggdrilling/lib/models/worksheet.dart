import 'package:aggdrilling/models/coresize.dart';
import 'package:aggdrilling/models/geologist.dart';
import 'package:aggdrilling/models/material.dart';
import 'package:aggdrilling/models/task.dart';
import 'package:aggdrilling/models/rigs.dart';
import 'package:aggdrilling/models/holes.dart';
import 'package:aggdrilling/models/worker.dart';
import 'package:aggdrilling/models/worsheet_stage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:collection';

class Project{
  String projectCode;
  String projectName;
  DateTime startDate;
  DateTime entryDate;
  String entryBy;
  String status;
  //
  List<WorkSheetStage> workSheetStages;
  List<CoreSize> coreSizes;
  List<Rigs> rigs;
  List<Geologist> geologists;
  List<Holes> holes;
  List<Task> tasks;
  List<Material> materials;
  List<Worker> workers;

  void Function(Project) callback;
  //
 final Queue queue = new Queue();
  Project(this.projectCode,this.projectName);
  Project.fromSnapshot(DocumentSnapshot snapshot) {

      this.projectCode = snapshot.data["projectCode"];
      this.projectName = snapshot.data["projectName"];
      try{
        this.startDate = DateTime.parse(snapshot.data["startDate"]);
        this.entryDate = DateTime.parse(snapshot.data["entryDate"]);
        this.entryBy =  snapshot.data["entryBy"];
        this.status = snapshot.data["status"];
      }catch(error){
        error.toString();
      }

  }
  loadAllDs(DocumentSnapshot snapshot,{ @required Function onComplete,
    @required Function onError,
  }){
    queue.add(data_to_load.MATERIAL);
    queue.add(data_to_load.CORE_SIZE);
    queue.add(data_to_load.RIGS);
    this.callback = onComplete;
    try{
      _getAllProjectCollection(snapshot);
    }
    catch(error){
      onError(error);
    }

  }
  _getAllProjectCollection(DocumentSnapshot snapshot){
    if(queue.isEmpty)
      return this.callback(this);
    var value = queue.first;
    if(value == data_to_load.MATERIAL) {
      queue.removeFirst();
      snapshot.reference.collection("materials").getDocuments().then((QuerySnapshot querySnapShot){
        this.materials = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.materials.add(Material.fromDocument(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.CORE_SIZE){
      queue.removeFirst();
      snapshot.reference.collection("coreSizes").getDocuments().then((QuerySnapshot querySnapShot){
        this.coreSizes = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.coreSizes.add(CoreSize.fromDocumentSnapshot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.RIGS){
      queue.removeFirst();
      snapshot.reference.collection("rigs").getDocuments().then((QuerySnapshot querySnapShot){
        this.rigs = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.rigs.add((Rigs.fromDocumentSnapshot(document)));
        }
        _getAllProjectCollection(snapshot);
      });
    }
  }
  getAllMaterialsFromSnapshot(DocumentSnapshot snapshot){
    List<Material> materials = new List();
    snapshot.reference.collection("materials").getDocuments().then((QuerySnapshot querySnapShot){
      for(DocumentSnapshot document in querySnapShot.documents)
      {
        materials.add(Material.fromDocument(document));
      }
    });

  }
  getAllCoreSizeFromSnapshot(DocumentSnapshot snapshot){
    List<CoreSize> coreSizes = new List();
    snapshot.reference.collection("coreSizes").getDocuments().then((QuerySnapshot querySnapshot){
      for(DocumentSnapshot document in querySnapshot.documents)
        {
          coreSizes.add(CoreSize.fromDocumentSnapshot(document));
        }

    });

  }
}
enum data_to_load{
  MATERIAL,
  CORE_SIZE,
  RIGS
}




