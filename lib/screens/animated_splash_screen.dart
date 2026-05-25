import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import 'dashboard_screen.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOutBack,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.primaryBlue,
      end: AppTheme.primaryBlueLight,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    _textController.forward();
    _progressController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize providers with staggered delays for smooth experience
      await Future.delayed(const Duration(milliseconds: 500));
      await Provider.of<ExpenseProvider>(context, listen: false).initialize();
      
      await Future.delayed(const Duration(milliseconds: 300));
      await Provider.of<CategoryProvider>(context, listen: false).initialize();
      
      await Future.delayed(const Duration(milliseconds: 300));
      await Provider.of<BudgetProvider>(context, listen: false).initialize();

      // Wait for animations to complete
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing app: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.95),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo Container
              AnimatedBuilder(
                animation: Listenable.merge([_logoAnimation, _pulseAnimation, _colorAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value * _pulseAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _colorAnimation.value ?? AppTheme.primaryBlue,
                            AppTheme.primaryBlueLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: (_colorAnimation.value ?? AppTheme.primaryBlue).withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating background circle
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _pulseController.value * 2 * 3.14159,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Main icon
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated App Name
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _textAnimation.value)),
                    child: Opacity(
                      opacity: _textAnimation.value,
                      child: Column(
                        children: [
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                AppConstants.appName,
                                textStyle: AppTheme.headingStyle.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            totalRepeatCount: 1,
                            pause: const Duration(milliseconds: 1000),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                          ),
                          const SizedBox(height: 12),
                          AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                AppConstants.appDescription,
                                textStyle: AppTheme.bodyStyle.copyWith(
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                duration: const Duration(milliseconds: 2000),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Progress Indicator
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(3, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _progressAnimation.value > (index * 0.33)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
