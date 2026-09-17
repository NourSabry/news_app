import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';

/// One article body block (Part 6.9): paragraph, heading, image or quote.
/// [dropCap] renders the block's first character large in `red` — only
/// the very first paragraph of the body gets one.
class ContentBlockView extends StatelessWidget {
  final ContentBlock block;
  final bool dropCap;

  const ContentBlockView({super.key, required this.block, this.dropCap = false});

  @override
  Widget build(BuildContext context) {
    final text = block.text ?? '';
    return switch (block.type) {
      'heading' => _Heading(text: text),
      'image' => _Figure(url: block.url, caption: text),
      'quote' => _Quote(text: text),
      _ => _Paragraph(text: text, dropCap: dropCap),
    };
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  final bool dropCap;

  const _Paragraph({required this.text, required this.dropCap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    final style = AppTextStyles.body.copyWith(color: ink);

    if (!dropCap || text.isEmpty) return Text(text, style: style);

    final red = brightness == Brightness.light ? AppColors.lightRed : AppColors.darkRed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Text(text[0], style: AppTextStyles.dropCap.copyWith(color: red)),
        ),
        Expanded(child: Text(text.substring(1), style: style)),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading({required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.headlineS.copyWith(color: ink)),
    );
  }
}

class _Figure extends StatelessWidget {
  final String? url;
  final String caption;

  const _Figure({required this.url, required this.caption});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final inkMuted = brightness == Brightness.light ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedImage(
          imageUrl: url,
          height: 220,
          borderRadius: AppSpacing.radiusImage,
          semanticLabel: caption.isEmpty ? null : caption,
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(caption, style: AppTextStyles.caption.copyWith(color: inkMuted)),
        ],
      ],
    );
  }
}

class _Quote extends StatelessWidget {
  final String text;

  const _Quote({required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    final red = brightness == Brightness.light ? AppColors.lightRed : AppColors.darkRed;
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: red, width: 3))),
      child: Text(text, style: AppTextStyles.quote.copyWith(color: ink)),
    );
  }
}
