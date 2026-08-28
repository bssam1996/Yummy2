import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/globals.dart' as globals;

class RecipeUserDetailsClass extends StatefulWidget {
  final String parentId;
  final TextStyle? customStyle;
  final String whatToReturn;
  const RecipeUserDetailsClass({Key? key, required this.parentId,this.customStyle,required this.whatToReturn}) : super(key: key);
  @override
  _RecipeUserDetailsClassState createState() => _RecipeUserDetailsClassState();
}

class _RecipeUserDetailsClassState extends State<RecipeUserDetailsClass> {
  @override
  Widget build(BuildContext context) {
    if(globals.userNames.containsKey(widget.parentId)){
      print("Brought from cache");
      return Text(globals.userNames[widget.parentId][widget.whatToReturn]??"",style: widget.customStyle,);
    }else{
      if(widget.parentId != "") {
        return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('Users').doc(widget.parentId).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Text("Getting data...",style: widget.customStyle,);
              }
              if(snapshot.data != null){
                if (snapshot.data?.data() == null){
                  globals.userNames[widget.parentId] = {"name":""};
                  return Text("",style: widget.customStyle,);
                }
                globals.userNames[widget.parentId] = (snapshot.data?.data() as Map);
                return Text((snapshot.data?.data() as Map)[widget.whatToReturn]??"",style: widget.customStyle,);
              }else{
                return Text("Getting data...",style: widget.customStyle,);
              }
            }
        );
      }else{
        return Text("Missing ID",style: widget.customStyle,);
      }
    }
  }
}