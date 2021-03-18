import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'global.dart';
import 'notification.dart';

class History extends StatefulWidget{
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin{

  String dateValue = DateFormat("yyyy-MM-dd").format(DateTime.now());
  TabController historyTab;
  GlobalFn global;
  var salesLists;
  var transferLists;
  var purchaseLists;
  var stockMovementList;
  var orderId, purchaseId, itemId, transferId;

  @override
  void initState(){
    super.initState();
    historyTab = TabController(length: 4, vsync: this);
    global = GlobalFn();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: Text("History"),
          bottom: TabBar(
            indicatorColor: Colors.white,
              labelColor: Colors.white,
              controller: historyTab,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  child: Text("Sales", style: TextStyle(fontSize: 12),),
                ),
                Tab(
                  icon: Icon(Icons.compare_arrows, color: Colors.white),
                  child: Text("Transfers", style: TextStyle(fontSize: 12),),
                ),
                Tab(
                  icon: Icon(Icons.local_shipping, color: Colors.white,),
                  child: Text("Purchases", style: TextStyle(fontSize: 12),),
                ),
                Tab(
                  icon: Icon(Icons.child_friendly, color: Colors.white,),
                  child: Text("Movement", style: TextStyle(fontSize: 12),),
                ),
              ]
          ),
        ),
        body: TabBarView(
          controller: historyTab,
          children: [
            Container(
              child: Card(
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),side: BorderSide(color: Color(0xFF1c4b82))
                      ),
                      onPressed:(){
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
                    Expanded(
                      child: FutureBuilder(future: global.salesHistory(dateValue), builder: (context, snapshot){
                          if(snapshot.hasData){
                            salesLists = snapshot.data;
                              if(salesLists.length >= 1) {
                                return ListView.builder(
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(salesLists[index]['order_no']),
                                      subtitle: Text(salesLists[index]['cus_name']),
                                      trailing: Text(global.priceFmt.format(double.parse(salesLists[index]['order_total_amount']))),
                                      onTap: () {
//                                        viewOrder(salesLists[index]);
                                      },
                                    );
                                  }, itemCount: salesLists.length,);
                              }else{
                                  return noRecords();
                              }
                          }else{
                            return Center(child: CircularProgressIndicator());
                          }
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                child: Card(
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),side: BorderSide(color: Color(0xFF1c4b82))
                        ),
                        onPressed:(){
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
                      Expanded(
                        child: FutureBuilder(future:global.transferHistory(dateValue), builder: (context, snapshot){
                          if(snapshot.hasData){
                            transferLists = snapshot.data;
                            if(transferLists.length >= 1) {
                              return ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(transferLists[index]['user']['name']),
                                    subtitle: Text(transferLists[index]['transfer_date']+"  "+transferLists[index]['transfer_time']),
                                    trailing: Text(transferLists[index]['transfer_status']),
                                    onTap: (){
//                                      viewTransfer();
                                    },
                                  );
                                }, itemCount: transferLists.length,);
                            }else{
                              return noRecords();
                            }
                          }else{
                            return Center(child: CircularProgressIndicator());
                          }
                        }),

                      ),
                    ],
                  ),
                ),
            ),
            Container(
              child: Card(
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),side: BorderSide(color: Color(0xFF1c4b82))
                      ),
                      onPressed:(){
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
                    Expanded(
                      child: FutureBuilder(future:global.purchaseHistory(dateValue), builder: (context, snapshot){
                        if(snapshot.hasData){
                          purchaseLists = snapshot.data;
                          if(purchaseLists.length >= 1) {
                            return ListView.builder(
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  title: Text(purchaseLists[index]['supplier']['sup_company_name']),
                                  subtitle: Text(purchaseLists[index]['purchase_date']+"  "+purchaseLists[index]['purchase_time']+"  |  "+purchaseLists[index]['payment']['payment_desc']),
                                  trailing: Text(purchaseLists[index]['qty']['qty_desc']),
                                  onTap: (){
                                    viewPurchase(purchaseLists[index]);
                                  },
                                );
                              }, itemCount: purchaseLists.length,);
                          }else{
                            return noRecords();
                          }
                        }else{
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Card(
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),side: BorderSide(color: Color(0xFF1c4b82))
                      ),
                      onPressed:(){
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
                    Expanded(
                      child: FutureBuilder(future:global.stockMovementHistory(dateValue), builder: (context, snapshot){
                        if(snapshot.hasData){
                          stockMovementList = snapshot.data;
                          if(stockMovementList.length >= 1) {
                            return ListView.separated(
                              separatorBuilder: (context, index){
                                return Divider(color: Color(0xff1c4b82), height: 0.0,);
                              },
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  title: (Provider.of<GlobalFn>(context).getSession.storeId.toString() == stockMovementList[index]['receiving_store_id'])? Text(stockMovementList[index]['transfer_store']['title']) : Text(stockMovementList[index]['receive_store']['title']),
                                  subtitle: Row(
                                    children: <Widget>[
                                      (Provider.of<GlobalFn>(context).getSession.storeId.toString() == stockMovementList[index]['receiving_store_id'])? Text("STOCK IN ", style: TextStyle(color: Colors.green, ),) : Text("STOCK OUT ", style: TextStyle(color: Colors.red, ),),
                                      (Provider.of<GlobalFn>(context).getSession.storeId.toString() == stockMovementList[index]['receiving_store_id'])? Icon(Icons.arrow_downward, size: 14, color: Colors.green,) : Icon(Icons.arrow_upward, size: 14, color: Colors.red,)
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(stockMovementList[index]['item']['item_name'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),),
                                      Wrap(
                                        children: <Widget>[
                                          Icon(Icons.shopping_cart, size: 15,),
                                          Text(' '+global.qtyFmt.format(double.parse(stockMovementList[index]['quantity']))+" "+stockMovementList[index]['qty_type']['qty_desc'], style: TextStyle(fontSize: 13, color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: (){ },
                                );
                              }, itemCount: stockMovementList.length,);
                          }else{
                            return noRecords();
                          }
                        }else{
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ]
        )
    );
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

  void viewOrder(order){
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
              height: 200,
              padding: EdgeInsets.only(left:20.0, right:20.0, top:20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Customer:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(order['cus']['cus_name'])
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),Row(
                    children: <Widget>[
                      Expanded(child: Text("Order No:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(order['order_no'])
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Unit:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(order['qty']['qty_desc'])
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Total Quantity:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(global.qtyFmt.format(double.parse(order['order_total_qty'])))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Total Amount:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(global.qtyFmt.format(double.parse(order['order_total_amount'])))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Payment:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(order['payment']['payment_desc'])
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Order Status:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(order['order_status'], style: TextStyle(fontStyle: FontStyle.italic),)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Date:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(order['order_date'])
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              constraints:BoxConstraints(
                minWidth: 300,
                minHeight: 100,
                maxWidth: 300,
                maxHeight: 250,
              ),
              padding: EdgeInsets.only(left:20.0, right:20.0,top:5.0),
              child: ListView.builder(shrinkWrap: true,itemBuilder: (context, index){
                return ListTile(
                  dense: true,
                  title: Text(order['items'][index]['item']['item_name']),
                  subtitle: Text("Quantity: "+ global.qtyFmt.format(double.parse(order['items'][index]['quantity'])) ),
                  trailing: Text(global.qtyFmt.format(double.parse(order['items'][index]['amount']))),
                );
              }, itemCount: order['items'].length ,)
            ),
            Divider(),
            ( order['order_status'] != 'CANCLED' ? Padding(
              padding: const EdgeInsets.only(left:20.0, right:20.0),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                color: Color(0xFF540e33),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Cancle Order",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: (){
                  orderId = order['order_id'];
                  confirmDialog(context, cancleSalesOrder);
                },
              ),
            ) : Text('') )
          ],
        );
      },
    );
  }

  void viewTransfer(){
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
              constraints:BoxConstraints(
                minWidth: 300,
                minHeight: 100,
                maxWidth: 300,
                maxHeight: 400,
              ),
              padding: EdgeInsets.all(20.0),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[


                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left:20.0, right:20.0),
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                color: Color(0xFF540e33),
                onPressed: (){
                  print('Clear');
                },
                child: new Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Cancle Transfer",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void viewPurchase(purchase){
    var purchaseItems = purchase['purchase_order_item'];
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
              constraints:BoxConstraints(
                minWidth: 300,
                minHeight: 100,
                maxWidth: 300,
                maxHeight: 500,
              ),
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder:(context, index){
                    var purchaseAmount = global.priceFmt.format( double.parse(purchaseItems[index]['purchase_qty']) * double.parse(purchaseItems[index]['purchase_price']) );
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      elevation: 3.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left:5.0, top:5.0, bottom: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: 1.0, color: Color(0xff1f3c88)),
                                        )
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text(purchaseItems[index]['items']['item_name'], style: TextStyle(fontSize: 18.0), ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:2.0, bottom: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Quantity:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(global.qtyFmt.format(double.parse(purchaseItems[index]['purchase_qty'])))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:2.0, bottom: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Price:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(global.priceFmt.format(double.parse(purchaseItems[index]['purchase_price'])))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:2.0, bottom: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Amount:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(purchaseAmount, style: TextStyle(color: Color(0xFF540e33)),)
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:2.0, bottom: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Status:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(purchaseItems[index]['purchase_status'], style: TextStyle(color: Color(0xFF540e33)),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ( (purchaseItems[index]['purchase_status'] == 'CANCLED')? Text(''): Container(
                            child: IconButton(
                              color: Color(0xFF540e33),
                              icon: Icon(Icons.cancel),
                              onPressed: (){
                                purchaseId = purchase['purchase_id'];
                                itemId = purchaseItems[index]['item_id'];
                                confirmDialog(context, canclePurchase);
                              },
                            ),
                          ))
                        ],
                      ),
                    );
                  },
                itemCount: purchaseItems.length,
              ),
            ),
            Divider(),
            ( (purchase['cancled_date'] == null) ? Padding(
              padding: const EdgeInsets.only(left:20.0, right:20.0),
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                color: Color(0xFF540e33),
                onPressed: (){
                  purchaseId = purchase['purchase_id'];
                  confirmDialog(context, cancleAllPurchase);
                },
                child: new Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Cancle Purchase",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ) : Text('')),
          ],
        );
      },
    );
  }

  cancleSalesOrder() async{
    Navigator.of(context).pop();
    Navigator.of(context).pop();
//    var data = await global.cancleSalesOrder(context, orderId);
//    if(data['status'] == true){
//      successNotify(context, data['response']);
//      setState(() { });
//    }else{
//      failureNotify(context, data['response']);
//    }
  }

  canclePurchase() async{
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    var data = await global.canclePurchase(context, purchaseId, itemId);
    if(data['status'] == true){
      successNotify(context, data['response']);
      setState(() { });
    }else{
      failureNotify(context, data['response']);
    }
  }

  cancleAllPurchase() async{
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    var data = await global.cancleAllPurchase(context, purchaseId);
    if(data['status'] == true){
      successNotify(context, data['response']);
      setState(() { });
    }else{
      failureNotify(context, data['response']);
    }
  }

  cancleTransfer() async{
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    var data = await global.cancleTransfer(context, transferId);
    if(data['status'] == true){
      successNotify(context, data['response']);
      setState(() { });
    }else{
      failureNotify(context, data['response']);
    }
  }

  cancleEachTransfer()async{

  }

}