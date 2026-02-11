// injection: single place to create bloc and dependencies
export 'presentation/pages/filemanager_injection.dart';

//data
export 'data/test_data.dart';

export 'data/datasources/filemanager_local_datasource.dart';
export 'data/datasources/filemanager_remote_datasource.dart';
export 'data/repositories/filemanager_repository_impl.dart';
export 'data/models/filemanager_file_model.dart';
export 'data/models/filemanager_folder_model.dart';

//--------------------------------------------------------------------

//domain
//domain/repositories
export 'domain/repositories/filemanager_repository.dart';
export 'domain/repositories/filter_repository.dart';

//domain/entities
export 'domain/entities/files_models.dart';
export 'domain/entities/filter_models.dart';

//domain/usecases
export 'domain/usecases/add_share_participant_usecase.dart';
export 'domain/usecases/add_tag_usecase.dart';
export 'domain/usecases/create_folder_usecase.dart';
export 'domain/usecases/delete_file_usecase.dart';
export 'domain/usecases/delete_folder_usecase.dart';
export 'domain/usecases/delete_tag_usecase.dart';
export 'domain/usecases/fetch_files_usecase.dart';
export 'domain/usecases/fetch_users_usecase.dart';
export 'domain/usecases/get_recent_file_ids_usecase.dart';
export 'domain/usecases/log_file_activity_usecase.dart';
export 'domain/usecases/move_file_to_folder_usecase.dart';
export 'domain/usecases/move_file_to_root_usecase.dart';
export 'domain/usecases/remove_share_participant_usecase.dart';
export 'domain/usecases/toggle_favorites_usecase.dart';
export 'domain/usecases/toggle_folder_favorite_usecase.dart';
export 'domain/usecases/update_share_permission_usecase.dart';
export 'domain/usecases/update_tags_usecase.dart';
export 'domain/usecases/upload_files_usecase.dart';
//--------------------------------------------------------------------

//presentation
//presentation/bloc
export 'presentation/bloc/filemanager_bloc.dart';

//presentation/controllers
export 'presentation/controllers/filter_controller.dart';

//presentation/widgets/filter
export 'presentation/widgets/filter/filter_widget/date_range_filter_widget.dart';
export 'presentation/widgets/filter/filter_widget/file_type_filter_widget.dart';
export 'presentation/widgets/filter/filter_widget/filter_status_widget.dart';
export 'presentation/widgets/filter/filter_widget/search_filter_widget.dart';
export 'presentation/widgets/filter/filter_widget/view_toggle_widget.dart';

//presentation/widgets/filter/date_filters
export 'presentation/widgets/filter/date_filters/quick_date_options.dart';
export 'presentation/widgets/filter/date_filters/selected_range_display.dart';
export 'presentation/widgets/filter/date_filters/date_selector_button.dart';

//presentation/widgets/table
export 'presentation/widgets/table/table_data_row.dart';
export 'presentation/widgets/table/table_header_row.dart';
export 'presentation/widgets/table/table_header_selector.dart';
export 'presentation/widgets/table/table_paginator.dart';
export 'presentation/widgets/table/table_row_shared_avatar.dart';
export 'presentation/widgets/filemanager_side_menu.dart';

//presentation/widgets/table/side_menu
export 'presentation/widgets/side_menu/share_file_dialog_runner.dart';
export 'presentation/widgets/side_menu/share_file_dialog.dart';
export 'presentation/widgets/side_menu/side_menu_bottom.dart';
export 'presentation/widgets/side_menu/side_menu_share_section.dart';
export 'presentation/widgets/side_menu/side_menu_popup.dart';
export 'presentation/widgets/side_menu/side_menu_sections.dart';

//presentation/widgets
export 'presentation/widgets/sections/all_favorites_section.dart';
export 'presentation/widgets/file_manager_table.dart';
export 'presentation/widgets/sections/file_manager_filter_section.dart';
export 'presentation/widgets/file_manager_header.dart';
export 'presentation/widgets/dialogs/upload_files_dialog.dart';
export 'presentation/widgets/favorite_star_button.dart';
export 'presentation/widgets/sections/favorites_section.dart';
export 'presentation/widgets/sections/recent_section.dart';
export 'presentation/widgets/sections/storage_section.dart';
