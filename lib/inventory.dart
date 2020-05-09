import 'package:flutter/material.dart';
import 'dart:core';
import 'personalisedSearch.dart';
import 'global.dart';
import 'notification.dart';
//import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';


class Inventory extends StatefulWidget{
  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory>{
  GlobalFn global;
  TextEditingController itemName;
  List<DropdownMenuItem> itemCategory;
  var inventories;
  Future inventoryFuture;

  @override
  void initState() {
    super.initState();
    itemName = TextEditingController();
    global = GlobalFn();
    inventoryFuture = global.getInventory();
  }

  @override
  Widget build(BuildContext context){
   return FutureBuilder(builder: (context, snapshot){
   inventories = snapshot.hasData ? snapshot.data["inv"] : [];
   itemCategory = snapshot.hasData? snapshot.data['category'].map<DropdownMenuItem>((category) =>
       DropdownMenuItem(
         child: Text(category['cat_desc']),
         value: category['cat_id'],
       )).toList() : [];
   return Scaffold(
      floatingActionButton:FloatingActionButton(
        backgroundColor: Color(0xff1c4b82),
          child: Icon(Icons.add_shopping_cart),
          onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context){
                  return addItem();
                })
              );
          }
      ),
       appBar: AppBar(
       title: Text("Inventory"),
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
                String itemName = inventories[index]['item_name'];
                _pickItem(context, itemId, itemName, itemCategory);
              },
            );
          }, itemCount: snapshot.data["inv"].length,) ): Center(child: CircularProgressIndicator())
       ),
     ),
   );
   }, future:inventoryFuture );
 }

  _pickItem(context, itemId, name, itemCategory){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return PickItem(itemId, name, itemCategory, (){
        inventoryFuture = global.getInventory();
        setState(() {});
      });
    }));
  }

  Widget addItem(){
   return Scaffold(
     appBar: AppBar(
       title: Text("Add Item"),
     ),
     body: FutureBuilder(
       builder: (context, snapshot){
         if(snapshot.hasData) {
           itemCategory = snapshot.data.map<DropdownMenuItem>((category) =>
               DropdownMenuItem(
                 child: Text(category['cat_desc']),
                 value: category['cat_id'],
               )).toList();
           return Container(
             child: Card(
               child: Column(
                 children: <Widget>[
                   Padding(
                     padding: const EdgeInsets.only(
                         left: 18.0, right: 18.0, bottom: 18.0),
                     child: TextField(
                       controller: itemName,
                       decoration: InputDecoration(labelText: "Item Name"),
                     ),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(
                         left: 18.0, right: 18.0, bottom: 18.0),
                     child: DropDownWidget(itemCategory, (picked){

                     }),
                   ),
                   Align(
                     child: Padding(
                       padding: const EdgeInsets.only(right: 18.0),
                       child: RaisedButton(onPressed: () {
                         print("add Item");
                         global.addItemData['itemName'] = itemName.text.toString();
                         global.addItem(context);
                       },
                         child: Text(
                           "Add Item", style: TextStyle(color: Colors.white,),),
                         color: Color(0xff1c4b82),
                         shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(5.0)),),
                     ),
                     alignment: Alignment.bottomRight,
                   ),
                 ],
               ),
             ),
           );
         }else{
           return Center(child: CircularProgressIndicator());
         }
       },future: global.getItemCategory(),
     ),
   );
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
          String itemName = val[index]['item_name'];
          _pickItem(context, itemId, itemName, itemCategory);
        },
      );
    }, itemCount: val.length,);
  }

}

class PickItem extends StatefulWidget{
  final String name;
  final String itemId;
  final Function inventoryFn;
  final List<DropdownMenuItem> itemCategory;
  PickItem(this.itemId, this.name, this.itemCategory, this.inventoryFn);
  @override
  _PickItemState createState() => _PickItemState();
}

class _PickItemState extends State<PickItem> with SingleTickerProviderStateMixin{
  GlobalFn global;
  List qtyTypesWidgets;
  List filteredQtyTypesWidgets;
  TabController pickItemController;
  TextEditingController itemName;
  TextEditingController manufacturer;
  TextEditingController minStockLevel;
  TextEditingController reorderLevel;
  TextEditingController initialQty;
  TextEditingController convertedQty;
  TextEditingController transferQty;
  Map<int, TextEditingController> quantity;
  Map<int, TextEditingController> costToSell;
  Map<int, TextEditingController> costPrice;
  Map<int, TextEditingController> salePrice;
  var selectedData;
  var initialQtyId;
  var convertedQtyId;
  Future _itemDetails;
  var checked;
  var pickedItemCategory;
  var fromQtyid;
  var toQtyid;


