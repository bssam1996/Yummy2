import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:yummy2/models/recipe.dart';
import 'package:yummy2/models/user.dart';
import 'package:yummy2/shared/constants.dart';

import '../../shared/snack.dart';

const _maximumWordsPerRecipeField = 1000;
const _maximumTagsPerRecipe = 10;

class _WordLimitTextInputFormatter extends TextInputFormatter {
  const _WordLimitTextInputFormatter(this.maximumWords);

  final int maximumWords;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = RegExp(r'\S+').allMatches(newValue.text).toList();
    if (words.length <= maximumWords) {
      return newValue;
    }

    final truncatedText = newValue.text.substring(
      0,
      words[maximumWords - 1].end,
    );
    return TextEditingValue(
      text: truncatedText,
      selection: TextSelection.collapsed(offset: truncatedText.length),
    );
  }
}

class AddEditRecipe extends StatefulWidget {
  final String method;
  final CustomUser? customUser;
  final Recipe? recipe;
  const AddEditRecipe({
    Key? key,
    required this.method,
    required this.customUser,
    this.recipe,
  }) : super(key: key);

  @override
  State<AddEditRecipe> createState() => _AddEditRecipeState();
}

class _AddEditRecipeState extends State<AddEditRecipe> {
  final firestoreInstance = FirebaseFirestore.instance;
  String selectedType = "Private";
  TextEditingController typeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController directionsController = TextEditingController();
  TextEditingController numOfMinutesController = TextEditingController();
  TextEditingController ovenTempController = TextEditingController();
  TextEditingController servingsNumController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController videoLinkController = TextEditingController();
  TextEditingController videoDescriptionController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  List videos = [];
  List<String> tags = [];
  List<String> _tagSuggestions = [];
  List<String> _categorySuggestions = [];
  final RoundedLoadingButtonController _createController =
      RoundedLoadingButtonController();
  RoundedLoadingButtonController _deleteController =
      new RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    if (widget.method == "Edit" && widget.recipe != null) {
      typeController.text = widget.recipe?.type ?? "";
      titleController.text = widget.recipe?.title ?? "";
      descriptionController.text = widget.recipe?.description ?? "";
      ingredientsController.text = widget.recipe?.ingredients ?? "";
      directionsController.text = widget.recipe?.directions ?? "";
      numOfMinutesController.text =
          widget.recipe?.numberOfMinutes.toString() ?? "";
      ovenTempController.text = widget.recipe?.ovenTemp.toString() ?? "";
      servingsNumController.text = widget.recipe?.servings.toString() ?? "";
      notesController.text = widget.recipe?.notes ?? "";
      videos = widget.recipe?.videos ?? [];
      tags = _normaliseTags(
        widget.recipe?.tags ?? const [],
        maximum: _maximumTagsPerRecipe,
      );
      selectedType = widget.customUser == null
          ? "Private"
          : widget.recipe?.sharing ?? "Private";
    }
    _loadRecipeSuggestions();
  }

  @override
  void dispose() {
    typeController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    ingredientsController.dispose();
    directionsController.dispose();
    numOfMinutesController.dispose();
    ovenTempController.dispose();
    servingsNumController.dispose();
    notesController.dispose();
    videoLinkController.dispose();
    videoDescriptionController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          title: Text(
            widget.method == "Create" ? "Create recipe" : "Edit recipe",
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.method == "Create"
                      ? "What are you making?"
                      : "Update your recipe",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add the details that make this recipe easy to cook again.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0E1D5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.networkWired,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: DropdownButton<String>(
                          value: selectedType.isNotEmpty
                              ? selectedType
                              : "Private",
                          iconSize: 24,
                          elevation: 16,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 20, color: darkBlue),
                          alignment: Alignment.center,
                          underline: Container(
                            height: 2,
                            color: const Color(0xFFF0E1D5),
                          ),
                          menuMaxHeight: 100,
                          onChanged: widget.customUser == null
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      selectedType = newValue.toString();
                                    }
                                    ;
                                  });
                                },
                          items:
                              [
                                if (widget.customUser != null) "Public",
                                "Private",
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(child: Text(value)),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.customUser == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Sign in to make a recipe public.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildCategoryField(),
                Divider(),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: FaIcon(
                      FontAwesomeIcons.paragraph,
                      color: Colors.black,
                      size: 25,
                    ),
                    hintText: "e.g Chocolate Cake",
                    labelText: "*Recipe's Title",
                  ),
                  controller: titleController,
                ),
                Divider(),
                _buildMultiLineRecipeField(
                  controller: descriptionController,
                  icon: FontAwesomeIcons.audioDescription,
                  hintText: "e.g White sauce chocolate cake",
                  labelText: "Brief Description",
                ),
                Divider(),
                _buildMultiLineRecipeField(
                  controller: ingredientsController,
                  icon: FontAwesomeIcons.table,
                  hintText: "e.g 1 salt tablespoon\n2 sugar tablespoon",
                  labelText: "Ingredients",
                ),
                Divider(),
                _buildMultiLineRecipeField(
                  controller: directionsController,
                  icon: FontAwesomeIcons.directions,
                  hintText: "e.g Start with boiling 1 L of milk",
                  labelText: "Directions",
                ),
                Divider(),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: FaIcon(
                      FontAwesomeIcons.clock,
                      color: Colors.black,
                      size: 25,
                    ),
                    hintText: "e.g 60",
                    labelText: "Number of minutes",
                  ),
                  controller: numOfMinutesController,
                  keyboardType: TextInputType.number,
                ),
                Divider(),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: FaIcon(
                      FontAwesomeIcons.thermometerEmpty,
                      color: Colors.black,
                      size: 38,
                    ),
                    hintText: "e.g 200",
                    labelText: "Oven Temperature",
                  ),
                  controller: ovenTempController,
                  keyboardType: TextInputType.number,
                ),
                Divider(),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: FaIcon(
                      FontAwesomeIcons.cookie,
                      color: Colors.black,
                      size: 25,
                    ),
                    hintText: "e.g 2",
                    labelText: "Servings",
                  ),
                  controller: servingsNumController,
                  keyboardType: TextInputType.number,
                ),
                Divider(),
                _buildMultiLineRecipeField(
                  controller: notesController,
                  icon: FontAwesomeIcons.stickyNote,
                  hintText: "e.g Don't forget constant steering",
                  labelText: "Notes",
                ),
                Divider(),
                _buildTagsField(),
                const Divider(),
                // Videos Links
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.video,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                //icon: Icon(Icons.add_circle),
                                hintText: "youtube.com/video1",
                                labelText: "Video Link",
                              ),
                              controller: videoLinkController,
                              keyboardType: TextInputType.text,
                            ),
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                //icon: Icon(Icons.add_circle),
                                hintText: "Video to show ingredients",
                                labelText: "Video Description",
                              ),
                              controller: videoDescriptionController,
                              keyboardType: TextInputType.text,
                            ),
                          ],
                        ),
                      ),
                      flex: 8,
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (videoLinkController.text.isEmpty ||
                                videoLinkController.text == "") {
                              return;
                            }
                            videos.add({
                              "link": videoLinkController.text,
                              "description": videoDescriptionController.text,
                            });
                            videoLinkController.text = "";
                            videoDescriptionController.text = "";
                          });
                        },
                        child: Icon(Icons.add, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.green.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: (videos.isNotEmpty)
                      ? ((videos.length) < 4)
                            ? ((videos.length) * 60).toDouble()
                            : 200
                      : 10,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(videos[index]["link"]),
                            subtitle: Text(videos[index]["description"]),
                            trailing: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  videos.removeAt(index);
                                });
                              },
                              child: Icon(Icons.delete, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                                backgroundColor: Color(0xffee7373),
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
                Divider(height: 20),
                RoundedLoadingButton(
                  color: darkBlue,
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  controller: _createController,
                  onPressed: () {
                    _handlesubmit();
                  },
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: widget.method == "Edit",
                  child: RoundedLoadingButton(
                    color: darkPink,
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
                              .doc(widget.recipe?.id)
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

  Widget _buildMultiLineRecipeField({
    required TextEditingController controller,
    required FaIconData icon,
    required String hintText,
    required String labelText,
  }) {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      maxLines: 50,
      minLines: 1,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        icon: FaIcon(icon, color: Colors.black, size: 25),
        hintText: hintText,
        labelText: labelText,
        counterText:
            '${_wordCount(controller.text)} / $_maximumWordsPerRecipeField words',
      ),
      controller: controller,
      keyboardType: TextInputType.multiline,
      inputFormatters: const [
        _WordLimitTextInputFormatter(_maximumWordsPerRecipeField),
      ],
      onChanged: (_) => setState(() {}),
    );
  }

  int _wordCount(String text) => RegExp(r'\S+').allMatches(text).length;

  Widget _buildCategoryField() {
    final searchTerm = typeController.text.trim().toLowerCase();
    final suggestions = _categorySuggestions
        .where(
          (category) =>
              searchTerm.isEmpty || category.toLowerCase().contains(searchTerm),
        )
        .take(30)
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 14),
          child: FaIcon(FontAwesomeIcons.burger, color: Colors.black, size: 23),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: typeController,
                textCapitalization: TextCapitalization.words,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[,;]')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: true,
                  hintText: 'e.g Dessert',
                  labelText: '*Recipe category',
                  helperText:
                      'Choose a previous category below or type a new one. One category per recipe.',
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Previously used categories',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: suggestions
                      .map(
                        (category) => ActionChip(
                          label: Text(category),
                          onPressed: () {
                            setState(() {
                              typeController.text = category;
                              typeController.selection =
                                  TextSelection.collapsed(
                                    offset: category.length,
                                  );
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    final availableSuggestions = _tagSuggestions
        .where(
          (tag) =>
              !tags.any(
                (selectedTag) => selectedTag.toLowerCase() == tag.toLowerCase(),
              ) &&
              (tagController.text.trim().isEmpty ||
                  tag.toLowerCase().contains(
                    tagController.text.trim().toLowerCase(),
                  )),
        )
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 14),
          child: FaIcon(FontAwesomeIcons.tags, color: Colors.black, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: tagController,
                enabled: tags.length < _maximumTagsPerRecipe,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: _addTags,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  hintText: 'e.g Quick, Vegetarian',
                  labelText: 'Tags (${tags.length}/$_maximumTagsPerRecipe)',
                  helperText:
                      'Add up to $_maximumTagsPerRecipe tags. Separate multiple tags with commas.',
                  suffixIcon: IconButton(
                    tooltip: 'Add tag',
                    onPressed: tags.length < _maximumTagsPerRecipe
                        ? () => _addTags(tagController.text)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags
                      .map(
                        (tag) => InputChip(
                          label: Text('#$tag'),
                          onDeleted: () {
                            setState(() => tags.remove(tag));
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
              if (availableSuggestions.isNotEmpty &&
                  tags.length < _maximumTagsPerRecipe) ...[
                const SizedBox(height: 12),
                const Text(
                  'Previously used tags',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: availableSuggestions
                      .take(30)
                      .map(
                        (tag) => ActionChip(
                          label: Text('#$tag'),
                          onPressed: () => _addTags(tag),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadRecipeSuggestions() async {
    final userId = widget.customUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await firestoreInstance
          .collection('Users')
          .doc(userId)
          .collection('recipes')
          .get();
      final previousTags = <dynamic>[];
      final previousCategories = <dynamic>[];
      for (final document in snapshot.docs) {
        final data = document.data() as Map;
        final tags = data['Tags'];
        if (tags is Iterable) previousTags.addAll(tags);
        previousCategories.add(data['Type'] ?? '');
      }
      if (!mounted) return;
      setState(() {
        _tagSuggestions = _normaliseTags(previousTags);
        _tagSuggestions.sort(
          (first, second) =>
              first.toLowerCase().compareTo(second.toLowerCase()),
        );
        _categorySuggestions = _normaliseCategories(previousCategories);
        _categorySuggestions.sort(
          (first, second) =>
              first.toLowerCase().compareTo(second.toLowerCase()),
        );
      });
    } catch (_) {
      // Suggestions are a convenience; manually entering a category or tag
      // must still work when older recipes cannot be loaded.
    }
  }

  List<String> _normaliseTags(Iterable<dynamic> rawTags, {int? maximum}) {
    final result = <String>[];
    final seen = <String>{};
    for (final rawTag in rawTags) {
      final tag = rawTag
          .toString()
          .trim()
          .replaceFirst(RegExp(r'^#+'), '')
          .replaceAll(RegExp(r'\s+'), ' ');
      final key = tag.toLowerCase();
      if (tag.isNotEmpty && seen.add(key)) result.add(tag);
      if (maximum != null && result.length == maximum) break;
    }
    return result;
  }

  List<String> _normaliseCategories(Iterable<dynamic> rawCategories) {
    final result = <String>[];
    final seen = <String>{};
    for (final rawCategory in rawCategories) {
      final category = _normaliseCategory(rawCategory.toString());
      final key = category.toLowerCase();
      if (category.isNotEmpty && seen.add(key)) result.add(category);
    }
    return result;
  }

  String _normaliseCategory(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  void _addTags(String input) {
    final newTags = _normaliseTags(input.split(','));
    if (newTags.isEmpty) return;

    var limitReached = false;
    setState(() {
      for (final tag in newTags) {
        final isDuplicate = tags.any(
          (selectedTag) => selectedTag.toLowerCase() == tag.toLowerCase(),
        );
        if (isDuplicate) continue;
        if (tags.length == _maximumTagsPerRecipe) {
          limitReached = true;
          break;
        }
        tags.add(tag);
      }
      tagController.clear();
    });
    if (limitReached && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        snack().displaySnackBar(
          'A recipe can have up to $_maximumTagsPerRecipe tags.',
          Colors.red,
        ),
      );
    }
  }

  Future<void> _handlesubmit() async {
    try {
      if (selectedType == "Public" && widget.customUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          snack().displaySnackBar(
            "Sign in to make a recipe public",
            Colors.red,
          ),
        );
        _createController.stop();
        return;
      }
      final category = _normaliseCategory(typeController.text);
      if (category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          snack().displaySnackBar("Recipe category is missing", Colors.red),
        );
        _createController.stop();
        return;
      }
      if (titleController.text.isEmpty || titleController.text == "") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(snack().displaySnackBar("Title is missing", Colors.red));
        _createController.stop();
        return;
      }
      if (widget.method == "Create") {
        await firestoreInstance
            .collection("Users")
            .doc(widget.customUser?.uid)
            .collection("recipes")
            .add({
              // "Code":int.parse(CodeController.text),
              "Created": DateTime.now(),
              "Sharing": selectedType,
              "Type": category,
              "Title": titleController.text,
              "Description": descriptionController.text,
              "Ingredients": ingredientsController.text,
              "Directions": directionsController.text,
              "NumberOfMinutes": int.tryParse(numOfMinutesController.text),
              "OvenTemp": int.tryParse(ovenTempController.text),
              "Servings": int.tryParse(servingsNumController.text),
              "Notes": notesController.text,
              "videos": videos,
              "Tags": tags,
            });
        if (!mounted) return;
        _createController.stop();
        Navigator.pop(context);
      } else {
        await firestoreInstance
            .collection("Users")
            .doc(widget.customUser?.uid)
            .collection("recipes")
            .doc(widget.recipe?.id)
            .set({
              "Type": category,
              "Sharing": selectedType,
              "Title": titleController.text,
              "Description": descriptionController.text,
              "Ingredients": ingredientsController.text,
              "Directions": directionsController.text,
              "NumberOfMinutes": int.tryParse(numOfMinutesController.text),
              "OvenTemp": int.tryParse(ovenTempController.text),
              "Servings": int.tryParse(servingsNumController.text),
              "Notes": notesController.text,
              "videos": videos,
              "Tags": tags,
            }, SetOptions(merge: true));
        if (!mounted) return;
        _createController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          snack().displaySnackBar("Saved successfully", Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(snack().displaySnackBar(e.toString()));
      _createController.stop();
      return;
    }
  }

  // void _handleDelete() {
  //   AwesomeDialog(
  //     context: context,
  //     dialogType: DialogType.WARNING,
  //     animType: AnimType.SCALE,
  //     headerAnimationLoop: false,
  //     showCloseIcon: true,
  //     title: 'Deleting Recipe',
  //     desc: 'Are you sure you want to delete this recipe?',
  //     btnCancelOnPress: () {
  //       _deleteController.stop();
  //     },
  //     btnOkOnPress: () {
  //       setState(() {
  //         FirebaseFirestore.instance.collection("Users").doc(widget.customUser?.uid).collection("recipes").doc(widget.recipe?.id).delete().then((value){
  //           _deleteController.stop();
  //           Navigator.pop(context);
  //         });
  //       });
  //     },
  //   ).show();
  // }
}
