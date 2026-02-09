# File Manager — Changelog

This document summarizes **all major database, domain, data-layer, and UI changes** made across recent development sessions. It includes return types, models, RPC shapes, and key behavioral details.

---

## 1. Database / Backend Alignment (FRONTEND_QUERIES_GUIDE.md)

- **Reference:** `FRONTEND_QUERIES_GUIDE.md` — single source of truth for how the frontend should perform file/folder/share/tag operations.
- **Data loading:** `get_user_files(current_user_id)` RPC returns `{ folders, root_files }`. Recent file IDs come from `file_activity` (order by `activity_at` DESC, limit 5–10).
- **File delete:** Owner-only; backend enforces `user_id` on `files`. CASCADE removes file_sharing, file_tags, file_activity, file_favorites, user_file_folders.
- **Folder delete:** User must own folder; trigger may delete owner’s files in that folder; shared files in folder are not deleted (other users’ placements).
- **Tags:** Canonical = `is_personal = false` (owner/editor); personal = `is_personal = true` (viewer). Delete canonical by `file_id + tag_name + is_personal = false`; delete personal by also filtering `user_id`.
- **Sharing:** `file_sharing` (file_id, shared_by, shared_with, access_type). Revoke triggers cleanup of user_file_folders, file_tags (personal), file_favorites, file_activity for revoked user.
- **Move file:** Per-user via `user_file_folders` (upsert for folder; delete for move to root). No trigger; doesn’t affect other users.

---

## 2. New RPC Return Shape & Role-Based Model

### 2.1 RPC `get_user_files` — Per-file shape (from backend)

Each file object in `folders[].files` and `root_files` is expected to include:

| Field             | Type          | Description                                                               |
| ----------------- | ------------- | ------------------------------------------------------------------------- |
| `id`              | String        | File id                                                                   |
| `file_name`       | String        | Display name                                                              |
| `file_type`       | String?       | MIME / type                                                               |
| `file_size`       | int?          | Size in bytes                                                             |
| `storage_url`     | String        | Storage path (used to build public URL)                                   |
| `created_at`      | DateTime-like | Created at                                                                |
| `folder_id`       | String?       | Present when file is inside a folder in this response                     |
| **`role`**        | String        | `'owner'` \| `'editor'` \| `'viewer'` — current user’s role for this file |
| **`owner_id`**    | String?       | File owner user id                                                        |
| **`owner_name`**  | String?       | File owner display name (may be filled by frontend from user_info)        |
| **`is_favorite`** | bool          | Current user’s favorite flag                                              |
| **`tags`**        | List          | `[{ tag_name, is_personal }]`                                             |
| **`shared_with`** | List          | `[{ user_id, name?, access }]` — `access` = `'view'` or `'edit'`          |

### 2.2 Domain entities (`lib/view/filemanager/domain/entities/files_models.dart`)

**Enums**

- `FileRole`: `owner`, `editor`, `viewer`
- `UserPermission`: `view`, `edit`
- `FileType`: `file`, `folder`

**FileTag**

- `String tagName`
- `bool isPersonal`
- Used for role-based tag UI (canonical vs personal).

**FileEntity** (extended for roles and owner)

- Existing: `id`, `name`, `path`, `createdAt`, `isFavorite`, `size`, `fileType`, `folderId`, `tags` (legacy list), `sharedWith`.
- **New/updated:**
  - `List<FileTag>? tags` — replaces/additional to flattened tag names; each tag has `tagName`, `isPersonal`.
  - `String? ownerId`, `String? ownerName`, `String? ownerAvatarUrl`
  - `FileRole? role` — current user’s role for this file.
- **Getter:** `tagNames` — `List<String>` from `tags` for backward compatibility.
- **Return type:** Same `FileEntity`; all new fields are optional for backward compatibility.

**SharedUser**

- `String id`, `String name`, `String email`, `UserPermission? permission`, `String avatarUrl`.
- Used in `FileEntity.sharedWith` and for share UI.

**FolderEntity**

- `id`, `name`, `createdAt`, `fileCount`, `parentId`, `isFavorite`, `files` (list of `FileEntity`).
- Folders in RPC have `is_favorite` for current user.

**FilemanagerItem (sealed)**

- `FileItem(FileEntity file)` | `FolderItem(FolderEntity folder)`.
- Helpers: `id`, `name`, `createdAt`, `isFile`, `isFolder`, `type`.

