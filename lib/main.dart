import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retailoffice/create_store.dart';
import 'package:retailoffice/stock_movement.dart';
import 'global.dart';
import 'login.dart';
import 'inventory.dart';
import 'sales.dart';
import 'price_update.dart';
import 'supplier.dart';
import 'customer.dart';
import 'manage_user.dart';
import 'purchase.dart';
import 'report.dart';
import 'history.dart';
import 'transfer.dart';
import 'tickets.dart';
//import 'package:flutter_toast_pk/flutter_toast_pk.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    runApp(RetailOffice());
}

class RetailOffice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalFn(),
      child: MaterialApp(
          theme: ThemeData(
              appBarTheme: AppBarTheme(color: Color(0xff1c4b82)),
              primaryColor: Color(0xff1c4b82),
              accentColor: Color(0xff1c4b82),
              indicatorColor: Color(0xff1c4b82),
              cardTheme: CardTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                )
              ),
          ),
          debugShowCheckedModeBanner: false,
          title: "RetailOffice",
          home: LandingPage(),
          routes: <String, WidgetBuilder>{
            "login" : (BuildContext context) => Login(),
            "inventory" : (BuildContext context)=>Inventory(),
            "sales" : (BuildContext context)=>Sales(),
            'price_update' : (BuildContext context) => PriceUpdate(),
            "supplier" : (BuildContext context)=>Supplier(),
            "purchase" : (BuildContext context)=>Purchase(),
            "transfer" : (BuildContext context)=>Transfer(),
            "customer" : (BuildContext context)=>Customer(),
            "user" : (BuildContext context)=>ManageUser(),
            "history" : (BuildContext context)=>History(),
            "report" : (BuildContext context)=>Report(),
            "ticket" : (BuildContext context)=>Ticket(),
            "stock_movement" : (BuildContext context)=>StockMovement(),
            "create_store" : (BuildContext context)=>CreateStore(),
          },
      ),
    );
  }
}


class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Container(
            child:  Login(),
          ),
        )
    );
  }
}
