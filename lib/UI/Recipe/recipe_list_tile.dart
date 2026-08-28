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
  final bool showType;
  const RecipeListTileClass({
    Key? key,
    this.customUser,
    required this.recipe,
    required this.editable,
    this.showType = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showType && recipe.type.trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recipe.type,
                  style: const TextStyle(
                    color: Color(0xFFB9503B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              recipe.title,
              style: const TextStyle(
                color: Color(0xFF264653),
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.description.trim().isNotEmpty)
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              if (recipe.parentId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: RecipeUserDetailsClass(
                    parentId: recipe.parentId,
                    whatToReturn: "Name",
                    showIcon: true,
                    customStyle: const TextStyle(
                      color: Color(0xFFB9503B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_rounded,
          color: Color(0xFFB9503B),
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