**PickedFile**

- `name`, `size`, `fileType`, `path?` — for upload input.

---

## 3. Data Layer

### 3.1 Data models

**FilemanagerFileModel** (`lib/view/filemanager/data/models/filemanager_file_model.dart`)

- Mirrors `FileEntity` with: `id`, `name`, `path`, `createdAt`, `isFavorite`, `size`, `fileType`, `tags` (List<FileTag>?), `folderId`, `ownerId`, `ownerName`, `ownerAvatarUrl`, `role`, `sharedWith`.
- **`toEntity()`** → `FileEntity`.
- `fromMap` / `toMap` for serialization; `copyWith` for updates.

**FilemanagerFolderModel** (`lib/view/filemanager/data/models/filemanager_folder_model.dart`)

- `id`, `name`, `parentId`, `createdAt`, `isFavorite`, `fileCount`, `files` (List<FilemanagerFileModel>).
- **`toEntity()`** → `FolderEntity` (maps inner files to entities).

### 3.2 Remote datasource (`FilemanagerRemoteDatasource`)

**Constructor**

- `FilemanagerRemoteDatasource({UserInfoService? userInfoService})`.
- Uses `UserInfoService` for enriching shared users and owner (name, avatar).

**Main methods (return types)**

| Method                                                   | Return type                     | Notes                                                                                                          |
| -------------------------------------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `fetchFoldersFiles()`                                    | `Future<List<FilemanagerItem>>` | RPC `get_user_files(p_user_id)`; parses `folders` + `root_files`; then `_enrichWithUserInfo(list)`.            |
| `getRecentFileIds()`                                     | `Future<List<String>>`          | From `file_activity` (user_id, order activity_at DESC, limit 5).                                               |
| `logFileActivity(fileId)`                                | `Future<void>`                  | RPC `log_file_activity(p_user_id, p_file_id)`.                                                                 |
| `uploadFiles(files, {folderId})`                         | `Future<List<FileEntity>>`      | Storage upload + `files` insert + optional `user_file_folders`; returns entities.                              |
| `deleteFile(fileId)`                                     | `Future<void>`                  | Owner-only: checks `files.user_id == currentUser`; deletes storage then file row.                              |
| `moveFileToFolder(fileId, folderId)`                     | `Future<void>`                  | Upsert `user_file_folders`.                                                                                    |
| `moveFileToRoot(fileId)`                                 | `Future<void>`                  | Delete `user_file_folders` for current user + file.                                                            |
| `createFolder(folderName, {fileIds})`                    | `Future<FolderEntity>`          | Insert folder; optionally upsert `user_file_folders` for fileIds.                                              |
| `deleteFolder(folderId)`                                 | `Future<void>`                  | Delete folder where user owns it.                                                                              |
| `toggleFavorite(entityId, isFolder, currentlyFavorited)` | `Future<void>`                  | Insert/delete in `file_favorites` (file_id or folder_id).                                                      |
| `toggleFavoriteFile(fileId, currentlyFavorited)`         | `Future<void>`                  | Delegates to `toggleFavorite(..., false, ...)`.                                                                |
| `addTag(fileId, tagName, {isPersonal})`                  | `Future<void>`                  | Insert into `file_tags` (file_id, user_id, tag_name, is_personal).                                             |
| `deleteTag(fileId, tagName, {isPersonal})`               | `Future<void>`                  | Delete from `file_tags`; if isPersonal, also eq user_id.                                                       |
| `updateTags(fileId, tags)`                               | `Future<FileEntity>`            | Legacy; re-fetches and returns file (no direct tag replace in DB).                                             |
| `addShareParticipant(fileId, user)`                      | `Future<FileEntity>`            | Owner check; upsert `file_sharing`; re-fetches and returns updated file.                                       |
| `updateSharePermission(fileId, userId, permission)`      | `Future<FileEntity>`            | Update `file_sharing.access_type`; re-fetches file.                                                            |
| `removeShareParticipant(fileId, userId)`                 | `Future<FileEntity>`            | Delete row in `file_sharing`; re-fetches file.                                                                 |
| `fetchUsers()`                                           | `Future<List<SharedUser>>`      | Via `UserInfoService.fetchAllUsers()`; excludes current user; maps to SharedUser (id, name, email, avatarUrl). |

**Parsing**

