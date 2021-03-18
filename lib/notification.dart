import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

void successNotify(context, data){
  showDialog(context: context, builder: (BuildContext context){
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)
          )
      ),
      children: <Widget>[
        Container(
            height: 135,
            padding: EdgeInsets.only(left:20.0, right:20.0, top:15.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Icon(Icons.check_circle_outline, color: Color(0xFF00bd56), size: 50.0,),
                  Text(data),
                  FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text("OK",), padding: EdgeInsets.only(top:0.0),)
                ]
            )
        )
      ],
    );
  });
}

void failureNotify(context, data){
  showDialog(context: context, builder: (BuildContext context){
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)
          )
      ),
      children: <Widget>[
        Container(
            height: 135,
            padding: EdgeInsets.only(left:20.0, right:20.0, top:15.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Icon(Icons.highlight_off, color: Color(0xFFaf0404), size: 50.0,),
                  Text(data),
                  FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text("OK",), padding: EdgeInsets.only(top:0.0),)
                ]
            )
        )
      ],
    );
  });
}

Widget noRecords({String msg:"No Records Found"}){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.insert_drive_file, size: 80.0, color: Color(0xffdadada),),
        Text(msg, style: TextStyle(
          fontSize: 15,
          color: Color(0xff63707e),
          fontWeight: FontWeight.w500
        ),)
      ],
    ),
  );
}

void confirmDialog(context, confirmMethod){
  showDialog(
    context: context,
    builder:(context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
          Radius.circular(10.0)
          )
        ),
        title: Text("Do you want to continue?", style: TextStyle(fontSize: 15, color: Color(0xff63707e)),),
        actions: <Widget>[
          FlatButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("NO")),
          FlatButton(
            onPressed: (){
              confirmMethod();
            },
            child: Text("YES")
          ),
        ],
      );
    }
  );
}

void confirmDialogWithText(context, confirmMethod){
  TextEditingController comment = TextEditingController();
  showDialog(
      context: context,
      builder:(context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)
              )
          ),
          title: Text("Comments: ", style: TextStyle(fontSize: 15, color: Color(0xff63707e)),),
          content: TextField(
            controller: comment,
            decoration: InputDecoration(
              hintText: "Optional..."
            ),
            maxLines: 5,
          ),
          actions: <Widget>[
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text("CANCLE")),
            RaisedButton(
              color: Color(0xff1c4b82),
              child: Text("CONTINUE",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onPressed: (){
                confirmMethod(comment.text.toString());
              },
            )
          ],
        );
      }
  );
}

void loading(context){
  ProgressDialog load;
  load = ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false);
  load.show();
}