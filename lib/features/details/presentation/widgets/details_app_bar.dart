import 'package:flutter/material.dart';
import '../../../../core/widgets/cached_image.dart';

class DetailsAppBar extends StatelessWidget {
  final String? imageUrl;

  const DetailsAppBar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      leading: Center(
        child: IconButton(
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
            foregroundColor: theme.colorScheme.onSurface,
          ),
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
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