- **`_fileFromRpc(Map)`** → `FilemanagerFileModel`: reads `role`, `owner_id`, `owner_name`, `tags` as `[{ tag_name, is_personal }]`, `shared_with` as `[{ user_id, name?, access }]` (access → UserPermission).
- **`_parseFileRole(dynamic)`** → `FileRole?` (owner/editor/viewer).
- **`_parseSharedWith(dynamic)`** → `List<SharedUser>?` (user_id, name, permission from access).
- **`_enrichWithUserInfo(List<FilemanagerItem>)`** → enriches in place: for each FileItem, fills shared users’ name/email/avatarUrl from `UserInfoService.fetchUsersByIds`; fills owner name/avatar; for **viewer** files with empty `shared_with`, adds current user to `sharedWith` with name/avatar from user_info (so viewer sees their own row and table shared column).

---

## 4. Repository & Use Cases

### 4.1 FilemanagerRepository (abstract)

- `fetchFiles()` → `Future<List<FilemanagerItem>>`
- `getRecentFileIds()` → `Future<List<String>>`
- `logFileActivity(String fileId)` → `Future<void>`
- `toggleFavoriteFile(String fileId, bool currentlyFavorited)` → `Future<void>`
- `toggleFavoriteFolder(String folderId, bool currentlyFavorited)` → `Future<void>`
- `uploadFiles(List<PickedFile> files, {String? folderId})` → `Future<List<FileEntity>>`
- `deleteFile(String fileId)` → `Future<void>`
- `moveFileToFolder(String fileId, String folderId)` → `Future<void>`
- `moveFileToRoot(String fileId)` → `Future<void>`
- `createFolder(String folderName, {List<String>? fileIds})` → `Future<FolderEntity>`
- `deleteFolder(String folderId)` → `Future<void>`
- `updateTags(String fileId, List<String> tags)` → `Future<FileEntity>`
- `addTag(String fileId, String tagName, {required bool isPersonal})` → `Future<void>`
- `deleteTag(String fileId, String tagName, {required bool isPersonal})` → `Future<void>`
- `addShareParticipant(String fileId, SharedUser user)` → `Future<FileEntity>`
- `updateSharePermission(String fileId, String userId, UserPermission permission)` → `Future<FileEntity>`
- `removeShareParticipant(String fileId, String userId)` → `Future<FileEntity>`
- `fetchUsers()` → `Future<List<SharedUser>>`

### 4.2 FilemanagerRepositoryImpl

- Implements all above; delegates to `FilemanagerRemoteDatasource`; no local DB for file list (optional local cache can be added later).
- **Return types:** Same as interface; share/tag methods return `FileEntity` where datasource returns it after re-fetch.

### 4.3 Use cases (domain/usecases)

- **FetchFilesUsecase** — `call()` → `Future<List<FilemanagerItem>>`
- **GetRecentFileIdsUsecase** — `call()` → `Future<List<String>>`
- **LogFileActivityUsecase** — `call(String fileId)` → `Future<void>`
- **ToggleFavoritesUsecase** — file favorite
- **ToggleFolderFavoriteUsecase** — folder favorite
- **UploadFilesUsecase** — `call(List<PickedFile>, {folderId})` → `Future<List<FileEntity>>`
- **DeleteFileUsecase** — `call(String fileId)` → `Future<void>`
- **DeleteFolderUsecase** — `call(String folderId)` → `Future<void>`
- **CreateFolderUsecase** — `call(String folderName, {fileIds})` → `Future<FolderEntity>`
- **MoveFileToFolderUsecase** / **MoveFileToRootUsecase** — `Future<void>`
- **UpdateTagsUsecase** — `call(String fileId, List<String> tags)` → `Future<FileEntity>`
- **AddTagUsecase** — `call(String fileId, String tagName, {isPersonal})` → `Future<void>`
- **DeleteTagUsecase** — `call(String fileId, String tagName, {isPersonal})` → `Future<void>`
- **AddShareParticipantUsecase** / **UpdateSharePermissionUsecase** / **RemoveShareParticipantUsecase** — return `Future<FileEntity>`
- **FetchUsersUsecase** — `call()` → `Future<List<SharedUser>>`

---

## 5. Common User-Info Layer (Core)

### 5.1 UserInfoEntity (`lib/core/user/user_info_entity.dart`)

