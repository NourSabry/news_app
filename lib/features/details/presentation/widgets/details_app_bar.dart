import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../bookmarks/presentation/widgets/bookmark_button.dart';

class DetailsAppBar extends StatelessWidget {
  final String? imageUrl;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  const DetailsAppBar({
    super.key,
    required this.imageUrl,
    required this.isBookmarked,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayStyle = IconButton.styleFrom(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
      foregroundColor: theme.colorScheme.onSurface,
    );
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      leading: Center(
        child: IconButton(
          tooltip: 'Back',
          style: overlayStyle,
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: BookmarkButton(
            isBookmarked: isBookmarked,
            onTap: onBookmark,
            style: overlayStyle,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(imageUrl: imageUrl, borderRadius: 0),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black38, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
