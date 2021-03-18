import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global.dart';
import 'personalisedSearch.dart';
import 'notification.dart';

class Supplier extends StatefulWidget{
  @override
  _SupplierState createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> with SingleTickerProviderStateMixin{
  GlobalFn global;
  TextEditingController companyName;
  TextEditingController contactName;
  TextEditingController mobile;
  TextEditingController email;
  TextEditingController address;
  TextEditingController url;
  var suppliers;

  @override
  void initState() {
    super.initState();
    companyName = TextEditingController();
    contactName = TextEditingController();
    mobile = TextEditingController();
    email = TextEditingController();
    address = TextEditingController();
    url = TextEditingController();
  }

    @override
    Widget build(BuildContext context){
      global = Provider.of<GlobalFn>(context);
      return FutureBuilder(builder:(context, snapshot){
        suppliers = snapshot.hasData ? snapshot.data : [];
        return Scaffold(
        appBar: AppBar(
          title: Text("Suppliers"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: !snapshot.hasData ? null : (){
                showSearch(context: context, delegate: SearchData(searchMethod, suppliers, 'sup_company_name'));
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff1c4b82),
          child: Icon(
              Icons.group_add
          ),
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
              return addSupplier();
            }));
          },
        ),

        body: Container(
          child: (snapshot.hasData ? ( snapshot.data.length < 1 ? noRecords() :
             ListView.builder(itemBuilder: (context, index,){
              return ListTile(
                dense: true,
                leading: Text((index+1).toString()),
                title: Text(snapshot.data[index]['sup_company_name']),
                subtitle: Text(snapshot.data[index]['sup_mobile']),
                trailing: Icon(Icons.remove_red_eye, color: Color(0xff1c4b82), size: 20, ),
                onTap: (){
                  _pickSupplier(context, snapshot.data[index]);
                },
              );
            }, itemCount: snapshot.data.length,) )
            : Center(child: CircularProgressIndicator())
            ),
          ),
        );
      },future: global.getSuppliers(),);
    }

    Widget addSupplier(){
      return Scaffold(
        appBar: AppBar(title: Text("Add Supplier"),),
        body: Container(
          child: SizedBox.expand(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(left:18.0, right:10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.domain, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: companyName,
                          decoration: InputDecoration(labelText: "Company Name"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.account_circle, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: contactName,
                          decoration: InputDecoration(labelText: "Contact Name"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone_android, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: mobile,
                          decoration: InputDecoration(labelText: "Mobile Number"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.mail_outline, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: email,
                          decoration: InputDecoration(labelText: "E-Mail (Optional) "),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: address,
                          decoration: InputDecoration(labelText: "Address"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.link, color: Color(0xff1c4b82),),
                        title: TextField(
                          controller: url,
                          decoration: InputDecoration(labelText: "Website (Optional) "),
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      Align(
                        child:Padding(
                          padding: const EdgeInsets.only(right:15.0),
                          child: RaisedButton(
                          onPressed: (){
                            global.addSupplierData['companyName']  = companyName.text;
                            global.addSupplierData['contactName'] = contactName.text;
                            global.addSupplierData['mobileNumber'] = mobile.text;
                            global.addSupplierData['mail'] = email.text;
                            global.addSupplierData['address'] = address.text;
                            global.addSupplierData['website'] = url.text;
                            global.addSupplier(context, (){
                              setState(() { });
                            });
                          },
                          child: Text("Add Supplier", style: TextStyle(color: Colors.white,),), color: Color(0xff1c4b82), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)) ,),
                        ),
                        alignment: Alignment.bottomRight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    void _pickSupplier(context, data){
      showModalBottomSheet(
          context: context,
          builder:(BuildContext context){
        return PickSupplier(data, (){
          setState(() { });
        });
      });
    }

    Widget searchMethod(List val){
        return (val.length < 1)? noRecords() : ListView.builder(itemBuilder: (context, index,){
          return ListTile(
            dense: true,
            leading: Text((index+1).toString()),
            title: Text(val[index]['sup_company_name']),
            subtitle: Text(val[index]['sup_mobile']),
            trailing: Icon(Icons.remove_red_eye, color: Color(0xff1c4b82), size: 20,),
            onTap: (){
              _pickSupplier(context, val[index]);
            },
          );
        }, itemCount: val.length,);
    }

  }


class PickSupplier extends StatefulWidget{
  final data;
  final callBack;

  PickSupplier(this.data, this.callBack);
  @override
  PickSupplierState createState() => PickSupplierState();
}

class PickSupplierState extends State<PickSupplier>{

  GlobalFn global;
  TextEditingController updateCompanyName;
  TextEditingController updateContactName;
  TextEditingController updateMobile;
  TextEditingController updateEmail;
  TextEditingController updateAddress;
  TextEditingController updateUrl;

  @override
  void initState() {
    super.initState();
     updateCompanyName = TextEditingController(text: widget.data['sup_company_name']);
     updateContactName = TextEditingController(text: widget.data['sup_contact_name']);
     updateMobile = TextEditingController(text: widget.data['sup_mobile']);
     updateEmail = TextEditingController(text: widget.data['sup_mail']);
     updateAddress = TextEditingController(text: widget.data['sup_address']);
     updateUrl = TextEditingController(text: widget.data['sup_website']);
  }

  @override
  Widget build(BuildContext context) {
    global = Provider.of<GlobalFn>(context);
    return Container(
      color: Color(0xFF737373),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )
        ),
        child: Column(
            children: <Widget>[
              ListTile(title: Text(widget.data['sup_company_name']), subtitle: Text(widget.data['sup_contact_name'])),
              Divider(
                height: 0.0,
                color: Theme.of(context).accentColor,
              ),
              Container(
                child: Expanded(
                  child: Container(
                      child: Card(
                        child: ListView(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.account_circle, color: Color(0xff1c4b82),),
                              title: Text(widget.data['sup_contact_name']),
                              trailing: FlatButton.icon(onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: ( BuildContext context) {
                                  return updateSupplier(widget.data, context);
                                }));
                              }, padding: EdgeInsets.all(0.0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,  icon: Icon(Icons.mode_edit, size: 17.0, color: Theme.of(context).accentColor,), label: Text("Update", style: TextStyle(fontSize: 16.0, color: Theme.of(context).accentColor)),)
                            ),
                            ListTile(
                              leading: Icon(Icons.phone_android, color: Color(0xff1c4b82),),
                              title: Text(widget.data['sup_mobile']),
                            ),
                            ListTile(
                              leading: Icon(Icons.mail_outline, color: Color(0xff1c4b82),),
                              title: Text(widget.data['sup_mail']),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_on, color: Color(0xff1c4b82),),
                              title: Text(widget.data['sup_address']),
                            ),
                            ListTile(
                              leading:  Icon(Icons.link, color: Color(0xff1c4b82),),
                              title: Text(widget.data['sup_website'].toString()),
                            ),
                          ],
                        ),
                      )
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  Widget updateSupplier(data, context){
    return  Scaffold(
        appBar: AppBar(
          title: Text("Update Supplier"),
        ),
        body: Container(
          child: SizedBox.expand(
            child: Card(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.domain, color: Color(0xff1c4b82),),
                      title: TextField(
                        controller: updateCompanyName,
                        decoration: InputDecoration(labelText: "Company Name"),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.account_circle, color: Color(0xff1c4b82),),
                      title: TextField(
                        controller: updateContactName,
                        decoration: InputDecoration(labelText: "Contact Name"),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone_android, color: Color(0xff1c4b82),),
                      title: TextField(
                        keyboardType: TextInputType.numberWithOptions(),
                        controller: updateMobile,
                        decoration: InputDecoration(labelText: "Mobile Number"),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.mail_outline, color: Color(0xff1c4b82),),
                      title: TextField(
                        controller: updateEmail,
                        decoration: InputDecoration(labelText: "E-Mail "),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Color(0xff1c4b82),),
                      title: TextField(
                        controller: updateAddress,
                        decoration: InputDecoration(labelText: "Address"),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.link, color: Color(0xff1c4b82),),
                      title: TextField(
                        controller: updateUrl,
                        decoration: InputDecoration(labelText: "Website "),
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    Align(
                      child:Padding(
                        padding: const EdgeInsets.only(right:15.0),
                        child: RaisedButton(
                          onPressed: (){
                            global.updateSupplierData.addAll({'supId':data['sup_id'],'companyName':updateCompanyName.text, 'contactName':updateContactName.text, 'mobileNumber':updateMobile.text, 'mail':updateEmail.text, 'address':updateAddress.text, 'website':updateUrl.text});
                            global.updateSupplier(context, (){
                              widget.callBack();
                            });
                          },
                          child: Text("Update", style: TextStyle(color: Colors.white,),), color: Color(0xff1c4b82), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)) ,),
                      ),
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

