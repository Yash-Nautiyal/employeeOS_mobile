# File Manager — Frontend Queries Guide

---

## DATA LOADING

**Load files + folders:**
```sql
SELECT get_user_files(current_user_id)
→ Returns { folders, root_files }
```

**Load recent files:**
```sql
SELECT file_id FROM file_activity
WHERE user_id = current_user_id
ORDER BY activity_at DESC LIMIT 10
→ Map IDs against already-loaded files from get_user_files
```

---

## FILE ACTIONS

**Upload file:**
```sql
INSERT INTO files (user_id, file_name, file_type, file_size, storage_url)
→ trg_file_upload_activity fires → activity updated for uploader
```
If uploading into a folder:
```sql
INSERT INTO user_file_folders (user_id, file_id, folder_id)
```

**Move file into folder (any user — owner or shared):**
```sql
INSERT INTO user_file_folders (user_id, file_id, folder_id)
ON CONFLICT (user_id, file_id) DO UPDATE SET folder_id = new_folder_id
→ No trigger. Per-user. Doesn't affect anyone else.
```

**Move file to root:**
```sql
DELETE FROM user_file_folders
WHERE user_id = current_user_id AND file_id = x
→ No trigger.
```

**Delete file (owner only):**
```sql
DELETE FROM files WHERE id = x
→ CASCADE: file_sharing deleted
  → trg_share_revoke_cleanup fires per shared user
    → their user_file_folders entries removed
    → their personal tags removed
    → their favorites removed
    → their activity removed
→ CASCADE: file_tags deleted (all users, all types)
→ CASCADE: file_activity deleted (all users)
→ CASCADE: file_favorites deleted (all users)
→ CASCADE: user_file_folders deleted (all users)
```

**Favorite file:**
```sql
INSERT INTO file_favorites (user_id, file_id)
→ No trigger.
```

**Unfavorite file:**
```sql
DELETE FROM file_favorites
WHERE user_id = current_user_id AND file_id = x
→ No trigger.
```

**View / Download file:**
```sql
SELECT log_file_activity(current_user_id, file_id)
→ Upserts activity for current user only. Manual — no DB operation to trigger on.
```

---

## FOLDER ACTIONS

**Create folder:**
```sql
INSERT INTO folders (user_id, folder_name, parent_id)
→ parent_id = NULL for root-level folder.
→ No trigger.
```

**Delete folder:**
```sql
DELETE FROM folders WHERE id = x
→ trg_folder_delete_files fires BEFORE DELETE
  → Finds files where file owner = folder owner AND file placed in this folder
  → DELETE FROM files for those files
    → Full cascade per file (same chain as "Delete file" above)
  → Shared files other users placed here? NOT deleted — they don't own them
→ Folder row deleted
→ CASCADE: user_file_folders rows with this folder_id removed
  → Any user who had placed a file in this folder — that file moves to their root
```

**Favorite folder:**
```sql
INSERT INTO file_favorites (user_id, folder_id)
→ No trigger.
```

**Unfavorite folder:**
```sql
DELETE FROM file_favorites
WHERE user_id = current_user_id AND folder_id = x
→ No trigger.
```

---

## SHARING ACTIONS

**Share file (owner or editor):**
```sql
INSERT INTO file_sharing (file_id, shared_by, shared_with, access_type)
VALUES (file_id, current_user_id, recipient_id, 'view' or 'edit')
→ trg_file_share_activity fires
  → activity updated for shared_by (sharer)
  → activity updated for shared_with (recipient)
```

**Change share access (owner or editor):**
```sql
UPDATE file_sharing SET access_type = 'edit' or 'view'
WHERE file_id = x AND shared_with = target_user_id
→ No trigger. Administrative action.
```

**Revoke share access (owner or editor):**
```sql
DELETE FROM file_sharing
WHERE file_id = x AND shared_with = target_user_id
→ trg_share_revoke_cleanup fires
  → DELETE user_file_folders WHERE user_id = revoked_user AND file_id = x
  → DELETE file_tags WHERE user_id = revoked_user AND file_id = x AND is_personal = true
  → DELETE file_favorites WHERE user_id = revoked_user AND file_id = x
  → DELETE file_activity WHERE user_id = revoked_user AND file_id = x
```
**Safety:** Owner is never in `file_sharing` — no row exists to delete, so structurally impossible to revoke owner.

**Editor shares further:**
```sql
INSERT INTO file_sharing (file_id, shared_by, shared_with, access_type)
VALUES (file_id, editor_user_id, new_recipient_id, 'view' or 'edit')
→ Same trigger. shared_by = editor's ID, not owner's.
```

---

## TAG ACTIONS

**Add tag — owner or editor (canonical):**
```sql
INSERT INTO file_tags (file_id, user_id, tag_name, is_personal)
VALUES (file_id, current_user_id, 'finance', false)
→ trg_tag_add_activity fires → creator's activity updated
→ Tag visible to all users who can see this file
```

**Add tag — viewer (personal):**
```sql
INSERT INTO file_tags (file_id, user_id, tag_name, is_personal)
VALUES (file_id, current_user_id, 'my-review', true)
→ trg_tag_add_activity fires → viewer's activity updated
→ Tag visible only to this viewer
```

**Delete tag — owner or editor (canonical):**
```sql
DELETE FROM file_tags
WHERE file_id = x AND tag_name = 'finance' AND is_personal = false
→ No trigger (can't identify who deleted)
→ Manual: SELECT log_file_activity(current_user_id, file_id)
→ Tag removed for everyone
```

**Delete tag — viewer (personal):**
```sql
DELETE FROM file_tags
WHERE file_id = x AND user_id = current_user_id AND tag_name = 'my-review' AND is_personal = true
→ trg_tag_delete_activity fires → viewer's activity updated
→ Only affects this viewer
```
