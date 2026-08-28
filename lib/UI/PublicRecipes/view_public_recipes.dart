import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yummy2/shared/constants.dart';

import '/UI/Recipe/recipe_list_tile.dart';
import '/UI/Recipe/search_recipes.dart';
import '/models/recipe.dart';
import '/models/user.dart';
import '../../shared/loading.dart';

class ViewPublicRecipesClass extends StatefulWidget {
  final CustomUser? customUser;
  const ViewPublicRecipesClass({Key? key, this.customUser}) : super(key: key);

  @override
  State<ViewPublicRecipesClass> createState() => _ViewPublicRecipesClassState();
}

class _PublicRecipesData {
  const _PublicRecipesData({required this.recipes});

  final List<Recipe> recipes;
}

class _ViewPublicRecipesClassState extends State<ViewPublicRecipesClass> {
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Public Recipes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: darkBlue,
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: _showSearch),
          ],
        ),
        backgroundColor: lightBlue,
        body: StreamBuilder<_PublicRecipesData>(
          stream: firestoreInstance
              .collectionGroup("recipes")
              .where("Sharing", isEqualTo: "Public")
              .orderBy("Created", descending: true)
              .snapshots()
              .asyncMap(_namedPublicRecipes),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<_PublicRecipesData> snapshot,
              ) {
                if (snapshot.hasError) {
                  return _errorState(snapshot.error);
                }
                if (!snapshot.hasData) return Loading();

                final recipes = snapshot.data!.recipes;
                if (recipes.isEmpty) {
                  return const Center(
                    child: Text('No public recipes from named profiles yet.'),
                  );
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
                    (first, second) => first.title.toLowerCase().compareTo(
                      second.title.toLowerCase(),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  children: [
                    for (final type in types) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: darkBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.public_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (final recipe in recipesByType[type]!)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RecipeListTileClass(
                            customUser: widget.customUser,
                            recipe: recipe,
                            editable: false,
                            showType: false,
                          ),
                        ),
                    ],
                  ],
                );
              },
        ),
      ),
    );
  }

  Future<void> _showSearch() async {
    try {
      final snapshot = await firestoreInstance
          .collectionGroup("recipes")
          .where("Sharing", isEqualTo: "Public")
          .orderBy("Created", descending: true)
          .get();
      if (!mounted) return;

      final recipes = _recipesFromSnapshot(snapshot);
      final authorNames = await _loadAuthorNames(recipes);
      if (!mounted) return;

      final namedRecipes = recipes
          .where(
            (recipe) => (authorNames[recipe.parentId] ?? '').trim().isNotEmpty,
          )
          .toList();

      showSearch(
        context: context,
        delegate: SearchRecipesClass(
          customUser: widget.customUser,
          listExample: namedRecipes,
          editable: false,
          authorNames: authorNames,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load public recipes: $error')),
      );
    }
  }

  Widget _errorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load public recipes.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<Map<String, String>> _loadAuthorNames(List<Recipe> recipes) async {
    final authorIds = recipes
        .map((recipe) => recipe.parentId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final authorEntries = await Future.wait(
      authorIds.map((authorId) async {
        try {
          final user = await firestoreInstance
              .collection('Users')
              .doc(authorId)
              .get();
          final data = user.data();
          return MapEntry(authorId, data?["Name"]?.toString() ?? '');
        } catch (_) {
          return MapEntry(authorId, '');
        }
      }),
    );
    return Map<String, String>.fromEntries(authorEntries);
  }

  Future<_PublicRecipesData> _namedPublicRecipes(QuerySnapshot snapshot) async {
    final recipes = _recipesFromSnapshot(snapshot);
    final authorNames = await _loadAuthorNames(recipes);
    return _PublicRecipesData(
      recipes: recipes
          .where(
            (recipe) => (authorNames[recipe.parentId] ?? '').trim().isNotEmpty,
          )
          .toList(),
    );
  }

  List<Recipe> _recipesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((document) {
      final data = document.data() as Map;
      final created = data["Created"];
      return Recipe(
        id: document.id,
        parentId: document.reference.parent.parent?.id ?? "",
        sharing: data["Sharing"]?.toString() ?? "",
        created: created is Timestamp
            ? created.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0),
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
      );
    }).toList();
  }
}
