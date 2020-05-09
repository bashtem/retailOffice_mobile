import 'package:flutter/material.dart';

class SearchData extends SearchDelegate<List>{
Function searchMethod;
List data;
String searchKey;
List searchKeys;
SearchData(this.searchMethod, this.data, this.searchKey, {this.searchKeys});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: (){
        query = '';
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var filtered, boolTest ;
    final List result = query.isEmpty ? data : data.where((each){
      if(searchKeys != null){
        filtered = false;
        searchKeys.forEach((item){
          if(item.runtimeType != String) {
            boolTest = each[item['key']][item['value']].toLowerCase().contains(query);
          }else {
            boolTest = each[item].toLowerCase().contains(query);
          }
          if(boolTest)
            filtered = boolTest;
        });
      }else{
        filtered = each[searchKey].toLowerCase().contains(query);
      }
      return filtered;
    }).toList();
    return searchMethod(result);
  }

}