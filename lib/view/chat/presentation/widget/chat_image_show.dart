import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatImageShow extends StatefulWidget {
  final String imageUrl;
  final String fileName;
  final Map<String, String> imageUrlsandFileName;
  final int index;

  const ChatImageShow({
    super.key,
    required this.imageUrl,
    required this.fileName,
    required this.imageUrlsandFileName,
    required this.index,
  });

  @override
  State<ChatImageShow> createState() => _ChatImageShowState();
}

class _ChatImageShowState extends State<ChatImageShow>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late ScrollController _thumbnailScrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _pageController = PageController(initialPage: _currentIndex);
    _thumbnailScrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    // Add listener to automatically scroll thumbnails when page changes
    _pageController.addListener(_scrollToCurrentThumbnail);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // now it's safe to depend on InheritedWidgets like MediaQuery, Theme, etc.
    for (var url in widget.imageUrlsandFileName.keys) {
      precacheImage(NetworkImage(url), context);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollToCurrentThumbnail);
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToCurrentThumbnail() {
    // Only scroll when page is settled
    if (_pageController.page == _pageController.page?.round()) {
      const thumbnailWidth = 96.0; // 80 for thumbnail + 16 for margin
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = _currentIndex * thumbnailWidth -
          (screenWidth / 2) +
          (thumbnailWidth / 2);

      // Ensure offset is within valid range
      if (_thumbnailScrollController.hasClients) {
        _thumbnailScrollController.animateTo(
          offset.clamp(
              0.0, _thumbnailScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.black,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Implement download functionality here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fullscreen image viewer
          Expanded(
            child: Hero(
              tag: 'image_${widget.imageUrl}',
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrlsandFileName.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _animationController.reset();
                    _animationController.forward();
                  });
                  _scrollToCurrentThumbnail();
                },
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _animationController,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Center(
                        child: FastCachedImage(
                          url:
                              widget.imageUrlsandFileName.keys.elementAt(index),
                          fit: BoxFit.contain,
                          fadeInDuration: Duration.zero,
                          errorBuilder: (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Image file name with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Padding(
              key: ValueKey<String>(
                  widget.imageUrlsandFileName.values.elementAt(_currentIndex)),
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.imageUrlsandFileName.values.elementAt(_currentIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Scrollable image previews with animations
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              controller: _thumbnailScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrlsandFileName.length,
              itemBuilder: (context, index) {
                bool isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    width: isSelected ? 86 : 70,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppPallete.primaryMain
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppPallete.primaryMain.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: FastCachedImage(
                        url: widget.imageUrlsandFileName.keys.elementAt(index),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, url) => Shimmer.fromColors(
                          enabled: true,
                          baseColor: AppPallete.grey400.withOpacity(0.5),
                          highlightColor: AppPallete.grey400.withOpacity(0.2),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppPallete.grey400.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        errorBuilder: (context, url, error) => const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageList extends StatelessWidget {
  final List<ImageMessage> images;
  const ImageList({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FastCachedImage(
            url: images[index].url,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            fadeInDuration: const Duration(seconds: 1),
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                color: AppPallete.errorMain,
                size: 50,
              );
            },
            loadingBuilder: (context, progress) {
              return Shimmer.fromColors(
                enabled: true,
                baseColor: AppPallete.grey400.withOpacity(0.5),
                highlightColor: AppPallete.grey400.withOpacity(0.2),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppPallete.grey400.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
