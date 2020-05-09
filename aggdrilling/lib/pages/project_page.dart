import 'package:aggdrilling/models/project.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/models/worksheet.dart';
import 'package:aggdrilling/pages/worksheet.dart';
import 'package:aggdrilling/utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProjectPage extends StatefulWidget{
  ProjectPage({this.mProject,this.loginUser});
  final Project mProject;
  final User loginUser;
  @override
  State<StatefulWidget> createState() => _ProjectPageState();
}
class _ProjectPageState extends State<ProjectPage>{
  bool _isLoading;
  final  _dbReference = Firestore.instance.collection('projects');
  @override
  void initState() {
    super.initState();
    if(widget.mProject != null){
      _isLoading = true;
      loadProjectDetail();
    }
    else {
        _isLoading = false;
      }
  }
  loadProjectDetail() async{
    _dbReference.document(widget.mProject.docId).get().then((DocumentSnapshot snapshot){
      widget.mProject.loadAllDs(snapshot, onComplete: (value)=>{
        widget.mProject.worksheet.sort((a,b){
         return b.workDate.compareTo(a.workDate);
        }),
        setState(() {
          _isLoading = false;
        })
      }, onError: (error)=>{
        setState(() {
          _isLoading = false;
        }),
        _showDialog(error),
      });
    });

  }
  _showDialog(String error) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Data Error"),
          content: new Text(error),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        IconButton(
          icon: Icon(Icons.add),
          onPressed: (){
            _worksheetUINavigator();
          },
        ),
        ],
      ),
      body: showWorkSheetList(),
    );
  }
  _worksheetUINavigator() async {

    String rsCb= await  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context){
         return WorkSheetPage(mWorkSheet:null ,mProject: widget.mProject,mUser: widget.loginUser,);
        },
      ),
    );
    if(rsCb !=null && rsCb.contains("reload")){
      _isLoading = true;
      loadProjectDetail();
    }
}
_selectedWorksheetUINavigator(WorkSheet workSheet,) async{
  String result= await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WorkSheetPage(mWorkSheet:workSheet ,
        mProject: widget.mProject,
        mUser: widget.loginUser,
      ),
    ),
  );
  if(result.contains("reload")){
    _isLoading = true;
    loadProjectDetail();
  }
}
  Widget showWorkSheetList() {
    if(_isLoading)
      return _showCircularProgress();
    if (widget.mProject.worksheet !=null && widget.mProject.worksheet.length>0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: widget.mProject.worksheet.length,
          itemBuilder: (BuildContext context, int index) {
            String statusDesc=widget.loginUser.appSettings.getStageDetails(widget.mProject.worksheet[index].currentStatus);
            var statusColor=CommonFunction.getStatusByColor(widget.mProject.worksheet[index].currentStatus);
            if(widget.mProject.worksheet[index].status!=null &&
                widget.mProject.worksheet[index].status.length>0) {
              widget.mProject.worksheet[index].status.sort((a, b) {
                return b.entryDate.compareTo(a.entryDate);
              });
            }

            return Card(
              elevation: 0.0,
              child: ListTile(
                title: Text(DateFormat("yyyy-MM-dd").format(widget.mProject.worksheet[index].workDate)),
                subtitle:Padding(
                  padding: EdgeInsets.fromLTRB(0,5,0,5),
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(text: "R:", style: TextStyle(fontSize:15.0,color: Colors.deepPurple )),
                        TextSpan(text:" "+ widget.mProject.worksheet[index].rigs.serial,),
                        TextSpan(text: widget.mProject.worksheet[index].holes !=null?" H:":"",
                            style: TextStyle(fontSize:15.0,color: Colors.indigo )),
                        TextSpan(text: widget.mProject.worksheet[index].holes !=null?widget.mProject.worksheet[index].holes:"",),
                      ]
                    ,
                  ),
                  ),
                ) ,
                trailing: Wrap(
                  spacing: 12, // space between two icons
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10,0,10),
                      child: Text(""+(statusDesc !=null?statusDesc:""),
                          style: TextStyle(fontSize: 17.0, color: statusColor)),
                    ),

                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_right),
                      onPressed: (){
                      _selectedWorksheetUINavigator(widget.mProject.worksheet[index]);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
            "No worksheet found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

}