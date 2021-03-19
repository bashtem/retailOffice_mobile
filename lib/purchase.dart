import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'notification.dart';
//import 'personalisedSearch.dart';


class Purchase extends StatefulWidget{
  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase>{
  GlobalFn global;
  List suppliers;
  List payments;
  List qty;
  List items;
  TextEditingController purchaseQuantity;
  TextEditingController purchasePrice;

  @override
  void initState() {
    super.initState();
    purchaseQuantity = TextEditingController();
    purchasePrice = TextEditingController();
  }

  @override
  Widget build(BuildContext context){
    global = Provider.of<GlobalFn>(context);
    var itemCount = (global.purchaseList.length <= 0)? Text('') : Positioned(
      right: 0,
      child: new Container(
        padding: EdgeInsets.all(1),
        decoration: new BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: BoxConstraints(
          minWidth: 12,
          minHeight: 12,
        ),
        child: new Text(
          global.purchaseList.length.toString(),
          style: new TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Purchase"),
          actions: <Widget>[
            IconButton(
                icon: Stack(children:[
                  Icon(Icons.local_shipping),
//                  itemCount,
                ]),
                onPressed: (){
//                  if(global.purchaseList.length > 0)
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return Delivery();
                    }));
            }),
            IconButton(
                icon: Stack(children:[
                  Icon(Icons.shopping_cart),
                  itemCount,
                ]),
                onPressed: (){
                  if(global.purchaseList.length > 0)
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return PurchaseCart(callBack: (){
                      setState(() { });
                    },);
                  }));
            }),
          ],
        ),
        body: FutureBuilder(
        builder: (context, snapshot){
          if(snapshot.hasData) {
            payments = dropDownWidget(snapshot.data['payment'], 'payment_desc');
            suppliers = dropDownWidget(snapshot.data['supplier'], 'sup_company_name');
            qty = dropDownWidget(snapshot.data['qtyTypes'], 'qty_desc');
            items = dropDownWidget(snapshot.data['items'], 'item_name');
            return Container(
              child: SizedBox.expand(
                child: (suppliers.length < 1 || items.length < 1)? noRecords(msg: "No Suppliers / Items Found"): Card(
                  child: Padding(
                      padding: const EdgeInsets.only(left:10.0, right:10.0),
                      child: SingleChildScrollView(
                          child:  Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.domain,
                                  color: Color(0xff1c4b82),),
                                title: DropDown(suppliers, 'supplier'),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.payment, color: Color(0xff1c4b82),),
                                title: DropDown(payments, 'payment', index: 1,),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.swap_vert, color: Color(0xff1c4b82),),
                                title: DropDown(qty, 'qty', index: 1,),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.label_outline, color: Color(0xff1c4b82),),
                                title: ItemsDropDown(items),
                              ),
                              ListTile(
                                leading: Icon(Icons.shopping_basket,
                                  color: Color(0xff1c4b82),),
                                title: TextField(
                                    controller: purchaseQuantity,
                                    decoration: InputDecoration(
                                        labelText: "Quantity"),
                                    keyboardType: TextInputType.number
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.monetization_on,
                                  color: Color(0xff1c4b82),),
                                title: TextField(
                                    controller: purchasePrice,
                                    decoration: InputDecoration(
                                        labelText: "Price"),
                                    keyboardType: TextInputType.number
                                ),
                              ),
                              SizedBox(height: 30.0,),
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      FlatButton(onPressed: (){
                                        global.purchaseList.clear();
                                        setState(() { });
                                      }, child: Container(child: Text("Clear Cart",style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),), decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0,))),)),
                                      RaisedButton(
                                        child: Text("Add Item", style: TextStyle(color: Colors.white,),),
                                        color: Color(0xff1c4b82),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0)
                                        ),
                                        onPressed: (){
                                          addToCart();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                alignment: Alignment.bottomRight,
                              ),
                            ],
                          )
                      )
                  ),
                ),
              ),
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        },future: global.getPurchaseData(),)
    );
  }

  addToCart(){
    setState(() {
      if((purchaseQuantity.text != '' && purchasePrice.text != '') && ( double.parse(purchaseQuantity.text) > 0 && double.parse(purchasePrice.text) > 0 )) {
        global.purchaseList.removeWhere((each) => each['item']['item_id'] == global.purchaseItemName['item_id']);
        global.purchaseList.add({
          'item': global.purchaseItemName,
          'quantity': purchaseQuantity.text,
          'price': purchasePrice.text
        });
        purchasePrice.text = '';
        purchaseQuantity.text = '';
      }
    });
  }

  List dropDownWidget(List collections, String key ){
    return collections.map((each){
      var title = (each[key].length > 25)? each[key].substring(0, 25) + '...' : each[key];
        return DropdownMenuItem(
          child: Text(title),
          value: each,
        );
      }).toList();
  }

}

