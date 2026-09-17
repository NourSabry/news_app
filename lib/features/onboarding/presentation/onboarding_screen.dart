import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/topic_picker.dart';
import '../../settings/presentation/cubit/settings_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    context.read<SettingsCubit>().loadTopics();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() => context.read<SettingsCubit>().completeOnboarding();

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildWelcomePage(theme, isDark),
                      _buildTopicsPage(theme),
                      _buildReadyPage(theme, isDark),
                    ],
                  ),
                ),
                _buildBottomSection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkBackground,
                  const Color(0xFF1A1D2E),
                  AppColors.darkBackground,
                ]
              : [
                  AppColors.lightBackground,
                  const Color(0xFFF0F4F8),
                  AppColors.lightBackground,
                ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOut,
        )),
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkAccent, AppColors.darkAccent.withValues(alpha: 0.6)]
                        : [AppColors.lightAccent, AppColors.lightAccent.withValues(alpha: 0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                          .withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.article_rounded,
                  size: 56,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'News Feed',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Stay informed with stories that matter to you',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsPage(ThemeData theme) {
    final settings = context.watch<SettingsCubit>().state;
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl * 2),
          Text(
            'What interests you?',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick topics to personalize your feed',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          if (settings.isLoadingTopics)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: TopicPicker(
                topics: settings.topics,
                selectedIds: settings.selectedTopicIds.toSet(),
                onToggle: context.read<SettingsCubit>().toggleTopic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReadyPage(ThemeData theme, bool isDark) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            "You're all set",
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your personalized feed is ready.\nDive in and explore.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                      : theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == 2 ? 'Get started' : 'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          if (_currentPage < 2) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