  @override
  void initState(){
    super.initState();
    global = GlobalFn();
    itemName = TextEditingController();
    manufacturer = TextEditingController();
    minStockLevel = TextEditingController();
    reorderLevel = TextEditingController();
    initialQty = TextEditingController();
    convertedQty = TextEditingController();
    transferQty = TextEditingController();
    quantity = {};
    costToSell = {};
    costPrice = {};
    salePrice = {};
    pickItemController = TabController(vsync:this, length: 2);
    _itemDetails = global.selectedInv(widget.itemId);
  }

  @override
  void dispose(){
    super.dispose();
    pickItemController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future:_itemDetails, builder: (context, snapshot){
      if(snapshot.hasData) {
        selectedData = snapshot.data;
        qtyTypesWidgets =  snapshot.data['item_qty'].map<DropdownMenuItem>((item) =>
          DropdownMenuItem(
            child: Text(item['qty_type']['qty_desc']),
            value: item['qty_id'],
          )
        ).toList();

        if(checked == null){
          itemName.text = selectedData['item_name'];
          manufacturer.text = selectedData['manufacturer'];
          minStockLevel.text = selectedData['min_stock_level'];
          reorderLevel.text = selectedData['reorder_level'];
          initialQtyId = (selectedData['conversion'] == null)? '' : selectedData['conversion']['initial_qty_id'];
          initialQty.text = (selectedData['conversion'] == null)? '' : selectedData['conversion']['initial_qty'];
          convertedQtyId = (selectedData['conversion'] == null)? '' : selectedData['conversion']['converted_qty_id'];
          convertedQty.text = (selectedData['conversion'] == null)? '' : selectedData['conversion']['converted_qty'];
        }

        filteredQtyTypesWidgets = filteredQtyTypes(qtyTypesWidgets, initialQtyId);
      }

      return Scaffold(
          appBar: AppBar(
            title: Text(widget.name, ),
            bottom: TabBar(
                controller: pickItemController,
                tabs: <Widget>[
                  Tab(
                    child: Text("Stock Item Details"),
                  ),
                  Tab(
                    child: Text("Stock Transfer"),
                  ),
                ]
            ),
          ),
          body: ((snapshot.hasData)?
          TabBarView(
            controller: pickItemController,
            children: [
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
                                  decoration: InputDecoration(
                                      labelText: "Name:"
                                  ),
                                  controller: itemName,
                                ),
                                SizedBox(
                                  height:10.0,
                                ),
                                Wrap(
                                  children: [
                                    Text("Category:",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff1c4b82)
                                      ),
                                    ),
                                    DropDownWidget(widget.itemCategory, (picked){
                                      pickedItemCategory = picked;
                                    }, selected: selectedData['item_category']['cat_id']),
                                  ]
                                ),
                                SizedBox(
                                  height:15.0,
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                    children: [
                                      Text("Unit Formula:",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xff1c4b82)
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.88,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Color(0xff1c4b82),
                                            width: 1
                                          )
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                                             children: <Widget>[
                                               Text("FROM:",
                                                style: TextStyle(
                                                  color: Color(0xff1c4b82)
                                                ),
                                               ),
                                               Container(
                                                   width: 100,
                                                   child: IgnorePointer(ignoring: true,
                                                     child: DropDownWidget(qtyTypesWidgets, (picked){
                                                       fromQtyid = picked;
                                                     }, selected: initialQtyId,),
                                                   )
                                               ),
                                               Container(
                                                 width: 100,
                                                 child: numberTextField('Quantity', initialQty)
                                               ),
                                             ],
                                           ),
                                           Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Text("TO:      ",
                                                  style: TextStyle(
                                                      color: Color(0xff1c4b82)
                                                  ),
                                                ),
                                                Container(
                                                    width: 100,
                                                    child: DropDownWidget(filteredQtyTypesWidgets, (picked){
                                                        toQtyid = picked;
                                                    }, selected: convertedQtyId)
                                                ),
                                                Container(
                                                  width: 100,
                                                  child: numberTextField('Quantity', convertedQty),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                      labelText: "Manufacturer:"
                                  ),
                                  controller: manufacturer,
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                      labelText: "Minimum Stock Level:"
                                  ),
                                  controller: minStockLevel,
                                  keyboardType: TextInputType.numberWithOptions(),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                      labelText: "Reorder Level:"
                                  ),
                                  controller: reorderLevel,
                                  keyboardType: TextInputType.numberWithOptions(),
                                ),
                                itemsQtyTypes(selectedData['item_qty']),
                                SizedBox(
                                  height: 10.0,
                                ),
                                FloatingActionButton(
                                  child: Text("SAVE"),
                                  onPressed: (){
                                    updateItemDetails(selectedData['item_qty']);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                              Wrap(
                                  direction: Axis.vertical,
                                  children: [
                                    Text("Unit Formula:",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff1c4b82)
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.88,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: Color(0xff1c4b82),
                                          width: 1
                                        )
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Text("FROM:",
                                                style: TextStyle(
                                                    color: Color(0xff1c4b82)
                                                ),
                                              ),
                                              Container(
                                                  width: 100,
                                                  child: IgnorePointer(ignoring: true,child: DropDownWidget(qtyTypesWidgets, (picked){}, selected: initialQtyId ))
                                              ),
                                              Container(
                                                width: 100,
                                                child: TextField(
                                                  keyboardType: TextInputType.numberWithOptions(),
                                                  decoration: InputDecoration(
                                                      labelText: "Quantity"
                                                  ),
                                                  readOnly: true,
                                                  controller: initialQty,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Text("TO:      ",
                                                style: TextStyle(
                                                    color: Color(0xff1c4b82)
                                                ),
                                              ),
                                              Container(
                                                  width: 100,
                                                  child: IgnorePointer(ignoring: true, child: DropDownWidget(filteredQtyTypesWidgets,(picked){}, selected: convertedQtyId))
                                              ),
                                              Container(
                                                width: 100,
                                                child: TextField(
                                                  keyboardType: TextInputType.numberWithOptions(),
                                                  decoration: InputDecoration(
                                                      labelText:  "Quantity"
                                                  ),
                                                  readOnly: true,
                                                  controller: convertedQty,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                              ),
                              SizedBox(
                                height:15.0,
                              ),
                              Wrap(
                                  children: [
                                    Text("Bigger Unit:",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xff1c4b82)
                                      ),
                                    ),
                                    IgnorePointer(ignoring: true, child: DropDownWidget(qtyTypesWidgets, (picked){}, selected:initialQtyId,)),
                                  ]
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: "Quantity of Big Unit to Transfer:"
                                ),
                                keyboardType: TextInputType.numberWithOptions(),
                                controller:transferQty,
                              ),
                              SizedBox(height:15.0),
                              Wrap(
                                children: [
                                  Text("Smaller Unit:",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff1c4b82)
                                    ),
                                  ),
                                  IgnorePointer(ignoring: true, child: DropDownWidget(filteredQtyTypesWidgets, (picked){}, selected:convertedQtyId,)),
                                ]
                              ),
                              SizedBox(
                                height: 20.0,
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
                                  stockTransfer();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ) : Center(child: CircularProgressIndicator())
          ),
        );
    }
    );
  }

  void updateItemDetails(List data){
    var qtyPrice = data.map((each){
      return {'qtyId':each['qty_type']['qty_id'], 'qty':quantity[each['qty_type']['qty_id']].text, 'costToSell':costToSell[each['qty_type']['qty_id']].text, 'costPrice':costPrice[each['qty_type']['qty_id']].text, 'salePrice':salePrice[each['qty_type']['qty_id']].text};
    }).toList();
    global.updateItemData.addAll({ 'itemId':selectedData['item_id'], "itemName":itemName.text, 'itemCategory':pickedItemCategory, 'fromQtyId':fromQtyid, 'toQtyId':toQtyid, 'initialQty':initialQty.text, 'convertedQty':convertedQty.text, 'manufacturer': manufacturer.text, 'minStockLevel':minStockLevel.text, 'reorderLevel' : reorderLevel.text, 'qtyPrice':qtyPrice });
    global.updateSelectedInv(context).whenComplete((){
      widget.inventoryFn();
    });
  }

  void stockTransfer(){
    var conversionId = (selectedData['conversion'] != null)? selectedData['conversion']['conversion_id']:'';
    global.stockTransferData.addAll({'itemId':selectedData['item_id'], 'conversionId':conversionId, 'fromQtyId':fromQtyid, 'toQtyId':toQtyid, 'transferQty':transferQty.text});
    global.transferStock(context, (){
      _itemDetails =  global.selectedInv(widget.itemId);
      _itemDetails.whenComplete((){
        checked = null;
        transferQty.clear();
      });
      setState((){});
      widget.inventoryFn();
    });
  }

  Widget itemsQtyTypes(List data){
    if(checked == null) {
      quantity.clear();
      costToSell.clear();
      costPrice.clear();
      salePrice.clear();
      checked = true;
    }
    return Column(
      children: data.map((each){
          quantity.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['quantity'])) ));
          costToSell.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['item_price']['min_price'])) ));
          costPrice.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['item_price']['price'] ))));
          salePrice.putIfAbsent(each['qty_type']['qty_id'], ()=>TextEditingController(text: global.genQtyFmt.format(double.parse(each['item_price']['max_price'])) ));

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
            ],
          );
        }
      ).toList(),
    );
  }

  Widget numberTextField(label, data){
    return TextField(
      keyboardType: TextInputType.numberWithOptions(),
      decoration: InputDecoration(
        labelText: label
      ),
      controller: data,
    );
  }

  List<DropdownMenuItem> filteredQtyTypes(List<DropdownMenuItem> qtyTypes, id){
    List<DropdownMenuItem> itm = List<DropdownMenuItem>.from(qtyTypes);
      var index = itm.indexWhere((each)=> (each.value == id));
    if(index != -1){
      itm.removeAt(index);
    }else{
      itm.removeAt(0);
    }
      return itm;
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