- **Fields:** `id`, `email`, `fullName`, `avatarUrl?`, `phoneNumber?`, `dateOfBirth?`, `role?`, `emailVerified`, `phoneVerified`, `createdAt?`, `lastActivity?`, `status?`.
- Represents a row from `public.user_info`.

### 5.2 UserInfoService (`lib/core/user/user_info_service.dart`)

- **Table:** `user_info`.
- **fetchAllUsers()** → `Future<List<UserInfoEntity>>` — select all, order by full_name.
- **fetchUserById(String id)** → `Future<UserInfoEntity?>` — maybeSingle.
- **fetchUsersByIds(List<String> ids)** → `Future<List<UserInfoEntity>>` — inFilter; returns only found users.
- Exported via `lib/core/index.dart` (user_info_index).

---

## 6. Bloc & Injection

### 6.1 FilemanagerInjection (`lib/view/filemanager/presentation/pages/filemanager_injection.dart`)

- **`FilemanagerInjection.createBloc({UserInfoService? userInfoService})`** → `FilemanagerBloc`.
- Builds: `FilemanagerRemoteDatasource`, `FilemanagerRepositoryImpl`, all use cases, and `FilemanagerBloc` with them. View no longer constructs use cases or bloc manually.

### 6.2 FilemanagerBloc events (selected; all in filemanager_event.dart)

- **FilemanagerLoadingEvent** — trigger load.
- **ToggleFavoriteEvent(String fileId)** — file star.
- **DeleteFileEvent(String fileId)** — delete file (owner-only at backend).
- **UploadFilesEvent(List<PickedFile>)** / **UploadFileEvent(String filePath)** — upload.
- **UpdateTagsEvent(String fileId, List<String> tags)** — legacy tag replace.
- **AddTagEvent(String fileId, String tagName, {isPersonal})** — add tag.
- **DeleteTagEvent(String fileId, String tagName, {isPersonal})** — remove tag.
- **AddShareParticipantEvent(fileId, SharedUser)** / **UpdateSharePermissionEvent(fileId, userId, UserPermission)** / **RemoveShareParticipantEvent(fileId, userId)** — sharing.
- **FetchAvailableUsersEvent** — load users for share dropdown.
- **CreateFolderEvent(folderName, {fileIds})** / **DeleteFolderEvent(folderId)** / **ToggleFolderFavoriteEvent(folderId, currentlyFavorited)** — folders.
- **DeleteSelectedEvent(fileIds, folderIds)** — bulk delete selected owner files and folders; emits success/error when done.
- **MoveFileToFolderEvent(fileId, folderId)** / **MoveFileToRootEvent(fileId)** — move.
- **RemoveFileFromFolderEvent(fileId)** — remove file from folder (move to root); state updates immediately via optimistic emit; same logic as MoveFileToRootEvent.
- **LogFileActivityEvent(fileId)** — log view/download.

### 6.3 FilemanagerBloc state

- **FilemanagerLoaded** holds `List<FilemanagerItem> items` (and optionally recent file IDs for Recent section). Loading/error states as needed.
- After share/tag/delete, bloc updates `items` in memory (replace file or remove item).

---

## 7. UI Changes — Share Section (Viewer vs Owner/Editor)

- **Owner:** Full list of shared users; can add, change permission, remove anyone.
- **Editor:** Full list; cannot change own row’s permission; can add/remove others and change others’ permission.
- **Viewer:** Only their **own** row (name + avatar), not “You have view access” or full list. When backend returns empty `shared_with` for viewer, enrichment adds current user to `sharedWith` with name/avatar from `UserInfoService` so the row and table shared column show correctly.
- **Side menu share:** Uses `SideMenuShareSection` / `_ShareSection`; `canChangePermission` and “Add” hidden for viewer; for editor, own row has `canChangePermission: false`.

---

## 8. UI Changes — Properties & Table

- **Properties (“Shared by”):** Side menu shows owner name and avatar when `file.ownerId` / `file.ownerName` / `file.ownerAvatarUrl` are set (enriched from user_info).
- **Table shared column:** For viewer files, enrichment adds current user to `sharedWith` with name/avatar so the shared column shows the viewer’s avatar.
- **Share dialog / “Share with”:** Uses enriched `sharedWith` (name, avatar, email) for display; viewer sees only their own entry in the share section.

---

## 9. UI Changes — Tags

