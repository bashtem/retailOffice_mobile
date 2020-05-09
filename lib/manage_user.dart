import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'global.dart';
import 'personalisedSearch.dart';
import 'notification.dart';

class ManageUser extends StatefulWidget{
  @override
  _ManageUserState createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser>{
  GlobalFn global;
  TextEditingController search = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  var selectedUser;
  var userRole;
  var userStatus;
  var usersFetched;
  Future users;


  @override
  void initState(){
    super.initState();
    global = GlobalFn();
    users = global.getUsers();
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(builder: (context, snapshot){
      usersFetched = snapshot.hasData ? snapshot.data : [];
    return Scaffold(
        appBar: AppBar(
          title: Text("Manage Users"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: !snapshot.hasData ? null : (){
                  showSearch(context: context, delegate: SearchData(searchUser, usersFetched, 'name'));
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff1c4b82),
          child: Icon(
              Icons.person_add
          ),
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
              return addUser();
            }));
          },
        ),
        body:Container(
          child: Card(
            child: (snapshot.hasData ? ( snapshot.data.length < 1 ? noRecords() :
             ListView.builder(itemBuilder: (context, index){
              return ListTile(
                dense: true,
                title: Text(usersFetched[index]['name']),
                subtitle: Text(usersFetched[index]['user_role']['role_desc']),
                trailing: Icon(Icons.remove_red_eye, color: Color(0xff1c4b82),),
                onTap: (){
                  viewUser(usersFetched[index]['user_id']);
                },
              );
            },itemCount: snapshot.data.length,) ) :
             Center(child: CircularProgressIndicator())
            )
          ),
        )
    );
    },future: users);
  }

  Widget addUser(){
    return Scaffold(
      appBar: AppBar(title: Text("Add User"),),
      body: Container(
        child: FutureBuilder(future: global.getRoles(),builder: (context, snapshot){
          if(snapshot.hasData){
              var data = snapshot.data['roles'];
              var stat = [{"desc":"ACTIVE", "value":"ACTIVE"}, {"desc":"INACTIVE", "value":"INACTIVE"}];
            return SizedBox.expand(
              child: Card(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.account_circle, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: name,
                          decoration: InputDecoration(labelText: "Full Name"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.assignment_ind, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: userId,
                          decoration: InputDecoration(labelText: "User ID"),
                        ),
                      ),ListTile(
                        leading: Icon(Icons.vpn_key, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: password,
                          decoration: InputDecoration(labelText: "Password"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone_android, color: Color(0xff1c4b82),),
                        title: TextField(
                          keyboardType: TextInputType.numberWithOptions(),
                          controller: phone,
                          decoration: InputDecoration(labelText: "Mobile Number"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.mail_outline, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: email,
                          decoration: InputDecoration(labelText: "E-Mail "),
                        ),
                      ),
                      ListTile(
                          leading: Icon(Icons.person_pin_circle, color: Color(0xff1c4b82),),
                          title: DropDown(data, 'role_desc', (value){ userRole = value;})
                      ),
                      ListTile(
                        leading: Icon(Icons.accessibility_new, color: Color(0xff1c4b82),),
                        title: DropDown(stat, 'desc', (value){userStatus = value;})
                      ),
                      SizedBox(height: 30.0,),
                      Align(
                        child:Padding(
                          padding: const EdgeInsets.only(right:15.0),
                          child: RaisedButton(
                            child: Text("Add User", style: TextStyle(color: Colors.white,),), color: Color(0xff1c4b82), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                            onPressed: (){
                              global.addUserData.addAll({'name':name.text, 'username':userId.text, 'phone':phone.text, 'email':email.text, 'password':password.text, 'role':userRole, 'status':userStatus });
                              global.addUser(context);
                            },),
                        ),
                        alignment: Alignment.bottomRight,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        })
      ),
    );
  }

  void viewUser(userId){
     showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(20.0)
              )
          ),
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left:20.0,right: 20.0, top: 20.0, bottom: 1.0),
              height: 400,
              width: 400,
              child: FutureBuilder(future:global.getUser(userId.toString()), builder: (context, snapshot){
                if(snapshot.hasData){
                   selectedUser = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("Name:", style: TextStyle(fontWeight: FontWeight.bold),)),
                          Text(selectedUser['name'])
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("User ID:", style: TextStyle(fontWeight: FontWeight.bold))),
                          Text(selectedUser['username'])
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("Phone No.:", style: TextStyle(fontWeight: FontWeight.bold))),
                          Text(selectedUser['phone'])
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("E-Mail:", style: TextStyle(fontWeight: FontWeight.bold))),
                          Flexible(child: Text(selectedUser['email']))
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("Role:", style: TextStyle(fontWeight: FontWeight.bold))),
                          Text(selectedUser['user_role']['role_desc'])
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("Status:", style: TextStyle(fontWeight: FontWeight.bold))),
                          CustomSwitch(userId, selectedUser['status']),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("Registered:", style: TextStyle(fontWeight: FontWeight.bold))),
                          Text(selectedUser['created_at'])
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      RaisedButton(
                        child: Text("Clear Session", style: TextStyle(color: Colors.white,),),
                        color: Color(0xff1c4b82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        onPressed: (){
                          global.clearUserSession(context, selectedUser['user_id']);
                        },
                      ),
                    ],
                  );
                }else{
                  return Center(child: CircularProgressIndicator());
                }
              }),
            )
          ],
        );
      }
    );
  }

  Widget searchUser(List val){
    return (val.length < 1)? noRecords() : ListView.builder(
      itemBuilder: (context, index) =>
          ListTile(
            dense: true,
            title: Text(val[index]['name']),
            subtitle: Text(val[index]['user_role']['role_desc']),
            trailing: Icon(Icons.remove_red_eye, color: Color(0xff1c4b82),),
            onTap: (){
              viewUser(val[index]['user_id']);
            },
          ),
      itemCount: val.length,);
  }

  void clearSession(){
  }

}

class DropDown extends StatefulWidget{
  final List items;
  final String name;
  final Function getData;
  DropDown(this.items, this.name, this.getData);
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown>{
  var picked;
  List stableTypes;

  @override
  void initState() {
    super.initState();
    picked = widget.items[0];
    stableTypes = widget.items;
    widget.getData(picked);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      items: stableTypes.map((each){
        return DropdownMenuItem(
          child: Text(each[widget.name]),
          value: each,
        );
      }).toList(),
      value: picked,
      onChanged: (selected){
        setState(() {
          picked = selected;
          widget.getData(picked);
        });
      },
    );
  }
}

class CustomSwitch extends StatefulWidget{
  final userId;
  final userStatus;
  CustomSwitch(this.userId, this.userStatus);
  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomSwitch>{
  bool switchValue;
  GlobalFn global;


  @override
  void initState() {
    super.initState();
    switchValue = checkSwitchValue();
  }
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: switchValue,
        activeColor: Color(0xff1c4b82),
        onChanged: (value){
      setState(() {
        switchValue = value;
        global.userStatus(widget.userId, switchValue);
      });
    });
  }

  bool checkSwitchValue(){
    bool res = (widget.userStatus == "ACTIVE")? true : false;
    return res;
  }

}