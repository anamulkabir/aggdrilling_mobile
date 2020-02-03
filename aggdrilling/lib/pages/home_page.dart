import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/pages/project_page.dart';
import 'package:flutter/material.dart';
import 'package:aggdrilling/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aggdrilling/models/project.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Project> _projectList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _query;
  bool _isLoading;
  User _loginUser;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _projectList = new List();
    _query = _database
        .reference()
        .child("itts_test").child("users").child(widget.userId);
    _query.once().then((DataSnapshot snapshot) {
      _loginUser = User.fromSnapshot(snapshot);
      if (_loginUser != null && _loginUser.permitProjects.length > 0) {
        loadProject();
      }
      else {
        setState(() {
          _isLoading = false;
        });

      }
    });

  }

  loadProject() async{
    _query = _database
        .reference()
        .child("itts_test").child("projects").child(_loginUser.permitProjects[0].code);
    _query.once().then((DataSnapshot snapshot){
      setState(() {
        _isLoading = false;
        _projectList.add(Project.fromSnapshot(snapshot));
      });
    } );

  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _projectList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
//      _projectList[_projectList.indexOf(oldEntry)] =
//          Project.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
//      _projectList.add(Project.fromSnapshot(event.snapshot));
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
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
//  addNewTodo(String todoItem) {
//    if (todoItem.length > 0) {
//      Project todo = new Project(todoItem.toString(), widget.userId, false);
//      _database.reference().child("todo").push().set(todo.toJson());
//    }
//  }

//  updateTodo(Project project) {
//    //Toggle completed
//    todo.completed = !todo.completed;
//    if (todo != null) {
//      _database.reference().child("todo").child(todo.key).set(todo.toJson());
//    }
//  }
//
//  deleteTodo(String todoId, int index) {
//    _database.reference().child("todo").child(todoId).remove().then((_) {
//      print("Delete $todoId successful");
//      setState(() {
//        _projectList.removeAt(index);
//      });
//    });
//  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                      controller: _textEditingController,
                      autofocus: true,
                      decoration: new InputDecoration(
                        labelText: 'Add new todo',
                      ),
                    ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
//                    addNewTodo(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showProjectList() {
    if(_isLoading)
      return _showCircularProgress();
    if (_projectList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _projectList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
            elevation: 0.0,
              child: ListTile(
              title: Text(_projectList[index].projectCode),
                subtitle: Text(_projectList[index].projectName),
                trailing: IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectPage(loginUser:_loginUser ,mProject: _projectList[index]),
                      ),
                    );
                  },
                ),
              ),
            );
//            return Dismissible(
//              key: Key(code),
//              background: Container(color: Colors.red),
//              onDismissed: (direction) async {
////                deleteTodo(todoId, index);
//              },
//              child: ListTile(
//                title: Text(
//                  code,
//                  style: TextStyle(fontSize: 20.0),
//                ),
//                trailing: IconButton(
//                    icon: (true)
//                        ? Icon(
//                      Icons.done_outline,
//                      color: Colors.green,
//                      size: 20.0,
//                    )
//                        : Icon(Icons.done, color: Colors.grey, size: 20.0),
//                    onPressed: () {
////                      updateTodo(_projectList[index]);
//                    }),
//              ),
//            );
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Aggressive Drilling'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showProjectList(),
        );
  }
}