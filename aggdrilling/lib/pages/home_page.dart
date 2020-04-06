import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/pages/project_page.dart';
import 'package:flutter/material.dart';
import 'package:aggdrilling/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final dbReference = Firestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
//  StreamSubscription<Event> _onTodoAddedSubscription;
//  StreamSubscription<Event> _onTodoChangedSubscription;
  bool _isLoading;
  User _loginUser;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _projectList = new List();
    dbReference.collection('users')
    .document(widget.userId).get()
    .then((DocumentSnapshot ds){
     _loginUser= User.fromSnapshot(ds);
     _loginUser.getAllPermits(ds, (value){
       if (_loginUser != null && _loginUser.permitProjects.length > 0) {
         loadProject();
       }
       else {
         setState(() {
           _isLoading = false;
         });

       }
     });

    });

  }

  loadProject() async{

     dbReference.collection('projects').where('projectCode',whereIn: _loginUser.getProjectCode() )
        .snapshots().listen((QuerySnapshot querySnapShot){
          querySnapShot.documents.forEach((document) {
            _projectList.add(Project.fromSnapshot(document));
            setState(() {
              _isLoading = false;
            });
          });
      });
  }

  @override
  void dispose() {
    super.dispose();
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
              title: Text(_projectList[index].projectCode,
              style: TextStyle(fontSize:17.0,color: Colors.lightBlue ),),
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
                contentPadding: const EdgeInsets.all(8.0),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Aggressive Drilling'),
        ),
        body: showProjectList(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(),
//            _createDrawerItem(
//              icon: Icons.account_circle,
//              text: 'Change Password',
//              onTap: (){
//
//              }
//            ),
            _createDrawerItem(
                icon: Icons.power_settings_new,
                text: 'Sign out',
                onTap: () {
                  _signOut(context);
                }),
            Divider(),

            ListTile(
              title: new Text('version: 0.1.1',),
              //style: new TextStyle(fontSize: 17.0, color: Colors.lightBlue)
            ),

          ],
        ),
      ),
        );
  }
  Widget _createHeader() {
    return UserAccountsDrawerHeader(
        accountName: Text("Welcome ${_loginUser!=null?(_loginUser.firstName):''}"),
        currentAccountPicture: CircleAvatar(
          backgroundColor:
          Theme.of(context).platform == TargetPlatform.iOS
              ? Colors.blue
              : Colors.white,
          child: Text(
            "${_loginUser!=null?_loginUser.firstName.substring(0,1):'A'}",
            style: TextStyle(fontSize: 40.0),
          ),
        )
        );
  }
  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
  Future<bool> _signOut(BuildContext context){
    return showDialog(
        context: context,
      child: AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure to sign out?'),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
          FlatButton(
            onPressed: (){
              signOut();
              Navigator.of(context).pop(false);
            },
            child: Text('Yes'),
          )
        ],
      ),
    );
  }
}