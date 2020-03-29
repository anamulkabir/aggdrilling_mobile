
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonFunction{
static String getStatusDesc(String status){
  if(status.isEmpty){
    return "Operator";
  }
  switch(status){
    case "enableOp":
      return "Operator";
    case "enableHq":
      return "Head Office";
    case "enableGo":
      return "Geologist";
    case "approved":
      return "approved";
    default:
      return "Operator";
  }
}
static Color getStatusByColor(String status){
  if(status.isEmpty){
    return Colors.blueGrey;
  }
  switch(status){
    case "enableOp":
      return Colors.blueGrey;
    case "enableHq":
      return Colors.amberAccent;
    case "enableGo":
      return Colors.blueAccent;
    case "approved":
      return Colors.lightGreen;
    default:
      return Colors.blueGrey;
  }
}
}