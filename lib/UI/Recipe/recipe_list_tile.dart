import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '/UI/Recipe/recipe_user_details.dart';
import '/UI/Recipe/view_recipe.dart';
import '/models/user.dart';

import '../../models/recipe.dart';
import 'add_edit_recipe.dart';

class RecipeListTileClass extends StatelessWidget {
  final CustomUser? customUser;
  final Recipe recipe;
  final bool editable;
  const RecipeListTileClass({
    Key? key,
    this.customUser,
    required this.recipe,
    required this.editable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Container(
          child: Column(
            children: [
              Text(
                recipe.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Divider(),
              Text(recipe.type),
            ],
          ),
        ),
        subtitle: Container(
          child: Column(
            children: [
              Text(recipe.description),
              Visibility(
                visible: recipe.parentId != "",
                child: RecipeUserDetailsClass(
                  parentId: recipe.parentId,
                  whatToReturn: "Name",
                ),
              ),
              //Divider(),
            ],
          ),
        ),
        onLongPress: () {
          if (editable) {
            Navigator.push(
              context,
              PageTransition(
                curve: Curves.linear,
                alignment: Alignment.topCenter,
                type: PageTransitionType.scale,
                child: AddEditRecipe(
                  method: "Edit",
                  customUser: customUser,
                  recipe: recipe,
                ),
              ),
            );
          }
        },
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              curve: Curves.linear,
              alignment: Alignment.topCenter,
              type: PageTransitionType.scale,
              child: ViewRecipeClass(customUser: customUser, recipe: recipe),
            ),
          );
        },
      ),
    );
  }
}
