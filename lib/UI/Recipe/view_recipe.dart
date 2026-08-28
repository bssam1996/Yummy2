import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummy2/shared/constants.dart';

import '../../models/recipe.dart';
import '../../shared/snack.dart';
import '/models/user.dart';
import 'add_edit_recipe.dart';
import 'helper.dart';
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
  final RoundedLoadingButtonController _deleteController =
      RoundedLoadingButtonController();
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
        appBar: AppBar(
          title: const Text('Recipe'),
          actions: [
            Builder(
              builder: (shareButtonContext) => IconButton(
                tooltip: 'Share recipe',
                onPressed: () => _shareRecipe(shareButtonContext),
                icon: Image.asset(
                  'assets/icons/share.png',
                  width: 23,
                  height: 23,
                  color: Colors.white,
                ),
              ),
            ),
            if (_canManageRecipe || widget.recipe.ingredients.trim().isNotEmpty)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: _handleOptionsClick,
                itemBuilder: (context) => [
                  if (_canManageRecipe)
                    const PopupMenuItem(
                      value: 'Edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit recipe'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'Multiply',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calculate_outlined),
                      title: Text('Multiply ingredients'),
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _recipeHero(),
              const SizedBox(height: 18),
              if (widget.recipe.ingredients.trim().isNotEmpty) ...[
                _detailCard(
                  icon: FontAwesomeIcons.bowlFood,
                  title: 'Ingredients',
                  text: widget.recipe.ingredients,
                  action: _ingredientsHaveBeenMultiplied
                      ? TextButton.icon(
                          onPressed: () {
                            setState(() {
                              widget.recipe.ingredients = _originalIngredients;
                              _ingredientsHaveBeenMultiplied = false;
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reset'),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
              ],
              if (widget.recipe.directions.trim().isNotEmpty) ...[
                _detailCard(
                  icon: FontAwesomeIcons.listCheck,
                  title: 'Directions',
                  text: widget.recipe.directions,
                ),
                const SizedBox(height: 14),
              ],
              if (widget.recipe.notes.trim().isNotEmpty) ...[
                _detailCard(
                  icon: FontAwesomeIcons.noteSticky,
                  title: 'Notes',
                  text: widget.recipe.notes,
                  accentColor: purpleColor,
                ),
                const SizedBox(height: 14),
              ],
              if (widget.recipe.videos?.isNotEmpty ?? false) ...[
                _videoSection(),
                const SizedBox(height: 20),
              ],
              if (_canManageRecipe) _deleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recipeHero() {
    final stats = <Widget>[
      if (widget.recipe.numberOfMinutes > 0)
        _stat(Icons.schedule_rounded, '${widget.recipe.numberOfMinutes} min'),
      if (widget.recipe.ovenTemp > 0)
        _stat(
          Icons.local_fire_department_outlined,
          '${widget.recipe.ovenTemp}°',
        ),
      if (widget.recipe.servings > 0)
        _stat(
          Icons.people_outline_rounded,
          '${widget.recipe.servings} servings',
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkBlue, Color(0xFF3D6970)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.recipe.type.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.recipe.type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          if (widget.recipe.type.trim().isNotEmpty) const SizedBox(height: 14),
          Text(
            widget.recipe.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (widget.recipe.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.recipe.description,
              style: const TextStyle(
                color: Color(0xFFE4F0F0),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 22),
            Wrap(spacing: 8, runSpacing: 8, children: stats),
          ],
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required FaIconData icon,
    required String title,
    required String text,
    Widget? action,
    Color accentColor = darkBlue,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor == darkBlue
                      ? const Color(0xFFE4F0F0)
                      : const Color(0xFFFCE4D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 16,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_outline_rounded, color: darkBlue),
              SizedBox(width: 12),
              Text(
                'Helpful videos',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < widget.recipe.videos!.length; index++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFCE4D6),
                foregroundColor: darkPurpleColor,
                child: const Icon(Icons.play_arrow_rounded),
              ),
              title: Text(widget.recipe.videos![index]['link'] ?? ''),
              subtitle: Text(widget.recipe.videos![index]['description'] ?? ''),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () =>
                  _openVideo(widget.recipe.videos![index]['link'] ?? ''),
            ),
        ],
      ),
    );
  }

  Widget _deleteButton() {
    return RoundedLoadingButton(
      color: darkPink,
      controller: _deleteController,
      onPressed: _deleteRecipe,
      child: const Text(
        'Delete recipe',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _deleteRecipe() async {
    if (await confirm(
      context,
      title: const Text('Delete recipe'),
      content: const Text('Are you sure you want to delete this recipe?'),
      textOK: const Text('Delete'),
      textCancel: const Text('Keep recipe'),
    )) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.customUser?.uid)
          .collection('recipes')
          .doc(widget.recipe.id)
          .delete();
      if (!mounted) return;
      _deleteController.stop();
      Navigator.pop(context);
    }
    _deleteController.stop();
  }

  Future<void> _openVideo(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null || !await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        snack().displaySnackBar('Could not open this video.', Colors.red),
      );
    }
  }

  Future<void> _shareRecipe(BuildContext shareButtonContext) async {
    final shareBox = shareButtonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        title: widget.recipe.title,
        subject: 'Recipe: ${widget.recipe.title}',
        text: _recipeShareText(),
        sharePositionOrigin: shareBox == null
            ? null
            : shareBox.localToGlobal(Offset.zero) & shareBox.size,
      ),
    );
  }

  String _recipeShareText() {
    final sections = <String>[
      '🍽️ ${widget.recipe.title}',
      if (widget.recipe.type.trim().isNotEmpty) 'Type: ${widget.recipe.type}',
      if (widget.recipe.description.trim().isNotEmpty)
        widget.recipe.description,
      if (widget.recipe.numberOfMinutes > 0)
        'Cooking time: ${widget.recipe.numberOfMinutes} minutes',
      if (widget.recipe.ovenTemp > 0)
        'Oven temperature: ${widget.recipe.ovenTemp}°',
      if (widget.recipe.servings > 0) 'Servings: ${widget.recipe.servings}',
      if (widget.recipe.ingredients.trim().isNotEmpty)
        'INGREDIENTS\n${widget.recipe.ingredients}',
      if (widget.recipe.directions.trim().isNotEmpty)
        'DIRECTIONS\n${widget.recipe.directions}',
      if (widget.recipe.notes.trim().isNotEmpty)
        'NOTES\n${widget.recipe.notes}',
      if (widget.recipe.videos?.isNotEmpty ?? false)
        'VIDEOS\n${_videoShareText()}',
    ];
    return sections.join('\n\n');
  }

  String _videoShareText() {
    return widget.recipe.videos!
        .map((video) {
          final description = video['description']?.toString().trim() ?? '';
          final link = video['link']?.toString() ?? '';
          return description.isEmpty ? link : '$description: $link';
        })
        .join('\n');
  }

  Future<void> _handleOptionsClick(String value) async {
    switch (value) {
      case 'Edit':
        if (!_canManageRecipe) return;
        Navigator.push(
          context,
          PageTransition(
            curve: Curves.linear,
            alignment: Alignment.topCenter,
            type: PageTransitionType.scale,
            child: AddEditRecipe(
              method: 'Edit',
              customUser: widget.customUser,
              recipe: widget.recipe,
            ),
          ),
        );
      case 'Multiply':
        final multiplier = await showDialog<double>(
          context: context,
          builder: (context) => multiplier_recipe.showdialog(context),
        );
        if (multiplier == null) return;
        setState(() {
          widget.recipe.ingredients = multiplyText(
            widget.recipe.ingredients,
            multiplier,
          );
          _ingredientsHaveBeenMultiplied = true;
        });
    }
  }
}
