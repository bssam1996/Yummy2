import '/UI/Recipe/recipe_list_tile.dart';
import '/models/user.dart';
import 'package:flutter/material.dart';
import '/models/recipe.dart';
class SearchRecipesClass extends SearchDelegate{
  final List<Recipe> listExample;
  final bool editable;
  CustomUser? customUser;

  SearchRecipesClass({this.customUser,required this.listExample,required this.editable});
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          icon: Icon(Icons.close),
          onPressed: (){
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
      Navigator.pop(context);
    });
  }
String selectedResult = "";
  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Recipe> suggestionList = [];
    query.isEmpty?
        suggestionList = listExample:
        suggestionList.addAll(listExample.where((element) =>
                element.type.toUpperCase().contains(query.toUpperCase()) ||
                element.title.toUpperCase().contains(query.toUpperCase()) ||
                element.description.toUpperCase().contains(query.toUpperCase())
        ));
        return ListView.builder(
              shrinkWrap:true,
              itemCount:suggestionList.length,
              itemBuilder: (BuildContext context,int index){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RecipeListTileClass(customUser: customUser,recipe: suggestionList[index],index: index,editable: editable,)
                  ],
                );
              }
          );
  }

}