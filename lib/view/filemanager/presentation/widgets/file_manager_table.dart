import 'package:employeeos/core/index.dart'
    show
        ActionConfirmDialog,
        EmptyContent,
        showRightSideTaskDetails,
        showCustomToast;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:toastification/toastification.dart';

import '../../index.dart'
    show
        CreateFolderEvent,
        DeleteSelectedEvent,
        FileItem,
        FileRole,
        FilemanagerActionState,
        FilemanagerBloc,
        FilemanagerState,
        FileFilterService,
        FileManagerFilterController,
        FileManagerFilterSection,
        FileManagerSideMenu,
        FilterControllerProvider,
        FilemanagerItem,
        FolderEntity,
        FolderItem,
        ShareFileDialogRunner,
        SharedUser,
        TableDataRow,
        TableHeaderRow,
        TableHeaderSelector,
        TablePaginator,
        ViewType;

class FileTableScreen extends StatefulWidget {
  final double screenWidth;
  final List<FilemanagerItem> items;
  final ScrollController verticalScrollController;
  final Function(String) onFavoriteToggle;
  final FilemanagerBloc bloc;
  const FileTableScreen(
      {super.key,
      required this.screenWidth,
      required this.verticalScrollController,
      required this.items,
      required this.onFavoriteToggle,
      required this.bloc});

  @override
  State<FileTableScreen> createState() => _FileTableScreenState();
}

