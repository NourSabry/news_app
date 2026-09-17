import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ink_button.dart';
import '../../settings/presentation/cubit/settings_cubit.dart';
import 'cubit/onboarding_cubit.dart';
import 'widgets/masthead_page.dart';
import 'widgets/page_dots.dart';
import 'widgets/ready_page.dart';
import 'widgets/sections_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<OnboardingCubit>().loadHeadlines();
    context.read<SettingsCubit>().loadTopics().then((_) {
      if (!mounted) return;
      final ids = context.read<SettingsCubit>().state.topics.map((t) => t.id).toList();
      context.read<OnboardingCubit>().loadTopicCounts(ids);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AppMotion.page,
      curve: AppMotion.curveIn,
    );
  }

  void _onNext() {
    if (_currentPage == 1) {
      context.read<OnboardingCubit>().loadPreview();
    }
    if (_currentPage < 2) {
      _goToPage(_currentPage + 1);
    } else {
      context.read<SettingsCubit>().completeOnboarding();
    }
  }

  void _skip() => context.read<SettingsCubit>().completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final paper = brightness == Brightness.light ? AppColors.lightPaper : AppColors.darkPaper;
    final settings = context.watch<SettingsCubit>().state;
    final onboarding = context.watch<OnboardingCubit>().state;
    final canContinue = _currentPage != 1 || settings.selectedTopicIds.isNotEmpty;

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  MastheadPage(headlines: onboarding.headlines, topics: settings.topics),
                  SectionsPage(
                    topics: settings.topics,
                    selectedIds: settings.selectedTopicIds.toSet(),
                    topicCounts: onboarding.topicCounts,
                    onToggle: context.read<SettingsCubit>().toggleTopic,
                  ),
                  ReadyPage(
                    preview: onboarding.preview,
                    topics: settings.topics,
                    isLoading: onboarding.isLoadingPreview,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  PageDots(count: 3, index: _currentPage),
                  const SizedBox(height: AppSpacing.xl),
                  InkButton(
                    label: switch (_currentPage) {
                      0 => 'Set up my edition',
                      1 => 'Continue',
                      _ => 'Start reading',
                    },
                    onPressed: canContinue ? _onNext : null,
                  ),
                  if (_currentPage == 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    InkButton(label: 'Skip for now', variant: InkButtonVariant.text, expand: false, onPressed: _skip),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
