# KANBAN MODULE — FRONTEND GUIDE
> Give this file to Cursor. It contains all model changes, every action→query mapping, and cascade/trigger effects.

---

## SECTION 1: BLOC MODEL CHANGES

### 1.1 NEW MODEL — `KanbanSubtask`
Replace `Map<String, bool> subtasks` everywhere with `List<KanbanSubtask>`.

```dart
class KanbanSubtask {
  final String id;
  final String name;
  final bool completed;

  const KanbanSubtask({
    required this.id,
    required this.name,
    required this.completed,
  });

  KanbanSubtask copyWith({String? id, String? name, bool? completed}) {
    return KanbanSubtask(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }

  factory KanbanSubtask.fromJson(Map<String, dynamic> json) {
    return KanbanSubtask(
      id: json['id'] as String,
      name: json['name'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
```

### 1.2 NEW MODEL — `KanbanAttachment`
Replace `List<String> attachments` everywhere with `List<KanbanAttachment>`.

```dart
class KanbanAttachment {
  final String id;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? uploadedBy;

  const KanbanAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedBy,
  });

  KanbanAttachment copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? uploadedBy,
  }) {
    return KanbanAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }

  factory KanbanAttachment.fromJson(Map<String, dynamic> json) {
    return KanbanAttachment(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      uploadedBy: json['uploaded_by'] as String?,
    );
  }
}
```

### 1.3 CHANGED MODEL — `KanbanAssignee`
Add `userId` field. This is needed to link back to the DB for add/remove operations.

```dart
class KanbanAssignee {
  final String userId;   // ADD THIS
  final String name;
  final String email;
  final String? avatarUrl;

  const KanbanAssignee({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  factory KanbanAssignee.fromJson(Map<String, dynamic> json) {
    return KanbanAssignee(
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  KanbanAssignee copyWith({
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return KanbanAssignee(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
```

### 1.4 CHANGED MODEL — `KanbanGroupItem`
Major refactor. Remove `date`, `dueDate` strings. Add proper typed fields.

