import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard.dart';
import 'global.dart';
import 'notification.dart';

class Login extends StatefulWidget {
  @override
  _LoginScreen3State createState() => new _LoginScreen3State();
}

class _LoginScreen3State extends State<Login> with TickerProviderStateMixin {

  final username = TextEditingController();
  final password = TextEditingController();
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new PageController(initialPage: 0, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gotoLogin();
    return Container(
        height: MediaQuery.of(context).size.height,
        child: PageView(
          controller: _controller,
          physics: new AlwaysScrollableScrollPhysics(),
          children: <Widget>[homePage(), loginPage(), ],
          scrollDirection: Axis.horizontal,
        )
    );
  }

  Widget homePage() {
    return new Container(
      decoration: BoxDecoration(
        color: Color(0xFF1c4b82),
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.dstATop
          ),
          image: AssetImage('assets/images/mountains.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 250.0),
            child: Center(
              child: Icon(
                Icons.store_mall_directory,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Retail",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  "Office",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loginPage() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.05), BlendMode.dstATop),
            image: AssetImage('assets/images/mountains.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: new Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Center(
              child: Icon(
                Icons.store,
                color: Color(0xFF1c4b82),
                size: 50.0,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "USERNAME",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1c4b82),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color(0xFF1c4b82),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Flexible(
                    child: TextField(
                      controller: username,
                      obscureText: false,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 24.0,
            ),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "PASSWORD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1c4b82),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color(0xFF1c4b82),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Flexible(
                    child: TextField(
                      controller: password,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '*********',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: new FlatButton(
                    child: new Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1c4b82),
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    onPressed: () => {
                      debugPrint("Password Forgotten")
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 4,
              child: Container(),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
              alignment: Alignment.center,
              child: new Row(
                children: <Widget>[
                  new Flexible(
                    child: new FlatButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Color(0xFF1c4b82),
                      onPressed: loginFn(),   // Login Method
                      child: new Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 20.0,
                        ),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: Text(
                                "LOGIN",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  gotoLogin(){
    Future.delayed(Duration(seconds: 3), (){
      _controller.animateToPage(
        1,
        duration: Duration(milliseconds: 1000),
        curve: Curves.decelerate,
      );
    });

  }

  loginFn(){
    return ()async{
      GlobalFn globalFn = Provider.of<GlobalFn>(context);
       loading(context);
      try{
        Map<String, dynamic> token = await globalFn.login(username.text, password.text);
        if(token['error'] == null){
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder:(BuildContext context)=> Dashboard()));
        }else{
          Navigator.of(context).pop();
          failedLogin();
        }
      }catch(e){
        print(e);
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("No Internet Connection..."), ));
      }
    };
  }

  void failedLogin(){
    showDialog(context: context, builder: (BuildContext context){
      return SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(10.0)
            )
        ),
        children: <Widget>[
          Container(
              height: 115,
              padding: EdgeInsets.only(left:20.0, right:20.0, top:15.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text("Login Failed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Text("Username or Password Incorrect"),
                    FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text("OK", style: TextStyle(color: Color(0xFF1c4b82)),), padding: EdgeInsets.only(top:0.0),)
                  ]
              )
          )
        ],
      );
    });
  }

}
