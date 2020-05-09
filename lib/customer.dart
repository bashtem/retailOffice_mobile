import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'global.dart';
import 'personalisedSearch.dart';
import 'notification.dart';

Future getCustomers;
Future customerDetails;

class Customer extends StatefulWidget {
  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  GlobalFn global;
  var fetchedCustomers;
  var setupData;

  @override
  void initState() {
    super.initState();
    global = GlobalFn();
    getCustomers = global.getCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        fetchedCustomers = snapshot.hasData ? snapshot.data['cus'] : [];
        if(snapshot.hasData)
          setupData = snapshot.data;
        return Scaffold(
            appBar: AppBar(
              title: Text("Customers"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Search',
                  onPressed: !snapshot.hasData
                      ? null
                      : () {
                          showSearch(
                              context: context,
                              delegate: SearchData(
                                  searchMethod, fetchedCustomers, 'cus_name'));
                        },
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Color(0xff1c4b82),
              child: Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return AddCustomer();
                }));
              },
            ),
            body: Container(
                child: Card(
              child: (snapshot.hasData
                  ? (snapshot.data.length < 1
                      ? noRecords()
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(fetchedCustomers[index]['cus_name']),
                              subtitle:
                                  Text(fetchedCustomers[index]['cus_mobile']),
                              trailing: Icon(
                                Icons.remove_red_eye,
                                color: Color(0xff1c4b82),
                                size: 20,
                              ),
                              onTap: () {
                                pickCustomer(context, fetchedCustomers[index]['cus_id'], setupData);
                              },
                            );
                          },
                          itemCount: fetchedCustomers.length,
                        ))
                  : Center(child: CircularProgressIndicator())),
            )));
      },
      future: getCustomers,
    );
  }

  Widget searchMethod(List val) {
    return (val.length < 1)
        ? noRecords()
        : ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                title: Text(val[index]['cus_name']),
                subtitle: Text(val[index]['cus_mobile']),
                trailing: Icon(
                  Icons.remove_red_eye,
                  color: Color(0xff1c4b82),
                  size: 20,
                ),
                onTap: () {
                  var cusIndex = val[index]['cus_id'];
                  pickCustomer(context, cusIndex, setupData);
                },
              );
            },
            itemCount: val.length,
          );
  }

  void pickCustomer(context, cusIndex, setupData){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return ViewCustomer(cusIndex, setupData);
    }));
  }
}

class ViewCustomer extends StatefulWidget {
  final setupData;
  final cusIndex;
  ViewCustomer(this.cusIndex,this.setupData);
  @override
  ViewCustomerState createState() => ViewCustomerState();
}

class ViewCustomerState extends State<ViewCustomer> with SingleTickerProviderStateMixin{

  TabController tabCtrl;
  TextEditingController creditAmount;
  TextEditingController discountAmount;
  TextEditingController discountQuantity;
  TextEditingController setDiscountAmount;

  var  pickedCustomer;
  var items, qtyTypes, creditTypes;
  List paymentTypes;
  var pickedQty, pickedCredit, pickedItem;
  GlobalFn global;

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(length: 3, vsync: this);
    qtyTypes = widget.setupData['qtyTypes'];
    items = widget.setupData['items'];
    paymentTypes = widget.setupData['payments'];
    creditTypes = widget.setupData['creditTypes'];
    creditAmount = TextEditingController();
    discountAmount = TextEditingController();
    discountQuantity = TextEditingController();
    setDiscountAmount = TextEditingController();

