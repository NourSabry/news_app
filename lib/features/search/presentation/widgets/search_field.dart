import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The Explore search field: a tall soft-surface input, no border.
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: p.accent,
        style: AppTextStyles.body.copyWith(color: p.ink),
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search stories, topics, sources',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(Icons.search_rounded, color: p.inkMuted),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : Semantics(
                  button: true,
                  container: true,
                  excludeSemantics: true,
                  label: 'Clear search',
                  child: IconButton(
                    icon: Icon(Icons.cancel_rounded, color: p.inkFaint),
                    onPressed: onClear,
                  ),
                ),
        ),
      ),
    );
  }
}
