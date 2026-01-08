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
  String get settings => '設定';

  @override
  String get theme => '主題';

  @override
  String get system_theme => '跟隨系統';

  @override
  String get light_theme => '淺色模式';

  @override
  String get dark_theme => '深色模式';

  @override
  String get language_settings => '語言';

  @override
  String get english => '英語';

  @override
  String get simplified_chinese => '簡體中文';

  @override
  String get traditional_chinese => '繁體中文';

  @override
  String get logs_cleared => '日誌已清除';

  @override
  String get about_walkgo => '關於 WalkGo';

  @override
  String get about_walkgo_content => '本應用可以幫助您自動記錄步數，以達成您的健康目標。\n\n版本: 1.0.0';

  @override
  String get close => '關閉';

  @override
  String get write_logs => '寫入日誌';

  @override
  String get clear_all_logs => '清除所有日誌';

  @override
  String get no_logs => '暫無日誌';

  @override
  String get about => '關於';

  @override
  String get rerun_setup => '重新執行歡迎與設定流程';

  @override
  String get rerun_setup_confirm_title => '確認操作';

  @override
  String get rerun_setup_confirm_content =>
      '您確定要重新執行設定流程嗎？這將會讓您返回到歡迎頁面，並需要重新授予權限。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get welcome_to_walkgo => '歡迎使用 WalkGo';

  @override
  String get welcome_message => '本應用可以幫助您自動將步數寫入您的健康數據，讓您輕鬆達成每日目標。';

  @override
  String get get_started => '開始使用';

  @override
  String get permission_health_title => '健康數據存取權限';

  @override
  String get permission_health_desc => 'WalkGo 需要存取您的健康數據以讀取和寫入步數，這是應用的核心功能。';

  @override
  String get permission_activity_title => '身體活動權限';

  @override
  String get permission_activity_desc => '在某些安卓版本上，此權限能讓應用在後台更精確地執行以偵測您的活動。';

  @override
  String get permission_notification_title => '通知權限';

  @override
  String get permission_notification_desc =>
      '我們需要顯示通知以維持後台服務的持續執行，並在步數成功寫入時通知您。';

  @override
  String get permission_battery_title => '停用電池優化';

  @override
  String get permission_battery_desc =>
      '為確保應用能在後台可靠執行而不被系統終止，請為 WalkGo 停用電池優化。';

  @override
  String get grant_permission => '授予權限';

  @override
  String get next_step => '下一步';

  @override
  String get setup_complete => '完成設定';

  @override
  String get param_settings => '參數設定';

  @override
  String get base_steps => '基礎步數';

  @override
  String get interval => '時間間隔（分鐘）';

  @override
  String get advanced_settings => '進階設定';

  @override
  String get manual_write_once => '手動寫入一次';

  @override
  String get start_auto_steps => '啟動自動服務';

  @override
  String get stop_auto_steps => '停止自動服務';

  @override
  String get status_running => '服務正在執行...';

  @override
  String get status_ready_to_start => '服務已就緒，可隨時啟動。';

  @override
  String get steps_gt_zero => '步數必須大於 0。';

  @override
  String manual_write_success(Object steps) {
    return '成功寫入 $steps 步。';
  }

  @override
  String get write_fail_check_log => '寫入步數失敗。請檢查您的健康應用或系統設定。';

  @override
  String write_error(Object error) {
    return '寫入步數時發生錯誤：$error';
  }

  @override
  String get background_service_start => '後台服務已啟動。';

  @override
  String get background_service_stop => '後台服務已停止。';

  @override
  String get notification_update_title => '步數更新';

  @override
  String automatic_write_success(Object steps) {
    return '已自動寫入 $steps 步。';
  }

  @override
  String get clear_data_button => '清除所有應用數據';

  @override
  String get clear_data_confirm_title => '確認刪除資料';

  @override
  String get clear_data_confirm_content => '這將永久刪除所有應用資料，包括您的設定和日誌。此操作無法撤銷。';

  @override
  String get data_cleared_success => '應用資料已成功清除。';

  @override
  String get app_will_restart => '應用程式現在將重新啟動。';

  @override
  String get auto_pause_title => '自動暫停服務';

  @override
  String get auto_pause_subtitle => '當寫入的步數達到一定數量時，自動停止服務。';

  @override
  String get auto_pause_steps_label => '自動暫停步數閾值';

  @override
  String get auto_pause_steps_hint => '在一次服務會話中寫入這麼多步數後，服務將會停止。';

  @override
  String get offset_settings_title => '隨機化步數';

  @override
  String get offset_settings_subtitle => '為步數啟用隨機偏移';

  @override
  String get app_reset => '重設應用';

  @override
  String get app_reset_desc => '此操作將清除所有應用資料和設定，將應用還原到初始狀態。';

  @override
  String get offset_steps_hint => '步數將在此值的正負範圍內隨機浮動。';

  @override
  String get permission_denied_title => '權限被永久拒絕';

  @override
  String get permission_denied_content =>
      '您已經永久拒絕了一個必要的權限。請前往您裝置的系統設定頁面，手動為本應用開啟該權限，以確保其正常運作。';

  @override
  String get open_settings => '開啟設定';

  @override
  String get auto_pause_notification_title => '服務已自動暫停';

  @override
  String get auto_pause_notification_content => '步數寫入服務已自動暫停，因為已達成此次會話的目標。';

  @override
  String get settings_tooltip => '開啟設定';

  @override
  String get log_type_manual => '手動';

  @override
  String get log_type_automatic => '自動';

  @override
  String get start_service_fail => '啟動服務失敗，請重試。';

  @override
  String get stop_service_fail => '停止服務失敗，請重試。';

  @override
  String get status_stopped => '服務已停止。';

  @override
  String get next_run_pending => '等待下一次執行。';

  @override
  String next_run_at(Object time) {
    return '下次執行時間：$time';
  }
}
