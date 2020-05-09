import 'package:flutter/material.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'notification.dart';
import 'personalisedSearch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class Ticket extends StatefulWidget{
  @override
  TicketState createState() => TicketState();
}

class TicketState extends State{
  GlobalFn global;
  var ticketLists;
  String dateValue = DateFormat("yyyy-MM-dd").format(DateTime.now());

  @override
  void initState() {
    super.initState();
    global = GlobalFn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future:global.salesHistory(dateValue), builder: (context, snapshot) {
      if (snapshot.hasData) {
        ticketLists = snapshot.data;
      }
      return Scaffold(
          appBar: AppBar(
            title: Text("Tickets"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Search',
                onPressed: !snapshot.hasData ? null : (){
                  showSearch(context: context, delegate: SearchData(searchMethod, ticketLists, 'order_no', searchKeys: ['order_no', 'order_total_amount', 'cus_name', 'order_time', {'key':'payment', 'value':'payment_desc'}]));
                },
              )
            ],
          ),
          body: Container(
            child: Card(
              child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15.0,
                    ),
                    Expanded(
                        child: ( (snapshot.hasData)? ( (ticketLists.length >= 1)?
                        ListView.separated(
                          separatorBuilder: (context, index){
                            return Divider(
                              height: 0.0,
                              color: Color(0xFF1c4b82),
                            );
                          },
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            TimeOfDay salesTime = TimeOfDay.fromDateTime(DateTime.parse( ticketLists[index]['order_date']+' '+ticketLists[index]['order_time'] ));
                            return ListTile(
                              dense: true,
                              title: Text(ticketLists[index]['order_no']+' | '+ticketLists[index]['payment']['payment_desc'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14 ), ),
                              subtitle: Wrap(
                                children: <Widget>[
                                  Text(ticketLists[index]['cus_name']+' ' ),
                                  Text(salesTime.format(context), style: TextStyle(color: Color(0xFF1c4b82), fontWeight: FontWeight.w500)),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text('NGN '+global.priceFmt.format(double.parse(ticketLists[index]['order_total_amount'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
                                  Wrap(
                                    children: <Widget>[
                                      Icon(Icons.print, size: 15, color: Color(0xFF1c4b82),),
                                      Text(' P', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1c4b82)),)
                                    ],
                                  )
                                ],
                              ),
                              onTap: () {
                                orderDetails(ticketLists[index]);
                              },
                            );
                          }, itemCount: ticketLists.length,) : noRecords()
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
          title: Text(sales[index]['order_no']+' | '+sales[index]['payment']['payment_desc'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14 ), ),
          subtitle: Wrap(
            children: <Widget>[
              Text(sales[index]['cus_name']+' ' ),
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


