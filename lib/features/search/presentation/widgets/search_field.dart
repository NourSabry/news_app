import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// The Explore search field (Part 6.7): `paperRaised`, hairline border,
/// red caret; the border turns `ink` when focused (via `AppTheme`).
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
    final brightness = Theme.of(context).brightness;
    final red = brightness == Brightness.light ? AppColors.lightRed : AppColors.darkRed;
    final inkFaint = brightness == Brightness.light ? AppColors.lightInkFaint : AppColors.darkInkFaint;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: red,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search stories, topics, sources',
          prefixIcon: Icon(Icons.search_rounded, color: inkFaint),
          suffixIcon: controller.text.isEmpty
              ? null
              : Semantics(
                  button: true,
                  label: 'Clear search',
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: inkFaint),
                    onPressed: onClear,
                  ),
                ),
        ),
      ),
    );
  }
}