- **SideMenuTagSection** / tags in side menu: Tags shown with role-based styling.
  - **Canonical** (`is_personal == false`): disabled/muted color; only owner/editor can remove.
  - **Personal** (`is_personal == true`): primary color; viewer can add/remove only personal tags; owner/editor can add/remove both.
- **Remove rule:** `_canRemoveTag(tag)` — viewer: only `tag.isPersonal`; owner/editor: any tag.
- **Add rule:** Viewer adds as personal only (`_addAsPersonal == true` when role is viewer).
- **Last-tag remove bug fix:** Replaced Flutter `Chip` with custom **`_TagChip`** (in filemanager_side_menu) with a 44×44 pt remove tap target so the last remaining (personal) tag can be removed reliably by the viewer.

---

## 10. UI Changes — Delete (Owner-Only)

- **Rule:** Only the **owner** of a file can delete it. Shared files (editor/viewer) cannot be deleted by non-owners. Backend already enforces (delete file checks `files.user_id`).
- **Side menu:** `SideMenuBottom` (Delete button) is shown only when `_canDeleteItem(isFile, file, folder)` is true:
  - **File:** `file?.role == FileRole.owner`.
  - **Folder:** always (folder list is current user’s folders).
- **Table row popup:** The “Delete” menu item (and divider above it) is shown only when `(widget.item as FileItem).file.role == FileRole.owner`.
- **Recent section popup:** The “Delete” menu item (and divider above it) is shown only when `widget.file.role == FileRole.owner`.
- Delete option is **removed** from side menu and from both popups for editors and viewers; only owners see Delete.

---

## 11. UI Changes — Table Header: Add to Folder & Bulk Delete

### 11.1 Add to folder (create folder with selected files)

- **When:** User selects one or more **files** (no folder selected). Add-folder icon in table header selector is enabled only when `!hasFolderSelected && selectedFileIds.isNotEmpty`.
- **Disabled when:** Any selected item is a folder (no folder inside folder).
- **Flow:** Tap add-folder icon → dialog “New folder” with name field → Create: dispatches **CreateFolderEvent(folderName, fileIds: selectedFileIds)**. Backend: insert folder, then upsert `user_file_folders` for each fileId (per FRONTEND_QUERIES_GUIDE).
- **Bloc:** After create, state is updated so (1) existing FileItems in state get **folderId = new folder.id** (files disappear from root, show inside folder), (2) new **FolderItem** is appended. Success toast via **FilemanagerSuccessActionState('Folder created')**; error toast on failure.
- **Widgets:** `TableHeaderSelector` has `hasFolderSelected`, `selectedFileIds`, `onAddToFolder`; `file_manager_table` implements `_onAddToFolderTap()` and the name dialog.

### 11.2 Bulk delete (table header trash)

- **When:** User has selection and taps trash icon in table header. **DeleteSelectedEvent(fileIds, folderIds)** is used; only **owner** files and user’s folders are deletable (`_deletableFileIds` = selected files where `file.role == FileRole.owner`).
- **Confirmation dialog:** Shows “You are about to delete: X file(s), Y folder(s) (containing Z file(s)). This action cannot be undone.” Cancel / Delete. Dialog **does not close** until delete completes, an error occurs, or user cancels. While deleting, dialog shows loading and “Deleting…”.
- **Bloc:** **`_deleteSelectedEvent`** — for each file id (excluding files inside folders being deleted), calls `deleteFileUsecase`; for each folder id, calls `deleteFolderUsecase`; then builds new items list (removes deleted files, deleted folders, and files whose folderId was deleted). Emits **FilemanagerSuccessActionState('Deleted')** then updated **FilemanagerLoaded**; on error emits **FilemanagerErrorActionState** and restores previous items.
- **View:** `BlocListener` in dialog listens for **FilemanagerActionState** and pops dialog; toasts for success/error are shown by `filemanager_view` BlocConsumer. Selection is cleared when dialog closes.

---

## 12. UI Changes — Remove from Folder & Immediate List Update

### 12.1 Remove from folder

