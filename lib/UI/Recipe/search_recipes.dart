import '/UI/Recipe/recipe_list_tile.dart';
import '/models/user.dart';
import 'package:flutter/material.dart';
import '/models/recipe.dart';

class SearchRecipesClass extends SearchDelegate {
  final List<Recipe> listExample;
  final bool editable;
  final Map<String, String> authorNames;
  CustomUser? customUser;

  SearchRecipesClass({
    this.customUser,
    required this.listExample,
    required this.editable,
    this.authorNames = const {},
  });
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String selectedResult = "";
  @override
  Widget buildResults(BuildContext context) {
    return Container(child: Center(child: Text(selectedResult)));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchTerm = query.trim().toUpperCase();
    final suggestionList = searchTerm.isEmpty
        ? List<Recipe>.of(listExample)
        : listExample
              .where(
                (recipe) =>
                    recipe.type.toUpperCase().contains(searchTerm) ||
                    recipe.title.toUpperCase().contains(searchTerm) ||
                    recipe.tags.any(
                      (tag) => tag.toUpperCase().contains(searchTerm),
                    ) ||
                    (authorNames[recipe.parentId] ?? '').toUpperCase().contains(
                      searchTerm,
                    ),
              )
              .toList();
    suggestionList.sort(
      (first, second) =>
          first.title.toLowerCase().compareTo(second.title.toLowerCase()),
    );

    if (suggestionList.isEmpty) {
      return const Center(child: Text('No recipes found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RecipeListTileClass(
              customUser: customUser,
              recipe: suggestionList[index],
              editable: editable,
            ),
          ],
        );
      },
    );
  }
}
