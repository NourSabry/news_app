import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  int _currentPage = 0;
  List<Topic> _topics = [];
  final Set<String> _selectedTopics = {};
  bool _isLoading = true;

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
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await ServiceLocator.instance.get<ApiClient>().getTopics();
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
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

  Future<void> _completeOnboarding() async {
    final storage = ServiceLocator.instance.get<LocalStorage>();
    await storage.setOnboardingCompleted();
    if (_selectedTopics.isNotEmpty) {
      await storage.setSelectedTopicIds(_selectedTopics.toList());
    }
    widget.onComplete();
  }

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
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: _buildTopicGrid(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid(ThemeData theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.2,
      ),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        final isSelected = _selectedTopics.contains(topic.id);
        return _buildTopicTile(theme, topic, isSelected);
      },
    );
  }

  Widget _buildTopicTile(ThemeData theme, Topic topic, bool isSelected) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTopics.remove(topic.id);
          } else {
            _selectedTopics.add(topic.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
              : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: isSelected
              ? null
              : Border.all(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              _getTopicIcon(topic.icon),
              size: 24,
              color: isSelected
                  ? AppColors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                topic.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  IconData _getTopicIcon(String iconName) {
    return switch (iconName) {
      'devices' => Icons.devices_rounded,
      'business' => Icons.business_rounded,
      'sports_soccer' => Icons.sports_soccer_rounded,
      'science' => Icons.science_rounded,
      'health_and_safety' => Icons.health_and_safety_rounded,
      'palette' => Icons.palette_rounded,
      _ => Icons.tag_rounded,
    };
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