- **Table row popup:** When file is inside a folder (`file.folderId != null`), a **“Remove from folder”** option is shown. Tap dispatches **RemoveFileFromFolderEvent(fileId)** (table_data_row uses this; MoveFileToRootEvent still supported and delegates to same handler).
- **Bloc:** **`_removeFileFromFolder(fileId, emit)`** (shared by **RemoveFileFromFolderEvent** and **MoveFileToRootEvent**): (1) **Optimistic update** — map items, set that file’s **folderId = null**, **emit** new state immediately so UI updates; (2) await **moveFileToRootUsecase.call(fileId)**; (3) on error, emit **FilemanagerErrorActionState** and restore previous items.
- **Backend:** Delete from `user_file_folders` for current user + file (per guide).

### 12.2 Table list reflects state immediately

- **Issue:** The table kept a cached **`_filtered`** list updated only in `didUpdateWidget`; the folder view could still show a file after “Remove from folder” until the next sync.
- **Fix:** Replaced cached **`_filtered`** with a getter **`_effectiveFiltered`** = `FileFilterService.applyFilters(_displayItems, _filterController.filterState)`. **`_displayItems`** is already derived from **`widget.items`** (and `_currentFolder`). So every build uses the latest **widget.items**; no stale cache.
- **Result:** When a file is removed from folder, bloc emits optimistic state (file’s folderId = null) → parent passes new items → table’s **`_displayItems`** / **`_folderFileItems`** no longer include that file → **`_effectiveFiltered`** and **`_pageItems`** update → file disappears from folder view and appears at root when user navigates back.

---

## 13. Bloc State — Success / Error Toasts

- **FilemanagerSuccessActionState(message)** — emitted after successful **CreateFolderEvent** and **DeleteSelectedEvent**; **filemanager_view** BlocConsumer listener shows success toast with `state.message`.
- **FilemanagerErrorActionState(message)** — already used; error toast with description. **buildWhen** keeps **FilemanagerActionState** from triggering a full rebuild so UI doesn’t flicker; listener still runs for toasts.

---

## 14. File / Widget Reference Summary

| Area              | File(s)                                                                                                 | Notes                                                                                      |
| ----------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Guide             | `FRONTEND_QUERIES_GUIDE.md`                                                                             | DB operations, triggers, RPC usage                                                         |
| Domain entities   | `domain/entities/files_models.dart`                                                                     | FileEntity, FileTag, FileRole, SharedUser, FolderEntity, FilemanagerItem                   |
| Data models       | `data/models/filemanager_file_model.dart`, `filemanager_folder_model.dart`                              | RPC → entity mapping                                                                       |
| Remote datasource | `data/datasources/filemanager_remote_datasource.dart`                                                   | RPC, enrichment, all API calls                                                             |
| Repository        | `domain/repositories/filemanager_repository.dart`, `data/repositories/filemanager_repository_impl.dart` | Contract and impl                                                                          |
| Use cases         | `domain/usecases/*.dart`                                                                                | One per operation; return types as above                                                   |
| User info         | `core/user/user_info_entity.dart`, `user_info_service.dart`, `core/index.dart`                          | Project-wide user fetch                                                                    |
| Bloc              | `presentation/bloc/filemanager_bloc.dart`, `filemanager_event.dart`                                     | Events (incl. DeleteSelectedEvent, RemoveFileFromFolderEvent), state, success/error toasts |
| Injection         | `presentation/pages/filemanager_injection.dart`                                                         | `createBloc()`                                                                             |
| Side menu         | `presentation/widgets/filemanager_side_menu.dart`                                                       | Info, Properties, Share, Tags, Delete (owner-only), \_TagChip                              |
| Share section     | `presentation/widgets/side_menu/side_menu_share_section.dart`, share_file_dialog_runner                 | Viewer single row; owner/editor full list                                                  |
| Tags              | `presentation/widgets/side_menu/side_menu_tag_section.dart`                                             | Role-based add/remove and colors                                                           |
| Table header      | `presentation/widgets/table/table_widgets/table_header_selector.dart`                                   | Add-folder (when only files selected), bulk delete (trash); onAddToFolder, onDelete        |
| Table             | `presentation/widgets/file_manager_table.dart`                                                          | \_effectiveFiltered getter (reactive list); add-folder dialog; delete confirm dialog       |
| Table row         | `presentation/widgets/table/table_widgets/table_data_row.dart`                                          | Popup: Remove from folder (when in folder), Delete only for owner                          |
| Recent            | `presentation/widgets/sections/recent_section.dart`                                                     | Popup: Delete only for owner                                                               |

---

_End of changelog. For RPC/DB details see `FRONTEND_QUERIES_GUIDE.md`._
