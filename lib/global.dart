import 'dart:async';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http ;
import 'dart:convert';
import 'package:retailoffice/notification.dart';
import 'package:intl/intl.dart';



class GlobalFn with ChangeNotifier{
  static final phoneIP = '172.20.10.3';
  static final officeIP = '192.168.15.3';
  final priceFmt = NumberFormat("#,##0.00", "en_US");
  final numFmt = NumberFormat("#,##0", "en_US");
  final qtyFmt = NumberFormat("#,##0.###", "en_US");
  final genQtyFmt = NumberFormat("###0.###", "en_US");
  final genFmt = NumberFormat("###0.##", "en_US");
  static String _clientId = '1';
  static String _clientSecret = 'oQFN96Gu1Ot7uKqG26A3JXO3eg2erGVq1PWPU0kh';
  static String _grantType = 'password';
//  static String _url = "http://$phoneIP/digitalfish/public";
  static String _url = "http://www.digitalfisheries.com/portal/public";
  static Session session;
  static Map<String, String> sessionHeader;
  final Map<String, dynamic> updateItemData = Map();
  final Map<String, dynamic> priceUpdate = Map();
  final Map<String, dynamic> addSupplierData = Map();
  final Map<String, dynamic> updateSupplierData = Map();
  final Map<String, dynamic> purchaseData = Map();
  final Map<String, dynamic> stockTransferData = Map();
  final Map<String, dynamic> creditData = Map();
  final Map<String, dynamic> payDebitData = Map();
  final Map<String, dynamic> payDiscountData = Map();
  final Map<String, dynamic> addDiscountData = Map();
  final Map<String, dynamic> delDiscountData = Map();
  final Map<String, dynamic> addUserData = Map();
  var purchaseList = <Map>[];
  Map purchaseItemName;
  String qtyType;
  String categoryType;
  Future stockItemDetails;
  Map<String, dynamic> authToken;

  Session get getSession => session;

  set setStockItemDetails(Future value){
    stockItemDetails = value;
    notifyListeners();
  }

  Future<Map> login(String user, String pass) async{
    Map<String, dynamic> loginData = {
      'client_id': _clientId,
      'client_secret': _clientSecret,
      'grant_type': _grantType,
      'username': user,
      'password': pass
    };
    final res = await http.post(_url + "/oauth/token", headers: {"Accept": "application/json"}, body: loginData);
    authToken = json.decode(res.body);
    if(authToken['error'] == null){
        final user = await http.get(_url + "/api/user", headers: {"Accept":"application/json", "Authorization":"Bearer "+authToken['access_token']});
        Map<String, dynamic> userData = json.decode(user.body);
        session = Session.data(authToken, userData);
        sessionHeader ={"Accept":"application/json", "Authorization": "Bearer " + session.accessToken};
    }
    return authToken;
  }

  String time(){
    var date =  DateTime.now();
    var time = formatDate(date, [HH, ':', nn, ':', ss]);
    return time;
  }

  Future<Map> dashboard() async{
      var date = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
      final res = await http.get(_url + "/api/dashboard/"+date, headers: sessionHeader);
      var data = json.decode(res.body);
      return data;
  }

  Future<List> getItemCategory() async{
    final res = await http.get(_url + "/api/getitemcategory", headers: sessionHeader);
    var data = json.decode(res.body);
    return data;
  }

  Future<Map> getInventory() async{
    final res = await http.get(_url + "/api/inventory", headers: sessionHeader);
    var data = json.decode(res.body);
    return data;
  }

  Future<Map> selectedInv(String itemId) async{
    final res = await http.get(_url + "/api/selectedinv/"+itemId, headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future updateSelectedInv(BuildContext context) async{
    loading(context);
    updateItemData['time'] = time();
    try{
      var res = await http.post(_url + "/api/updateselectedinventory", headers: sessionHeader, body: jsonEncode(updateItemData));
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Item Update Failed");
    }
  }

  Future updatePrice(BuildContext context) async{
    loading(context);
    priceUpdate['time'] = time();
    try{
      var res = await http.post(_url + "/api/updateprice", headers: sessionHeader, body: jsonEncode(priceUpdate));
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Price Update Failed");
    }
  }

  Future addItem(BuildContext context, req, callBack) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/additem", headers: sessionHeader, body: req);
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Item Insertion Failed");
    }
  }

  Future<List> getSuppliers() async{
    final res = await http.get(_url + "/api/getsuppliers", headers: sessionHeader);
    var data = json.decode(res.body);
    return data;
  }

