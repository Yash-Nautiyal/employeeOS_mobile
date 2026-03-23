# Kanban Drag-and-Drop UI Guide (Beginner Friendly)

This guide explains only the **UI behavior** in the Kanban board (presentation layer).  
No database/data-layer concepts are needed to understand this.

Think of it like this:

- A **column** is a shelf.
- A **section** is a small lane inside that shelf (`createdByMe` or `assignedToMe`).
- A **task card** is a toy block.
- Dragging means: pick a toy block and place it in another spot.

---

## 1) Big Picture: Which UI files do what?

Core drag/drop files:

- `lib/view/kanban/presentation/pages/kanban_view.dart`
  - Main board screen, hover state, auto-scroll, and final "move" trigger.
- `lib/view/kanban/presentation/widgets/kanban_column_view.dart`
  - One column container; has a column-level drop zone (important for empty areas).
- `lib/view/kanban/presentation/widgets/kanban_section_view.dart`
  - Builds section list with top/between/bottom drop points and ghost preview.
- `lib/view/kanban/presentation/widgets/kanban_draggable_task.dart`
  - Makes each task card draggable via `LongPressDraggable`.
- `lib/view/kanban/presentation/widgets/drop_down_widgets/card_drop_target.dart`
  - Decides whether drop is before or after a card.
- `lib/view/kanban/presentation/widgets/drop_down_widgets/drop_slot.dart`
  - Thin drop slot at top/bottom (and between cards).
- `lib/view/kanban/presentation/widgets/drop_down_widgets/ghost_task_card.dart`
  - Faded "preview card" shown while hovering.
- `lib/view/kanban/presentation/bloc/kanban_bloc.dart`
  - Applies final move in UI state using `_moveTaskInState`.
- `lib/view/kanban/domain/modals/kanban_modal.dart`
  - Defines `DragPayload` and `KanbanSection`.

Other presentation files (header, side menu, subtasks, attachments, etc.) are UI helpers and do not drive main drag/drop placement logic.

---

## 2) The data packet that travels during drag

When you start dragging, the card sends a small packet called `DragPayload`:

- `task` -> which task is moving
- `fromColumn` -> where it came from (column id)
- `fromSection` -> where it came from inside column (`createdByMe` or `assignedToMe`)

File:

- `lib/view/kanban/domain/modals/kanban_modal.dart` (`class DragPayload`)

This packet is what every drop target reads to decide if drop is allowed and where to place the card.

---

## 3) Step-by-step: What happens when user drags a card?

### Step A: User long-presses card

File: `kanban_draggable_task.dart`

- Widget: `LongPressDraggable<DragPayload>`
- Important callbacks:
  - `onDragStarted`
  - `onDragEnd`
  - `onDragCompleted`
  - `onDraggableCanceled`
- `feedback` is the floating card under your finger.
- `childWhenDragging` is the faded original card left in list.

### Step B: Board starts drag mode + auto-scroll

File: `kanban_view.dart`

- `onDragStarted` stores `_draggingTaskId` and starts a timer.
- `onDragMove` calls `_maybeAutoScroll(globalOffset)`.
- `_autoScrollTick()` checks pointer near left/right edge and scrolls board horizontally with `jumpTo`.

### Step C: Hovering over targets computes destination

Files:

- `drop_slot.dart` (top/bottom slots)
- `card_drop_target.dart` (over card body)
- `kanban_column_view.dart` (whole column fallback target)

Rules:

- `DropSlot` and `CardDropTarget` only accept if `fromSection == section`.
  - So `createdByMe` cannot drop into `assignedToMe` and vice versa.
- `CardDropTarget` uses `_indexForOffset(...)`:
  - Cursor in top half of card -> insert **before** (`baseIndex`)
  - Cursor in bottom half -> insert **after** (`baseIndex + 1`)

### Step D: Hover preview updates

Files:

- `kanban_view.dart` stores `_hoverColumnId`, `_hoverSection`, `_hoverIndex`, `_hoverTask`.
- `kanban_section_view.dart` shows `GhostTaskCard` at computed index.
- `drop_slot.dart` animates active slot height/color.

