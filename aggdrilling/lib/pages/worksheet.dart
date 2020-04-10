import 'package:aggdrilling/models/comments.dart';
import 'package:aggdrilling/models/coresize.dart';
import 'package:aggdrilling/models/holes.dart';
import 'package:aggdrilling/models/material.dart';
import 'package:aggdrilling/models/project.dart';
import 'package:aggdrilling/models/rigs.dart';
import 'package:aggdrilling/models/task.dart';
import 'package:aggdrilling/models/task_log.dart';
import 'package:aggdrilling/models/used_materials.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/models/worker.dart';
import 'package:aggdrilling/models/worksheet.dart';
import 'package:aggdrilling/models/worksheet_status.dart';
import 'package:aggdrilling/models/worsheet_stage.dart';
import 'package:aggdrilling/utils/common_functions.dart';
import 'package:aggdrilling/utils/input_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class WorkSheetPage extends StatefulWidget{
  WorkSheetPage({this.mWorkSheet,this.mProject,this.mUser});
  WorkSheet mWorkSheet;
  final Project mProject;
  final User mUser;
  @override
  State<StatefulWidget> createState() {
    return new _WorkSheetPageState();
  }
}
class _WorkSheetPageState extends State<WorkSheetPage>{
  bool _isLoading;
  final format = DateFormat("yyyy-MM-dd");
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm a");
  final timeFormat = DateFormat("hh:mm a");
  final _dbReference = Firestore.instance.collection('projects');
  Rigs _selectedRigs;
  Holes _selectedHoles;
  Worker _selectedWorker;
  Task _selectedTask;
  CoreSize _selectedCoreSize;
  MaterialItems _selectedMaterial;
  ConsumeMaterials _selectedUsedMaterial;
  double _startMeter;
  double _endMeter;
  String _selectedNote;
  List<TaskLog> _taskLogs = new List();
  List<ConsumeMaterials> _consumeMaterials = new List();
  List<Comments> _comments;
  Comments _selectedComments;
  List<String> _nextStages = new List();
  WorkSheetStage _worksheetStages;
  WorkSheetStatus _currentWorkSheetStatus;
  WorkSheetStatus _selectedWorkSheetStatus;
  String _selectedStatus;
  AutoCompleteTextField<Rigs> ddlRigs;
  AutoCompleteTextField<Holes> ddlHoles;
  AutoCompleteTextField<Task> ddlTasks;
  AutoCompleteTextField<CoreSize> ddlCoreSize;
  AutoCompleteTextField<Worker> ddlWorker;
  AutoCompleteTextField<MaterialItems> ddlMaterials;
  AutoCompleteTextField<String> ddlNextStages;
  GlobalKey keyRigs = new GlobalKey<AutoCompleteTextFieldState<Rigs>>();
  GlobalKey keyHoles = new GlobalKey<AutoCompleteTextFieldState<Holes>>();
  GlobalKey keyWorker = new GlobalKey<AutoCompleteTextFieldState<Worker>>();
  GlobalKey keyCoreSize = new GlobalKey<AutoCompleteTextFieldState<CoreSize>>();
  GlobalKey keyTasks = new GlobalKey<AutoCompleteTextFieldState<Task>>();
  GlobalKey keyMaterialItems = new GlobalKey<AutoCompleteTextFieldState<MaterialItems>>();
  GlobalKey keyNextStages = new GlobalKey<AutoCompleteTextFieldState<String>>();
  final DateTimeWrapper _workDate = new DateTimeWrapper(dateTime:DateTime.now());
  String _startTime;
  String _endTime;
  bool taskLogAddNew = true;
  bool addNewMaterial = true;
  bool addNewRemark = true;
  bool worksheetUpdate = false;
  bool hasPermitStatus = false;
  bool hasSubmitStatus = false;
  int taskIndexForUpdate = -1;
  int usedMaterialIndexForUpdate = -1;
  final rigController = new TextEditingController();
  final holeController = new TextEditingController();
  final taskController = new TextEditingController();
  final workerController = new TextEditingController();
  final noteController = new TextEditingController();
  final startMController = new TextEditingController();
  final endMController = new TextEditingController();
  final coreSizeController = new TextEditingController();
  final materialItemController = new TextEditingController();
  final materialQtyController = new TextEditingController();
  final commentController = new TextEditingController();
  final nextStagesController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTime ="7:00 AM";
    _endTime = "7:00 AM";
    if(widget.mWorkSheet != null){
      _isLoading = true;
      loadWorksheetDetail();
    }
    else {
      loadUI();
      _isLoading = false;
    }

  }
  loadWorksheetDetail() async{
    _dbReference.document(widget.mProject.docId).collection("worksheet").
    document(widget.mWorkSheet.docId).get().then((DocumentSnapshot snapshot){
      widget.mWorkSheet.loadAllDs(snapshot, onComplete: (value)=>{
      setState((){
        _isLoading = false;
        loadUI();
      })
      }, onError: (error)=>{
        setState(() {
          _isLoading = false;
        }),
        _showDialog(error),
      });
    });
  }
  loadUI(){
    ddlRigs = new AutoCompleteTextField<Rigs>(
        decoration: new InputDecoration(
          labelText: 'Rigs',
          hintText: 'Select Rigs',
        ),
        itemSubmitted: (item) {
          setState(() {
            _selectedRigs = item;
            rigController.text=_selectedRigs.serial;
            worksheetUpdate = true;
          });
        },
        key: keyRigs,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.rigs,
        itemBuilder: (context,suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.serial,
            ),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: rigController,
        itemSorter: (a, b) => a.serial.compareTo(b.serial),
        itemFilter: (suggestion,input) =>
            suggestion.serial.toLowerCase().startsWith(input.toLowerCase())
    );
    ddlHoles = new AutoCompleteTextField<Holes>(
        decoration: new InputDecoration(
          labelText: 'Holes',
          hintText: 'Select Holes',
        ),
        itemSubmitted: (item) {
          setState(() {
            _selectedHoles = item;
            holeController.text=_selectedHoles.name;
            worksheetUpdate = true;
          });
        },
        key: keyHoles,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.holes,
        itemBuilder: (context,suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.name,
            ),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: holeController,
        itemSorter: (a, b) => a.name.compareTo(b.name),
        itemFilter: (suggestion,input) =>
            suggestion.name.toLowerCase().startsWith(input.toLowerCase())
    );
    ddlTasks = new AutoCompleteTextField<Task>(
      decoration: new InputDecoration(
        labelText: 'Tasks',
        hintText: 'Select Task',
      ),
      itemSubmitted: (item) {
        setState(() {
          _selectedTask = item;
          taskController.text=_selectedTask.name;
        });
      },
      key: keyTasks,
      clearOnSubmit: false,
      minLength: 0,
      suggestions: widget.mProject.tasks,
      itemBuilder: (context,suggestion) => new Padding(
        child: new ListTile(
          title: new Text(suggestion.name),
        ),
        padding: EdgeInsets.all(0.0),
      ),
      controller: taskController,
      itemSorter: (a, b) => a.name.compareTo(b.name),
      itemFilter: (suggestion,input) =>
          suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
    );
    ddlWorker = new AutoCompleteTextField<Worker>(
        decoration: new InputDecoration(
          labelText: 'Worker',
          hintText: 'Select Employee',
        ),
        itemSubmitted: (item) {
          setState(() {
            _selectedWorker = item;
            workerController.text=_selectedWorker.lastName+' '+_selectedWorker.firstName;
//            worksheetUpdate = true;
          });
        },
        key: keyWorker,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.workers,
        itemBuilder: (context,suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.lastName +' '+ suggestion.firstName+'-'+suggestion.designation.substring(0,1).toUpperCase()),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: workerController,
        itemSorter: (a, b) => a.lastName.compareTo(b.lastName),
        itemFilter: (suggestion,input) =>
            suggestion.lastName.toLowerCase().startsWith(input.toLowerCase())
    );
    ddlCoreSize = new AutoCompleteTextField<CoreSize>(
      decoration: new InputDecoration(
        labelText: 'CoreSize',
        hintText: 'Select CoreSize',
      ),
      itemSubmitted: (item) {
        setState(() {
          _selectedCoreSize = item;
          coreSizeController.text=_selectedCoreSize.core;
//          worksheetUpdate = true;
        });
      },
      key: keyCoreSize,
      clearOnSubmit: false,
      minLength: 0,
      suggestions: widget.mProject.coreSizes,
      itemBuilder: (context,suggestion) => new Padding(
        child: new ListTile(
          title: new Text(suggestion.core,
          ),
        ),
        padding: EdgeInsets.all(8.0),
      ),
      controller: coreSizeController,
      itemSorter: (a, b) => a.core.compareTo(b.core),
      itemFilter: (suggestion,input) =>
          suggestion.core.toLowerCase().startsWith(input.toLowerCase()),
    );
    ddlMaterials = new AutoCompleteTextField<MaterialItems>(
      decoration: new InputDecoration(
          labelText: 'Used Material',
          hintText: 'Select Used materials'
      ),
      itemSubmitted: (item){
        setState(() {
          _selectedMaterial = item;
          materialItemController.text = _selectedMaterial.name;
        });
      },
      key: keyMaterialItems,
      clearOnSubmit: false,
      minLength: 0,
      suggestions: widget.mProject.materials,
      itemBuilder: (context,suggestion)=> new Padding(
          child: new ListTile(
            title: new Text(suggestion.name),
          ),
          padding: EdgeInsets.all(8.0)),
      controller: materialItemController,
      itemSorter: (a, b)=>a.name.compareTo(b.name),
      itemFilter: (suggestion, input) =>
          suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
    );
    _isLoading = false;
    if(widget.mWorkSheet !=null) {
      loadWorkSheet(widget.mWorkSheet);
    }
    loadProjectPermitStatus();
    checkPermitStatus();
  }

  void loadWorkSheet(WorkSheet workSheet){
      _workDate.dateTime = workSheet.workDate;
      _selectedRigs = workSheet.rigs;
      rigController.text = _selectedRigs.serial;
      _selectedHoles = workSheet.holes;
      holeController.text = _selectedHoles!=null?_selectedHoles.name:'';
      _taskLogs = workSheet.taskLogs;
      _consumeMaterials = workSheet.consumeMaterials;
      _comments = workSheet.comments;
  }
  void loadProjectPermitStatus(){
    if(widget.mWorkSheet == null){
      _currentWorkSheetStatus = getCurrentStatus(null);
    }
    else
      {
        _currentWorkSheetStatus = getCurrentStatus(widget.mWorkSheet.status);
      }
    _worksheetStages = getWorkSheetStagesFromList(widget.mProject.workSheetStages,_currentWorkSheetStatus);
    if(_worksheetStages !=null){
    _nextStages.addAll(_worksheetStages.nextStages);
    }
    ddlNextStages = new AutoCompleteTextField<String>(
      decoration: new InputDecoration(
          labelText: 'Submit To',
          hintText: 'Submit To'
      ),
      itemSubmitted: (item){
        setState(() {
          _selectedStatus = item;
          nextStagesController.text = widget.mUser.appSettings.getStageDetails(_selectedStatus);
        });
      },
      onFocusChanged: (hasFocus){},
      clearOnSubmit: false,
      minLength: 0,
      suggestions: _nextStages,
      itemBuilder: (context,suggestion)=> new Padding(
          child: new ListTile(
            title: new Text(widget.mUser.appSettings.getStageDetails(suggestion) ),
          ),
          padding: EdgeInsets.all(8.0)),
      controller: nextStagesController,
      itemSorter: (a, b)=>a.compareTo(b),
      itemFilter: (suggestion, input) =>
          suggestion.toLowerCase().startsWith(input.toLowerCase()),
    );
  }
  void checkPermitStatus(){
    PermitProjects permitProjects = widget.mUser.getUserPermitProjectByCode(widget.mProject.projectCode);
    if(permitProjects != null && permitProjects.permitSteps!=null
    && permitProjects.permitSteps.indexOf(_currentWorkSheetStatus.status)>=0 ){
      for(WorkSheetStage workSheetStage in widget.mProject.workSheetStages){
        if(workSheetStage.name.toLowerCase().contains(_currentWorkSheetStatus.status.toLowerCase())){
          if(workSheetStage.actions.indexOf("add")>=0 ||
              workSheetStage.actions.indexOf("update")>=0){
            setState(() {
              hasPermitStatus = true;
            });
          }
          if(workSheetStage.actions.indexOf("submit")>=0){
            hasSubmitStatus = true;
          }

        }
      }
    }
  }
  WorkSheetStatus getCurrentStatus(List<WorkSheetStatus> status)
  {
    WorkSheetStatus workSheetStatus;
    if(status == null || status.length==0) {
      workSheetStatus = new WorkSheetStatus('enableOP');
    }
    else{
      status.sort((a, b){
       return b.entryDate.compareTo(a.entryDate);
      });
      workSheetStatus = status[0];
    }
    return workSheetStatus;
  }
  WorkSheetStage getWorkSheetStagesFromList(List<WorkSheetStage> stages,  WorkSheetStatus status){
    for(WorkSheetStage workSheetStage in stages){
      if(workSheetStage.name.toLowerCase().contains(status.status.toLowerCase()))
        return workSheetStage;
    }
    return null;
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
    return new DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: new AppBar(
            title: Text(widget.mProject.projectName),
              actions: <Widget>[
                if(hasPermitStatus && worksheetUpdate)
                  new Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                    child: IconButton(icon: Icon(Icons.done),
                        onPressed: saveWorkSheet),
                  ),

              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: choices.map((TabMenu choice) {
                  return Tab(
                    text: choice.title,
                  );
                }).toList(),
              ),

          ),
          body: TabBarView(
                children: choices.map((TabMenu choice) {
                switch(choice.shortName){
                  case 'task':
                    return loadTasksForm();
                  case 'material':
                    return loadMaterialForm();
                  case 'remark':
                    return loadCommentForm();
                  default:
                    return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ChoiceCard(choice: choice),
                          );
                }
                }).toList(),
          ),

      ),

    );

  }
  Widget loadTasksForm(){
    if(_isLoading) {
      return _showCircularProgress();
    }
    return Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 5, 5, 0),
                child: new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Work Date',
                    labelText: 'Work Date',
                  ),
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    callDatePicker(_workDate);
                  },
                  controller:  TextEditingController(text: format.format(_workDate.dateTime)),

                ),
              ),
            ),
            new Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
                  child:  ddlRigs,
                  ),
            ),
            new Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
                child:  ddlHoles,
              ),
            ),
          ],

        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                child:  ddlTasks,
              ),
            ),
            if(_selectedTask !=null && _selectedTask.taskType.toLowerCase().contains('drilling'))
              new Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  ddlCoreSize,
                ),
              ),
            if(_selectedTask!=null && _selectedTask.logType.contains('E'))
              new Expanded(
              flex: 3,
              child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
              child:  ddlWorker,
              ),
              ),
            if(_selectedTask!=null && _selectedTask.logType.contains('C'))
              new Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  new TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      labelText: 'Note'
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],

                    controller: noteController,

                  ),
                ),
              ),

          ],

        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 3,
              child: _createStartTimeDdl(CommonFunction.getAllSiftWorkHours()),
            ),
            new Expanded(
              flex: 3,
              child: _createEndTimeDdl(CommonFunction.getAllSiftWorkHours()),
            ),
            if(_selectedTask !=null && _selectedTask.logType.contains('P'))
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                child: new TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8),
                    BlacklistingTextInputFormatter.singleLineFormatter,
                    ValidatorInputFormatter(
                      editingValidator: DecimalNumberSubmitValidator(
                      ),
                    )
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Start(M)',
                    labelText: 'Start(M)',

                  ),
                  controller: startMController,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if(_selectedTask !=null && _selectedTask.logType.contains('P'))
              new Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child: new TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(8),
                      BlacklistingTextInputFormatter.singleLineFormatter,
                      ValidatorInputFormatter(
                        editingValidator: DecimalNumberSubmitValidator(
                        ),
                      )
                    ],
                    decoration: const InputDecoration(
                      hintText: 'End(M)',
                      labelText: 'End(M)',
                    ),
                    controller:  endMController,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if(hasPermitStatus)
            new Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 0),
                child: IconButton(
                  icon: Icon(taskLogAddNew?Icons.add:Icons.done),
                  onPressed: () {
                      setTaskLog();
                  },
                ),
              ),
            ),
          ],
        ),
        new Container(
          color: Colors.grey,
          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                    flex: 3,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      child: new Text("Task",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Worker",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Work(H)",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Note",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 1,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text(" ") ,
                    )
                )
              ]
          ),
        ),
        Expanded(
         child: loadLogTaskList()
          ),
      ],
    );

  }
  Widget _createStartTimeDdl(List<String> values){
    return DropdownButton<String>(
      hint: Text("Start Time"), // Not necessary for Option 1//
      value: _startTime,
      onChanged: (newValue) {
        setState(() {
          _startTime = newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<String>(
          child: new Text(data, style: TextStyle(fontSize: 14.0),),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createEndTimeDdl(List<String> values){
    return DropdownButton<String>(
      hint: Text("End Time"), // Not necessary for Option 1
      value: _endTime,
      onChanged: (newValue) {
        setState(() {
          _endTime = newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<String>(
          child: new Text(data, style: TextStyle(fontSize: 14.0)),
          value: data,
        );
      }).toList(),
    );
  }
  Widget loadMaterialForm(){
    if(_isLoading){
      return _showCircularProgress();
    }
    return Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 5,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                  child: ddlMaterials,
                ),
            ),
            new Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                child: new TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Quantity'
                  ),
                  controller: materialQtyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(4),
                    BlacklistingTextInputFormatter.singleLineFormatter,
                  ],
                ),

              ),
            ),
            if(hasPermitStatus)
            new Expanded(
              flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 10, 10),
                  child: new IconButton(
                    icon: Icon(addNewMaterial?Icons.add:Icons.done),
                    onPressed: (){
                      setConsumeMaterial();
                    },
                  ),
                )
            ),
          ],
        ),
        new Container(
          color: Colors.grey,
          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  flex: 5,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      child: new Text("Material",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                  flex: 3,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Quantity",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                  flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text(" ") ,
                    )
                )
              ]
          ),
        ),
        Expanded(
          child: loadUsedMaterialList(),
        )
      ],
    );
  }
  Widget loadCommentForm(){
    if(_isLoading){
      return _showCircularProgress();
    }
    return Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                  child: new TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Comments',
                        hintText: 'Comments'
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    maxLength: 200,
                    controller: commentController,
                  ),

                ),
              ),
            ],
          ),
          if(hasSubmitStatus)
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 10),
                    child: ddlNextStages,
                  ),
                ),
                new Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                      child: new FlatButton(
                        child: Text('Submit'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                        onPressed: (){
                          _submitConfirmation(context);
                        },
                      ),
                    )
                ),
              ],
            ),
          new Container(
            color: Colors.grey,
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                      flex: 3,
                      child:Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                        child: new Text("Comment",style: TextStyle(fontSize: 16.0),) ,
                      )
                  ),
                ]
            ),
          ),
          Expanded(
            child: loadCommentList(),
          )
        ],
    );

  }
  void setTaskLog(){
    if(isValidTask()){
      TaskLog taskLog;
      if(_taskLogs == null){
        _taskLogs = new List();
      }
      var tempDayShiftStart = timeFormat.parse(widget.mUser.appSettings.dayShiftStart);
      var tempDayShiftEnd = timeFormat.parse(widget.mUser.appSettings.dayShiftEnd);
      if(taskLogAddNew) {
        taskLog = new TaskLog(task: _selectedTask,
            startTime: _startTime,
            endTime: _endTime
        );
      }
      else {
        if(taskIndexForUpdate>=0) {
          taskLog = _taskLogs[taskIndexForUpdate];
          taskLog.task = _selectedTask;
          taskLog.startTime = _startTime;
          taskLog.endTime = _endTime;
        }
      }
        taskLog.coreSize = _selectedCoreSize;
        taskLog.startMeter = double.parse(startMController.text.isEmpty?"0":startMController.text);
        taskLog.endMeter = double.parse(endMController.text.isEmpty?"0":endMController.text);
        taskLog.worker = _selectedWorker;
        var startTime = timeFormat.parse(taskLog.startTime);
        var endTime = timeFormat.parse(taskLog.endTime);
        if(startTime.isAfter(endTime))
          endTime = endTime.add(Duration(days: 1));
        var hoursWorked = endTime.difference(startTime);
        var duration = (hoursWorked.inMinutes/60).toStringAsFixed(2);
        taskLog.workHours=double.parse(duration);
        _selectedNote = noteController.text;
        taskLog.comment = _selectedNote;
        taskLog.coreSize = _selectedCoreSize;

        taskLog.entryDate = DateTime.now();
        taskLog.entryBy = widget.mUser;
        if(startTime.compareTo(tempDayShiftStart)>=0 && startTime.compareTo(tempDayShiftEnd)<=0){
          taskLog.shift="D";
        }
        else{
          taskLog.shift="N";
        }

      setState(() {
        taskLogAddNew = true;
        worksheetUpdate = true;
        if(taskIndexForUpdate>=0){
          _taskLogs[taskIndexForUpdate]=taskLog;
        }
        else{
          _taskLogs.add(taskLog);
        }
        clearTaskInput();
      });
      }


  }
  void clearTaskInput(){
    _selectedTask = null;
    _startTime ="7:00 AM";
    _endTime = "7:00 AM";
    _startMeter = 0;
    _endMeter = 0;
    _selectedWorker = null;
    _selectedNote ="";
    _selectedCoreSize = null;
    taskController.text="";
    coreSizeController.text="";
    workerController.text="";
    noteController.text="";
    startMController.text="";
    endMController.text="";
    taskIndexForUpdate = -1;
  }
  bool isValidWorkSheet(){
    if(_selectedRigs == null){
      _showDialog("Please choose Rigs");
      return false;
    }
    else if(_selectedRigs.serial.toLowerCase()!=rigController.text.toLowerCase()){
      _showDialog("Please choose Rigs");
      return false;
    }
    if(_workDate == null){
      _showDialog("Please put work date");
      return false;
    }
    if(holeController.text != null && holeController.text.isNotEmpty ){
      if(_selectedHoles==null){
        _showDialog("Please select valid holes");
        return false;
      }
      else if(_selectedHoles.name.toLowerCase()!=holeController.text.toLowerCase()){
        _showDialog("Please select valid holes");
        return false;
      }
    }
    return true;
  }
  bool isValidTask()
  {
    if(_selectedTask == null){
      _showDialog("Please Choose task");
      return false;
    }
    if(_selectedTask.logType.contains('E')){
      if(_selectedWorker == null){
        _showDialog("Please worker!");
            return false;
      }
    }

    if(_selectedTask.logType.contains('P')){
      _startMeter = double.parse(startMController.text.isEmpty?"0":startMController.text);
      _endMeter = double.parse(endMController.text.isEmpty?"0":endMController.text);
      if(_startMeter>_endMeter){
        _showDialog("End meter can not be less than Start meter");
        return false;
      }
    }
    return true;
  }
  void setConsumeMaterial(){
    if(isValidConsumeMaterial()){
      if(_consumeMaterials == null){
        _consumeMaterials = new List();
      }
      ConsumeMaterials consumeMaterials;
      if(addNewMaterial){
        consumeMaterials = new ConsumeMaterials(_selectedMaterial,
            double.parse(materialQtyController.text.isEmpty?"0":materialQtyController.text));

      }
      else{
        consumeMaterials = _consumeMaterials[usedMaterialIndexForUpdate];
        consumeMaterials.material = _selectedMaterial;
        consumeMaterials.qty = double.parse(materialQtyController.text.isEmpty?"0":materialQtyController.text);
      }
      consumeMaterials.entryBy = widget.mUser;
      consumeMaterials.entryDate = DateTime.now();
      setState(() {
        addNewMaterial = true;
        worksheetUpdate = true;
        if(usedMaterialIndexForUpdate >= 0){
          _consumeMaterials[usedMaterialIndexForUpdate]=consumeMaterials;
        }
        else{
          _consumeMaterials.add(consumeMaterials);
        }
      clearConsumeMaterialInput();
      });

    }
  }
  void clearConsumeMaterialInput(){
    _selectedUsedMaterial = null;
    _selectedMaterial = null;
    materialQtyController.text = "";
    materialItemController.text = "";
  }
  void clearComment(){
    commentController.text = "";
    _selectedStatus = null;
    _selectedWorkSheetStatus = null;
  }
  bool isValidConsumeMaterial()
  {
    if(_selectedMaterial == null){
      _showDialog("Please Choose Material");
      return false;
    }
    if(!CommonFunction.isNumeric(materialQtyController.text)){
        _showDialog("Please put quantity!");
        return false;
    }
    return true;
  }
  bool isValidComment()
  {
    if(commentController.text.isEmpty){
      _showDialog("Please put comment!");
      return false;
    }
    return true;
  }

  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
  }
  Future<TimeOfDay> getTime(){
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    );
  }
  void callDatePicker(DateTimeWrapper dateTime) async {
    DateTime _datetime = await getDate();
    setState(() {
      if(_datetime !=null){
        dateTime.dateTime = _datetime;
      }

    });
  }
