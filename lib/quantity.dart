import 'package:flutter/material.dart';
import 'global.dart';
import 'notification.dart';
import 'personalisedSearch.dart';


class Quantity extends StatefulWidget{
  @override
  QuantityState createState() => QuantityState();
}

class QuantityState extends State<Quantity> {
  GlobalFn global;
  List topItems;
  double totalItems = 0;

  @override
  void initState() {
    global = GlobalFn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: global.getTopQuantity(), builder: (context, snapshot) {
      if (snapshot.hasData) {
        totalItems = 0;
        topItems = snapshot.data;
        topItems.forEach((x){
          totalItems+= double.parse(x['quantity']);
        });
      }
      return Scaffold(
          appBar: AppBar(
            title: Text("Top Items Quantity"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Search',
                onPressed: !snapshot.hasData ? null : () {
                  showSearch(context: context,
                    delegate: SearchData(searchMethod, topItems, 'item_name', searchKeys: ['item_name','quantity'])
                  );
                },
              )
            ],
          ),
          body: Container(
            child: Card(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.grey.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text("Total Quantity:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(global.qtyFmt.format(totalItems),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    padding: EdgeInsets.all(10.0),
                  ),
                  Expanded(
                    child: (snapshot.hasData ? (topItems.length < 1 ? noRecords() :
                    ListView.builder(itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SizedBox(child: Text((index + 1).toString()), width: 30.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(topItems[index]['item_name'], style: TextStyle(fontSize: 14),),
                                        Text(topItems[index]['qty_desc']),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Wrap(
                                      children: <Widget>[
                                        Icon(Icons.shopping_cart, size: 15,),
                                        Text(' '+global.qtyFmt.format(double.parse(topItems[index]['quantity'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    Wrap(
                                      children: <Widget>[
                                        Text('NGN '+global.priceFmt.format(double.parse(topItems[index]['max_price'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold), ),
//                                        Icon(Icons.shopping_cart, size: 15,),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 0.3,
                              color: Color(0xff1c4b82),
                            )
                          ],
                        ),
                      );
                    }, itemCount: topItems.length,) ): Center(child: CircularProgressIndicator())
                    ),
                  ),
                ],
              ),
            ),
          )
      );
    });
  }

  Widget searchMethod(List topItemsList){
    return (topItemsList.length < 1)? noRecords() : ListView.builder(itemBuilder: (context, index) {
      return ListTile(
        dense: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(' '+global.qtyFmt.format(double.parse(topItemsList[index]['quantity'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
            Wrap(
              children: <Widget>[
                Icon(Icons.shopping_cart, size: 15,),
              ],
            )
          ],
        ),
        subtitle: Row(
          children: <Widget>[
            SizedBox(width: 30.0,),
            Text(topItemsList[index]['qty_desc']),
          ],
        ),
        title: Row(
          children: <Widget>[
            SizedBox(child: Text((index + 1).toString()), width: 30.0,),
            Text(topItemsList[index]['item_name'], style: TextStyle(fontSize: 14),),
          ],
        ),
      );
    }, itemCount: topItemsList.length,);
  }

}