### Step E: User releases card (drop accepted)

Flow:

- Drop target calls `onAccept(...)`
- `kanban_view.dart` -> `_moveTask(...)`
- `_moveTask` dispatches `KanbanTaskMoved(...)` to bloc

### Step F: Bloc applies new list order

File: `kanban_bloc.dart`

- Event handler: `_onMoveTask`
- Core reorder logic: `_moveTaskInState(...)`
  - remove from old list
  - clamp target index
  - insert into new list
  - return updated columns

After this, Flutter rebuilds and card appears in new place.

---

## 4) "Who controls what?" (quick map)

- **Can drag start?** -> `LongPressDraggable` in `kanban_draggable_task.dart`
- **What is being dragged?** -> `DragPayload` in `kanban_modal.dart`
- **Drop allowed or not?** -> `onWillAcceptWithDetails` in:
  - `drop_slot.dart`
  - `card_drop_target.dart`
  - `kanban_column_view.dart`
- **Exact insert index?** ->
  - `_indexForOffset` in `card_drop_target.dart`
  - `index` in `drop_slot.dart`
- **Hover preview state?** -> `_hover*` fields in `kanban_view.dart`
- **Ghost card preview?** -> `GhostTaskCard` insertion in `kanban_section_view.dart`
- **Horizontal auto-scroll while dragging?** -> `_maybeAutoScroll` / `_autoScrollTick` in `kanban_view.dart`
- **Final move update?** -> `_moveTaskInState` in `kanban_bloc.dart`

---

## 5) Most useful tweak points (with exact knobs)

### A) Drag feel and visuals

File: `kanban_draggable_task.dart`

- `LongPressDraggable` -> change press/drag behavior
- `feedback` opacity (`0.9`) -> how solid floating card looks
- `childWhenDragging` opacity (`0.2`) -> how faded original card looks
- `hapticFeedbackOnStart` -> vibration on drag start

### B) Edge auto-scroll speed

File: `kanban_view.dart`

- `edge = 140.0` -> how close to edge before scroll starts
- `maxStep = 44.0` -> scroll speed per tick
- timer period `Duration(milliseconds: 16)` -> tick frequency

### C) Drop slot size and highlight

File: `drop_slot.dart`

- `height: show ? 14 : 0` -> visible slot thickness
- animation duration `120ms` -> slot open/close speed
- active color `onSurface.withOpacity(0.10)` -> hover highlight strength

### D) Before/after split line of a card

File: `card_drop_target.dart`

- `mid = box.size.height / 2`
  - change threshold if you want easier "insert before" or "insert after"

### E) Restriction between sections

Files:

- `drop_slot.dart`
- `card_drop_target.dart`

Current rule:

- Reject when `details.data.fromSection != section`

If you remove/relax this check, cross-section drag will be allowed.

---

## 6) Why column-level DragTarget exists

File: `kanban_column_view.dart`

Even if section/card targets are not visible (like empty area), dropping still works because entire column is also a `DragTarget`.  
It computes a safe end index (`list.length`) and accepts there.

This is why users can still drop into sparse/empty column regions.

---

## 7) Beginner mental model (super simple)

Imagine 3 helpers:

- Helper 1 (`KanbanDraggableTask`) says: "I picked up this card."
- Helper 2 (`DropSlot` / `CardDropTarget`) says: "I know exactly where it can land."
- Helper 3 (`KanbanBloc._moveTaskInState`) says: "Okay, remove from old spot and insert into new spot."

That is the whole drag-and-drop story.

---

## 8) If you want to change behavior safely

Use this order:

1. Change acceptance rule (`onWillAcceptWithDetails`) if needed.
2. Change index logic (`_indexForOffset` or slot index) if needed.
3. Keep final reorder logic (`_moveTaskInState`) consistent.
4. Test:
   - same-column reorder
   - cross-column reorder
   - empty column/section drop
   - near-edge auto-scroll

If these four pass, your drag system is usually stable.
