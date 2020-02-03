import 'package:aggdrilling/models/project.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget{
  ProjectPage({this.mProject,this.loginUser});
  final Project mProject;
  final User loginUser;
  @override
  State<StatefulWidget> createState() => _ProjectPageState();
}
class _ProjectPageState extends State<ProjectPage>{
  Query _query;
  bool _isLoading;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  @override
  void initState() {
    super.initState();
    if(widget.mProject != null){
      _isLoading = false;
    }
  }
  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.mProject.projectName),
        actions: <Widget>[

        ],
      ),
      body: showWorkSheetList(),
    );
  }
  Widget showWorkSheetList() {
    if(_isLoading)
      return _showCircularProgress();
    if (widget.mProject.projectCode.length>0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 0.0,
              child: ListTile(
                title: Text(widget.mProject.projectCode),
                subtitle: Text(widget.mProject.projectName),
                trailing: IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: (){
                    return SnackBar(
                      content: Text(widget.mProject.projectName),
                    );
                  },
                ),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
            "Welcome. No project found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

}