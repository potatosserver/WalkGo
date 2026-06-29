// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get walkgo => 'WalkGo';

  @override
  String get settings_tooltip => '設定';

  @override
  String get status_card_title => '狀態';

  @override
  String get status_running => '服務運行中...';

  @override
  String get status_ready_to_start => '服務已準備就緒。';

  @override
  String get status_stopped => '服務已停止。';

  @override
  String next_run_at(String time) {
    return '下次運行於 $time';
  }

  @override
  String get next_run_title => '下次執行於';

  @override
  String get next_run_pending => '等待下次運行...';

  @override
  String get this_run => '本次步數';

  @override
  String get session_steps => '本次步數';

  @override
  String get remaining_steps_today => '今日剩餘步數';

  @override
  String get parameter_settings => '參數設定';

  @override
  String get base_steps => '基礎步數';

  @override
  String get offset_steps => '偏移步數';

  @override
  String get interval_minutes => '間隔（分鐘）';

  @override
  String get actions => '操作';

  @override
  String get start_auto_mode => '啟動自動模式';

  @override
  String get stop_auto_mode => '停止自動模式';

  @override
  String get settings => '設定';

  @override
  String get app_settings => '應用程式設定';

  @override
  String get theme => '主題';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get system => '系統';

  @override
  String get language => '語言';

  @override
  String get english => '英文';

  @override
  String get chinese => '中文';

  @override
  String get advanced_parameters => '進階參數';

  @override
  String get auto_pause_title => '自動暫停服務';

  @override
  String get auto_pause_description => '當寫入的步數達到設定的閾值時，自動暫停服務。';

  @override
  String get auto_pause_steps_label => '自動暫停步數閾值';

  @override
  String get write_logs => '步數日誌';

  @override
  String get logs_cleared => '日誌已清除。';

  @override
  String get clear_all_logs => '清除所有日誌';

  @override
  String get clear_logs_confirm_title => '確認清除日誌';

  @override
  String get clear_logs_confirm_content => '確定要清除所有步數日誌嗎？此操作無法復原。';

  @override
  String get no_logs => '尚無日誌。';

  @override
  String get log_type_manual => '手動';

  @override
  String get log_type_automatic => '自動';

  @override
  String get offset_settings_title => '隨機化步數';

  @override
  String get offset_settings_subtitle => '啟用步數隨機偏移';

  @override
  String log_write_success(String totalSteps) {
    return '寫入後的總步數：$totalSteps';
  }

  @override
  String log_write_success_auto(String steps) {
    return '自動寫入 $steps 步。';
  }

  @override
  String log_write_success_manual(String steps) {
    return '手動寫入 $steps 步。';
  }

  @override
  String get start_auto_mode => '啟動自動服務';

  @override
  String get stop_auto_mode => '停止自動服務';

  @override
  String get write_fail_check_log => '寫入步數失敗，請檢查您的健康應用程式或系統設定。';

  @override
  String write_error(String error) {
    return '寫入步數時發生錯誤：$error';
  }

  @override
  String get background_service_start => '背景服務已啟動。';

  @override
  String get background_service_stop => '背景服務已停止。';

  @override
  String get notification_update_title => '步數更新';

  @override
  String automatic_write_success(String steps) {
    return '成功自動寫入 $steps 步';
  }

  @override
  String get clear_data_button => '清除所有應用程式資料';

  @override
  String get clear_data_confirm_title => '確認刪除';

  @override
  String get clear_data_confirm_content =>
      '此操作將永久刪除所有應用程式資料，包括您的設定和日誌。此操作無法復原。';

  @override
  String get data_cleared_success => '應用程式資料已成功清除。';

  @override
  String get app_will_restart => '應用程式即將重新啟動。';

  @override
  String get auto_pause_subtitle => '當寫入一定步數後自動停止服務。';

  @override
  String get auto_pause_steps_hint => '在一次工作階段中寫入這麼多步數後，服務將會停止。';

  @override
  String get app_reset => '重設應用程式';

  @override
  String get app_reset_desc => '此操作將清除所有應用程式資料和設定，將應用程式還原至初始狀態。';

  @override
  String get offset_steps_hint => '步數將會在此值的正負範圍內隨機化。';

  @override
  String get permission_denied_title => '權限已被永久拒絕';

  @override
  String get permission_denied_content =>
      '您已永久刪絕一項必要權限。請前往您裝置上此應用程式的設定頁面，並手動授予權限以確保其正常運作。';

  @override
  String get open_settings => '開啟設定';

  @override
  String get auto_pause_notification_title => '服務已自動暫停';

  @override
  String auto_pause_notification_content_with_steps(String steps) {
    return '因為已達成 $steps 步的階段性目標，服務已自動暫停。';
  }

  @override
  String get steps_written_this_session => '累積步數';

  @override
  String get auto_pause_remaining => '剩餘步數';

  @override
  String get start_service_fail => '啟動服務失敗。';

  @override
  String get stop_service_fail => '停止服務失敗。';

  @override
  String get param_settings => '參數設定';

  @override
  String get interval => '間隔（分鐘）';

  @override
  String get language_settings => '語言設定';

  @override
  String get about => '關於';

  @override
  String get system_theme => '系統主題';

  @override
  String get light_theme => '淺色主題';

  @override
  String get dark_theme => '深色主題';

  @override
  String get system_language => '系統語言';

  @override
  String get traditional_chinese => '繁體中文';

  @override
  String get about_walkgo => '關於 WalkGo';

  @override
  String get about_walkgo_content => '此應用程式可幫助您將步數記錄到您的健康資料中。';

  @override
  String get welcome_to_walkgo => '歡迎使用 WalkGo';

  @override
  String get welcome_message => '在開始之前，請授予必要的權限。';

  @override
  String get get_started => '開始使用';

  @override
  String get cancel => '取消';

  @override
  String get permission_health_title => '健康權限';

  @override
  String get permission_health_desc => '需要此權限才能將步數寫入您的健康資料。';

  @override
  String get permission_activity_title => '活動識別權限';

  @override
  String get permission_activity_desc => '需要此權限才能識別您的身體活動並準確記錄步數。';

  @override
  String get permission_notification_title => '通知權限';

  @override
  String get permission_notification_desc => '需要此權限才能向您傳送有關您的進度和應用程式狀態的通知。';

  @override
  String get permission_battery_title => '電池優化權限';

  @override
  String get permission_battery_desc => '需要此權限才能允許應用程式在背景中運行。';

  @override
  String get grant_permission => '授予權限';

  @override
  String get setup_complete => '設定完成';

  @override
  String get next_step => '下一步';

  @override
  String get rerun_setup => '查看歡迎頁面';

  @override
  String get close => '關閉';

  @override
  String get confirm => '確認';

  @override
  String get complete => '完成';

  @override
  String session_total_steps_template(Object steps) {
    return '本次工作階段總步數：$steps';
  }

  @override
  String get manual_write_button_text => '手動寫入一次';

  @override
  String get manual_steps_label => '手動步數';

  @override
  String get manual_steps_hint => '手動增加特定數量的步數。';

  @override
  String get auto_pause_steps_label => '自動暫停閾值';

  @override
  String get auto_pause_steps_label_hint => '在一次工作階段中寫入這麼多步數後，服務將會停止。';

  @override
  String get notification_service_running => '服務運行中';

  @override
  String notification_next_run(String time) {
    return '下次寫入於: $time';
  }

  @override
  String notification_steps_written(String steps) {
    return '已寫入 $steps 步';
  }

  @override
  String get notification_channel_id => 'WalkGo 服務';

  @override
  String get notification_channel_desc => '用於 WalkGo 背景服務的通知';

  @override
  String get status_stopped => '服務已停止';

  @override
  String get status_ready_to_start => '準備就緒，等待您開啟自動模式。';

  @override
  String get notification_steps_written_title => '成功寫入步數';

  @override
  String get manual_write_initiated => '手動寫入已啟動。';

  @override
  String get manual_write_button_text => '手動寫入一次';

  @override
  String manual_write_success_feedback(String steps) {
    return '已手動寫入 $steps 步';
  }

  @override
  String get auto_service_started => '自動服務已啟動';

  @override
  String get auto_service_stopped => '自動服務已停止';

  @override
  String get auto_mode_running_lock_warning => '自動模式運行中，無法修改參數。';

  @override
  String get error_base_less_than_offset => '基礎步數必須大於隨機偏移步數。';

  @override
  String get error_threshold_too_low => '自動暫停閾值必須大於單次最大步數（基礎 + 偏移）。';

  @override
  String today_steps_total(String steps) {
    return '今日總計：$steps 步';
  }

  @override
  String get developer_label => '作者 : 卓稟鈞 (Andrew Cho)';

  @override
  String get github_source_code => 'GitHub 原始碼';

  @override
  String version_label(String version) {
    return '版本：$version';
  }

  @override
  String get check_for_updates => '檢查更新';

  @override
  String get update_available => '發現新版本';

  @override
  String update_available_desc(String version) {
    return '新版本 $version 已發佈。您要現在更新嗎？';
  }

  @override
  String get updating => '正在更新...';

  @override
  String downloading_apk(String apkName) {
    return '正在下載: $apkName';
  }

  @override
  String get verifying_integrity => '正在核對檔案完整性...';

  @override
  String update_failed(String error) {
    return '更新失敗：$error';
  }

  @override
  String get latest_version_installed => '目前已是最新版本。';

  @override
  String get no_updates_available => '沒有可用的更新。';

  @override
  String get invalid_architecture => '找不到適合您裝置架構的更新檔。';

  @override
  String get hash_mismatch => '檔案完整性校驗失敗，下載可能已損壞。';

  @override
  String get checking_for_updates => '正在檢查更新...';

  @override
  String get update_check_failed => '檢查更新失敗，請檢查您的網路連線。';

  @override
  String get manual_download => '手動下載';

  @override
  String get auto_update => '自動更新';

  @override
  String get manual_download_title => '手動下載';

  @override
  String get manual_download_prompt => '請下載名為：';

  @override
  String manual_download_description(String architecture) {
    return '您的裝置架構為：$architecture。請下載名為：';
  }

  @override
  String manual_download_filename(String filename) {
    return '檔案名稱：$filename';
  }

  @override
  String get copy_link => '複製連結';

  @override
  String get go_to_download => '前往下載頁面';

  @override
  String get link_copied => '連結已複製到剪貼簿';

  @override
  String get view_release_notes => '查看版本資訊';

  @override
  String get release_notes => '版本資訊';

  @override
  String get download_latest_version => '重新安裝應用程式';

  @override
  String get unknown_error => '發生未知錯誤。';

  @override
  String get update_ready_to_install => '更新已準備好安裝。';

  @override
  String get retry => '重試';

  @override
  String get install => '安裝';

  @override
  String get download => '下載';

  @override
  String get starting_installation => '正在開始安裝...';

  @override
  String get notification_start_button => '啟動';

  @override
  String get notification_stop_button => '停止';

  @override
  String get view_on_google_play => '在 Google Play 上查看';

  @override
  String get skip_permission_title => '權限略過警告';

  @override
  String get skip_permission_description =>
      '略過此權限可能會影響應用程式的穩定性和背景同步。系統可能會強制停止應用程式，導致計步同步中斷。';

  @override
  String get skip_permission_confirm => '確認略過';

  @override
  String get skip_permission_label => '暫時略過';

  @override
  String get skip_notification_warning => '通知權限警告';

  @override
  String get skip_notification_desc =>
      '如果您略過通知權限，前台服務的優先級將會降低，系統可能隨時在背景強制停止應用程式，從而中斷計步同步。';

  @override
  String get skip_battery_warning => '電池優化警告';

  @override
  String get skip_battery_desc =>
      '如果您略過電池優化，Android 系統將在手機進入休眠模式時暫停同步任務，導致無法即時將步數寫入健康數據。';

  @override
  String get skip_permission_cancel => '取消';
}
