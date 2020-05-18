import 'package:flutter/material.dart';
import 'global.dart';
import 'notification.dart';
import 'personalisedSearch.dart';


class PriceUpdate extends StatefulWidget{
  @override
  PriceUpdateState createState() => PriceUpdateState();
}

class PriceUpdateState extends State<PriceUpdate>{
  GlobalFn global;
  var inventories;
  Future inventoryFuture;

  @override
  void initState() {
    super.initState();
    global = GlobalFn();
    inventoryFuture = global.getInventory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot){
      inventories = snapshot.hasData ? snapshot.data["inv"] : [];
      return Scaffold(
        appBar: AppBar(
          title: Text("Price Update"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: !snapshot.hasData ? null : (){
                showSearch(context: context, delegate: SearchData(searchMethod, inventories, 'item_name'));
              },
            )
          ],
        ),
        body: Container(
          child: (snapshot.hasData ? (snapshot.data["inv"].length < 1 ? noRecords() :
          ListView.builder(itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('NGN '+global.priceFmt.format(double.parse(inventories[index]['max_price'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold), ),
                  Wrap(
                    children: <Widget>[
                      Icon(Icons.shopping_cart, size: 15,),
                      Text(' '+global.qtyFmt.format(double.parse(inventories[index]['quantity'])))
                    ],
                  )
                ],
              ),
              subtitle: Text(inventories[index]['default_unit']['qty_desc']),
              leading: Text((index + 1).toString()),
              title: Text(inventories[index]['item_name'], style: TextStyle(fontSize: 14),),
              onTap: () {
                String itemId = inventories[index]['item_id'].toString();
                _pickItem(context, itemId);
              },
            );
          }, itemCount: snapshot.data["inv"].length,) ): Center(child: CircularProgressIndicator())
          ),
        ),
      );
    }, future:inventoryFuture );
  }

  Widget searchMethod(List val){
    return (val.length < 1)? noRecords() : ListView.builder(itemBuilder: (context, index) {
      return ListTile(
        dense: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('NGN '+global.priceFmt.format(double.parse(val[index]['max_price'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold), ),
            Wrap(
              children: <Widget>[
                Icon(Icons.shopping_cart, size: 15,),
                Text(' '+global.qtyFmt.format(double.parse(val[index]['quantity'])))
              ],
            )
          ],
        ),
        subtitle: Text(val[index]['default_unit']['qty_desc']),
        leading: Text((index + 1).toString()),
        title: Text(val[index]['item_name'], style: TextStyle(fontSize: 14),),
        onTap: () {
          String itemId = val[index]['item_id'].toString();
          _pickItem(context, itemId);
        },
      );
    }, itemCount: val.length,);
  }

  _pickItem(context, itemId){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return PickItem(itemId, (){
        inventoryFuture = global.getInventory();
        setState(() {});
      });
    }));
  }

}

class PickItem extends StatefulWidget{
  final String itemId;
  final Function inventoryFn;
  PickItem(this.itemId, this.inventoryFn);
  @override
  _PickItemState createState() => _PickItemState();
}

class _PickItemState extends State<PickItem> {
  GlobalFn global;
  TextEditingController itemName;
  var selectedData;
  Future _itemDetails;
  var checked;
  Map<int, TextEditingController> quantity;
  Map<int, TextEditingController> costToSell;
  Map<int, TextEditingController> costPrice;
  Map<int, TextEditingController> salePrice;
  Map<String, TextEditingController> tieredQty;
  Map<String, TextEditingController> tieredPrice;
  List tieredPricesQty;