//  void callTimePicker(TimeWrapper time) async {
//    TimeOfDay tod = await getTime();
//    setState(() {
//      if(tod !=null){
//        time.timeOfDay = tod;
//      }
//
//    });
//  }
  Widget loadLogTaskList()
  {
    if(_isLoading)
      return _showCircularProgress();
    if(_taskLogs !=null && _taskLogs.length>0)
      {
        return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: _taskLogs.length,
          itemBuilder: (BuildContext context,int index){
            var startTime = timeFormat.parse(_taskLogs[index].startTime);
            var endTime = timeFormat.parse(_taskLogs[index].endTime);
            if(startTime.isAfter(endTime))
              endTime = endTime.add(Duration(days: 1));
            var hoursWorked = endTime.difference(startTime);
            var duration = (hoursWorked.inMinutes/60).toStringAsFixed(2);
            _startMeter = _taskLogs[index].startMeter;
            _endMeter = _taskLogs[index].endMeter;

            String displayProgress;
            double workDoneProgress=0;
            if(_endTime !=null && _startMeter !=null){
              workDoneProgress = (_endMeter -_startMeter).abs();
             displayProgress = workDoneProgress.toStringAsFixed(2)+"M";
            }
            String displayNote = _taskLogs[index].comment!=null?_taskLogs[index].comment:"";
            return new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  flex:3,
                  child:ListTile(
                    title: Text(_taskLogs[index].task.name),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(_taskLogs[index].worker!=null?_taskLogs[index].worker.lastName+' '+_taskLogs[index].worker.firstName:''),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(duration),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(workDoneProgress>0?displayProgress:displayNote),
                  ),
                ),
                new Expanded(
                  flex: 1,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          setState(() {
                            taskLogAddNew=false;
                            loadTaskForUpdate(index);
                          });
                        },
                      ),
                    )
                ),
              ],
            );
          },
        );
      }
    else {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
          child: Text(
            "No Task found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ));
    }

  }
  Widget loadUsedMaterialList()
  {
    if(_isLoading)
      return _showCircularProgress();
    if(_consumeMaterials !=null && _consumeMaterials.length>0)
    {
      return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _consumeMaterials.length,
        itemBuilder: (BuildContext context,int index){
          return new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                flex: 5,
                child:ListTile(
                  title: Text(_consumeMaterials[index].material.name),
                ),
              ),
              new Expanded(
                flex:3,
                child:ListTile(
                  title: Text(_consumeMaterials[index].qty.toString()),
                ),
              ),
              new Expanded(
                  flex: 2,
                  child:Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          addNewMaterial=false;
                          loadUsedMaterialForUpdate(index);
                        });
                      },
                    ),
                  )
              ),
            ],
          );
        },
      );
    }
    else {
      return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
          child: Text(
            "No Used material found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ));
    }

  }
  Widget loadCommentList()
  {
    if(_isLoading)
      return _showCircularProgress();

    if(_comments !=null && _comments.length>0)
    {
      _comments.sort((a,b){
        return b.entryDate.compareTo(a.entryDate);
      });
      return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _comments.length,
        itemBuilder: (BuildContext context,int index){
          return new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                flex:3,
                child:ListTile(
                  title: Text(_comments[index].comment),
                ),
              ),
              new Expanded(
                  child:ListTile(
                    title: Text(_comments[index].entryBy.lastName),
                  )),
            ],
          );
        },
      );
    }
    else {
      return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
          child: Text(
            "No Comments",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ));
    }

  }
  void loadTaskForUpdate(int index){
    if(_taskLogs.length>index)
      {
        taskIndexForUpdate = index;
        _selectedTask = _taskLogs[index].task;
        taskController.text=_selectedTask.name;
        _selectedCoreSize =_taskLogs[index].coreSize;
        coreSizeController.text =_selectedCoreSize!=null?_selectedCoreSize.core:'';
        _selectedWorker =_taskLogs[index].worker;
        workerController.text=_selectedWorker!=null? _selectedWorker.lastName:'';
        _startTime = _taskLogs[index].startTime;
        _endTime = _taskLogs[index].endTime;
        _startMeter =_taskLogs[index].startMeter;
        startMController.text=_startMeter !=null?_startMeter.toString():"";
        _endMeter = _taskLogs[index].endMeter;
        endMController.text = _endMeter !=null?_endMeter.toString():"";
        _selectedNote = _taskLogs[index].comment;
        noteController.text = _selectedNote;
      }
  }
  void loadUsedMaterialForUpdate(int index){
    if(_consumeMaterials.length > index){
      usedMaterialIndexForUpdate = index;
      _selectedUsedMaterial = _consumeMaterials[index];
      _selectedMaterial = _selectedUsedMaterial.material;
      materialItemController.text = _selectedMaterial.name;
      materialQtyController.text = _selectedUsedMaterial.qty.toString();

    }
  }
  void saveWorkSheet(){
    if(!isValidWorkSheet()) {
      return;
    }
    if(widget.mWorkSheet==null)
      {
        widget.mWorkSheet = new WorkSheet(null, null);
        widget.mWorkSheet.entryDate = DateTime.now();
        widget.mWorkSheet.entryBy = widget.mUser;
      }
    widget.mWorkSheet.rigs = _selectedRigs;
    widget.mWorkSheet.holes = _selectedHoles;
    widget.mWorkSheet.workDate = _workDate.dateTime;
    widget.mWorkSheet.taskLogs = _taskLogs;
    widget.mWorkSheet.consumeMaterials = _consumeMaterials;
    widget.mWorkSheet.comments = _comments;
    saveWorkSheetDB();
//    widget.mWorkSheet.status;
    setState(() {
      worksheetUpdate = false;
    });

  }
  void saveWorkSheetDB() async{
    if(widget.mWorkSheet !=null){
      try {
        if (widget.mWorkSheet.docId == null ||
            widget.mWorkSheet.docId.isEmpty) {
          DocumentReference ref = await _dbReference.document(
              widget.mProject.docId).
          collection("worksheet").add(widget.mWorkSheet.toJson());
          for (TaskLog taskLog in widget.mWorkSheet.taskLogs) {
            await ref.collection("taskLogs").add(
                taskLog.toJson()
            );
          }
          for (ConsumeMaterials material in widget.mWorkSheet
              .consumeMaterials) {
            await ref.collection("consumeMaterials").add(
                material.toJson()
            );
          }
          if (_selectedComments != null) {
            await ref.collection("msg").add(
                _selectedComments.toJson()
            );
          }
          if(_selectedWorkSheetStatus != null){
            await ref.collection("status").add(_selectedWorkSheetStatus.toJson());
            await ref.updateData({"currentStatus":_selectedWorkSheetStatus.status});
          }

        }
        else {
          DocumentReference ref = await _dbReference.document(
              widget.mProject.docId).
          collection("worksheet").document(widget.mWorkSheet.docId);
          ref.setData(widget.mWorkSheet.toJson());
          ref.collection("taskLogs").getDocuments().then((snapshot) {
            for (DocumentSnapshot docs in snapshot.documents) {
              docs.reference.delete();
            }
            for (TaskLog taskLog in widget.mWorkSheet.taskLogs) {
              ref.collection("taskLogs").add(
                  taskLog.toJson()
              );
            }
          });

          ref.collection("consumeMaterials").getDocuments().then((snapshot) {
            for (DocumentSnapshot docs in snapshot.documents) {
              docs.reference.delete();
            }
            for (ConsumeMaterials material in widget.mWorkSheet
                .consumeMaterials) {
              ref.collection("consumeMaterials").add(
                  material.toJson()
              );
            }
          });

          if (_selectedComments != null) {
            await ref.collection("msg").add(
                _selectedComments.toJson()
            );
          }
          if(_selectedWorkSheetStatus != null){
            await ref.collection("status").add(_selectedWorkSheetStatus.toJson());
            await ref.updateData({"currentStatus":_selectedWorkSheetStatus.status});
          }
        }
        clearTaskInput();
        clearConsumeMaterialInput();
        clearComment();
        Navigator.pop(context, 'reload');
      }catch(exception){
        _showDialog(exception.toString());
      }

    }
  }
  void submitWorkSheet(){

   // _selectedStatus = nextStagesController.text;
    _selectedComments = new Comments(commentController.text);
    _selectedComments.entryDate = DateTime.now();
    _selectedComments.entryBy = widget.mUser;
    if(_selectedStatus!=null && _selectedStatus.isNotEmpty){

      _selectedWorkSheetStatus = new WorkSheetStatus(_selectedStatus);
      _selectedWorkSheetStatus.entryBy=widget.mUser;
      _selectedWorkSheetStatus.entryDate = new DateTime.now();
    }
    saveWorkSheet();
  }
   _submitConfirmation(BuildContext context){
    if(nextStagesController.text.isEmpty){
      _showDialog("Select Submit to ");
      return false;
    }
    if(widget.mUser.appSettings.getStageDetails(_selectedStatus)!=nextStagesController.text){
      _showDialog("Plesae select submit to");
      return false;
    }
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Submit Worksheet'),
        content: Text('Are you sure to submit the worksheet?'),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
          FlatButton(
            onPressed: (){
              submitWorkSheet();
              Navigator.of(context).pop(false);
            },
            child: Text('Yes'),
          )
        ],
      ),
    );
  }

}
class DateTimeWrapper{
  DateTime dateTime;
  DateTimeWrapper({this.dateTime});
}
class TabMenu {
  const TabMenu({this.title, this.shortName, this.icon});

  final String title;
  final String shortName;
  final IconData icon;
}

const List<TabMenu> choices = const <TabMenu>[
  const TabMenu(title: 'Tasks', shortName: 'task', icon: Icons.directions_car),
  const TabMenu(title: 'Used Materials', shortName: 'material', icon: Icons.arrow_forward),
  const TabMenu(title: 'Remark/Submit',shortName: 'remark', icon: Icons.directions_boat),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final TabMenu choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;

    return Card(
      color: Colors.white,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

