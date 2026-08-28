import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/models/globals.dart' as globals;

class RecipeUserDetailsClass extends StatelessWidget {
  final String parentId;
  final TextStyle? customStyle;
  final String whatToReturn;
  final bool showIcon;
  const RecipeUserDetailsClass({
    Key? key,
    required this.parentId,
    this.customStyle,
    required this.whatToReturn,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (parentId.isEmpty) return const SizedBox.shrink();

    final cachedUser = globals.userNames[parentId];
    if (cachedUser is Map) {
      return _nameWidget(cachedUser[whatToReturn]?.toString() ?? '');
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(parentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const SizedBox.shrink();
        }
        final user = snapshot.data!.data() as Map;
        globals.userNames[parentId] = user;
        return _nameWidget(user[whatToReturn]?.toString() ?? '');
      },
    );
  }

  Widget _nameWidget(String name) {
    if (name.trim().isEmpty) return const SizedBox.shrink();
    final nameText = Text(name, style: customStyle);
    if (!showIcon) return nameText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.person_outline_rounded,
          size: 16,
          color: Color(0xFFB9503B),
        ),
        const SizedBox(width: 6),
        Flexible(child: nameText),
      ],
    );
  }
}
