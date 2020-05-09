import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'global.dart';
import 'notification.dart';
import 'personalisedSearch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:open_iconic_flutter/open_iconic_flutter.dart';


class Sales extends StatefulWidget{
  @override
  SalesState createState() => SalesState();
}

class SalesState extends State<Sales>{
  GlobalFn global;
  var salesLists;
  String dateValue = DateFormat("yyyy-MM-dd").format(DateTime.now());
  double totalSalesAmount = 0;

  @override
  Widget build(BuildContext context) {
    global = Provider.of<GlobalFn>(context);
    return FutureBuilder(future:global.salesHistory(dateValue), builder: (context, snapshot) {
      if (snapshot.hasData) {
        totalSalesAmount = 0;
        salesLists = snapshot.data;
        salesLists.forEach((x){
          totalSalesAmount+= double.parse(x['order_total_amount']);
        });
      }
      return Scaffold(
          appBar: AppBar(
            title: Text("Sales"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Search',
                onPressed: !snapshot.hasData ? null : (){
                  showSearch(context: context, delegate: SearchData(searchMethod, salesLists, 'cus_name', searchKeys: ['order_no', 'order_total_amount', 'cus_name', 'order_time', {'key':'payment', 'value':'payment_desc'}]));
                },
              )
            ],
          ),
          body: Container(
            child: Card(
              child: Column(
                children: <Widget>[
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
                            child: Text(dateValue),
                          ),
                          Icon(Icons.today, color: Color(0xFF1c4b82),)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    color: Colors.grey.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(dateValue,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(global.priceFmt.format(totalSalesAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    padding: EdgeInsets.all(10.0),
                  ),
                  Expanded(
                      child: ( (snapshot.hasData)? ( (salesLists.length >= 1)?
                      ListView.separated(
                        separatorBuilder: (context, index){
                          return Divider(
                            height: 0.0,
                            color: Color(0xFF1c4b82),
                          );
                        },
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          TimeOfDay salesTime = TimeOfDay.fromDateTime(DateTime.parse( salesLists[index]['order_date']+' '+salesLists[index]['order_time'] ));
                          return ListTile(
                            dense: true,
                            title: Text(salesLists[index]['cus_name'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14 ), ),
                            subtitle: Wrap(
                              children: <Widget>[
                                Text(salesLists[index]['order_no']+' | '+salesLists[index]['payment']['payment_desc']+' ' ),
                                Text(salesTime.format(context), style: TextStyle(color: Color(0xFF1c4b82), fontWeight: FontWeight.w500)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text('NGN '+global.priceFmt.format(double.parse(salesLists[index]['order_total_amount'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
                                Wrap(
                                  children: <Widget>[
                                    Icon(Icons.print, size: 15, color: Color(0xFF1c4b82),),
                                    Text(' P', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82)),)
                                  ],
                                )
                              ],
                            ),
                            onTap: () {
                              orderDetails(salesLists[index]);
                            },
                          );
                        }, itemCount: salesLists.length,) : noRecords()
                      ): Center(child: CircularProgressIndicator())
                      )
                  ),
                ]
              ),
            ),
          )
      );
    });
  }

  _showDate(BuildContext context) async{
    final DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050)
    );
    if(datePicked != null){
      setState(() {
        dateValue = DateFormat("yyyy-MM-dd").format(datePicked);
      });
    }
  }