    global = GlobalFn();
    customerDetails = global.getEachCustomer(widget.cusIndex);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: customerDetails,
      builder: (context, snapshot){
        if(snapshot.hasData){
          pickedCustomer = snapshot.data;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Customer Profile"),
            bottom: TabBar(tabs: [
              Tab(
                child: Text("Profile"),
              ),
              Tab(
                child: Text("Credit"),
              ),
              Tab(
                child: Text("Discount"),
              ),
            ], controller: tabCtrl,),
          ),
          body: ((snapshot.hasData)?
              TabBarView(
              controller: tabCtrl,
              children:[
                  Container(
                    child: Column(children: <Widget>[
                      Container(
                        child: Expanded(
                          child: Container(
                              child: Card(
                                child: ListView(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.account_circle,
                                        color: Color(0xff1c4b82),
                                      ),
                                      title: Text(pickedCustomer['cus_name']),
                                      trailing: FlatButton.icon(
                                        onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: ( BuildContext context) {
                                              return UpdateCustomer(data: pickedCustomer, paymentTypes: paymentTypes,);
                                            }));
                                        },
                                        padding: EdgeInsets.all(0.0),
                                        materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                        icon: Icon(
                                          Icons.mode_edit,
                                          size: 17.0,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        label: Text("Update",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Theme.of(context)
                                                    .accentColor)),
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.phone_android,
                                        color: Color(0xff1c4b82),
                                      ),
                                      title: Text(pickedCustomer['cus_mobile']),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.mail_outline,
                                        color: Color(0xff1c4b82),
                                      ),
                                      title: Text(pickedCustomer['cus_mail']),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.payment,
                                        color: Color(0xff1c4b82),
                                      ),
                                      title: Text(pickedCustomer['payment']['payment_desc']),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        color: Color(0xff1c4b82),
                                      ),
                                      title: Text(pickedCustomer['cus_address']),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    child: SizedBox.expand(
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              dense: true,
                              title: Text("Available Credit", ),
                              trailing: Text(global.priceFmt.format(double.parse(pickedCustomer['credit']['available_credit']))),
                            ),
                            ListTile(
                              dense: true,
                              title: Text("Outstanding Credit"),
                              trailing: Text(global.priceFmt.format(double.parse(pickedCustomer['credit']['out_credit']))),
                            ),
                            Divider(color: Theme.of(context).accentColor, height: 0.0),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  ListTile(
                                    dense: true,
                                    leading: Icon(Icons.swap_vert, color: Color(0xff1c4b82),),
                                    title: DropDown(creditTypes, 'credit_desc', (value){pickedCredit = value;}),
                                  ),
                                  ListTile(
                                    dense: true,
                                    leading: Icon(Icons.monetization_on, color: Color(0xff1c4b82),),
                                    title: TextField(
                                      controller: creditAmount,
                                      decoration: InputDecoration(labelText: "Amount"),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child:Padding(
                                      padding: const EdgeInsets.only(right:15.0),
                                      child: RaisedButton(
                                        child: Text("Process", style: TextStyle(color: Colors.white,),), color: Color(0xff1c4b82), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                        onPressed: (){
                                          global.creditData.addAll({"cusId":pickedCustomer['cus_id'], "creditType":pickedCredit, "creditAmount":creditAmount.text});
                                          global.creditProcess(context, (){ setState(() {
                                            creditAmount.clear();
                                          });});
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: Theme.of(context).accentColor, height: 0.0,),
                            Expanded(
                              child: ( (snapshot.hasData)? ( (pickedCustomer['credit_orders'].length == 0)? noRecords(): ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: pickedCustomer['credit_orders'].length,
                                  itemBuilder: (context, index){
                                    var credit = pickedCustomer['credit_orders'];
                                      return ListTile(
                                        dense: true,
                                        title: Text(credit[index]['order']['order_no']),
                                        trailing: Text(global.priceFmt.format(double.parse(credit[index]['order']['order_total_amount']))),
                                        subtitle: Text(credit[index]['order']['qty']['qty_desc']),
                                        onTap: (){
                                          showCredit(credit[index]);
                                        },
                                      );
                                  }
                              )) : Text('') ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            dense: true,
                            title: Text("Discount Balance"),
                            trailing: Text(global.priceFmt.format(double.parse(pickedCustomer['discount']['discount_credit']))),
                          ),
                          ListTile(
                            leading: Icon(Icons.thumb_up, color: Color(0xff1c4b82),),
                            dense: true,
                            title: TextField(
                              controller: discountAmount,
                              keyboardType: TextInputType.numberWithOptions(),
                              decoration: InputDecoration(
                                  hintText: "Payment Amount"
                              ),
                            ),
                            trailing: RaisedButton(
                              color: Color(0xFF1c4b82),
                              shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              child: Text(
                                "Pay",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                              onPressed: () {
                                  global.payDiscountData.addAll({'amount':discountAmount.text, 'cusId':pickedCustomer['cus_id']});
                                  global.payDiscount(context, (){
                                    setState(() {
                                      discountAmount.clear();
                                    });
                                  });
                              },
                            ),
                          ),
                          Divider(color: Theme.of(context).accentColor, ),
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  dense: true,
                                  leading: Icon(Icons.swap_vert, color: Color(0xff1c4b82),),
                                  title: DropDown(qtyTypes, 'qty_desc', (value){
                                    pickedQty = value;
                                  }),
                                ),
                                ListTile(
                                  dense: true,
                                  leading: Icon(Icons.label_outline, color: Color(0xff1c4b82),),
                                  title: DropDown(items, 'item_name', (value){
                                    pickedItem = value;
                                  }),
                                ),
                                ListTile(
                                  dense: true,
                                  leading: Icon(Icons.shopping_basket, color: Color(0xff1c4b82),),
                                  title: TextField(
                                    controller: discountQuantity,
                                    keyboardType: TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(labelText: "Quantity"),
                                  ),
                                ),
                                ListTile(
                                  dense: true,
                                  leading: Icon(Icons.monetization_on, color: Color(0xff1c4b82),),
                                  title: TextField(
                                    controller: setDiscountAmount,
                                    keyboardType: TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(labelText: "Discount Amount"),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child:Padding(
                                    padding: const EdgeInsets.only(right:15.0),
                                    child: RaisedButton(
                                      child: Text("Add Discount", style: TextStyle(color: Colors.white,),), color: Color(0xff1c4b82), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                      onPressed: (){
                                          global.addDiscountData.addAll({'cusId':pickedCustomer['cus_id'], 'item': pickedItem, 'qty':pickedQty, 'amount':setDiscountAmount.text, 'quantity':discountQuantity.text});
                                          global.addDiscount(context, (){
                                            setState(() {
                                              discountQuantity.clear();
                                              setDiscountAmount.clear();
                                            });
                                          });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Theme.of(context).accentColor, ),
                          Expanded(
                            child: ( (snapshot.hasData)? ( (pickedCustomer['discount_items'].length == 0)? noRecords(): ListView.builder(
                              shrinkWrap: true,
                              itemCount: pickedCustomer['discount_items'].length,
                              itemBuilder: (context, index){
                                var discount = pickedCustomer['discount_items'];
                                return ListTile(
                                  dense: true,
                                  title: Text(discount[index]['item']['item_name']),
                                  trailing: Text(global.priceFmt.format(double.parse(discount[index]['discount_amount']))),
                                  subtitle: Text(discount[index]['item_qty']+" "+discount[index]['unit']['qty_desc']),
                                  onTap: (){
                                    showDiscount(discount[index]);
                                  },
                                );
                              }
                          )) : Text('') ),
                          )
                        ],
                      ),
                    ),
                  ),
              ]
          ) : Center(child: CircularProgressIndicator())
          ),
        );
      },
    );
  }

  void showCredit(data){
     showDialog(
        context: context,
        builder: (context) {
      return SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(20.0))),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            height: 400,
            width: 300,
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                            "Order No:")),
                    Text(data['order']['order_no'])
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child:
                        Text("Unit:")),
                    Text(data['order']['qty']['qty_desc'])
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                            "Quantity:")),
                    Text(global.qtyFmt.format(double.parse(data['order']['order_total_qty'])))
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                            "Amount:")),
                    Text(global.priceFmt.format(double.parse(data['order']['order_total_amount'])))
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                            "Order Status:")),
                    Text(data['order']['order_status'])
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                            "Payment:")),
                    Text(data['credit_order_status'])
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child:
                        Text("Date:")),
                    Text(data['order']['order_date'])
                  ],
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                ),
                FlatButton(
                  shape:
                  new RoundedRectangleBorder(
                    borderRadius:
                    new BorderRadius
                        .circular(30.0),
                  ),
                  color: Color(0xFF1c4b82),
                  child: new Container(
                    child: new Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: <Widget>[
                        Text(
                          "Clear Debt",
                          textAlign:
                          TextAlign
                              .center,
                          style: TextStyle(
                              color: Colors
                                  .white,
                              fontWeight:
                              FontWeight
                                  .bold),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    global.payDebitData.addAll({"cusId":data['cus_id'], "amount":data['order']['order_total_amount'], "creditOrderId":data['credit_order_id']});
                    global.payDebit(context, (){
                      setState(() {
                      });
                    });
                  },
                ),
              ],
            ),
          )
        ],
      );
    },
    );
  }

  void showDiscount(data){
     showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.all(
                  Radius.circular(
                      20.0))),
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
              height: 300,
              width: 300,
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                              "Item:", style: TextStyle(fontWeight: FontWeight.bold),)),
                      Text(data['item']['item_name'])
                    ],
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                              "Unit:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(data['unit']['qty_desc'])
                    ],
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                              "Quantity:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(data['item_qty'])
                    ],
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                              "Discount Amount:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(global.priceFmt.format(double.parse(data['discount_amount'])))
                    ],
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                              "Date:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(data['enabled_date'])
                    ],
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                  ),
                  FlatButton(
                    shape:
                    new RoundedRectangleBorder(
                      borderRadius:
                      new BorderRadius
                          .circular(
                          30.0),
                    ),
                    color:
                    Color(0xFF540e33),
                    onPressed: () {
                      global.delDiscountData.addAll({'itemId':data['item_id'], 'qtyId':data['qty_id'], 'cusId': data['cus_id']});
                      global.delDiscount(context, (){
                        setState(() {
                        });
                      });
                    },
                    child: new Container(
                      child: new Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: <Widget>[
                          Text(
                            "Remove Discount",
                            textAlign:
                            TextAlign
                                .center,
                            style: TextStyle(
                                color: Colors
                                    .white,
                                fontWeight:
                                FontWeight
                                    .bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

}

class UpdateCustomer extends StatefulWidget{
  final data;
  final paymentTypes;
  UpdateCustomer({this.data, this.paymentTypes});
  @override
  _UpdateCustomerState createState() => _UpdateCustomerState();
}

class _UpdateCustomerState extends State<UpdateCustomer>{

  GlobalFn global;
  TextEditingController updateName = TextEditingController();
  TextEditingController updatePhone = TextEditingController();
  TextEditingController updateEmail = TextEditingController();
  TextEditingController updateAddress = TextEditingController();
  var updatePayment;

  @override void initState() {
    global = new GlobalFn();
    updateName.text =  widget.data['cus_name'];
    updatePhone.text =  widget.data['cus_mobile'];
    updateEmail.text = widget.data['cus_mail'];
    updateAddress.text = widget.data['cus_address'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var index = widget.paymentTypes.indexWhere((each)=> each['payment_id'] == (widget.data['payment_id']));
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Customer"),
      ),
      body: Container(
        child: SizedBox.expand(
          child: Card(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Color(0xff1c4b82),
                    ),
                    title: TextField(
                      controller: updateName,
                      decoration: InputDecoration(labelText: "Full Name"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone_android,
                      color: Color(0xff1c4b82),
                    ),
                    title: TextField(
                      controller: updatePhone,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: false),
                      decoration:
                      InputDecoration(labelText: "Mobile Number"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.mail_outline,
                      color: Color(0xff1c4b82),
                    ),
                    title: TextField(
                      controller: updateEmail,
                      decoration:
                      InputDecoration(labelText: "E-Mail (Optional)"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Color(0xff1c4b82),
                    ),
                    title: TextField(
                      controller: updateAddress,
                      decoration: InputDecoration(labelText: "Address"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.payment,
                      color: Color(0xff1c4b82),
                    ),
                    title: DropDown(
                      widget.paymentTypes, 'payment_desc', (value) {
                      updatePayment = value;
                    }, index: index,  ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Align(
                    child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: RaisedButton(
                            child: Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            color: Color(0xff1c4b82),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            onPressed: () {
                              global.updateCustomerData.addAll({
                                "cus_id":widget.data['cus_id'],
                                "name": updateName.text,
                                "phone": updatePhone.text,
                                "email": updateEmail.text,
                                "address": updateAddress.text,
                                "payment": updatePayment
                              });
                              global.updateCustomer(context, (){
                                  Navigator.of(context).pop();
                                  getCustomers = global.getCustomers();
                                  customerDetails = global.getEachCustomer(widget.data['cus_id']);
                              } );
                            })),
                    alignment: Alignment.bottomRight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class AddCustomer extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  GlobalFn global;
  var paymentTypes;
  TextEditingController name;
  TextEditingController phone;
  TextEditingController email;
  TextEditingController address;
  var payment;
  Future addCustomerData;

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    phone = TextEditingController();
    email = TextEditingController();
    address = TextEditingController();
    global = GlobalFn();
    addCustomerData = global.getPurchaseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Customer"),
      ),
      body: Container(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              paymentTypes = snapshot.data;
              return SizedBox.expand(
                child: Card(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.account_circle,
                            color: Color(0xff1c4b82),
                          ),
                          title: TextField(
                            controller: name,
                            decoration: InputDecoration(labelText: "Full Name"),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.phone_android,
                            color: Color(0xff1c4b82),
                          ),
                          title: TextField(
                            controller: phone,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: false),
                            decoration:
                                InputDecoration(labelText: "Mobile Number"),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.mail_outline,
                            color: Color(0xff1c4b82),
                          ),
                          title: TextField(
                            controller: email,
                            decoration:
                                InputDecoration(labelText: "E-Mail (Optional)"),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Color(0xff1c4b82),
                          ),
                          title: TextField(
                            controller: address,
                            decoration: InputDecoration(labelText: "Address"),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.payment,
                            color: Color(0xff1c4b82),
                          ),
                          title: DropDown(
                              paymentTypes['payment'],'payment_desc', (value) {
                            payment = value;
                          }, index: 1,),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Align(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: RaisedButton(
                                  child: Text(
                                    "Add Customer",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: Color(0xff1c4b82),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  onPressed: () {
                                    global.addCustomerData.addAll({
                                      "name": name.text,
                                      "phone": phone.text,
                                      "email": email.text,
                                      "address": address.text,
                                      "payment": payment
                                    });
                                    global.addCustomer(context);
                                  })),
                          alignment: Alignment.bottomRight,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
          future:addCustomerData,
        ),
      ),
    );
  }
}

class DropDown extends StatefulWidget {
  final List items;
  final String name;
  final Function getData;
  final index;
  DropDown(this.items, this.name, this.getData, {this.index});
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  var picked;
  List stableTypes;

  @override
  void initState() {
    super.initState();
    picked = (widget.index != null) ? widget.items[widget.index] : widget.items[0];
    stableTypes = widget.items;
    widget.getData(picked);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      items: stableTypes.map((each) {
        return DropdownMenuItem(
          child: Text(each[widget.name]),
          value: each,
        );
      }).toList(),
      value: picked,
      onChanged: (selected) {
        setState(() {
          picked = selected;
          widget.getData(picked);
        });
      },
    );
  }
}