class _FileTableScreenState extends State<FileTableScreen>
    with SingleTickerProviderStateMixin {
      
  FolderEntity? _currentFolder;

  /// Keys to look up folder icon position in rows (for fly-to-header animation).
  final Map<String, GlobalKey> _folderIconKeys = {};
  final GlobalKey _headerIconKey = GlobalKey();
  Rect? _iconFlyStartRect;

  /// When non-null, we're flying the icon back to this folder's row (back animation).
  String? _folderExitingId;
  OverlayEntry? _flyOverlay;
  late final AnimationController _flyController;
  static const Duration _flyDuration = Duration(milliseconds: 320);

  /// Root-level items: folders + root files (folderId == null). No files inside folders.
  List<FilemanagerItem> get _rootLevelItems => widget.items
      .where(
          (i) => i is FolderItem || (i is FileItem && i.file.folderId == null))
      .toList();

  /// Files that belong to [_currentFolder]. Only used when _currentFolder != null.
  List<FilemanagerItem> get _folderFileItems => _currentFolder == null
      ? []
      : widget.items
          .whereType<FileItem>()
          .where((i) => i.file.folderId == _currentFolder!.id)
          .toList();

  /// Source list for current view: root-level or folder contents.
  List<FilemanagerItem> get _displayItems =>
      _currentFolder == null ? _rootLevelItems : _folderFileItems;

  @override
  void didUpdateWidget(covariant FileTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filtered = List.from(_displayItems);
      _applyFilters();
      setState(
          () {}); // Force immediate rebuild so remove-from-folder etc. reflect right away.
    }
  }

  late List<FilemanagerItem> _filtered;
  final Set<String> _selected = {};

  // Filter state - now using the new controller system
  ViewType _viewType = ViewType.list;
  late FileManagerFilterController _filterController;
  // Paging
  int _pageIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rppOptions = const [5, 10, 25, 50];

  // Horizontal sync (header <-> body)
  late final LinkedScrollControllerGroup _hGroup;
  late final ScrollController _hHeaderCtrl;
  late final ScrollController _hBodyCtrl;

  // Column widths (tweak as you like)
  late double _wName;
  static const double _wSize = 120;
  static const double _wType = 90;
  static const double _wModified = 130;
  static const double _wShared = 110;
  static const double _wActions = 80;
  double get _tableWidth =>
      _wName +
      _wSize +
      _wType +
      _wModified +
      _wShared +
      _wActions +
      34; // + padding

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_displayItems);

    // Initialize filter controller
    _filterController = FileManagerFilterController();
    _filterController.addListener(_applyFilters);

    _hGroup = LinkedScrollControllerGroup();
    _hHeaderCtrl = _hGroup.addAndGet();
    _hBodyCtrl = _hGroup.addAndGet();

    _flyController = AnimationController(vsync: this, duration: _flyDuration);
    _flyController.addStatusListener(_onFlyStatusChanged);

    // Adjust name column width based on screen width
    if (widget.screenWidth < 600) {
      _wName = 300;
    } else {
      _wName = 400;
    }
  }

  void _onFlyStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _flyOverlay?.remove();
      _flyOverlay = null;
      _flyController.reset();
      if (mounted) {
        setState(() {
          _iconFlyStartRect = null;
          _folderExitingId = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _flyController.removeStatusListener(_onFlyStatusChanged);
    _flyController.dispose();
    _flyOverlay?.remove();
    _filterController.removeListener(_applyFilters);
    _filterController.dispose();
    _hHeaderCtrl.dispose();
    _hBodyCtrl.dispose();
    super.dispose();
  }

  // Filter methods
  void _applyFilters() {
    final filterState = _filterController.filterState;

    setState(() {
      _filtered = FileFilterService.applyFilters(_displayItems, filterState);
      _pageIndex = 0;
      _selected.removeWhere((id) => !_filtered.any((item) => item.id == id));
    });
  }

  void _goBackToRoot() {
    setState(() {
      _currentFolder = null;
      _filtered = List.from(_displayItems);
      _applyFilters();
    });
  }

  void _onBackFromFolder() {
    if (_currentFolder == null) return;
    final folderId = _currentFolder!.id;
    Rect? headerRect;
    final headerContext = _headerIconKey.currentContext;
    if (headerContext != null) {
      final box = headerContext.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final o = box.localToGlobal(Offset.zero);
        headerRect = Rect.fromLTWH(o.dx, o.dy, box.size.width, box.size.height);
      }
    }

    if (headerRect == null) {
      _goBackToRoot();
      return;
    }

    setState(() {
      _folderExitingId = folderId;
      _currentFolder = null;
      _filtered = List.from(_displayItems);
      _applyFilters();
      _iconFlyStartRect = headerRect;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startIconFlyBackAnimation());
  }

  void _startIconFlyBackAnimation() {
    if (!mounted || _folderExitingId == null || _iconFlyStartRect == null) {
      if (mounted) {
        setState(() {
          _iconFlyStartRect = null;
          _folderExitingId = null;
        });
      }
      return;
    }
    final iconKey = _folderIconKeys[_folderExitingId];
    Rect? endRect;
    if (iconKey?.currentContext != null) {
      final box = iconKey!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final o = box.localToGlobal(Offset.zero);
        endRect = Rect.fromLTWH(o.dx, o.dy, box.size.width, box.size.height);
      }
    }
    if (endRect == null) {
      if (mounted) {
        setState(() {
          _iconFlyStartRect = null;
          _folderExitingId = null;
        });
      }
      return;
    }
    final startRect = _iconFlyStartRect!;
    final endRectValue = endRect;
    _flyOverlay = OverlayEntry(
      builder: (context) => _FlyingFolderIcon(
        startRect: startRect,
        endRect: endRectValue,
        animation: _flyController.view,
      ),
    );
    Overlay.of(context).insert(_flyOverlay!);
    _flyController.forward();
  }

  void _onFolderTap(FolderEntity folder) {
    final iconKey = _folderIconKeys[folder.id];
    Rect? startRect;
    if (iconKey?.currentContext != null) {
      final box = iconKey!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final o = box.localToGlobal(Offset.zero);
        startRect = Rect.fromLTWH(o.dx, o.dy, box.size.width, box.size.height);
      }
    }

    setState(() {
      _currentFolder = folder;
      _filtered = List.from(_displayItems);
      _applyFilters();
      _iconFlyStartRect = startRect;
    });

    if (startRect != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _startIconFlyAnimation());
    }
  }

  void _startIconFlyAnimation() {
    if (!mounted || _iconFlyStartRect == null) return;
    final endContext = _headerIconKey.currentContext;
    if (endContext == null) return;
    final endBox = endContext.findRenderObject() as RenderBox?;
    if (endBox == null || !endBox.hasSize) return;
    final o = endBox.localToGlobal(Offset.zero);
    final endRect =
        Rect.fromLTWH(o.dx, o.dy, endBox.size.width, endBox.size.height);
    final startRect = _iconFlyStartRect!;

    _flyOverlay = OverlayEntry(
      builder: (context) => _FlyingFolderIcon(
        startRect: startRect,
        endRect: endRect,
        animation: _flyController.view,
      ),
    );
    Overlay.of(context).insert(_flyOverlay!);
    _flyController.forward();
  }

  // Paging helpers (now use filtered data)
  int get _total => _filtered.length;
  int get _pageCount => (_total / _rowsPerPage).ceil().clamp(1, 1 << 30);
  int get _startIndex => _pageIndex * _rowsPerPage;
  int get _endIndex => (_startIndex + _rowsPerPage).clamp(0, _total);
  List<FilemanagerItem> get _pageItems =>
      _filtered.sublist(_startIndex, _endIndex);

  void _goFirst() => setState(() => _pageIndex = 0);
  void _goPrev() =>
      setState(() => _pageIndex = (_pageIndex - 1).clamp(0, _pageCount - 1));
  void _goNext() =>
      setState(() => _pageIndex = (_pageIndex + 1).clamp(0, _pageCount - 1));
  void _goLast() => setState(() => _pageIndex = _pageCount - 1);

  void _changeRpp(int v) {
    // keep top-left item visible: recompute page so the old start stays in view
    final oldStart = _startIndex;
    setState(() {
      _rowsPerPage = v;
      _pageIndex = (oldStart / _rowsPerPage).floor().clamp(0, _pageCount - 1);
    });
  }

  // Selection helpers (current page only; change to _all to select across dataset)
  bool get _isAllSelectedOnPage =>
      _pageItems.isNotEmpty &&
      _pageItems.every((f) => _selected.contains(f.id));

  bool get _isAnySelectedOnPage =>
      _pageItems.any((f) => _selected.contains(f.id));

  /// Selected items (from current _filtered). Used for add-to-folder.
  List<FilemanagerItem> get _selectedItems =>
      _filtered.where((i) => _selected.contains(i.id)).toList();

  bool get _hasFolderSelected => _selectedItems.any((i) => i.isFolder);

  List<String> get _selectedFileIds =>
      _selectedItems.whereType<FileItem>().map((f) => f.file.id).toList();

  /// Deletable files (owner only) and folders for the delete-selected action.
  List<String> get _deletableFileIds => _selectedItems
      .whereType<FileItem>()
      .where((f) => f.file.role == FileRole.owner)
      .map((f) => f.file.id)
      .toList();

  List<String> get _selectedFolderIds =>
      _selectedItems.whereType<FolderItem>().map((f) => f.folder.id).toList();

  /// Number of files inside the selected folders (for confirmation message).
  int get _filesInsideSelectedFoldersCount {
    final folderIds = _selectedFolderIds.toSet();
    return widget.items
        .whereType<FileItem>()
        .where((f) =>
            f.file.folderId != null && folderIds.contains(f.file.folderId!))
        .length;
  }

  void _onAddToFolderTap() {
    final fileIds = _selectedFileIds;
    if (fileIds.isEmpty) return;
    final bloc = context.read<FilemanagerBloc>();
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => ActionConfirmDialog(
        title: 'New folder',
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder name',
            hintText: 'Enter folder name',
          ),
          onSubmitted: (name) {
            final n = name.trim();
            if (n.isEmpty) return;
            bloc.add(CreateFolderEvent(n, fileIds: fileIds));
            setState(() => _selected.clear());
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
        ),
        primaryLabel: 'Create',
        primaryOnTap: () {
          final name = controller.text.trim();
          if (name.isEmpty) {
            showCustomToast(
              context: ctx,
              type: ToastificationType.error,
              title: 'Enter a folder name',
            );
            return;
          }
          bloc.add(CreateFolderEvent(name, fileIds: fileIds));
          setState(() => _selected.clear());
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _onShareTap() {
    // Share is only for files; disabled when folder selected (TableHeaderSelector).
    final fileItems = _selectedItems.whereType<FileItem>().toList();
    if (fileItems.isEmpty || !context.mounted) return;
    if (fileItems.length == 1) {
      showRightSideTaskDetails(
        context,
        BlocProvider.value(
          value: widget.bloc,
          child: FileManagerSideMenu(item: fileItems.first),
        ),
      );
      return;
    }
    // Multiple files: open share dialog "Share these N files with" and share all with selected user.
    final existingSharedUsers = <String, SharedUser>{};
    for (final item in fileItems) {
      for (final u in item.file.sharedWith ?? []) {
        existingSharedUsers[u.id] = u;
      }
    }
    ShareFileDialogRunner.showMultiple(
      context,
      bloc: widget.bloc,
      fileIds: _selectedFileIds,
      existingSharedUsers: existingSharedUsers.values.toList(),
    );
  }

  void _onDeleteTap() {
    // Rule: cannot delete shared files (e.g. in personal folders)
    final deletableItems = _selectedItems
        .whereType<FileItem>()
        .where((f) => f.file.role == FileRole.owner)
        .toList();
    final hasSharedFile = deletableItems.any((f) {
      final sw = f.file.sharedWith;
      return sw != null && sw.isNotEmpty;
    });
    if (hasSharedFile) {
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Cannot delete',
        description:
            'Your selection contains shared file(s). Shared files cannot be deleted.',
      );
      return;
    }
    final fileIds = _deletableFileIds;
    final folderIds = _selectedFolderIds;
    final fileCount = fileIds.length;
    final folderCount = folderIds.length;
    if (fileCount == 0 && folderCount == 0) return;
    final bloc = context.read<FilemanagerBloc>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _DeleteConfirmDialog(
          fileCount: fileCount,
          folderCount: folderCount,
          filesInsideFoldersCount: _filesInsideSelectedFoldersCount,
          fileIds: fileIds,
          folderIds: folderIds,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _selected.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterControllerProvider(
      controller: _filterController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---------- Filter Section ----------
          FileManagerFilterSection(
            currentViewType: _viewType,
            filteredResultsCount: _total,
            onFiltersChanged: _applyFilters,
            onViewTypeChanged: (viewType) {
              setState(() {
                _viewType = viewType;
              });
            },
          ),

          const SizedBox(height: 24),

          // ---------- Drill-down header (when inside a folder) ----------
          if (_currentFolder != null) ...[
            _FolderDrillHeader(
              folder: _currentFolder!,
              onBack: _onBackFromFolder,
              iconKey: _headerIconKey,
              iconVisible: _iconFlyStartRect == null,
              textVisible: _iconFlyStartRect == null,
            ),
            const SizedBox(height: 16),
          ],

          // ---------- Table card ----------
          Column(
            children: [
              // Horizontal scrollable header (stays fixed vertically)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _hHeaderCtrl,
                child: SizedBox(
                  height: 80,
                  width: _tableWidth,
                  child: _selected.isEmpty
                      ? TableHeaderRow(
                          selectedCount: _selected.length,
                          onClear: _selected.isEmpty
                              ? null
                              : () => setState(() => _selected.clear()),
                          widthName: _wName,
                          widthSize: _wSize,
                          widthType: _wType,
                          widthModified: _wModified,
                          widthShared: _wShared,
                          widthActions: _wActions,
                          checkboxValue: _isAllSelectedOnPage
                              ? true
                              : (_isAnySelectedOnPage ? null : false),
                          onCheckboxChanged: (val) {
                            setState(() {
                              if (val == true) {
                                for (final f in _pageItems) {
                                  _selected.add(f.id);
                                }
                              } else {
                                for (final f in _pageItems) {
                                  _selected.remove(f.id);
                                }
                              }
                            });
                          },
                        )
                      : TableHeaderSelector(
                          selectedCount: _selected.length,
                          onSelectAll: () => setState(() {
                            for (final f in _pageItems) {
                              _selected.add(f.id);
                            }
                          }),
                          onClear: _selected.isEmpty
                              ? null
                              : () => setState(() => _selected.clear()),
                          hasFolderSelected: _hasFolderSelected,
                          selectedFileIds: _selectedFileIds,
                          onAddToFolder: _onAddToFolderTap,
                          onShare: _onShareTap,
                          onDelete: _onDeleteTap,
                        ),
                ),
              ),

              // spacing between header and rows (requested)
              const SizedBox(height: 8),

              // ---------- Rows: vertically scrollable, horizontally linked to header ----------
              _pageItems.isEmpty
                  ? const EmptyContent(
                      icon: 'assets/icons/empty/ic-content.svg',
                      title: "No Files Found",
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _hBodyCtrl,
                      child: SizedBox(
                        width: _tableWidth,
                        child: ListView.builder(
                          controller: widget.verticalScrollController,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _pageItems.length,
                          itemBuilder: (context, i) {
                            final item = _pageItems[i];
                            final selected = _selected.contains(item.id);
                            return GestureDetector(
                              key: ValueKey('${item.id}_$i'),
                              onTap: () {
                                if (item.isFolder) {
                                  _onFolderTap(
                                    (item as FolderItem).folder,
                                  );
                                } else {
                                  showRightSideTaskDetails(
                                    context,
                                    BlocProvider.value(
                                      value: widget.bloc,
                                      child: FileManagerSideMenu(item: item),
                                    ),
                                  );
                                }
                              },
                              child: TableDataRow(
                                item: item,
                                selected: selected,
                                widthName: _wName,
                                widthSize: _wSize,
                                widthType: _wType,
                                widthModified: _wModified,
                                widthShared: _wShared,
                                widthActions: _wActions,
                                folderIconKey: item.isFolder
                                    ? _folderIconKeys.putIfAbsent(
                                        item.id,
                                        () => GlobalKey(),
                                      )
                                    : null,
                                hideFolderIconForFlyBack: item.isFolder &&
                                    _folderExitingId == item.id,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selected.add(item.id);
                                  } else {
                                    _selected.remove(item.id);
                                  }
                                }),
                                onStar: () => widget.onFavoriteToggle(item.id),
                                onMenu: (action) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('$action → ${item.name}')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),

              // ---------- External Paginator (fixed, does not scroll with rows) ----------
              TablePaginator(
                total: _total,
                pageIndex: _pageIndex,
                rowsPerPage: _rowsPerPage,
                pageCount: _pageCount,
                startIndex: _startIndex,
                endIndex: _endIndex,
                rppOptions: _rppOptions,
                onFirst: _pageIndex > 0 ? _goFirst : null,
                onPrev: _pageIndex > 0 ? _goPrev : null,
                onNext: _pageIndex < _pageCount - 1 ? _goNext : null,
                onLast: _pageIndex < _pageCount - 1 ? _goLast : null,
                onRowsPerPageChanged: (v) {
                  if (v != null) _changeRpp(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Header shown when drilled into a folder: back button + folder icon/name.
class _FolderDrillHeader extends StatelessWidget {
  const _FolderDrillHeader({
    required this.folder,
    required this.onBack,
    required this.iconKey,
    required this.iconVisible,
    required this.textVisible,
  });

  final FolderEntity folder;
  final VoidCallback onBack;
  final GlobalKey iconKey;
  final bool iconVisible;
  final bool textVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
              tooltip: 'Back',
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  key: iconKey,
                  width: 32,
                  height: 32,
                  child: iconVisible
                      ? SvgPicture.asset(
                          'assets/icons/file/ic-folder.svg',
                          width: 32,
                          height: 32,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  opacity: textVisible ? 1 : 0,
                  child: Text(
                    folder.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlyingFolderIcon extends StatelessWidget {
  const _FlyingFolderIcon({
    required this.startRect,
    required this.endRect,
    required this.animation,
  });

  final Rect startRect;
  final Rect endRect;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(animation.value);
        final left = startRect.left + (endRect.left - startRect.left) * t;
        final top = startRect.top + (endRect.top - startRect.top) * t;
        final width = startRect.width + (endRect.width - startRect.width) * t;
        final height =
            startRect.height + (endRect.height - startRect.height) * t;
        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/icons/file/ic-folder.svg',
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Dialog that confirms bulk delete and stays open until delete completes, errors, or user cancels.
class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog({
    required this.fileCount,
    required this.folderCount,
    required this.filesInsideFoldersCount,
    required this.fileIds,
    required this.folderIds,
  });

  final int fileCount;
  final int folderCount;
  final int filesInsideFoldersCount;
  final List<String> fileIds;
  final List<String> folderIds;

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<FilemanagerBloc, FilemanagerState>(
      listenWhen: (previous, current) => current is FilemanagerActionState,
      listener: (context, state) {
        if (context.mounted) Navigator.of(context).pop();
      },
      child: ActionConfirmDialog(
        title: 'Delete selected?',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to delete:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.fileCount > 0)
              Text(
                '• ${widget.fileCount} file(s)',
                style: theme.textTheme.bodyMedium,
              ),
            if (widget.folderCount > 0) ...[
              Text(
                '• ${widget.folderCount} folder(s)',
                style: theme.textTheme.bodyMedium,
              ),
              if (widget.filesInsideFoldersCount > 0)
                Text(
                  '  (containing ${widget.filesInsideFoldersCount} file(s))',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        cancelLabel: 'Cancel',
        primaryLabel: 'Delete',
        primaryColor: theme.colorScheme.error,
        loading: _loading,
        onCancel: () {
          if (!_loading) Navigator.of(context).pop();
        },
        primaryOnTap: () {
          setState(() => _loading = true);
          context.read<FilemanagerBloc>().add(
                DeleteSelectedEvent(
                  fileIds: widget.fileIds,
                  folderIds: widget.folderIds,
                ),
              );
        },
      ),
    );
  }
}