class PurchaseCart extends StatefulWidget{

  final callBack;

  const PurchaseCart({Key key, this.callBack}) : super(key: key);

  @override
  PurchaseCartState createState() => PurchaseCartState();
}

class PurchaseCartState extends State<PurchaseCart>{
  GlobalFn global;
  String dateValue = DateFormat("yyyy-MM-dd").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    double grandTotal = 0;
    global = Provider.of<GlobalFn>(context);
    global.purchaseList.forEach((each){
      grandTotal+= ( double.parse(each['quantity']) * double.parse(each['price']));
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){ savePurchase(); }, backgroundColor: Color(0xff1c4b82), child: Icon(Icons.save),),
      appBar: AppBar(
        bottom: PreferredSize(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:73.0, bottom: 10.0),
                  child: Text(global.purchaseData['qty']['qty_desc']+" | "+global.purchaseData['payment']['payment_desc'], style: TextStyle(color: Colors.white),),
                ),
              ],
            ), preferredSize: null),
        title: Text(global.purchaseData['supplier']['sup_company_name']),

      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
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
                Text(global.priceFmt.format(grandTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor
                    )),
              ],
            ),
            padding: EdgeInsets.all(10.0),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
            child: Container(
                color: Color(0xffecf2f9),
                child: ListView.builder(
                  itemBuilder: (context, index){
                    final decimalFmt = NumberFormat("#,##0.###", "en_US");
                    var amount = double.parse(global.purchaseList[index]['quantity']) * double.parse(global.purchaseList[index]['price']);
                    var price = double.parse(global.purchaseList[index]['price']);
                    var quantity = double.parse(global.purchaseList[index]['quantity']);
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      elevation: 10.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left:10.0, top:10.0, bottom: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: 1.0, color: Color(0xff1f3c88)),
                                        )
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text(global.purchaseList[index]['item']['item_name'], style: TextStyle(fontSize: 18.0), ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:5.0, bottom: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Quantity:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(decimalFmt.format(quantity))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:5.0, bottom: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Price:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(decimalFmt.format(price))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:20.0, right:20.0, top:5.0, bottom: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Amount:", style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text(decimalFmt.format(amount), style: TextStyle(color: Color(0xffc1224f)),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            flex: 1,
                          ),
                          Container(
                            child: IconButton(
                              icon: Icon(Icons.delete_outline),
                              color: Color(0xffc82121),
                              onPressed: (){
                                setState(() {
                                  global.purchaseList.removeAt(index);
                                  if(global.purchaseList.length == 0)
                                    Navigator.of(context).pop();
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: global.purchaseList.length,
                )
            ),
          ),
        ],
      ),
    );
  }

  void savePurchase(){
    global.savePurchase(context, (){
      widget.callBack();
    });
  }

}

class DropDown extends StatefulWidget{
  final List types;
  final objKey;
  final index;
  DropDown(this.types, this.objKey, {this.index});
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown>{

  List<DropdownMenuItem> _menuItems;
  var picked;
  GlobalFn global;

  @override
  void initState() {
    super.initState();
    _menuItems = widget.types;
    picked = (widget.index != null) ? _menuItems[widget.index].value : _menuItems[0].value;
  }

  @override
  void dispose() {
    super.dispose();
    global.purchaseList.clear();
  }

  @override
  Widget build(BuildContext context){
    global = Provider.of<GlobalFn>(context);
    global.purchaseData[widget.objKey] = picked;
    return DropdownButtonFormField(
      items: _menuItems,
      value: picked,
      onChanged: (selected){
        setState(() {
          if(global.purchaseList.length <= 0)
              picked = selected;
        });
      },
    );
  }


}

class ItemsDropDown extends StatefulWidget{
  final List items;
  ItemsDropDown(this.items);
  @override
  _ItemsDropDownState createState() => _ItemsDropDownState();
}

class _ItemsDropDownState extends State<ItemsDropDown>{

  List<DropdownMenuItem> _menuItems;
  var picked;
  GlobalFn global;

  @override
  void initState() {
    super.initState();
    _menuItems = widget.items;
    picked = _menuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    global = Provider.of<GlobalFn>(context);
    global.purchaseItemName = picked;
    return DropdownButtonFormField(
      items: _menuItems,
      value: picked,
      onChanged: (selected){
        setState(() {
            picked = selected;
            global.purchaseItemName = picked;
        });
      },
    );
  }
}

class Delivery extends StatefulWidget{
  @override
  DeliveryState createState() => DeliveryState();
}

class DeliveryState extends State<Delivery>{
  GlobalFn global;
  List pendingList;
  List selected = List();
  List confirmedItems = List();
  var snapData;

