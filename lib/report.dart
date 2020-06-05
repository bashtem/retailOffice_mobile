import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:retailoffice/global.dart';
import 'package:retailoffice/notification.dart';

var pickedReport;

class Report extends StatefulWidget{
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report>{
  String initialDate;
  String finalDate;
  List<DropdownMenuItem> reportTypes;
  GlobalFn global;
  List itemsList;
  Future getReportType;
  double totalAmount = 0;
  double totalQty = 0;
  int totalTicket = 0;


  @override
  void initState() {
    global = new GlobalFn();
    itemsList = [];
    initialDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    finalDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    reportTypes = <DropdownMenuItem>[
      DropdownMenuItem(child: Text("Top Sales Stocks"), value: 'topSales', ),
      DropdownMenuItem(child: Text("Top Customers (Volume)"), value: 'topCustomersVolume', ),
      DropdownMenuItem(child: Text("Top Customers (Amount)"), value: 'topCustomersAmount', ),
      DropdownMenuItem(child: Text("Top Customers (Tickets)"), value: 'topCustomersTickets', ),
    ];
    pickedReport = reportTypes[0].value;
    getReportType = global.getTopSales(initialDate, finalDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: getReportType,
      builder: (context, snapshot){
        if (snapshot.hasData) {
          totalAmount = 0;
          totalQty = 0;
          totalTicket = 0;
          itemsList = snapshot.data;
          itemsList.forEach((x){
            totalAmount+= double.parse(x['amount']);
            totalQty+= double.parse(x["qty"]);
            totalTicket+= ((x['tickets']) != null)? int.parse(x["tickets"]): 0;
          });
        }
         return Scaffold(
              appBar: AppBar(
                title: Text("Report"),
              ),
              body: Container(
                child: SizedBox.expand(
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        _dropDownReportTypes(),
                        FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                              side: BorderSide(color: Color(0xFF1c4b82))
                          ),
                          onPressed: () {
                            _showDate(context);
                          },
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(initialDate+'  -  '+finalDate),
                                ),
                                Icon(Icons.today, color: Color(0xFF1c4b82),)
                              ],
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.grey.withOpacity(0.3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Text(initialDate+'  -  '+finalDate,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12
                                    )), flex: 2,
                              ),
                              (((itemsList.length > 0) && (itemsList[0]['tickets'] != null))? Expanded(child: Text(totalTicket.toString(), style: TextStyle(color: Colors.red),), flex: 1,) : Text('')),
                              Expanded(child: Text(global.qtyFmt.format(totalQty), style: TextStyle(fontWeight: FontWeight.bold),), flex: 1,),
                              Expanded(child: Center(child: Text(global.priceFmt.format(totalAmount), style: TextStyle( fontWeight: FontWeight.bold, fontSize: 11))), flex: 1,),
                            ],
                          ),
                          padding: EdgeInsets.all(10.0),
                        ),
                        reportTypeWidget(snapshot, pickedReport),
                      ],
                    ),
                  ),
                ),
              )
          );
      }
    );
  }

  void reportFetch(){
    switch(pickedReport){
      case 'topSales' :
        getReportType = null;

        getReportType = global.getTopSales(initialDate, finalDate);
        break;
      case 'topCustomersVolume':
        getReportType = global.getTopCustomersVolume(initialDate, finalDate);
        break;
      case 'topCustomersAmount':
        getReportType = global.getTopCustomersAmount(initialDate, finalDate);
        break;
      case 'topCustomersTickets':
        getReportType = global.getTopCustomersTickets(initialDate, finalDate);
        break;
      default:
    }
  }

  void _showDate(context) async{
     List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: new DateTime.now(),
        initialLastDate: (new DateTime.now()),
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2050)
    );
    if(picked != null){
      setState(() {
        initialDate = DateFormat("yyyy-MM-dd").format(picked[0]);
        finalDate = DateFormat("yyyy-MM-dd").format(picked[1]);
        reportFetch();
      });
    }
  }

  Widget _dropDownReportTypes(){
    return DropdownButtonFormField(
      decoration: const InputDecoration(hoverColor: Color(0xff1c4b82),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0)
      ),
      value: pickedReport,
      items: reportTypes,
      onChanged: (value){
        setState(() {
          pickedReport = value;
          reportFetch();
        });
      },
    );
  }

  Widget reportTypeWidget(snapshot, reports){
    Widget reportType;
    switch(reports){
      case 'topSales' :
        reportType =  topSalesStock(snapshot);
        break;
      case 'topCustomersVolume':
        reportType =  topCustomersVolume(snapshot);
        break;
      case 'topCustomersAmount':
        reportType =  topCustomersAmount(snapshot);
        break;
      case 'topCustomersTickets':
        reportType =  topCustomersTickets(snapshot);
        break;
      default:
        reportType = Text('');
    }
    return reportType;
  }

  Widget topSalesStock(snapshot){
    return ((snapshot.hasData)? ((itemsList.length >= 1)?
    Expanded(
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: Text("NAME", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold)), flex: 2,),
                Expanded(child: Text("QUANTITY", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold),), flex: 1,),
                Expanded(child: Container(padding: EdgeInsets.only(left: 15.0),child: Text("AMOUNT", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold))), flex: 1,),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(itemBuilder: (context, index){
                 return Container(
                   padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 10.0, left: 5.0),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: Text(itemsList[index]['name'], softWrap: true), flex: 2,),
                        Expanded(child: Text(global.qtyFmt.format(double.parse(itemsList[index]["qty"]))), flex: 1,),
                        Expanded(child: Align( alignment: Alignment.centerRight,child: Text(global.priceFmt.format(double.parse(itemsList[index]["amount"])))), flex: 1,)
                      ],

                ),
                 );
              }, itemCount: itemsList.length, shrinkWrap: true, ),
            ),
          ),
        ],
      ),
    ) : Expanded( child: noRecords())) : Expanded(child:Center(child: CircularProgressIndicator())));
  }

  Widget topCustomersVolume(snapshot){
    return ((snapshot.hasData)? ((itemsList.length >= 1)?
    Expanded(
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: Text("NAME", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold)), flex: 2,),
                Expanded(child: Text("QUANTITY", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold),), flex: 1,),
                Expanded(child: Container(padding: EdgeInsets.only(left: 15.0), child: Text("AMOUNT", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold))), flex: 1,),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 10.0, left: 15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: Text(itemsList[index]['name'], softWrap: true), flex: 2,),
                        Expanded(child: Text(global.qtyFmt.format(double.parse(itemsList[index]["qty"]))), flex: 1,),
                        Expanded(child: Align(alignment: Alignment.centerRight, child: Text(global.priceFmt.format(double.parse(itemsList[index]["amount"])))), flex: 1,)
                      ],
                  ),
                );
              }, itemCount: itemsList.length, shrinkWrap: true, ),
            ),
          ),
        ],
      ),
    ) : Expanded( child: noRecords())) : Expanded(child:Center(child: CircularProgressIndicator())));
  }

  Widget topCustomersAmount(snapshot){
    return ((snapshot.hasData)? ((itemsList.length >= 1)?
    Expanded(
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: Text("NAME", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold)), flex: 2,),
                Expanded(child: Text("QUANTITY", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold),), flex: 1,),
                Expanded(child: Container(padding: EdgeInsets.only(left: 15.0), child: Text("AMOUNT", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold))), flex: 1,),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 10.0, left: 15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: Text(itemsList[index]['name'], softWrap: true), flex: 2,),
                        Expanded(child: Text(global.qtyFmt.format(double.parse(itemsList[index]["qty"]))), flex: 1,),
                        Expanded(child: Align(alignment: Alignment.centerRight, child: Text(global.priceFmt.format(double.parse(itemsList[index]["amount"])))), flex: 1,)
                      ],
                  ),
                );
              }, itemCount: itemsList.length, shrinkWrap: true, ),
            ),
          ),
        ],
      ),
    ) : Expanded( child: noRecords())) : Expanded(child:Center(child: CircularProgressIndicator())));
  }

  Widget topCustomersTickets(snapshot){
    return ((snapshot.hasData)? ((itemsList.length >= 1)?
    Expanded(
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: Text("NAME", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold)), flex: 2,),
                Expanded(child: Text("TKTS.", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold)), flex: 1,),
                Expanded(child: Text("QTY.", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold),), flex: 1,),
                Expanded(child: Container(padding: EdgeInsets.only(left: 8.0), child: Text("AMOUNT", style: TextStyle( color: Color(0xff1c4b82), fontWeight: FontWeight.bold))), flex: 1,),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(itemBuilder: (context, index){
                return  Container(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 10.0, left: 15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: Text(itemsList[index]['name'], softWrap: true, ), flex: 2,),
                        Expanded(child: Text((itemsList[index]["tickets"]).toString()?? '0', style: TextStyle(fontSize: 14, color: Colors.red),), flex: 1,),
                        Expanded(child: Text(global.qtyFmt.format(double.parse(itemsList[index]["qty"])), style: TextStyle(fontSize: 12)), flex: 1,),
                        Expanded(child: Align(alignment: Alignment.centerRight, child: Text(global.priceFmt.format(double.parse(itemsList[index]["amount"])), style: TextStyle(fontSize: 11),)), flex: 1,)
                      ],
                  ),
                );
              }, itemCount: itemsList.length, shrinkWrap: true, ),
            ),
          ),
        ],
      ),
    ) : Expanded( child: noRecords())) : Expanded(child:Center(child: CircularProgressIndicator())));
  }

}