import 'dart:io';
import 'dart:ui';
import 'package:employeeos/core/common/components/ui/custom_textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mime/mime.dart';

class MediaPreviewItem {
  final String path;
  final String name;
  final int size;
  String caption;

  MediaPreviewItem({
    required this.path,
    required this.name,
    required this.size,
    this.caption = '',
  });

  String get mimeType => lookupMimeType(path) ?? 'application/octet-stream';

  bool get isImage =>
      mimeType.startsWith('image/') && !name.toLowerCase().endsWith('.svg');

  bool get isVideo => mimeType.startsWith('video/');

  bool get isPDF => mimeType == 'application/pdf';

  String get sizeString {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ChatMediaPreview extends StatefulWidget {
  final List<MediaPreviewItem> mediaItems;
  final VoidCallback onCancel;
  final void Function(List<MediaPreviewItem>) onSend;
  final ThemeData theme;

  const ChatMediaPreview({
    super.key,
    required this.mediaItems,
    required this.onCancel,
    required this.onSend,
    required this.theme,
  });

  @override
  State<ChatMediaPreview> createState() => _ChatMediaPreviewState();
}

class _ChatMediaPreviewState extends State<ChatMediaPreview> {
  late List<MediaPreviewItem> items;
  late PageController _pageController;
  int _currentIndex = 0;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    items = List.from(widget.mediaItems);
    _pageController = PageController();
    if (items.isNotEmpty) {
      _captionController.text = items[0].caption;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      if (items.isEmpty) {
        widget.onCancel();
      } else if (_currentIndex >= items.length) {
        _currentIndex = items.length - 1;
        _pageController.jumpToPage(_currentIndex);
        _captionController.text = items[_currentIndex].caption;
      }
    });
  }

  void _onPageChanged(int index) {
    // Save current caption before switching
    if (_currentIndex < items.length) {
      items[_currentIndex].caption = _captionController.text;
    }

    setState(() {
      _currentIndex = index;
      _captionController.text = items[index].caption;
    });
  }

  void _handleSend() {
    // Save the current caption before sending
    if (_currentIndex < items.length) {
      items[_currentIndex].caption = _captionController.text;
    }
    widget.onSend(items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppPallete.black
            : AppPallete.white,
      ),
      child: Column(
        children: [
          // Main Image Preview
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildMediaPreview(item);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: GestureDetector(
                        onTap: widget.onCancel,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surface.withOpacity(0.5),
                          ),
                          child: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: (items.length > 1)
                      ? SizedBox(
                          height: 60,
                          child: Center(
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                horizontal: (MediaQuery.of(context).size.width -
                                        (items.length * 73.0).clamp(
                                            0,
                                            MediaQuery.of(context)
                                                .size
                                                .width)) /
                                    2,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isSelected = index == _currentIndex;
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? AppPallete.primaryMain
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: _buildThumbnail(item),
                                        ),
                                        // Delete button always visible on hover/tap
                                        Align(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onTap: () => _removeItem(index),
                                            child: SvgPicture.asset(
                                              'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                                              color: Colors.white,
                                              width: 25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // Bottom Section
          AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10)
                    .copyWith(bottom: 8, top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextfield(
                        controller: _captionController,
                        keyboardType: TextInputType.multiline,
                        theme: theme,
                        onchange: (value) {
                          setState(() {
                            _captionController.text = value;
                          });
                        },
                        hintText: 'Add a caption...',
                        maxLines: 3,
                        labelText: "Caption",
                        alwaysFloatingLabel: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Send button
                    GestureDetector(
                      onTap: _handleSend,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppPallete.primaryMain,
                        child: SvgPicture.asset(
                          "assets/icons/common/solid/ic-iconamoon_send-fill.svg",
                          color: AppPallete.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaPreviewItem item) {
    if (item.isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Image.file(
          File(item.path),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      );
    } else if (item.isPDF) {
      return _buildPDFPreview(item);
    } else if (item.isVideo) {
      return _buildVideoPreview(item);
    } else {
      return _buildFilePreview(item);
    }
  }

  Widget _buildThumbnail(MediaPreviewItem item) {
    if (item.isImage) {
      return Image.file(
        File(item.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildFileIcon(item),
      );
    }
    return _buildFileIcon(item);
  }

  Widget _buildPDFPreview(MediaPreviewItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.sizeString,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(MediaPreviewItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppPallete.primaryMain.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_fill,
              size: 100,
              color: AppPallete.primaryMain,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.sizeString,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(MediaPreviewItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insert_drive_file,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.sizeString,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.mimeType.split('/').last.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(MediaPreviewItem item) {
    IconData icon = Icons.insert_drive_file;
    Color color = Colors.grey;

    if (item.isPDF) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (item.isVideo) {
      icon = Icons.play_circle_outline;
      color = Colors.white;
    }

    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Failed to load media',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
