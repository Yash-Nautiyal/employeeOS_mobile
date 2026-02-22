import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

Future<void> showCustomImageViewer(
  BuildContext context, {
  required List<String> imageUrls,
  int initialIndex = 0,
  bool showDotsIndicator = true,
  bool showNumericIndicator = true,
}) async {
  final validUrls = imageUrls.where((url) => url.trim().isNotEmpty).toList();
  if (validUrls.isEmpty) return;

  final safeInitialIndex = initialIndex.clamp(0, validUrls.length - 1);
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CustomImageViewer(
        imageUrls: validUrls,
        initialIndex: safeInitialIndex,
        showDotsIndicator: showDotsIndicator,
        showNumericIndicator: showNumericIndicator,
      ),
      fullscreenDialog: true,
    ),
  );
}

class CustomImageViewer extends StatefulWidget {
  const CustomImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.showDotsIndicator = true,
    this.showNumericIndicator = true,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final bool showDotsIndicator;
  final bool showNumericIndicator;

  @override
  State<CustomImageViewer> createState() => _CustomImageViewerState();
}

class _CustomImageViewerState extends State<CustomImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: total,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.imageUrls[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                );
              },
              loadingBuilder: (context, event) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (total > 1)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showNumericIndicator)
                    Text(
                      '${_currentIndex + 1} / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (widget.showNumericIndicator && widget.showDotsIndicator)
                    const SizedBox(height: 10),
                  if (widget.showDotsIndicator)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(total, (index) {
                          final isActive = index == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 16 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