  Widget searchMethod(var sales){
    return (sales.length < 1)? noRecords() : ListView.separated(
      separatorBuilder: (context, index){
        return Divider(
          height: 0.0,
          color: Color(0xFF1c4b82),
        );
      },
      shrinkWrap: true,
      itemBuilder: (context, index) {
        TimeOfDay salesTime = TimeOfDay.fromDateTime(DateTime.parse( sales[index]['order_date']+' '+sales[index]['order_time'] ));
        return ListTile(
          dense: true,
          title: Text(sales[index]['cus_name'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14 ), ),
          subtitle: Wrap(
            children: <Widget>[
              Text(sales[index]['order_no']+' | '+sales[index]['payment']['payment_desc']+' ' ),
              Text(salesTime.format(context), style: TextStyle(color: Color(0xFF1c4b82), fontWeight: FontWeight.w500)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('NGN '+global.priceFmt.format(double.parse(sales[index]['order_total_amount'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
              Wrap(
                children: <Widget>[
                  Icon(Icons.print, size: 15, color: Color(0xFF1c4b82),),
                  Text(' P', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82)),)
                ],
              )
            ],
          ),
          onTap: () {
            orderDetails(sales[index]);
          },
        );
      }, itemCount: sales.length,);
  }

  orderDetails(order){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      TimeOfDay salesTime = TimeOfDay.fromDateTime(DateTime.parse( order['order_date']+' '+order['order_time'] ));
      return Scaffold(
        appBar: AppBar(
          title: Text("Order Detail"),
        ),
        body: Container(
          child: Card(
            child: Column(
              children: <Widget>[
                Container(
                  color: Color(0xff1c4b82),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text("Sale Order # - "+order['order_no'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                      Text("NGN "+global.priceFmt.format(double.parse(order['order_total_amount'])),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                ),
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      title: Wrap(
                        children: <Widget>[
                          Icon(Icons.person, size: 16, color: Color(0xFF1c4b82),),
                          Text(" Customer:",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82)) ,
                          )
                        ],
                      ),
                      subtitle: Text(order['cus_name'], style: TextStyle(fontSize: 15),),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Icon(Icons.blur_on, size: 16, color: Color(0xFF1c4b82),),
                              Text("Receipt No:",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82))
                              )
                            ],
                          ),
                          Text("R"+order['order_id'].toString(),
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                      color: Color(0xFF1c4b82),
                    ),
                    ListTile(
                      title: Text("Order Date",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15
                        ),
                      ),
                      subtitle: Wrap(
                        children: <Widget>[
                          Icon(Icons.today, size: 16, color: Color(0xFF1c4b82),),
                          Text("Timestamp: "+order['order_date']+" "+salesTime.format(context),
                            style: TextStyle(
                              color: Color(0xFF1c4b82),
                            ),
                          )
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(' Status',
                            style: TextStyle(
                                color: Colors.grey
                            ),
                          ),
                          Wrap(
                            children: <Widget>[
                              Icon(Icons.print, size: 15, color: Color(0xFF1c4b82),),
                              Text(' P', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82)),)
                            ],
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                      color: Color(0xFF1c4b82),
                    ),
                    ListTile(
                      title: Text("Amount Paid",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15
                        ),
                      ),
                      subtitle: Wrap(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.moneyBillAlt, size: 16, color: Color(0xFF1c4b82),),
                          Text("  "+global.priceFmt.format(double.parse(order['order_total_amount'])),
                            style: TextStyle(
                              color: Color(0xFF1c4b82),
                            ),
                          )
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(' Balance Owned',
                            style: TextStyle(
                                color: Colors.grey
                            ),
                          ),
                          Wrap(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.moneyCheckAlt, size: 15, color: Color(0xFF1c4b82),),
                              Text('  0', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82)),)
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Color(0xff1c4b82),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text("Orders",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                      Icon(
                        Icons.apps,
                        color: Colors.white,
                        size: 14,
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: order['items'].length,
                    itemBuilder: (context, index){
                      return ListTile(
                        title: Text(order['items'][index]['item']['item_name'],
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14
                          ),
                        ),
                        subtitle: Wrap(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.box,
                              size: 13,
                              color: Color(0xffee4540),
                            ),
                            Text("  "),
                            Text(global.qtyFmt.format(double.parse(order['items'][index]['quantity']))+" "+order['qty']['qty_desc'],
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82))
                            )
                          ],
                        ),
                        trailing: Text(global.priceFmt.format(double.parse(order['items'][index]['amount'])),
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w700
                          ),
                        ),
                      );
                  }, )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Color(0xff1c4b82),
                      child: Text("CANCLE ORDER",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                      onPressed: (){
                        cancleOrder(order['order_id']);
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    RaisedButton(
                      color: Color(0xff1c4b82),
                      child: Text("RE-PRINT",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                      onPressed: (){
                        global.reprintReceipt(context, order['order_id'].toString());
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    RaisedButton(
                      color: Color(0xff1c4b82),
                      child: Text("BACK",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }));
  }

  void cancleOrder(orderId){
    confirmDialogWithText(context, (String comment) async{
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      var data = await global.cancleSalesOrder(context, orderId, comment);
      if(data['status'] == true){
        successNotify(context, data['response']);
        setState(() { });
      }else{
        failureNotify(context, data['response']);
      }
    });
  }

}