```dart
class KanbanGroupItem {
  final String itemId;
  final String title;
  final String columnId;                    // ADD — needed for column selector dropdown
  final KanbanAssignee? reporter;           // CHANGED — was String assignedBy
  final List<KanbanAssignee> assignees;
  final DateTime? dueStart;                 // CHANGED — was String date
  final DateTime? dueEnd;                   // CHANGED — was String dueDate
  final String priority;
  final String description;
  final List<KanbanAttachment> attachments; // CHANGED — was List<String>
  final List<KanbanSubtask> subtasks;       // CHANGED — was Map<String, bool>
  final DateTime? archivedAt;               // ADD
  final DateTime createdAt;                 // ADD

  const KanbanGroupItem({
    required this.itemId,
    required this.title,
    required this.columnId,
    this.reporter,
    required this.assignees,
    this.dueStart,
    this.dueEnd,
    required this.priority,
    required this.description,
    required this.attachments,
    required this.subtasks,
    this.archivedAt,
    required this.createdAt,
  });

  String get id => itemId;

  int get completedTasks => subtasks.where((s) => s.completed).length;
  int get totalTasks => subtasks.length;

  bool get isOverdue =>
      dueEnd != null && DateTime.now().isAfter(dueEnd!) && archivedAt == null;

  bool get allSubtasksComplete =>
      subtasks.isEmpty || subtasks.every((s) => s.completed);

  String get assignedToLabel =>
      assignees.isEmpty ? 'Unassigned' : assignees.first.name;

  /// Format due date for card display
  String get displayDate {
    if (dueEnd == null) return '';
    // Use your preferred date formatting here
    return '${dueEnd!.day} ${_monthName(dueEnd!.month)}';
  }

  static String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  /// Build from board-level JSON (summary, no subtask details)
  factory KanbanGroupItem.fromBoardJson(Map<String, dynamic> json, String columnId) {
    return KanbanGroupItem(
      itemId: json['id'] as String,
      title: json['name'] as String,
      columnId: columnId,
      reporter: json['reporter'] != null
          ? KanbanAssignee.fromJson(json['reporter'])
          : null,
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((a) => KanbanAssignee.fromJson(a))
          .toList(),
      dueStart: json['due_start'] != null
          ? DateTime.parse(json['due_start'])
          : null,
      dueEnd: json['due_end'] != null
          ? DateTime.parse(json['due_end'])
          : null,
      priority: json['priority'] as String? ?? 'medium',
      description: '', // Not loaded at board level
      attachments: [], // Not loaded at board level
      subtasks: [],    // Not loaded at board level — use counts below
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Build from detail-level JSON (full data)
  factory KanbanGroupItem.fromDetailJson(Map<String, dynamic> json) {
    return KanbanGroupItem(
      itemId: json['id'] as String,
      title: json['name'] as String,
      columnId: json['column_id'] as String,
      reporter: json['reporter'] != null
          ? KanbanAssignee.fromJson(json['reporter'])
          : null,
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((a) => KanbanAssignee.fromJson(a))
          .toList(),
      dueStart: json['due_start'] != null
          ? DateTime.parse(json['due_start'])
          : null,
      dueEnd: json['due_end'] != null
          ? DateTime.parse(json['due_end'])
          : null,
      priority: json['priority'] as String? ?? 'medium',
      description: json['description'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => KanbanAttachment.fromJson(a))
          .toList(),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((s) => KanbanSubtask.fromJson(s))
          .toList(),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  KanbanGroupItem copyWith({
    String? itemId,
    String? title,
    String? columnId,
    KanbanAssignee? reporter,
    List<KanbanAssignee>? assignees,
    DateTime? dueStart,
    DateTime? dueEnd,
    String? priority,
    String? description,
    List<KanbanAttachment>? attachments,
    List<KanbanSubtask>? subtasks,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) {
    return KanbanGroupItem(
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      columnId: columnId ?? this.columnId,
      reporter: reporter ?? this.reporter,
      assignees: assignees ?? this.assignees,
      dueStart: dueStart ?? this.dueStart,
      dueEnd: dueEnd ?? this.dueEnd,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      subtasks: subtasks ?? this.subtasks,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**IMPORTANT — Board-level subtask counts:**
At board level, the RPC returns `subtask_total` and `subtask_completed` instead of full subtask objects. You need to handle this in the card widget. Either:
- Add `int subtaskTotal` and `int subtaskCompleted` fields to `KanbanGroupItem` for board-level use.
- Or parse them separately in the column widget.

Recommended: add these two fields and populate them from board JSON:
```dart
  final int? subtaskTotal;       // ADD — from board load only
  final int? subtaskCompleted;   // ADD — from board load only
```
And in `fromBoardJson`:
```dart
  subtaskTotal: json['subtask_total'] as int? ?? 0,
  subtaskCompleted: json['subtask_completed'] as int? ?? 0,
```

### 1.5 CHANGED MODEL — `KanbanColumn`
Add `position`.

```dart
class KanbanColumn {
  final String id;
  final String title;
  final int position;                            // ADD
  final List<KanbanGroupItem> createdByMe;
  final List<KanbanGroupItem> assignedToMe;

  const KanbanColumn({
    required this.id,
    required this.title,
    required this.position,
    required this.createdByMe,
    required this.assignedToMe,
  });

  int get totalCount => createdByMe.length + assignedToMe.length;

