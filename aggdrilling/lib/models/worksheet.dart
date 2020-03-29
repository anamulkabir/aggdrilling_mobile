import 'package:aggdrilling/models/comments.dart';
import 'package:aggdrilling/models/rigs.dart';
import 'package:aggdrilling/models/holes.dart';
import 'package:aggdrilling/models/task_log.dart';
import 'package:aggdrilling/models/used_materials.dart';
import 'package:aggdrilling/models/worksheet_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkSheet{
  DateTime workDate;
  DateTime entryDate;
  String entryBy;
  Holes holes;
  Rigs rigs;
  List<TaskLog> taskLogs;
  List<Comments> comments;
  List<WorkSheetStatus> status;
  List<ConsumeMaterials> consumeMaterials;

  void Function(WorkSheet) callback;
  //
 final Queue queue = new Queue();
  WorkSheet(this.rigs,this.holes);
  WorkSheet.fromDocumentSnapShot(DocumentSnapshot snapshot) {
    final df= new DateFormat("yyyy-MM-dd hh:mm:ss a");
      try{
        this.status = snapshot.data["status"];
        this.entryBy = snapshot.data["entryBy"];
        this.workDate = DateTime.parse(snapshot.data["workDate"]);
        this.entryDate = df.parse(snapshot.data["entryDate"]);
        this.rigs = Rigs.fromDs(snapshot.data["rigs"]);
        this.holes = Holes.fromDs(snapshot.data["holes"]);
      }catch(error){
        error.toString();
      }

  }
  loadAllDs(DocumentSnapshot snapshot,{ @required Function onComplete,
    @required Function onError,
  }){
    queue.add(data_to_load.STATUS);
    queue.add(data_to_load.USEDMATERIALS);
    queue.add(data_to_load.COMMENTS);
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
    if(value == data_to_load.STATUS) {
      queue.removeFirst();
      snapshot.reference.collection("status").getDocuments().then((QuerySnapshot querySnapShot){
        this.status = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.status.add(WorkSheetStatus.fromDocumentSnapshot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.USEDMATERIALS){
      queue.removeFirst();
      snapshot.reference.collection("usedMaterials").getDocuments().then((QuerySnapshot querySnapShot){
        this.consumeMaterials = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.consumeMaterials.add(ConsumeMaterials.fromDocumentSnapshot(document));
        }
        _getAllProjectCollection(snapshot);
      });
    }
    else if(value == data_to_load.COMMENTS){
      queue.removeFirst();
      snapshot.reference.collection("comments").getDocuments().then((QuerySnapshot querySnapShot){
        this.comments = new List();
        for(DocumentSnapshot document in querySnapShot.documents){
          this.comments.add((Comments.fromDocumentSnapshot(document)));
        }
        _getAllProjectCollection(snapshot);
      });
    }
  }

}
enum data_to_load{
  COMMENTS,
  STATUS,
  USEDMATERIALS
}




