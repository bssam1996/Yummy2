import 'package:yummy2/shared/constants.dart';

import 'get_user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/UI/Recipe/recipe_list_tile.dart';
import '/models/user.dart';
import '/models/recipe.dart';
import '../../shared/loading.dart';
class ViewPublicRecipesClass extends StatefulWidget {
  final CustomUser? customUser;
  const ViewPublicRecipesClass({Key? key,this.customUser}) : super(key: key);

  @override
  State<ViewPublicRecipesClass> createState() => _ViewPublicRecipesClassState();
}

class _ViewPublicRecipesClassState extends State<ViewPublicRecipesClass> {
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Public Recipes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          backgroundColor: darkBlue,
        ),
        backgroundColor: lightBlue,
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collectionGroup("recipes").where("Sharing",isEqualTo: "Public").orderBy("Created",descending: true).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Loading();
              recipes = [];
              if(snapshot.data != null){
                int snapshotLength = snapshot.data?.docs.length??0;
                for(int snapIndex = 0; snapIndex < snapshotLength; snapIndex++){
                  Recipe recipe = Recipe(
                    id: snapshot.data?.docs.elementAt(snapIndex).id??"",
                    sharing: (snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Sharing"]?.toString()??"",
                    created: (snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Created"].toDate(),
                    type:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Type"]?.toString()??"",
                    title:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Title"]?.toString()??"",
                    description:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Description"]?.toString()??"",
                    ingredients:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Ingredients"]?.toString()??"",
                    directions:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Directions"]?.toString()??"",
                    numberOfMinutes:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["NumberOfMinutes"]??0,
                    ovenTemp:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["OvenTemp"]??0,
                    servings:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Servings"]??0,
                    notes:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["Notes"]?.toString()??"",
                    videos:(snapshot.data?.docs.elementAt(snapIndex).data() as Map)["videos"]??[],
                  );
                  var parentID = snapshot.data?.docs.elementAt(snapIndex).reference.parent.parent?.id;
                  recipe.parentId = parentID??"";
                  recipes.add(recipe);
                }
              }
              return ListView.builder(
                  shrinkWrap:true,
                  itemCount:recipes.length,
                  itemBuilder: (BuildContext context,int index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RecipeListTileClass(customUser: widget.customUser,recipe: recipes[index],index: index,editable:false)
                        ],
                      ),
                    );
                  }
              );
            }
        ),
      ),
    );
  }
}
