import 'package:flutter/material.dart';
import 'global.dart';
import 'notification.dart';
import 'personalisedSearch.dart';
//import 'package:provider/provider.dart';

class Transfer extends StatefulWidget{
  @override
  TransferState createState() => TransferState();
}

class TransferState extends State{
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
          title: Text("Stock Transfer"),
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
  List qtyTypesWidgets;
  List filteredQtyTypesWidgets;
  TextEditingController itemName;
  TextEditingController initialQty;
  TextEditingController convertedQty;
  TextEditingController transferQty;
  var selectedData;
  var initialQtyId;
  var convertedQtyId;
  Future _itemDetails;
  var checked;
//  var fromQtyid;
//  var toQtyid;
  Map<int, TextEditingController> quantity;


  @override
  void initState(){
    super.initState();
    global = GlobalFn();
    itemName = TextEditingController();
    initialQty = TextEditingController();
    convertedQty = TextEditingController();
    transferQty = TextEditingController();
    _itemDetails = global.selectedInv(widget.itemId);
    quantity = {};
  }

  @override
  void dispose(){
    super.dispose();
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
          initialQtyId = (selectedData['conversion'] == null)? '' : selectedData['conversion']['initial_qty_id'];
          initialQty.text = (selectedData['conversion'] == null)? '' : selectedData['conversion']['initial_qty'];
          convertedQtyId = (selectedData['conversion'] == null)? '' : selectedData['conversion']['converted_qty_id'];
          convertedQty.text = (selectedData['conversion'] == null)? '' : selectedData['conversion']['converted_qty'];
        }

        filteredQtyTypesWidgets = filteredQtyTypes(qtyTypesWidgets, initialQtyId);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text("Stock Transfer", ),
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
                        itemsQuantity(selectedData['item_qty']),
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
        ) : Center(child: CircularProgressIndicator())
        ),
      );
    }
    );
  }


  void stockTransfer(){
    var conversionId = (selectedData['conversion'] != null)? selectedData['conversion']['conversion_id']:'';
    global.stockTransferData.addAll({'itemId':selectedData['item_id'], 'conversionId':conversionId, 'fromQtyId':initialQtyId, 'toQtyId':convertedQtyId, 'transferQty':transferQty.text});
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