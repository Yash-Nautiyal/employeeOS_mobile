import 'dart:async';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class HeadingSlide extends StatefulWidget {
  final ThemeData theme;
  const HeadingSlide({super.key, required this.theme});

  @override
  State<HeadingSlide> createState() => _HeadingSlideState();
}

class _HeadingSlideState extends State<HeadingSlide> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Timer? _timer;

  final List<Map<String, String>> _cardData = [
    {
      'title': 'Understanding Blockchain Technology: Beyond Cryptocurrency',
      'subtitle':
          'The children giggled with joy as they ran through the sprinklers on a hot summer day.',
      'imageUrl': 'assets/illustrations/cover-4.webp',
    },
    {
      'title': 'Mindfulness Meditation',
      'subtitle': 'Practice daily for better mental well-being...',
      'imageUrl': 'assets/illustrations/cover-5.webp',
    },
    {
      'title': 'Sleep Tracker Pro',
      'subtitle': 'Analyze your sleep patterns for better rest...',
      'imageUrl': 'assets/illustrations/cover-6.webp',
    },
  ];
  late final int _totalPages;
  @override
  void initState() {
    super.initState();
    _totalPages = _cardData.length;
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });

    // Start the automatic animation
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _totalPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 500),
              height: isWideScreen ? screenWidth * 0.4 : screenHeight * 0.6,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _cardData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = (_pageController.page! - index).abs();
                        value = (1 - (value * 0.3)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(
                        scale: 0.9 + (value * 0.1),
                        child: Opacity(
                          opacity: 0.5 + (value * 0.5),
                          child: FeaturedCard(
                            theme: widget.theme,
                            title: _cardData[index]['title'] ?? '',
                            subtitle: _cardData[index]['subtitle'] ?? '',
                            imageUrl: _cardData[index]['imageUrl'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: !isWideScreen ? 20 : 10,
                  vertical: !isWideScreen ? 2 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ...List.generate(
                    _cardData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? widget.theme.primaryColor
                            : widget.theme.colorScheme.primaryFixed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    iconSize: !isWideScreen ? 15 : 20,
                    onPressed: _goToPreviousPage,
                    color: _currentPage > 0
                        ? widget.theme.primaryColor
                        : widget.theme.disabledColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    iconSize: !isWideScreen ? 15 : 20,
                    onPressed: _goToNextPage,
                    color: _currentPage < _totalPages - 1
                        ? widget.theme.primaryColor
                        : widget.theme.disabledColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

class FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final ThemeData theme;

  const FeaturedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEATURED APP',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700, color: AppPallete.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: AppPallete.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