  Future addSupplier(BuildContext context) async{
    try{
      var res = await http.post(_url + "/api/addsupplier", headers: sessionHeader, body: jsonEncode(addSupplierData));
      var data = json.decode(res.body);
      if(data['status'] == true) {
        Navigator.of(context).pop();
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future updateSupplier(BuildContext context) async{
    try{
      var res = await http.post(_url + "/api/updatesupplier", headers: sessionHeader, body: jsonEncode(updateSupplierData));
      var data = json.decode(res.body);
      if(data['status'] == true) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Update Failed");
    }
  }


   Future getPurchaseData() async{
    final res = await http.get(_url + "/api/getpurchasedata", headers: sessionHeader);
    var data = json.decode(res.body);
    return data;
  }

  Future savePurchase(BuildContext context) async{
    try{
      var res = await http.post(_url + "/api/savepurchase", headers: sessionHeader, body: {"data":jsonEncode(purchaseData), "list":jsonEncode(purchaseList), "time":time()});
      var data = json.decode(res.body);
      if(data['status'] == true) {
        Navigator.of(context).pop();
        purchaseList.clear();
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future getPendingPurchases() async{
    final res = await http.get(_url + "/api/getpendingpurchases", headers: sessionHeader);
    var data = json.decode(res.body);
    return data;
  }

  Future confirmDelivery(BuildContext context, purchaseItems, callBackFn) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/confirmdelivery", headers: sessionHeader, body: jsonEncode(purchaseItems) );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBackFn();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      Navigator.of(context).pop();
      failureNotify(context, "Operation Failed");
    }
  }

  Future transferStock(BuildContext context, callback) async{
    loading(context);
    stockTransferData['time'] = time();
    try{
      var res = await http.post(_url + "/api/transferstock", headers: sessionHeader, body: jsonEncode(stockTransferData) );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callback();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      Navigator.of(context).pop();
      failureNotify(context, "Operation Failed");
    }
  }


  Future<Map> getCustomers() async{
    final res = await http.get(_url + "/api/getcustomers", headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future<Map> getEachCustomer(cusId) async{
    final res = await http.get(_url + "/api/geteachcustomer/"+cusId.toString(), headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future addCustomer(BuildContext context, req, callBack) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/addcustomer", headers: sessionHeader, body: jsonEncode(req));
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future updateCustomer(BuildContext context, req, Function callback) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/updatecustomer", headers: sessionHeader, body: jsonEncode(req));
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      callback();
      if(data['status'] == true) {
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future creditProcess(BuildContext context, callBack) async{
    creditData['time'] = time();
    try{
      var res = await http.post(_url + "/api/creditprocess", headers: sessionHeader, body: jsonEncode(creditData));
      var data = json.decode(res.body);
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future payDebit(BuildContext context, callBack) async{
    loading(context);
    payDebitData['time'] = time();
    try{
      var res = await http.post(_url + "/api/paydebit", headers: sessionHeader, body: jsonEncode(payDebitData));
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future payDiscount(BuildContext context, callBack) async{
    payDiscountData['time'] = time();
    try{
      var res = await http.post(_url + "/api/paydiscount", headers: sessionHeader, body: jsonEncode(payDiscountData));
      var data = json.decode(res.body);
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future addDiscount(BuildContext context, callBack) async{
    addDiscountData['time'] = time();
    try{
      var res = await http.post(_url + "/api/adddiscount", headers: sessionHeader, body: jsonEncode(addDiscountData));
      var data = json.decode(res.body);
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future delDiscount(BuildContext context, callBack) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/deldiscount", headers: sessionHeader, body: jsonEncode(delDiscountData));
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
        callBack();
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }


  Future<List> getUsers() async{
    final res = await http.get(_url + "/api/getusers", headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future<Map> getRoles() async{
    final res = await http.get(_url + "/api/getroles", headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future addUser(BuildContext context, callBack) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/adduser", headers: sessionHeader, body: jsonEncode(addUserData) );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if(data['status'] == true){
        successNotify(context, data['response']);
        callBack();
      }else{
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future<Map> getUser(userId) async{
    final res = await http.get(_url + "/api/getuser/"+userId, headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future<void> userStatus(userId, status) async{
     http.get(_url + "/api/userstatus/"+userId.toString()+'/'+status.toString(), headers: sessionHeader);
  }

  Future salesHistory(date) async{
    final res = await http.get(_url + "/api/managersaleshistory/"+date, headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future transferHistory(date) async{
    final res = await http.get(_url + "/api/managertransferhistory/"+date, headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future purchaseHistory(date) async{
    final res = await http.get(_url + "/api/managerpurchasehistory/"+date, headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future cancleSalesOrder(BuildContext context, orderId, comment) async{
    var comments; var req;
    loading(context);
    try{
      comments = (comment == '')? '...' : comment;
      req = {'orderId': orderId, 'comments': comments, 'time':time()};
      var res = await http.post(_url + "/api/canclesalesorder", body: jsonEncode(req), headers: sessionHeader );
      var data = json.decode(res.body);
      Navigator.pop(context);
      return data;
    }catch(e){
      Navigator.pop(context);
      failureNotify(context, "Operation Failed");
    }
  }

  Future canclePurchase(BuildContext context, purchaseId, itemId) async{
    try{
      var res = await http.get(_url + "/api/canclepurchase/"+purchaseId.toString()+"/"+itemId.toString()+"/"+time(), headers: sessionHeader );
      var data = json.decode(res.body);
      return data;
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future cancleAllPurchase(BuildContext context, purchaseId) async{
    try{
      var res = await http.get(_url + "/api/cancleallpurchase/"+purchaseId.toString()+"/"+time(), headers: sessionHeader );
      var data = json.decode(res.body);
      return data;
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future cancleTransfer(BuildContext context, transferId) async{
    try{
      var res = await http.get(_url + "/api/canclepurchase/"+transferId.toString()+"/"+time(), headers: sessionHeader );
      var data = json.decode(res.body);
      return data;
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future clearUserSession(BuildContext context, transferId) async{
    loading(context);
    try{
      var res = await http.get(_url + "/api/clearusersession/"+transferId.toString(), headers: sessionHeader );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true){
        successNotify(context, data['response']);
      }else{
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future reprintReceipt(BuildContext context, orderId) async{
    loading(context);
    try{
      var res = await http.get(_url + "/api/reprintreceipt/"+orderId, headers: sessionHeader );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      if(data['status'] == true) {
        successNotify(context, data['response']);
      }else {
        failureNotify(context, data['response']);
      }
    }catch(e){
      Navigator.of(context).pop();
      failureNotify(context, "Operation Failed");
    }
  }

  Future<List> getTopSales(initialDate, finalDate) async{
    final res = await http.post(_url + "/api/topsales", headers: sessionHeader, body: jsonEncode({'initialDate':initialDate, 'finalDate':finalDate}));
    var data =  json.decode(res.body);
    return data;
  }

  Future<List> getTopQuantity() async{
    final res = await http.get(_url + "/api/gettopquantity", headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future<List> getTopCustomersVolume(initialDate, finalDate) async{
    final res = await http.post(_url + "/api/topcustomersvolume", headers: sessionHeader, body: jsonEncode({'initialDate':initialDate, 'finalDate':finalDate}));
    var data =  json.decode(res.body);
    return data;
  }

  Future<List> getTopCustomersAmount(initialDate, finalDate) async{
    final res = await http.post(_url + "/api/topcustomersamount", headers: sessionHeader, body: jsonEncode({'initialDate':initialDate, 'finalDate':finalDate}));
    var data =  json.decode(res.body);
    return data;
  }

  Future<List> getTopCustomersTickets(initialDate, finalDate) async{
    final res = await http.post(_url + "/api/topcustomerstickets", headers: sessionHeader, body: jsonEncode({'initialDate':initialDate, 'finalDate':finalDate}));
    var data =  json.decode(res.body);
    return data;
  }

  Future<List> getStores() async{
    final res = await http.get(_url + "/api/fetchstore", headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future createStore(BuildContext context, storeData) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/createstore", body: jsonEncode(storeData), headers: sessionHeader );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if(data['status'] == true){
        successNotify(context, data['response']);
      }else{
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future switchStore(BuildContext context, storeId) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/switchstore", body: jsonEncode({"store_id" : storeId}), headers: sessionHeader );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if(data['status'] == true){
        successNotify(context, data['response']);
      }else{
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future<List> getStockMovementData() async{
    final res = await http.get(_url + "/api/stockmovementdata", headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }

  Future stockMovement(BuildContext context, stockMovementData, callback) async{
    loading(context);
    try{
      var res = await http.post(_url + "/api/stockmovement", body: jsonEncode(stockMovementData), headers: sessionHeader );
      var data = json.decode(res.body);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if(data['status'] == true){
        successNotify(context, data['response']);
        callback();
      }else{
        failureNotify(context, data['response']);
      }
    }catch(e){
      failureNotify(context, "Operation Failed");
    }
  }

  Future stockMovementHistory(date) async{
    final res = await http.get(_url + "/api/stockmovementhistory/"+date, headers: sessionHeader);
    var data =  json.decode(res.body);
    return data;
  }


}



class Session{
  String accessToken;
  dynamic refreshToken;
  dynamic tokenType;
  String name;
  int userId;
  String userRole;
  var merchantId;
  var storeId;
  Session({this.accessToken, this.refreshToken, this.tokenType, this.name, this.userId, this.userRole, this.merchantId, this.storeId});
  factory Session.data(Map<String, dynamic> token, Map<String, dynamic> user){
    return Session(
      accessToken : token['access_token'],
      refreshToken : token['refresh_token'],
      tokenType : token['token_type'],
      name : user['name'],
      userId : user['user_id'],
      userRole: user['user_role']['role_desc'],
      merchantId: user['merchant_id'],
      storeId: user['store_id']
    );
  }
}