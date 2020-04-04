
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonFunction{
static String getStatusDesc(String status){
  if(status ==null || status.isEmpty){
    return "Operator";
  }
  switch(status.toLowerCase()){
    case "enableop":
      return "Operator";
    case "enablehq":
      return "Head Office";
    case "enablego":
      return "Geologist";
    case "approved":
      return "approved";
    default:
      return "Operator";
  }
}
static Color getStatusByColor(String status){
  if(status == null || status.isEmpty){
    return Colors.blueGrey;
  }
  switch(status.toLowerCase()){
    case "enableop":
      return Colors.blueGrey;
    case "enablehq":
      return Colors.amberAccent;
    case "enablego":
      return Colors.blueAccent;
    case "approved":
      return Colors.lightGreen;
    default:
      return Colors.blueGrey;
  }
}
static List<String> getAllSiftWorkHours(){
  List<String> shiftHours = new List();
  int initialHOur=6;
  bool isAm=true;
  for(int i=0;i<24;i++){
    if(initialHOur==12){
      isAm=!isAm;

    }
    shiftHours.add(""+initialHOur.toString()+":00 "+ (isAm==true?"AM":"PM"));
    shiftHours.add(""+initialHOur.toString()+":30 "+ (isAm==true?"AM":"PM"));
    initialHOur++;
    if(initialHOur>12){
      initialHOur = initialHOur-12;
    }
  }
  return shiftHours;
}
}