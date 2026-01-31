import 'package:flutter/material.dart';

import 'popup_arrow_side.dart';
import 'responsive_popup_container.dart';

/// Preferred side to open the popup relative to the anchor.
enum PopupPreferredPosition { left, right, top, bottom, auto }

/// Placement for the popup when using [ResponsivePopupController.show] with
/// [preferredPosition] or [childBuilder].
class PopupPlacement {
  const PopupPlacement({
    required this.offset,
    required this.arrowSide,
    this.arrowOffset = 0.5,
  });

  final Offset offset;
  final PopupArrowSide arrowSide;

  /// Position along the arrow edge (0.0 = start, 1.0 = end). Not necessarily center.
  final double arrowOffset;
}

class ResponsivePopupController {
  OverlayEntry? _entry;

  bool get isShowing => _entry != null;

  static const double _popupWidth = 180;
  static const double _popupHeight = 100;
  static const double _gap = 8;

  /// Shows the popup.
  ///
  /// - [preferredPosition]: open on left, right, top, bottom, or [PopupPreferredPosition.auto].
  /// - [manualOffset]: delta added to the computed offset (e.g. to nudge position).
  /// - [arrowOffsetOverride]: when non-null, used instead of computed arrow alignment (0.0–1.0).
  /// - When [anchorKey] and [childBuilder] are provided, placement is computed from [preferredPosition].
  void show({
    required BuildContext context,
    required LayerLink link,
    Widget? child,
    Widget Function(PopupPlacement placement)? childBuilder,
    Offset offset = const Offset(0, 8),
    PopupPreferredPosition preferredPosition = PopupPreferredPosition.auto,
    Offset? manualOffset,
    double? arrowOffsetOverride,
    GlobalKey? anchorKey,
  }) {
    hide();

    final usePlacement = anchorKey != null && childBuilder != null;
    Offset finalOffset = offset;
    Widget finalChild;

    if (usePlacement) {
      final key = anchorKey;
      final placement = _computePlacement(
        context,
        key,
        preferredPosition,
        manualOffset ?? Offset.zero,
        arrowOffsetOverride,
      );
      if (placement != null) {
        finalOffset = placement.offset;
        finalChild = childBuilder(placement);
      } else {
        finalChild = childBuilder(PopupPlacement(
          offset: offset + (manualOffset ?? Offset.zero),
          arrowSide: _arrowSideForPosition(preferredPosition),
          arrowOffset: arrowOffsetOverride ?? 0.5,
        ));
      }
    } else if (childBuilder != null) {
      final placement = PopupPlacement(
        offset: offset + (manualOffset ?? Offset.zero),
        arrowSide: _arrowSideForPosition(preferredPosition),
        arrowOffset: arrowOffsetOverride ?? 0.5,
      );
      finalChild = childBuilder(placement);
    } else {
      finalChild = child ?? const SizedBox.shrink();
    }

    _entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: hide,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: link,
                offset: finalOffset,
                showWhenUnlinked: false,
                child: finalChild,
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  PopupArrowSide _arrowSideForPosition(PopupPreferredPosition pos) {
    switch (pos) {
      case PopupPreferredPosition.top:
        return PopupArrowSide.bottom;
      case PopupPreferredPosition.bottom:
        return PopupArrowSide.top;
      case PopupPreferredPosition.left:
        return PopupArrowSide.right;
      case PopupPreferredPosition.right:
        return PopupArrowSide.left;
      case PopupPreferredPosition.auto:
        return PopupArrowSide.bottom;
    }
  }

  PopupPlacement? _computePlacement(
    BuildContext context,
    GlobalKey anchorKey,
    PopupPreferredPosition preferredPosition,
    Offset manualOffset,
    double? arrowOffsetOverride,
  ) {
    final anchorContext = anchorKey.currentContext;
    if (anchorContext == null) return null;

    final anchorBox = anchorContext.findRenderObject() as RenderBox?;
    if (anchorBox == null || !anchorBox.hasSize) return null;

    final screenSize = MediaQuery.sizeOf(context);
    final anchorPos = anchorBox.localToGlobal(Offset.zero);
    final anchorSize = anchorBox.size;

    final spaceAbove = anchorPos.dy;
    final spaceBelow = screenSize.height - (anchorPos.dy + anchorSize.height);
    final spaceLeft = anchorPos.dx;
    final spaceRight = screenSize.width - (anchorPos.dx + anchorSize.width);

    double dx = 0;
    double dy = 0;
    PopupArrowSide arrowSide = PopupArrowSide.bottom;
    double arrowOffset = 0.5;

    void applyManualOffset() {
      dx += manualOffset.dx;
      dy += manualOffset.dy;
      dx = dx.clamp(
        -anchorPos.dx,
        screenSize.width - anchorPos.dx - _popupWidth,
      );
      dy = dy.clamp(
        -anchorPos.dy,
        screenSize.height - anchorPos.dy - _popupHeight,
      );
    }

    switch (preferredPosition) {
      case PopupPreferredPosition.auto:
        {
          final above = spaceAbove >= _popupHeight + _gap;
          final below = spaceBelow >= _popupHeight + _gap;
          final left = spaceLeft >= _popupWidth + _gap;
          final right = spaceRight >= _popupWidth + _gap;
          double bestScore = -double.infinity;
          PopupArrowSide? bestSide;
          double? bestDx;
          double? bestDy;
          double? bestArrowOffset;
          if (above && spaceAbove > bestScore) {
            bestScore = spaceAbove;
            bestSide = PopupArrowSide.bottom;
            bestDy = -_popupHeight - _gap;
            final preferredDx = anchorSize.width / 2 - _popupWidth / 2;
            bestDx = preferredDx.clamp(
              -anchorPos.dx,
              screenSize.width - anchorPos.dx - _popupWidth,
            );
            bestArrowOffset =
                ((anchorSize.width / 2 - bestDx) / _popupWidth).clamp(0.0, 1.0);
          }
          if (below && spaceBelow > bestScore) {
            bestScore = spaceBelow;
            bestSide = PopupArrowSide.top;
            bestDy = anchorSize.height + _gap;
            final preferredDx = anchorSize.width / 2 - _popupWidth / 2;
            bestDx = preferredDx.clamp(
              -anchorPos.dx,
              screenSize.width - anchorPos.dx - _popupWidth,
            );
            bestArrowOffset =
                ((anchorSize.width / 2 - bestDx) / _popupWidth).clamp(0.0, 1.0);
          }
          if (left && spaceLeft > bestScore) {
            bestScore = spaceLeft;
            bestSide = PopupArrowSide.right;
            bestDx = -_popupWidth - _gap;
            final preferredDy = anchorSize.height / 2 - _popupHeight / 2;
            bestDy = preferredDy.clamp(
              -anchorPos.dy,
              screenSize.height - anchorPos.dy - _popupHeight,
            );
            bestArrowOffset = ((anchorSize.height / 2 - bestDy) / _popupHeight)
                .clamp(0.0, 1.0);
          }
          if (right && spaceRight > bestScore) {
            bestScore = spaceRight;
            bestSide = PopupArrowSide.left;
            bestDx = anchorSize.width + _gap;
            final preferredDy = anchorSize.height / 2 - _popupHeight / 2;
            bestDy = preferredDy.clamp(
              -anchorPos.dy,
              screenSize.height - anchorPos.dy - _popupHeight,
            );
            bestArrowOffset = ((anchorSize.height / 2 - bestDy) / _popupHeight)
                .clamp(0.0, 1.0);
          }
          if (bestSide != null && bestDx != null && bestDy != null) {
            dx = bestDx;
            dy = bestDy;
            arrowSide = bestSide;
            arrowOffset =
                (arrowOffsetOverride ?? bestArrowOffset ?? 0.5).clamp(0.0, 1.0);
            applyManualOffset();
            return PopupPlacement(
              offset: Offset(dx, dy),
              arrowSide: arrowSide,
              arrowOffset: arrowOffset,
            );
          }
          dx = anchorSize.width / 2 - _popupWidth / 2;
          dy = -_popupHeight - _gap;
          arrowSide = PopupArrowSide.bottom;
          arrowOffset = arrowOffsetOverride ?? 0.5;
          applyManualOffset();
          return PopupPlacement(
            offset: Offset(dx, dy),
            arrowSide: arrowSide,
            arrowOffset: arrowOffset.clamp(0.0, 1.0),
          );
        }

      case PopupPreferredPosition.top:
        dy = -_popupHeight - _gap;
        arrowSide = PopupArrowSide.bottom;
        final preferredDx = anchorSize.width / 2 - _popupWidth / 2;
        dx = preferredDx.clamp(
          -anchorPos.dx,
          screenSize.width - anchorPos.dx - _popupWidth,
        );
        arrowOffset =
            ((anchorSize.width / 2 - dx) / _popupWidth).clamp(0.0, 1.0);
        applyManualOffset();
        break;
      case PopupPreferredPosition.bottom:
        dy = anchorSize.height + _gap;
        arrowSide = PopupArrowSide.top;
        final preferredDxB = anchorSize.width / 2 - _popupWidth / 2;
        dx = preferredDxB.clamp(
          -anchorPos.dx,
          screenSize.width - anchorPos.dx - _popupWidth,
        );
        arrowOffset =
            ((anchorSize.width / 2 - dx) / _popupWidth).clamp(0.0, 1.0);
        applyManualOffset();
        break;
      case PopupPreferredPosition.left:
        dx = -_popupWidth - _gap;
        arrowSide = PopupArrowSide.right;
        final preferredDyL = anchorSize.height / 2 - _popupHeight / 2;
        dy = preferredDyL.clamp(
          -anchorPos.dy,
          screenSize.height - anchorPos.dy - _popupHeight,
        );
        arrowOffset =
            ((anchorSize.height / 2 - dy) / _popupHeight).clamp(0.0, 1.0);
        applyManualOffset();
        break;
      case PopupPreferredPosition.right:
        dx = anchorSize.width + _gap;
        arrowSide = PopupArrowSide.left;
        final preferredDyR = anchorSize.height / 2 - _popupHeight / 2;
        dy = preferredDyR.clamp(
          -anchorPos.dy,
          screenSize.height - anchorPos.dy - _popupHeight,
        );
        arrowOffset =
            ((anchorSize.height / 2 - dy) / _popupHeight).clamp(0.0, 1.0);
        applyManualOffset();
        break;
    }

    if (arrowOffsetOverride != null) {
      arrowOffset = arrowOffsetOverride.clamp(0.0, 1.0);
    }
    return PopupPlacement(
      offset: Offset(dx, dy),
      arrowSide: arrowSide,
      arrowOffset: arrowOffset,
    );
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  void dispose() {
    hide();
  }
}
