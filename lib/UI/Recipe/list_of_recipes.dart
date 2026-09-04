import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/UI/Recipe/recipe_list_tile.dart';
import '/models/user.dart';
import '/models/recipe.dart';
import '../../shared/loading.dart';
import '../../shared/constants.dart';

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
              tags: Recipe.tagsFrom(data["Tags"]),
            ),
          );
        }

        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes yet.'));
        }

        final recipesByCategory = <String, List<Recipe>>{};
        final categoryLabels = <String, String>{};
        for (final recipe in recipes) {
          final categoryLabel = recipe.type.trim().isEmpty
              ? 'Uncategorised'
              : recipe.type.trim();
          final categoryKey = categoryLabel.toLowerCase();
          recipesByCategory.putIfAbsent(categoryKey, () => []).add(recipe);
          categoryLabels.putIfAbsent(categoryKey, () => categoryLabel);
        }

        final categoryKeys = recipesByCategory.keys.toList()..sort();
        for (final recipesInCategory in recipesByCategory.values) {
          recipesInCategory.sort(
            (first, second) =>
                first.title.toLowerCase().compareTo(second.title.toLowerCase()),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 88),
          children: [
            for (final categoryKey in categoryKeys) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    key: PageStorageKey('my-recipes-category-$categoryKey'),
                    initiallyExpanded: true,
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    collapsedShape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Row(
                      children: [
                        const Icon(
                          Icons.restaurant_menu_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          categoryLabels[categoryKey]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      for (final recipe in recipesByCategory[categoryKey]!)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: RecipeListTileClass(
                            customUser: widget.customUser,
                            recipe: recipe,
                            editable: true,
                            showType: false,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
