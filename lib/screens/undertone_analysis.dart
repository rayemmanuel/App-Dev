import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette_screen.dart';
import '../utils/transitions_helper.dart';

class UndertoneAnalysisScreen extends StatelessWidget {
  const UndertoneAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header Section with animation
              AnimatedSlideIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                begin: const Offset(0, -0.3),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Camera Icon with scale animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B7355),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'Undertone Analysis',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      Text(
                        'Use your camera to detect your skin undertone',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      // Start Camera Analysis Button
                      ElevatedButton(
                        onPressed: () {
                          context.elegantNavigateTo(const PaletteScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7355),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Start Camera Analysis',
                              style: GoogleFonts.inter(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Undertone Types Title
              AnimatedSlideIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Undertone Types',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Undertone Cards with staggered animation
              Expanded(
                child: ListView(
                  children: const [
                    StaggeredListItem(
                      index: 0,
                      baseDelay: Duration(milliseconds: 100),
                      child: UndertoneCard(
                        title: 'Warm Undertone',
                        subtitle: 'Golden, yellow, peachy undertones',
                        colors: [
                          Color(0xFFE57373),
                          Color(0xFFFFB74D),
                          Color(0xFFFFF176),
                          Color(0xFFFFCC02),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    StaggeredListItem(
                      index: 1,
                      baseDelay: Duration(milliseconds: 100),
                      child: UndertoneCard(
                        title: 'Cool Undertone',
                        subtitle: 'Pink, blue, purple undertones',
                        colors: [
                          Color(0xFF42A5F5),
                          Color(0xFFBA68C8),
                          Color(0xFFEC407A),
                          Color(0xFF7986CB),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    StaggeredListItem(
                      index: 2,
                      baseDelay: Duration(milliseconds: 100),
                      child: UndertoneCard(
                        title: 'Neutral Undertone',
                        subtitle: 'Balanced mix of warm and cool',
                        colors: [
                          Color(0xFFBDBDBD),
                          Color(0xFFBCAAA4),
                          Color(0xFF9E9E9E),
                          Color(0xFFA1887F),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UndertoneCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final bool showCameraIcon;

  const UndertoneCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.showCameraIcon = false,
  }) : super(key: key);

  @override
  State<UndertoneCard> createState() => _UndertoneCardState();
}

class _UndertoneCardState extends State<UndertoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.15 : 0.1),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile Image Placeholder with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          if (widget.showCameraIcon)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B7355),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 15),
              // Text and Colors
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Color Palette with staggered animation
                    Row(
                      children: List.generate(
                        widget.colors.length,
                        (index) => TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 25,
                                height: 25,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: widget.colors[index],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