  @override
  void initState(){
    super.initState();
    global = GlobalFn();
    itemName = TextEditingController();
    _itemDetails = global.selectedInv(widget.itemId);
    quantity = {};
    costToSell = {};
    costPrice = {};
    salePrice = {};
    tieredQty = {};
    tieredPricesQty = [];
    tieredPrice = {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future:_itemDetails, builder: (context, snapshot){
      if(snapshot.hasData) {
        selectedData = snapshot.data;
        if(checked == null){
          itemName.text = selectedData['item_name'];
        }
      }
      return Scaffold(
        appBar: AppBar(
          title: Text("Price Update", ),
        ),
        body: ((snapshot.hasData)?
        Container(
          child: Card(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left:15, right:15),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: "Name:"
                          ),
                          controller: itemName,
                        ),
                        SizedBox(
                          height:15.0,
                        ),
                        Text("Last updated : "+selectedData['updated_at'], style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        itemsPrices(selectedData['item_qty']),
                        SizedBox(
                          height:25.0,
                        ),
                        RaisedButton(
                          child: Text("SAVE",
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          onPressed: (){
                            updatePrice(selectedData['item_qty']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) : Center(child: CircularProgressIndicator())
        ),
      );
    });
  }

  void updatePrice(List data){

    tieredPricesQty.clear();
    var prices = data.map((each){
      [0,1,2].forEach((iter){
        String id = (each['item_tiered_price'].length > iter)? each['item_tiered_price'][iter]['id'].toString() : each['qty_type']['qty_id'].toString()+iter.toString()+"_";
        String tieredId = (each['item_tiered_price'].length > iter)? each['item_tiered_price'][iter]['id'].toString() : '0';
        tieredPricesQty.add({'id' : tieredId, 'qtyId' : each['qty_type']['qty_id'], 'qty' : tieredQty[id].text, 'price' : tieredPrice[id].text });
      });
      return {'qtyId':each['qty_type']['qty_id'], 'costToSell':costToSell[each['qty_type']['qty_id']].text, 'costPrice':costPrice[each['qty_type']['qty_id']].text, 'salePrice':salePrice[each['qty_type']['qty_id']].text};
    }).toList();

    global.priceUpdate.addAll({'itemId':selectedData['item_id'], 'prices':prices, 'tieredData' : tieredPricesQty});
    global.updatePrice(context).whenComplete((){
      widget.inventoryFn();
    });
  }

  Widget itemsPrices(List data){
    if(checked == null) {
      costToSell.clear();
      costPrice.clear();
      salePrice.clear();
      tieredQty.clear();
      tieredPrice.clear();
      checked = true;
    }
    return Column(
      children: data.map((each){
        quantity.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['quantity'])) ));
        costToSell.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['item_price']['min_price'])) ));
        costPrice.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['item_price']['price'] ))));
        salePrice.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['item_price']['max_price'])) ));
        [0,1,2].forEach((iter){
            var id = (each['item_tiered_price'].length > iter)? each['item_tiered_price'][iter]['id'].toString() : each['qty_type']['qty_id'].toString()+iter.toString()+"_";
            tieredQty.putIfAbsent(id, ()=>TextEditingController(text: ((each['item_tiered_price'].length > 0) && (each['item_tiered_price'].length > iter) )? global.genQtyFmt.format(double.parse(each['item_tiered_price'][iter]['qty'])) : '0') );
            tieredPrice.putIfAbsent(id, ()=>TextEditingController(text: ((each['item_tiered_price'].length > 0) && (each['item_tiered_price'].length > iter) )? global.genQtyFmt.format(double.parse(each['item_tiered_price'][iter]['price'])) : '0') );
        });
        return Column(
          children: <Widget>[
            Container(
              color: Color(0xff1c4b82),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(each['qty_type']['qty_desc'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ],
              ),
              padding: EdgeInsets.all(10.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: 100,
                  child: TextField(
                    readOnly: true,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        labelText: "QTY"
                    ),
                    controller: quantity[each['qty_type']['qty_id']],
                  ),
                ),
                Container(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        labelText: "Cost To Sell"
                    ),
                    controller: costToSell[each['qty_type']['qty_id']],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        labelText: "Cost Price"
                    ),
                    controller: costPrice[each['qty_type']['qty_id']],
                  ),
                ),
                Container(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        labelText: "Sale Price"
                    ),
                    controller: salePrice[each['qty_type']['qty_id']],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Column(
              children: [ for(var i = 0; i < 3; i++)
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                      Container(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                            labelText: "Quantity"
                          ),
                          controller: tieredQty[(each['item_tiered_price'].length > i)? each['item_tiered_price'][i]['id'].toString() : each['qty_type']['qty_id'].toString()+i.toString()+"_"],
                        ),
                      ),
                      Container(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                             labelText: "Price Tiered"
                          ),
                          controller: tieredPrice[(each['item_tiered_price'].length > i)? each['item_tiered_price'][i]['id'].toString() : each['qty_type']['qty_id'].toString()+i.toString()+"_"],
                        ),
                      ),
                  ],
                )
              ]
            ),

            SizedBox(
              height: 15.0,
            ),
          ],
        );
      }
      ).toList(),
    );
  }

}