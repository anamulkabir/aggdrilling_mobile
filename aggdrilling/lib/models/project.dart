import 'package:aggdrilling/models/coresize.dart';
import 'package:aggdrilling/models/geologist.dart';
import 'package:aggdrilling/models/material.dart';
import 'package:aggdrilling/models/task.dart';
import 'package:aggdrilling/models/rigs.dart';
import 'package:aggdrilling/models/holes.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/models/worker.dart';
import 'package:aggdrilling/models/worksheet.dart';
import 'package:aggdrilling/models/worsheet_stage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:collection';

class Project{
  String docId;
  String projectCode;
  String projectName;
  DateTime startDate;
  DateTime entryDate;
  User entryBy;
  String status;
  //
  List<WorkSheetStage> workSheetStages;
  List<CoreSize> coreSizes;
  List<Rigs> rigs;
  List<Geologist> geologists;
  List<Holes> holes;
  List<Task> tasks;
  List<MaterialItems> materials;
  List<Worker> workers;
  List<WorkSheet> worksheet;

  void Function(Project) callback;
  //
 final Queue queue = new Queue();
  Project(this.projectCode,this.projectName);
  Project.fromDs(Map<dynamic,dynamic> ds){
    this.projectCode = ds["projectCode"];
    this.projectName = ds["projectName"];
    try{
      this.startDate = DateTime.parse(ds["startDate"]);
      this.entryDate = DateTime.parse(ds["entryDate"]);
      this.entryBy =  User.fromDs(ds["entryBy"]);
      this.status = ds["status"];
    }catch(error){
      error.toString();
    }
  }
  Project.fromSnapshot(DocumentSnapshot snapshot) {
      this.docId = snapshot.documentID;
      this.projectCode = snapshot.data["projectCode"];
      this.projectName = snapshot.data["projectName"];
      try{
        this.startDate = DateTime.parse(snapshot.data["startDate"]);
        this.entryDate = DateTime.parse(snapshot.data["entryDate"]);
        this.entryBy =  User.fromDs(snapshot.data["entryBy"]);
        this.status = snapshot.data["status"];
      }catch(error){
        error.toString();
      }

  }
  loadAllDs(DocumentSnapshot snapshot,{ @required Function onComplete,
    @required Function onError,
  }){
    queue.add(data_to_load.MATERIALS);
    queue.add(data_to_load.CORE_SIZES);
    queue.add(data_to_load.RIGS);
    queue.add(data_to_load.HOLES);
    queue.add(data_to_load.WORKSHEET_STAGES);
    queue.add(data_to_load.TASKS);
    queue.add(data_to_load.GEOLOGISTS);
    queue.add(data_to_load.WORKERS);
    queue.add(data_to_load.WORKSHEETS);
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
    if(value == data_to_load.MATERIALS) {
      queue.removeFirst();
      snapshot.reference.collection("materials").getDocuments().then((QuerySnapshot querySnapShot){
        this.materials = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.materials.add(MaterialItems.fromDocument(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.CORE_SIZES){
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
    else if(value == data_to_load.HOLES){
      queue.removeFirst();
      snapshot.reference.collection("holes").getDocuments().then((QuerySnapshot querySnapShot){
        this.holes = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.holes.add(Holes.fromDocumentSnapShot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.WORKSHEET_STAGES){
      queue.removeFirst();
      snapshot.reference.collection("workSheetStages").getDocuments().then((QuerySnapshot querySnapShot){
        this.workSheetStages = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.workSheetStages.add(WorkSheetStage.fromDocumentSnapShot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.TASKS){
      queue.removeFirst();
      snapshot.reference.collection("tasks").getDocuments().then((QuerySnapshot querySnapShot){
        this.tasks = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.tasks.add(Task.fromDocumentSnapShot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.GEOLOGISTS){
      queue.removeFirst();
      snapshot.reference.collection("geologists").getDocuments().then((QuerySnapshot querySnapShot){
        this.geologists = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.geologists.add(Geologist.fromDocumentSnapShot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.WORKERS){
      queue.removeFirst();
      snapshot.reference.collection("workers").getDocuments().then((QuerySnapshot querySnapShot){
        this.workers = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.workers.add(Worker.fromDocumentSnapShot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.WORKSHEETS){
      queue.removeFirst();
      snapshot.reference.collection("worksheet").getDocuments().then((QuerySnapshot querySnapShot){
        this.worksheet = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.worksheet.add(WorkSheet.fromDocumentSnapShot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
  }
}
enum data_to_load{
  MATERIALS,
  CORE_SIZES,
  RIGS,
  HOLES,
  WORKSHEET_STAGES,
  TASKS,
  GEOLOGISTS,
  WORKERS,
  WORKSHEETS

}