  bool get isArchive => title.toLowerCase() == 'archive';

  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    final columnId = json['id'] as String;
    return KanbanColumn(
      id: columnId,
      title: json['name'] as String,
      position: json['position'] as int,
      createdByMe: (json['created_by_me'] as List<dynamic>? ?? [])
          .map((t) => KanbanGroupItem.fromBoardJson(t, columnId))
          .toList(),
      assignedToMe: (json['assigned_to_me'] as List<dynamic>? ?? [])
          .map((t) => KanbanGroupItem.fromBoardJson(t, columnId))
          .toList(),
    );
  }
}
```

### 1.6 UPDATED — `DragPayload`
No changes needed, current design is fine.

---

## SECTION 2: ACTION → QUERY → EFFECT MAP

Every user action, what Supabase call to make, and what happens as a result.

---

### BOARD

#### Load Board
```
Action:    App opens / pull to refresh
Query:     final res = await supabase.rpc('get_kanban_board', params: {'p_user_id': userId});
Parse:     List<KanbanColumn> columns = (res as List).map((c) => KanbanColumn.fromJson(c)).toList();
Cascade:   None
Notes:     Single RPC call returns all columns + task card summaries.
           Tasks sorted by created_at DESC (done server-side).
```

---

### COLUMNS

#### Create Column
```
Action:    User clicks "+ Add column", types name, presses Enter
Query:     final res = await supabase.rpc('create_column', params: {'p_name': name});
Parse:     res['id'], res['position']
Cascade:   None
Local:     Append new KanbanColumn to state
```

#### Rename Column
```
Action:    Column menu → Rename
Query:     await supabase.from('kanban_columns').update({'name': newName}).eq('id', columnId);
Cascade:   Trigger sets updated_at (if you add trigger — currently none on columns)
Local:     Update column title in state
Guard:     Block if column.isArchive == true
```

#### Delete Column
```
Action:    Column menu → Delete
Query:     final res = await supabase.rpc('delete_column', params: {'p_column_id': columnId});
Cascade:   DB CASCADE → deletes all kanban_tasks in column
                       → CASCADE → deletes subtasks, assignees, attachments of those tasks
Local:     Remove column from state
Guard:     Block if column.isArchive == true (also enforced server-side)
```

#### Clear Column
```
Action:    Column menu → Clear
Query:     final res = await supabase.rpc('clear_column', params: {
             'p_column_id': columnId,
             'p_user_id': userId,
           });
Parse:     res['deleted_count']
Cascade:   Only deletes tasks where reporter_id = current user.
           CASCADE → subtasks, assignees, attachments of deleted tasks.
           Tasks created by OTHER users remain untouched.
