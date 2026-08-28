import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/UI/Recipe/recipe_list_tile.dart';
import '/models/user.dart';
import '/models/recipe.dart';
import '../../shared/loading.dart';

class ListOfRecipesClass extends StatefulWidget {
  final CustomUser? customUser;
  const ListOfRecipesClass({Key? key, required this.customUser})
    : super(key: key);

  @override
  State<ListOfRecipesClass> createState() => _ListOfRecipesClassState();
}

class _ListOfRecipesClassState extends State<ListOfRecipesClass> {
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreInstance
          .collection('Users')
          .doc(widget.customUser?.uid)
          .collection("recipes")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();

        final recipes = <Recipe>[];
        for (final document in snapshot.data!.docs) {
          final data = document.data() as Map;
          recipes.add(
            Recipe(
              id: document.id,
              parentId: document.reference.parent.parent?.id ?? "",
              sharing: data["Sharing"]?.toString() ?? "",
              created: data["Created"].toDate(),
              type: data["Type"]?.toString() ?? "",
              title: data["Title"]?.toString() ?? "",
              description: data["Description"]?.toString() ?? "",
              ingredients: data["Ingredients"]?.toString() ?? "",
              directions: data["Directions"]?.toString() ?? "",
              numberOfMinutes: data["NumberOfMinutes"] ?? 0,
              ovenTemp: data["OvenTemp"] ?? 0,
              servings: data["Servings"] ?? 0,
              notes: data["Notes"]?.toString() ?? "",
              videos: data["videos"] ?? [],
            ),
          );
        }

        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes yet.'));
        }

        final recipesByType = <String, List<Recipe>>{};
        for (final recipe in recipes) {
          final type = recipe.type.trim().isEmpty
              ? 'Uncategorised'
              : recipe.type.trim();
          recipesByType.putIfAbsent(type, () => []).add(recipe);
        }

        final types = recipesByType.keys.toList()
          ..sort(
            (first, second) =>
                first.toLowerCase().compareTo(second.toLowerCase()),
          );
        for (final recipesInType in recipesByType.values) {
          recipesInType.sort(
            (first, second) =>
                first.title.toLowerCase().compareTo(second.title.toLowerCase()),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 88),
          children: [
            for (final type in types) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  type,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              for (var index = 0; index < recipesByType[type]!.length; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RecipeListTileClass(
                    customUser: widget.customUser,
                    recipe: recipesByType[type]![index],
                    editable: true,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
