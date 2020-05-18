import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global.dart';
import 'notification.dart';


class CreateStore extends StatefulWidget{
  @override
  _CreateStoreState createState() => _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore>{
  GlobalFn global;
  final formKey = new GlobalKey<FormState>();
  String title;
  String mobile;
  String address;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    global = Provider.of<GlobalFn>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Create Store"),
        ),
        body: Container(
          child: SizedBox.expand(
            child: Card(
              child: Padding(
                  padding: const EdgeInsets.only(left:10.0, right:10.0),
                  child: SingleChildScrollView(
                      child:  Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.domain,
                                color: Color(0xff1c4b82),),
                              title: TextFormField(
                                onSaved: (value) => title = value,
                                validator: (value){
                                  if(value.isEmpty){
                                    return "Store title is required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Title"),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.phone_android,
                                color: Color(0xff1c4b82),
                              ),
                              title: TextFormField(
                                  onSaved: (value) => mobile = value,
                                  validator: (value){
                                    if(value.isEmpty){
                                      return "Mobile Number is required";
                                    }
                                    if(value.length < 11)
                                      return "Mobile Number not valid.";
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      labelText: "Mobile Number"),
                                  keyboardType: TextInputType.number
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: Color(0xff1c4b82),
                              ),
                              title: TextFormField(
                                onSaved: (value) => address = value,
                                validator: (value){
                                  if(value.isEmpty){
                                    return "Store Address is required";
                                  }
                                  return null;
                                },
                                  decoration: InputDecoration(
                                      labelText: "Adress"),
                              ),
                            ),
                            SizedBox(height: 30.0,),
                            Align(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: RaisedButton(
                                  child: Text("Create Store", style: TextStyle(color: Colors.white,),),
                                  color: Color(0xff1c4b82),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)
                                  ),
                                  onPressed: (){
                                    if(formKey.currentState.validate()){
                                        formKey.currentState.save();
                                        confirmDialog(context, (){
                                          Navigator.of(context).pop();
                                          global.createStore(context, {'title':title, 'mobile':mobile, 'address':address} );
                                          }
                                        );
                                    }
                                  },
                                ),
                              ),
                              alignment: Alignment.bottomRight,
                            ),
                          ],
                        ),
                      )
                  )
              ),
            ),
          ),
        )
    );
  }

}