Local:     Remove tasks from createdByMe list for that column.
           Keep assignedToMe list unchanged (those are other people's tasks).
```

#### Reorder Columns (drag)
```
Action:    User drags column to new position
Query:     final positions = columns.asMap().entries.map((e) =>
             {'id': e.value.id, 'position': e.index}
           ).toList();
           await supabase.rpc('reorder_columns', params: {'p_positions': positions});
Cascade:   None
Local:     Reorder columns list in state, update position fields
Notes:     Send ALL column positions at once. The DEFERRABLE UNIQUE constraint
           allows this to work in a single transaction.
```

---

### TASKS

#### Create Task
```
Action:    User clicks "+" in column header, types name, presses Enter
Query:     final res = await supabase.from('kanban_tasks').insert({
             'name': name,
             'column_id': columnId,
             'reporter_id': userId,
           }).select('id, name, created_at').single();
Cascade:   None
Local:     Add new KanbanGroupItem to column's createdByMe list at index 0
           (it's the newest, and list is sorted created_at DESC)
Notes:     Only name is set at creation. All other fields added later via detail panel.
```

#### Open Task Detail
```
Action:    User taps a task card
Query:     final res = await supabase.rpc('get_task_detail', params: {'p_task_id': taskId});
Parse:     KanbanGroupItem.fromDetailJson(res)
Cascade:   None
Notes:     This returns full data: subtasks, attachments, reporter, assignees.
           Board-level data only has summaries.
```

#### Update Task Fields (name, description, priority, due dates)
```
Action:    User edits fields in detail panel
Query:     await supabase.from('kanban_tasks').update({
             // Include only changed fields:
             'name': newName,           // if changed
             'description': newDesc,    // if changed
             'priority': newPriority,   // if changed
             'due_start': dueStart?.toIso8601String(),  // if changed
             'due_end': dueEnd?.toIso8601String(),      // if changed
           }).eq('id', taskId);
Cascade:   Trigger → update_updated_at fires automatically
Local:     Update KanbanGroupItem in state
```

#### Move Task to Column (drag or dropdown)
```
Action:    User drags task to another column OR changes column in dropdown
Query:     final res = await supabase.rpc('move_task_to_column', params: {
             'p_task_id': taskId,
             'p_column_id': targetColumnId,
             'p_user_id': userId,
           });
Parse:     Check res['success']. If false, show res['error'] as toast.
Cascade:   If target = Archive → archived_at is set server-side
           If source = Archive → archived_at is cleared server-side
Local:     On success: remove task from source column list, add to target column list.
           Update task's columnId and archivedAt in local state.
Guard:     If target is Archive and subtasks incomplete → server returns error.
           Show toast: "Please complete all subtasks before moving to Archive"
```

#### Mark Task Complete
```
Action:    User clicks "Mark Complete" button in detail panel
Query:     final res = await supabase.rpc('mark_task_complete', params: {
             'p_task_id': taskId,
             'p_user_id': userId,
           });
Parse:     Check res['success']. If false, show res['error'] as toast.
Cascade:   Server moves task to Archive column + sets archived_at
Local:     On success: move task to Archive column in state.
           Show toast: "Task marked as complete and moved to Archive!"
Guard:     Server validates all subtasks complete. If not → error returned.
           Show toast: "Please complete all subtasks before marking the task as complete"
```

#### Delete Task
```
Action:    User clicks trash icon in detail panel
Query:     final res = await supabase.rpc('delete_task', params: {
             'p_task_id': taskId,
             'p_user_id': userId,
           });
Parse:     Check res['success']. If false, show res['error'] as toast.
Cascade:   DB CASCADE → deletes subtasks, assignees, attachments
Local:     Remove task from column list in state. Close detail panel.
Guard:     Only creator can delete. Server checks reporter_id = p_user_id.
           If not creator → error: "Only the creator can delete this task"
```

---

### ASSIGNEES

#### Add Assignee
```
Action:    User clicks "+" next to "Assigned to" in detail panel, selects a user
Query:     await supabase.from('kanban_task_assignees').insert({
             'task_id': taskId,
             'user_id': selectedUserId,
           });
Cascade:   None
Local:     Add KanbanAssignee to task's assignees list in state.
Notes:     The selected user will now see this task in their "Assigned to me" section.
```

#### Remove Assignee
```
Action:    User removes an assignee from the list
Query:     await supabase.from('kanban_task_assignees')
             .delete()
             .eq('task_id', taskId)
             .eq('user_id', targetUserId);
Cascade:   None
Local:     Remove KanbanAssignee from task's assignees list in state.
```

---

### SUBTASKS

#### Add Subtask
```
Action:    User clicks "+ Add Subtask", types name
Query:     final res = await supabase.from('kanban_task_subtasks').insert({
             'task_id': taskId,
             'name': subtaskName,
           }).select('id, name, completed').single();
Cascade:   None
Local:     Add KanbanSubtask to task's subtasks list in state.
```

#### Toggle Subtask Complete
```
Action:    User checks/unchecks a subtask checkbox
Query:     await supabase.from('kanban_task_subtasks')
             .update({'completed': newValue})
             .eq('id', subtaskId);
Cascade:   Trigger → update_updated_at on subtask
Local:     Update subtask's completed field in state.
           Recalculate completedTasks / totalTasks on parent task.
```

#### Edit Subtask Name
```
Action:    User clicks edit icon on subtask, changes name
Query:     await supabase.from('kanban_task_subtasks')
             .update({'name': newName})
             .eq('id', subtaskId);
Cascade:   Trigger → update_updated_at on subtask
Local:     Update subtask's name in state.
```

#### Delete Subtask
```
Action:    User clicks trash icon on subtask
Query:     await supabase.from('kanban_task_subtasks')
             .delete()
             .eq('id', subtaskId);
Cascade:   None
Local:     Remove subtask from task's subtasks list in state.
           Recalculate completedTasks / totalTasks.
```

---

### ATTACHMENTS

#### Upload Attachment
```
Action:    User drops file or clicks browse in detail panel
Step 1:    Upload to Supabase Storage:
           final path = '$taskId/${file.name}';
           await supabase.storage.from('kanban-attachments').upload(path, file);
           final url = supabase.storage.from('kanban-attachments').getPublicUrl(path);

Step 2:    Insert record:
           final res = await supabase.from('kanban_task_attachments').insert({
             'task_id': taskId,
             'file_name': file.name,
             'file_url': url,
             'file_type': file.mimeType,
             'file_size': file.size,
             'uploaded_by': userId,
           }).select().single();
Cascade:   None
Local:     Add KanbanAttachment to task's attachments list in state.
```

#### Delete Attachment
```
Action:    User deletes an attachment
Step 1:    Delete from storage:
           await supabase.storage.from('attachments').remove([storagePath]);

Step 2:    Delete record:
           await supabase.from('kanban_task_attachments')
             .delete()
             .eq('id', attachmentId);
Cascade:   None
Local:     Remove KanbanAttachment from task's attachments list in state.
```

---

## SECTION 3: RPC RESPONSE SHAPES

### get_kanban_board
```json
[
  {
    "id": "uuid",
    "name": "To do",
    "position": 1,
    "created_by_me": [
      {
        "id": "uuid",
        "name": "Task name",
        "priority": "medium",
        "due_start": "2026-02-17T00:00:00Z",
        "due_end": "2026-02-18T00:00:00Z",
        "archived_at": null,
        "created_at": "2026-02-18T10:00:00Z",
        "subtask_total": 3,
        "subtask_completed": 1,
        "assignees": [
          {"user_id": "uuid", "name": "Alice", "email": "a@b.com", "avatar_url": null}
        ],
        "reporter": {"user_id": "uuid", "name": "You", "email": "you@b.com", "avatar_url": null}
      }
    ],
    "assigned_to_me": []
  }
]
```

### get_task_detail
```json
{
  "id": "uuid",
  "name": "Task name",
  "description": "Some text",
  "column_id": "uuid",
  "column_name": "To do",
  "priority": "medium",
  "due_start": "2026-02-17T00:00:00Z",
  "due_end": "2026-02-18T00:00:00Z",
  "archived_at": null,
  "created_at": "2026-02-18T10:00:00Z",
  "updated_at": "2026-02-18T10:00:00Z",
  "reporter": {"user_id": "uuid", "name": "Alice", "email": "a@b.com", "avatar_url": null},
  "assignees": [
    {"user_id": "uuid", "name": "Bob", "email": "b@b.com", "avatar_url": null}
  ],
  "subtasks": [
    {"id": "uuid", "name": "Subtask 1", "completed": true},
    {"id": "uuid", "name": "Subtask 2", "completed": false}
  ],
  "attachments": [
    {"id": "uuid", "file_name": "doc.pdf", "file_url": "https://...", "file_type": "application/pdf", "file_size": 12345, "uploaded_by": "uuid"}
  ]
}
```

---

## SECTION 4: IMPORTANT NOTES

### Archive Detection
Currently Archive is detected by `LOWER(name) = 'archive'`. This is fragile — if someone renames it, things break. For now this works because the UI blocks renaming Archive. Future version should add `is_archive` boolean flag to `kanban_columns`.

### Clear Column — Creator-Only Behavior
`clear_column` only deletes tasks where `reporter_id = current_user`. If the user expects ALL tasks to vanish, they'll see other people's tasks still there. Consider showing a toast: "Cleared X tasks. Tasks created by others were not affected."

### Fixed Column Toggle
This is a per-user UI preference. Store it in local storage or a user_preferences table. It does NOT affect the schema. When "Fixed column" is ON, disable drag-to-reorder on columns in the UI.

