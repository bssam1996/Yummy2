import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummy2/shared/constants.dart';
import '../../shared/snack.dart';
import '/models/user.dart';
import 'helper.dart';

import '../../models/recipe.dart';
import 'add_edit_recipe.dart';
import 'multiplier_recipe.dart' as multiplier_recipe;

class ViewRecipeClass extends StatefulWidget {
  final Recipe recipe;
  final CustomUser? customUser;
  const ViewRecipeClass({Key? key, required this.recipe, this.customUser})
    : super(key: key);

  @override
  State<ViewRecipeClass> createState() => _ViewRecipeClassState();
}

class _ViewRecipeClassState extends State<ViewRecipeClass> {
  final customstyleforHeads = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final customstyleforDetails = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  RoundedLoadingButtonController _deleteController =
      new RoundedLoadingButtonController();
  late final String _originalIngredients;
  bool _ingredientsHaveBeenMultiplied = false;

  bool get _canManageRecipe =>
      widget.customUser != null &&
      (widget.recipe.parentId.isEmpty ||
          widget.recipe.parentId == widget.customUser!.uid);

  @override
  void initState() {
    super.initState();
    _originalIngredients = widget.recipe.ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          backgroundColor: darkBlue,
          title: const Text(
            "Recipe Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            Visibility(
              visible: _canManageRecipe,
              child: PopupMenuButton<String>(
                onSelected: handleOptionsClick,
                itemBuilder: (BuildContext context) {
                  return {'Edit', 'Multiply'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
            // IconButton(
            //   onPressed: (){
            //     Navigator.push(context, PageTransition(
            //         curve: Curves.linear,
            //         alignment: Alignment.topCenter,
            //         type: PageTransitionType.scale,
            //         child: AddEditRecipe(method: "Edit",customUser: widget.customUser,recipe: widget.recipe,))
            //     );
            //   },
            //   icon: FaIcon(
            //     FontAwesomeIcons.penToSquare,
            //     color: Colors.white
            //   ),
            // )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                ..._detailSection(
                  FontAwesomeIcons.paragraph,
                  "Title: ",
                  widget.recipe.title,
                ),
                ..._detailSection(
                  FontAwesomeIcons.burger,
                  "Type: ",
                  widget.recipe.type,
                ),
                ..._detailSection(
                  FontAwesomeIcons.audioDescription,
                  "Description: ",
                  widget.recipe.description,
                ),
                if (widget.recipe.ingredients.trim().isNotEmpty) ...[
                  elementRow(
                    FontAwesomeIcons.table,
                    "Ingredients: ",
                    widget.recipe.ingredients,
                  ),
                  Visibility(
                    visible: _ingredientsHaveBeenMultiplied,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            widget.recipe.ingredients = _originalIngredients;
                            _ingredientsHaveBeenMultiplied = false;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset ingredients'),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
                ..._detailSection(
                  FontAwesomeIcons.diamondTurnRight,
                  "Directions: ",
                  widget.recipe.directions,
                ),
                if (widget.recipe.numberOfMinutes > 0)
                  ..._detailSection(
                    FontAwesomeIcons.clock,
                    "Minutes: ",
                    widget.recipe.numberOfMinutes.toString(),
                  ),
                if (widget.recipe.ovenTemp > 0)
                  ..._detailSection(
                    FontAwesomeIcons.temperatureEmpty,
                    "Oven Temp: ",
                    widget.recipe.ovenTemp.toString(),
                  ),
                if (widget.recipe.servings > 0)
                  ..._detailSection(
                    FontAwesomeIcons.cookie,
                    "Servings: ",
                    widget.recipe.servings.toString(),
                  ),
                ..._detailSection(
                  FontAwesomeIcons.noteSticky,
                  "Notes: ",
                  widget.recipe.notes,
                ),
                if (widget.recipe.videos?.isNotEmpty ?? false) ...[
                  videoListing(FontAwesomeIcons.video),
                  const Divider(),
                ],

                Visibility(
                  visible: _canManageRecipe,
                  child: RoundedLoadingButton(
                    color: Color(0xffee7373),
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    controller: _deleteController,
                    onPressed: () async {
                      if (await confirm(
                        context,
                        title: const Text('Deleting Recipe'),
                        content: const Text(
                          'Are you sure you want to delete this recipe?',
                        ),
                        textOK: const Text('Yes'),
                        textCancel: const Text('No'),
                      )) {
                        setState(() {
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(widget.customUser?.uid)
                              .collection("recipes")
                              .doc(widget.recipe.id)
                              .delete()
                              .then((value) {
                                _deleteController.stop();
                                Navigator.pop(context);
                              });
                        });
                      }
                      _deleteController.stop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _detailSection(FaIconData icon, String title, String text) {
    if (text.trim().isEmpty) {
      return const [];
    }
    return [elementRow(icon, title, text), const Divider()];
  }

  Widget elementRow(var icon, var title, var text) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [FaIcon(icon, color: Colors.black, size: 20)],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text(title, style: customstyleforHeads)],
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: AutoSizeText(text, style: customstyleforDetails)),
            ],
          ),
        ),
      ],
    );
  }

  Widget videoListing(var icon) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [FaIcon(icon, color: Colors.black, size: 23)],
              ),
            ),
            Expanded(
              flex: 9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("- List Of Videos -", style: customstyleforDetails),
                ],
              ),
            ),
          ],
        ),
        Container(
          height: ((widget.recipe.videos?.length ?? 0) > 0)
              ? ((widget.recipe.videos?.length ?? 0) < 4)
                    ? ((widget.recipe.videos?.length ?? 0) * 100).toDouble()
                    : 200
              : 10,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.recipe.videos?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(widget.recipe.videos![index]["link"]),
                      subtitle: Text(
                        widget.recipe.videos![index]["description"],
                      ),
                      onTap: () {
                        try {
                          launch((widget.recipe.videos![index]["link"] ?? ""));
                        } catch (e) {
                          print(e.toString());
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(snack().displaySnackBar(e.toString()));
                        }
                      },
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void handleOptionsClick(String value) async {
    if (!_canManageRecipe) {
      return;
    }
    switch (value) {
      case 'Edit':
        Navigator.push(
          context,
          PageTransition(
            curve: Curves.linear,
            alignment: Alignment.topCenter,
            type: PageTransitionType.scale,
            child: AddEditRecipe(
              method: "Edit",
              customUser: widget.customUser,
              recipe: widget.recipe,
            ),
          ),
        );
        break;
      case 'Multiply':
        var data = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return multiplier_recipe.showdialog(context);
          },
        );
        if (data == null) {
          break;
        }
        print(data);
        try {
          setState(() {
            widget.recipe.ingredients = multiplyText(
              widget.recipe.ingredients,
              data,
            );
            _ingredientsHaveBeenMultiplied = true;
          });
          break;
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(snack().displaySnackBar(e.toString(), Colors.red));
          break;
        }
    }
  }
}
