import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;
  final IconData? icon;

  const AppIcon({
    super.key,
    this.size = 60,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
    this.icon = Icons.account_balance_wallet_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryBlue;
    final icColor = iconColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: size * 0.08,
                  offset: Offset(-size * 0.04, -size * 0.04),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: icColor,
      ),
    );
  }
}

class AnimatedAppIcon extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;
  final Duration duration;
  final bool autoAnimate;

  const AnimatedAppIcon({
    super.key,
    this.size = 60,
    this.backgroundColor,
    this.iconColor,
    this.icon = Icons.account_balance_wallet_rounded,
    this.duration = const Duration(milliseconds: 1000),
    this.autoAnimate = true,
  });

  @override
  State<AnimatedAppIcon> createState() => _AnimatedAppIconState();
}

class _AnimatedAppIconState extends State<AnimatedAppIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoAnimate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void animate() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: AppIcon(
              size: widget.size,
              backgroundColor: widget.backgroundColor,
              iconColor: widget.iconColor,
              icon: widget.icon,
            ),
          ),
        );
      },
    );
  }
}

class PulsingAppIcon extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;

  const PulsingAppIcon({
    super.key,
    this.size = 60,
    this.backgroundColor,
    this.iconColor,
    this.icon = Icons.account_balance_wallet_rounded,
  });

  @override
  State<PulsingAppIcon> createState() => _PulsingAppIconState();
}

class _PulsingAppIconState extends State<PulsingAppIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AppIcon(
            size: widget.size,
            backgroundColor: widget.backgroundColor,
            iconColor: widget.iconColor,
            icon: widget.icon,
          ),
        );
      },
    );
  }
}
