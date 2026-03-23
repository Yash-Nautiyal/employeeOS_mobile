import 'package:employeeos/core/index.dart'
    show CustomDialog, CustomDropdown, CustomTextButton;
import 'package:employeeos/view/filemanager/domain/entities/files_models.dart';
import 'package:employeeos/view/filemanager/presentation/bloc/filemanager_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:keyboard_sticky/keyboard_sticky.dart';

enum AddToFolderMode { createNew, addToExisting }

/// Dialog: Add selected files to a new folder or to an existing folder. Only one option at a time.
class AddToFolderDialog extends StatefulWidget {
  const AddToFolderDialog({
    super.key,
    required this.fileIds,
    required this.folders,
  });

  final List<String> fileIds;
  final List<FolderItem> folders;

  @override
  State<AddToFolderDialog> createState() => _AddToFolderDialogState();
}

class _AddToFolderDialogState extends State<AddToFolderDialog> {
  final TextEditingController _nameController = TextEditingController();
  AddToFolderMode _mode = AddToFolderMode.createNew;
  String? _selectedFolderName;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isCreateMode => _mode == AddToFolderMode.createNew;
  bool get _canSubmit {
    if (_loading) return false;
    if (_isCreateMode) return _nameController.text.trim().isNotEmpty;
    return _selectedFolderName != null && _selectedFolderName!.isNotEmpty;
  }

  String get _primaryLabel {
    if (_loading) return _isCreateMode ? 'Creating...' : 'Adding...';
    return _isCreateMode ? 'Create' : 'Add';
  }

  void _submit() {
    if (!_canSubmit) return;
    final bloc = context.read<FilemanagerBloc>();
    setState(() => _loading = true);
    if (_isCreateMode) {
      bloc.add(CreateFolderEvent(
        _nameController.text.trim(),
        fileIds: widget.fileIds,
      ));
    } else {
      final folder = widget.folders.firstWhere(
        (f) => f.folder.name == _selectedFolderName,
        orElse: () => widget.folders.first,
      );
      bloc.add(MoveFileToFolderEvent(widget.fileIds, folder.folder.id));
    }
  }

  Widget _buildOptionCards(
    ThemeData theme, {
    required bool isWideScreen,
    required bool hasExistingFolders,
  }) {
    final createCard = _OptionCard(
      theme: theme,
      icon: 'assets/icons/common/solid/ic-solar-add-folder-bold.svg',
      label: 'Create new folder',
      isSelected: _isCreateMode,
      onTap: () {
        setState(() {
          _mode = AddToFolderMode.createNew;
          _selectedFolderName = null;
        });
      },
    );

    final existingCard = hasExistingFolders
        ? _OptionCard(
            theme: theme,
            icon: 'assets/icons/common/solid/ic-solar-folder-bold.svg',
            label: 'Add to existing folder',
            isSelected: !_isCreateMode,
            onTap: () {
              setState(() {
                _mode = AddToFolderMode.addToExisting;
                _nameController.clear();
              });
            },
          )
        : null;

    if (isWideScreen) {
      return Row(
        children: [
          Expanded(child: createCard),
          if (existingCard != null) ...[
            const SizedBox(width: 8),
            Expanded(child: existingCard),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        createCard,
        if (existingCard != null) ...[
          const SizedBox(height: 8),
          existingCard,
        ],
      ],
    );
  }

  Widget _buildFormField(ThemeData theme) {
    if (_isCreateMode) {
      return KeyboardSticky.both(
        controller: _nameController,
        useMaterial: true,
        builder: (context, controller, field) =>
            field ?? const SizedBox.shrink(),
        fieldBuilder: (context, controller, focusNode) => TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Project files',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
          ),
        ),
        floatingBuilder: (context, controller, field) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: field ?? const SizedBox.shrink(),
        ),
        floatingFieldBuilder: (context, controller, focusNode) => TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Project files',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
    }

    return CustomDropdown(
      value: _selectedFolderName,
      theme: theme,
      label: 'Select folder',
      isSearchable: true,
      onChange: (value) => setState(
        () => _selectedFolderName = value.toString(),
      ),
      selectedItemBuilder: (context) => widget.folders
          .map(
            (f) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                f.folder.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
      items: widget.folders
          .map(
            (f) => DropdownMenuItem<String>(
              value: f.folder.name,
              child: Text(
                f.folder.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomTextButton(
          padding: 0,
          onClick: _loading ? () {} : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        CustomTextButton(
          padding: 0,
          backgroundColor: _canSubmit || _loading
              ? (_loading
                  ? theme.disabledColor.withValues(alpha: 0.3)
                  : theme.colorScheme.onSurface)
              : theme.disabledColor.withValues(alpha: 0.3),
          onClick: () {
            if (_loading) return;
            if (_canSubmit) _submit();
          },
          child: Text(
            _primaryLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasExistingFolders = widget.folders.isNotEmpty;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isLandscape = !isPortrait;
    final isWideScreen = isLandscape || MediaQuery.of(context).size.width > 500;

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: BlocListener<FilemanagerBloc, FilemanagerState>(
        listenWhen: (previous, current) => current is FilemanagerActionState,
        listener: (context, state) {
          if (context.mounted) Navigator.of(context).pop();
        },
        child: CustomDialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: isLandscape
                ? _buildLandscape(theme, isWideScreen, hasExistingFolders)
                : _buildPortrait(theme, isWideScreen, hasExistingFolders),
          ),
        ),
      ),
    );
  }

  /// Portrait: shrink-wrap Column, scrollable middle section.
  Widget _buildPortrait(
      ThemeData theme, bool isWideScreen, bool hasExistingFolders) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add to folder',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Choose an option',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildOptionCards(theme,
            isWideScreen: isWideScreen, hasExistingFolders: hasExistingFolders),
        const SizedBox(height: 20),
        _buildFormField(theme),
        const SizedBox(height: 20),
        _buildActions(theme),
      ],
    );
  }

  /// Landscape: fill available height, scrollable body between fixed title & actions.
  Widget _buildLandscape(
      ThemeData theme, bool isWideScreen, bool hasExistingFolders) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed title
        Text(
          'Add to folder',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        // Scrollable body (takes remaining space in landscape)
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose an option',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildOptionCards(theme,
                isWideScreen: isWideScreen,
                hasExistingFolders: hasExistingFolders),
            const SizedBox(height: 16),
            _buildFormField(theme),
          ],
        ),
        const SizedBox(height: 12),
        // Fixed actions
        _buildActions(theme),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeData theme;
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? theme.primaryColor.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : theme.dividerColor.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