  @override
  void initState() {
    global = new GlobalFn();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot){
      if(snapshot.hasData){
        snapData = snapshot.data;
        pendingList = snapData;
      }
      return Scaffold(
        appBar: AppBar(
          title: Text("Confirm Delivery"),
          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.search),
//              tooltip: 'Search',
//            onPressed: !snapshot.hasData ? null : (){
//              showSearch(context: context, delegate: SearchData(searchMethod, pendingList, 'purchase_qty', searchKeys: ['']));
//            },
//            )
          ],
        ),
        body: (!snapshot.hasData)? Center(child: CircularProgressIndicator()) : ((pendingList.length > 0)? Container(
          child: Card(
            child: Column(
              children: <Widget>[
                Expanded(
                     child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index){
                          selected.add(false);
                          return ListTile(
                            dense: true,
                            title: Text(pendingList[index]['purchase_order']['supplier']['sup_company_name']),
                            subtitle: Row(
                              children: <Widget>[
                                Wrap(
                                  children: <Widget>[
                                    Icon(Icons.shopping_cart, size: 15, color: Color(0xFF1c4b82),),
                                    Text(' '+global.qtyFmt.format(double.parse(pendingList[index]['purchase_qty'])))
                                  ],
                                ),
                                Text("   "+pendingList[index]['items']['item_name']),
                              ],
                            ),
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                canclePendingPurchase(pendingList, index),
                                ((pendingList[index]['purchase_status'] == 'SUCCESS')?  Icon(Icons.check_circle_outline, color: Colors.green,) : checkPendingPurchase(selected, index, pendingList)),
                              ],
                            )
                          );
                        }, separatorBuilder: (context, index){
                      return Divider( color: Color(0xFF1c4b82),);
                  }, itemCount: pendingList.length),
             ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Color(0xff1c4b82),
                      child: Text("Confirm", style: TextStyle(color: Colors.white),),
                      onPressed: !(confirmedItems.length > 0) ? null : (){
                        global.confirmDelivery(context, confirmedItems, (){setState((){});});
                      }
                  ),
                )
              ],
            )
          ),
        ) : noRecords()),
      );
    }, future: global.getPendingPurchases(),);
  }

  Widget checkPendingPurchase(selected, index, pendingList){
    return Checkbox(
        value: selected[index],
        onChanged:(bool value){
          setState(() {
            selected[index] = value;
            if(value)
              confirmedItems.add({'itemId': pendingList[index]['items']['item_id'], 'purchaseItemId':pendingList[index]['purchase_item_id'], 'purchasePrice':pendingList[index]['purchase_price'],  'quantity':pendingList[index]['purchase_qty'], 'qtyId':pendingList[index]['purchase_order']['qty_id']});
            else
              confirmedItems.removeWhere((each)=> each['purchaseItemId'] == pendingList[index]['purchase_item_id']);
          });
        }
    );
  }

  Widget canclePendingPurchase(pendingList, index){
    return IconButton(icon: Icon(Icons.clear), color: Colors.red, onPressed: (){
          confirmDialog(context, () async{
            Navigator.of(context).pop();
            loading(context);
            var data = await global.canclePurchase(context, pendingList[index]['purchase_id'], pendingList[index]['items']['item_id']);
            Navigator.of(context).pop();
            if(data['status'] == true){
              successNotify(context, data['response']);
              setState(() { });
            }else{
              failureNotify(context, data['response']);
            }
          });
    });
  }

  Widget searchMethod(var pendingList){
    return ((pendingList.length > 0)? Container(
      child: Card(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      selected.add(false);
                      return ListTile(
                          dense: true,
                          title: Text(pendingList[index]['purchase_order']['supplier']['sup_company_name']),
                          subtitle: Row(
                            children: <Widget>[
                              Wrap(
                                children: <Widget>[
                                  Icon(Icons.shopping_cart, size: 15, color: Color(0xFF1c4b82),),
                                  Text(' '+global.qtyFmt.format(double.parse(pendingList[index]['purchase_qty'])))
                                ],
                              ),
                              Text("   "+pendingList[index]['items']['item_name']),
                            ],
                          ),
                          trailing: checkPendingPurchase(selected, index, pendingList)
                      );
                    }, separatorBuilder: (context, index){
                  return Divider( color: Color(0xFF1c4b82),);
                }, itemCount: pendingList.length),
              ),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                    color: Color(0xff1c4b82),
                    child: Text("Confirm", style: TextStyle(color: Colors.white),),
                    onPressed: !(confirmedItems.length > 0) ? null : (){
//                        global.confirmDelivery(context, );
                    }
                ),
              )
            ],
          )
      ),
    ) : noRecords());
  }

}