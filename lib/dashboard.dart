import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:path_provider/path_provider.dart';
import 'package:retailoffice/purchase.dart';
import 'package:retailoffice/quantity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
//import 'package:provider/provider.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/widgets.dart';


class Dashboard extends StatefulWidget{
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>{
  GlobalFn global;
  var dashboardData;
  Timer timer;
  Future dashboardFuture;
  File profilePix;
  SharedPreferences prefs;

  @override
  void initState(){
    global = GlobalFn();
    setProfilePix();
    dashboardFuture = global.dashboard();
    timer = Timer.periodic(Duration(seconds: 15), (timer){
      dashboardFuture = global.dashboard();
      setState((){  });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(future: dashboardFuture, builder: (context, snapshot){
      if(snapshot.hasData){
        dashboardData = snapshot.data;
      }
      return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.autorenew),
                onPressed: (){
                  dashboardFuture = global.dashboard();
                  setState((){  });
                },
              ),
            ],
            backgroundColor: Color(0xff1c4b82),
            title:Text("Dashboard"),
          ),
          drawer: Drawer(
            child: Container(
              color:Color(0xff1c4b82),
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50.0)
                      ),
                      color: Color(0xff1c4b82),
                    ),
                    accountName: Text(GlobalFn.session.name),
                    accountEmail: Text(GlobalFn.session.userRole,),
                    currentAccountPicture: CircleAvatar(
                      child: InkWell(
                        onTap: (){
                          pickProfileImage();
                        },
                      ),
                      backgroundImage: profilePix == null ? AssetImage("assets/images/profile.png") : FileImage(profilePix),
                      backgroundColor: Color(0xffdee1ec),
                    ),
                    otherAccountsPictures: <Widget>[
                      CircleAvatar(
                        backgroundColor: Color(0xffdee1ec),
                        child: Text(GlobalFn.session.name[0]),
                      )
                    ],
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child : Column(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.tv, color: Color(0xff1c4b82),),
                              title: Text("Dashboard"),
                              onTap: (){
                                Navigator.pop(context);
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.format_list_bulleted, color: Color(0xff1c4b82)),
                              title: Text("Inventory"),
                              onTap: (){
                                Navigator.of(context).pushNamed("inventory");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.business, color: Color(0xff1c4b82)),
                              title: Text("Suppliers"),
                              onTap: (){
                                Navigator.of(context).pushNamed("supplier");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.local_shipping, color: Color(0xff1c4b82)),
                              title: Text("Purchase"),
                              onTap: (){
                                Navigator.of(context).pushNamed("purchase");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.compare_arrows, color: Color(0xff1c4b82)),
                              title: Text("Transfer"),
                              onTap: (){
                                Navigator.of(context).pushNamed("transfer");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.people_outline, color: Color(0xff1c4b82)),
                              title: Text("Customers"),
                              onTap: (){
                                Navigator.of(context).pushNamed("customer");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.account_circle, color: Color(0xff1c4b82)),
                              title: Text("Manage Users"),
                              onTap: (){
                                Navigator.of(context).pushNamed("user");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.history, color: Color(0xff1c4b82)),
                              title: Text("History"),
                              onTap: (){
                                Navigator.of(context).pushNamed("history");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.insert_drive_file, color: Theme.of(context).accentColor,),
                              title: Text("Report"),
                              onTap: (){
                                debugPrint("reports");
                                Navigator.of(context).pushNamed("report");
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.power_settings_new, color: Color(0xff1c4b82)),
                              title: Text("Logout"),
                              onTap: (){
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            )
                          ])
                  ),
                ],
              ),
            ),
          ),
          body: WillPopScope(
            onWillPop: logout,
            child: Container(
              color: Color(0xff1c4b82),
              child: Container(
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius:BorderRadius.only(
                      topLeft:Radius.circular(40.0),
                      topRight: Radius.circular(40.0)
                    )
                  ),
                  child: ((snapshot.hasData)? SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height:35.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Card(
                              elevation: 5.0,
                              child: Container(
                                  width: 160,
                                  height: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(Icons.store, color: Color(0xffdc3545),),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(global.priceFmt.format(double.parse(dashboardData['salesAmount'].toString())), style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xffdc3545)
                                          ),),
                                          Wrap(
                                            spacing: 5.0,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.lens, size: 7.0, color: Color(0xffdc3545),),
                                              Text("Sales",
                                                style: TextStyle(
                                                  color: Color(0xff6c7b95),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                              ),
                            ),
                            Card(
                              elevation: 5.0,
                              child: InkWell(
                                child: Container(
                                  width: 160,
                                  height: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(Icons.add_shopping_cart, color: Color(0xff007bff ),),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(global.numFmt.format(dashboardData['salesCount']), style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xff007bff)
                                          ),),
                                          Wrap(
                                            spacing: 5.0,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.lens, size: 7.0, color: Color(0xff007bff),),
                                              Text("Tickets",
                                                style: TextStyle(
                                                  color: Color(0xff6c7b95),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ),
                                splashColor: Color(0xff99caff),
                                onTap: (){
                                  Navigator.pushNamed(context, 'ticket');
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Card(
                              elevation: 2.0,
                              child: InkWell(
                                child: Container(
                                    width: 160,
                                    height: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.box, size: 20, color: Color(0xff293462, ),),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(global.qtyFmt.format(double.parse(dashboardData['totalQuantity'])), style: TextStyle(
                                                fontSize: 17,
                                                color: Color(0xff293462)
                                            ),),
                                            Wrap(
                                              spacing: 5.0,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.lens, size: 7.0, color: Color(0xff293462),),
                                                Text("Total Quantity",
                                                  style: TextStyle(
                                                    color: Color(0xff6c7b95),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                splashColor: Color(0xff909dd0),
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return Quantity();
                                  }));
                                },
                              ),
                            ),
                            Card(
                              elevation: 2.0,
                              child: InkWell(
                                child: Container(
                                    width: 160,
                                    height: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Text("NGN", style:TextStyle(color: Color(0xfff88020),fontSize: 16),),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(global.priceFmt.format(double.parse(dashboardData['stockValue'])), style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xfff88020)
                                            ),),
                                            Wrap(
                                              spacing: 5.0,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.lens,  size: 7.0, color: Color(0xfff88020),),
                                                Text("Stock Value",
                                                  style: TextStyle(
                                                    color: Color(0xff6c7b95),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                splashColor: Color(0xfffbb174),
                                onTap: (){
                                  print('hello world');
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Card(
                              elevation: 2.0,
                              child: InkWell(
                                child: Container(
                                    width: 160,
                                    height: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(Icons.swap_horiz, color: Color(0xff28a745  ),),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(global.numFmt.format(dashboardData['transferCount']), style: TextStyle(
                                                fontSize: 20,
                                                color: Color(0xff28a745)
                                            ),),
                                            Wrap(
                                              spacing: 5.0,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.lens, size: 7.0, color: Color(0xff28a745),),
                                                Text("Transfers",
                                                  style: TextStyle(
                                                    color: Color(0xff6c7b95),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                splashColor: Color(0xff98e6ab),
                                onTap: (){
                                  print('hello world');
                                },
                              ),
                            ),
                            Card(
                              elevation: 2.0,
                              child: InkWell(
                                child: Container(
                                    width: 160,
                                    height: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(Icons.local_shipping, color: Color(0xff029ACF),),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(global.numFmt.format(dashboardData['purchaseCount']), style: TextStyle(
                                                fontSize: 20,
                                                color: Color(0xff029ACF)
                                            ),),
                                            Wrap(
                                              spacing: 5.0,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.lens, size: 7.0, color: Color(0xff029ACF),),
                                                Text("Purchase Orders",
                                                  style: TextStyle(
                                                    color: Color(0xff6c7b95),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                splashColor: Color(0xff81dcfe),
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return Delivery();
                                  }));
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height:20.0,
                        ),
                        Divider(
                          color: Color(0xFF1c4b82),
                          height: 1.0,
                        ),
                        GridView.count(
                          shrinkWrap: true,
                          primary: false,
                          padding: const EdgeInsets.all(5.0),
                          crossAxisSpacing: 1.0,
                          crossAxisCount: 3,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.list), onPressed: (){
                                  Navigator.of(context).pushNamed("inventory");
                                }),
                                Text("INVENTORY", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.content_paste), onPressed: (){
                                  Navigator.of(context).pushNamed("sales");
                                }),
                                Text("SALES", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.local_shipping), onPressed: (){
                                  Navigator.of(context).pushNamed("purchase");
                                }),
                                Text("PURCHASE", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.compare_arrows), onPressed: (){
                                  Navigator.of(context).pushNamed("transfer");
                                }),
                                Text("STOCK TRANSFER", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.dvr), onPressed: (){
                                  Navigator.of(context).pushNamed("price_update");
                                }),
                                Text("PRICE UPDATE", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.insert_drive_file), onPressed: (){
                                  Navigator.of(context).pushNamed("report");
                                }),
                                Text("REPORT", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(iconSize: 40, color: Color(0xff1c4b82), icon: Icon(Icons.power_settings_new), onPressed: (){
                                  Navigator.of(context).pop();
                                }),
                                Text("SIGN OUT", style: TextStyle(color:Color(0xff1c4b82), fontSize: 12 ),)
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  ) : Center(child: CircularProgressIndicator()) )
              ),
            ),
          )
      );
    });
  }

  void pickProfileImage() async{
    prefs = await SharedPreferences.getInstance();
    File image = await ImagePicker.pickImage(source: ImageSource.gallery,);
    final String documentPath = (await getApplicationDocumentsDirectory()).path;
    var filename = Path.basename(image.path);
    image.copy("$documentPath/$filename");
    prefs.setString("profilePixPath", "$documentPath/$filename");
    setState(() {
      profilePix = image;
    });
  }

  void setProfilePix() async{
    prefs = await SharedPreferences.getInstance();
    String profilePixPath = prefs.getString('profilePixPath');
    setState(() {
      profilePix = File(profilePixPath);
    });
  }

  Future<bool> logout(){
     return showDialog(
       context: context,
       builder: (context) => new AlertDialog(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.all(
             Radius.circular(10.0)
           )
         ),
         content: new Text('You are about to Logout?'),
         actions: <Widget>[
           new FlatButton(
             onPressed: () => Navigator.of(context).pop(false),
             child: new Text('No'),
           ),
           new FlatButton(
             onPressed: (){
               Navigator.of(context).pop(true);
             },
             child: new Text('Yes'),
           ),
         ],
       ),
     ) ?? false;
  }

}