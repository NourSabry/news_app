import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';

/// One article body block: paragraph, heading, image or quote. [dropCap]
/// renders the first character large — only the opening paragraph gets one.
class ContentBlockView extends StatelessWidget {
  final ContentBlock block;
  final bool dropCap;

  const ContentBlockView({
    super.key,
    required this.block,
    this.dropCap = false,
  });

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
    final p = context.palette;
    final style = AppTextStyles.body.copyWith(color: p.ink);

    if (!dropCap || text.isEmpty) return Text(text, style: style);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm, top: 6),
          child: Text(
            text[0],
            style: AppTextStyles.dropCap.copyWith(color: p.ink),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        text,
        style: AppTextStyles.headlineM.copyWith(color: context.palette.ink),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String? url;
  final String caption;

  const _Figure({required this.url, required this.caption});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: CachedImage(
              imageUrl: url,
              borderRadius: AppSpacing.radiusMd,
              semanticLabel: caption.isEmpty ? null : caption,
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              caption,
              style: AppTextStyles.caption.copyWith(color: p.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  final String text;

  const _Quote({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“',
            style: AppTextStyles.dropCap.copyWith(color: p.accent, height: 0.6),
          ),
          Text(text, style: AppTextStyles.quote.copyWith(color: p.ink)),
        ],
      ),
    );
  }
}
