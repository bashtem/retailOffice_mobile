import 'package:flutter/material.dart';
import 'global.dart';
import 'notification.dart';
import 'personalisedSearch.dart';
//import 'package:provider/provider.dart';

class StockMovement extends StatefulWidget{
  @override
  StockMovementState createState() => StockMovementState();
}

class StockMovementState extends State<StockMovement>{
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
  Widget build(BuildContext context){
    return FutureBuilder(builder: (context, snapshot){
      inventories = snapshot.hasData ? snapshot.data["inv"] : [];
      return Scaffold(
        appBar: AppBar(
          title: Text("Stock Movement"),
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
          child: Card(
            child: (snapshot.hasData ? (snapshot.data["inv"].length < 1 ? noRecords() :
            ListView.builder(itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(' '+global.qtyFmt.format(double.parse(inventories[index]['quantity'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
                    Wrap(
                      children: <Widget>[
                        Icon(Icons.shopping_cart, size: 15,),
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
        ),
      );
    }, future:inventoryFuture );
  }

  _pickItem(context, itemId){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return PickItem(itemId, (){
        inventoryFuture = global.getInventory();
        setState(() {});
      });
    }));
  }

  Widget searchMethod(var val){
    return (val.length < 1)? noRecords() : ListView.builder(itemBuilder: (context, index) {
      return ListTile(
        dense: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(' '+global.qtyFmt.format(double.parse(val[index]['quantity'])), style: TextStyle(color: Color(0xff1c4b82), fontWeight: FontWeight.bold),),
            Wrap(
              children: <Widget>[
                Icon(Icons.shopping_cart, size: 15,),
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
  List qtyTypesWidgets = new List();
  String itemName;
  var selectedData;
  Future _itemDetails;
  List stores = [];
  var checked;
  Map<int, TextEditingController> quantity = {};
  var selectedStore;
  var selectedUnit;
  final _formKeyStockMovement = GlobalKey<FormState>();
  var moveQty;



  @override
  void initState(){
    super.initState();
    global = GlobalFn();
    _itemDetails = global.selectedInv(widget.itemId);
    global.getStockMovementData().then((onValue){
      stores = onValue.map<DropdownMenuItem>((each) =>
          DropdownMenuItem(
            child: Text(each['title']),
            value: each['store_id'],
          )
      ).toList();
      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(future:_itemDetails, builder: (context, snapshot){
      if(snapshot.hasData) {
        selectedData = snapshot.data;
        qtyTypesWidgets =  selectedData['item_qty'].map<DropdownMenuItem>((item) =>
            DropdownMenuItem(
              child: Text(item['qty_type']['qty_desc']),
              value: item['qty_id'],
            )
        ).toList();
        itemName = selectedData['item_name'];
      }

      return Scaffold(
        appBar: AppBar(
          title: Text("Stock Movement", ),
        ),
        body: stores.length > 0 ? ((snapshot.hasData)?
        Container(
          child: SizedBox.expand(
            child: Card(
              child: Container(
                padding: EdgeInsets.only(left:15, right:15),
                child: Form(
                  key: _formKeyStockMovement,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      TextFormField(
                        initialValue: itemName,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: "Name:"
                        ),
                      ),
                      itemsQuantity(selectedData['item_qty']),
                      SizedBox(
                        height:20.0,
                      ),
                      Text("Select Store:",
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xff1c4b82)
                        ),
                      ),
                      DropDownWidget(stores, (pickedStore){
                        selectedStore = pickedStore;
                      }),
                      SizedBox(height: 20,),
                      Text("Select Unit:",
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xff1c4b82)
                        ),
                      ),
                      DropDownWidget(qtyTypesWidgets, (pickedUnit){
                        selectedUnit = pickedUnit;
                      }),
                      TextFormField(
                        onSaved: (value) => moveQty = value,
                        validator: (value){
                          return (value.isEmpty || double.parse(value) <= 0) ? "Invalid Quantity" : null;
                        },
                        decoration: InputDecoration(
                            labelText: "Quantity to Move:"
                        ),
                        keyboardType: TextInputType.numberWithOptions(),
                      ),

                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        child: Text("MOVE STOCK",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        ),
                        onPressed:(){
                          if(_formKeyStockMovement.currentState.validate()){
                              _formKeyStockMovement.currentState.save();
                              confirmDialog(context, (){
                                Navigator.of(context).pop();
                                var data = {"itemId":selectedData["item_id"], "receivingStoreId" : selectedStore, "qtyId" : selectedUnit, "quantity" : moveQty, "time" : global.time()};
                                global.stockMovement(context, data, (){
                                  widget.inventoryFn();
                                } );
                              });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ) : Center(child: CircularProgressIndicator())
        ):noRecords(msg:"No Store Found"),
      );
    }
    );
  }

  Widget itemsQuantity(List data){
    if(checked == null) {
      quantity.clear();
    }
    return Column(
      children : data.map((each){
        quantity.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['quantity'])) ));
        return TextField(
          readOnly: true,
          decoration: InputDecoration(
              labelText: each['qty_type']['qty_desc']+" Quantity:"
          ),
          controller: quantity[each['qty_type']['qty_id']],
        );
      }).toList(),
    );
  }

}

class DropDownWidget extends StatefulWidget{

  final List types;
  final selected;
  final Function callBack;
  DropDownWidget(this.types, this.callBack, {this.selected});

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget>{

  List<DropdownMenuItem> _menuItems;
  var picked;

  @override
  void initState() {
    super.initState();
    _menuItems = widget.types;
    var index = searchIndex(widget.selected);
    if(index != -1){
      picked = _menuItems[index].value;
    }else{
      picked = _menuItems[0].value;
    }
    widget.callBack(picked);
  }

  @override
  Widget build(BuildContext context){
    return DropdownButtonFormField(
      items: _menuItems,
      value: picked,
      onChanged: (selected){
        setState(() {
          picked = selected;
          widget.callBack(picked);
        });
      },
    );
  }

  int searchIndex(value){
    return  _menuItems.indexWhere((each)=> (each.value == value));
  }

}