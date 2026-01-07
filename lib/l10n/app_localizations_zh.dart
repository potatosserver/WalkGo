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
  String get status_running => '背景服務運行中，正在自動寫入步數...';

  @override
  String get status_ready_to_start => '準備開始自動寫入步數。';

  @override
  String manual_write_success(Object steps) {
    return '手動寫入成功：$steps 步';
  }

  @override
  String automatic_write_success(Object steps) {
    return '自動寫入成功：$steps 步';
  }

  @override
  String get steps_gt_zero => '步數必須大於 0。';

  @override
  String get write_fail_check_log => '寫入失敗，請檢查日誌以獲取更多資訊。';

  @override
  String write_error(Object error) {
    return '寫入時發生錯誤：$error';
  }

  @override
  String get background_service_start => '背景服務已啟動。';

  @override
  String get background_service_stop => '背景服務已停止。';

  @override
  String get param_settings => '參數設定';

  @override
  String get base_steps => '基礎步數';

  @override
  String get base_steps_hint => '每次自動寫入的基礎步數。';

  @override
  String get offset_steps => '浮動步數';

  @override
  String get offset_steps_hint => '將在基礎步數上隨機增減一個介於 -offset 和 +offset 之間的值。';

  @override
  String get interval => '間隔（分鐘）';

  @override
  String get interval_hint => '自動寫入步數的時間間隔。';

  @override
  String get manual_write_once => '手動寫入一次（測試）';

  @override
  String get stop_auto_steps => '停止自動步數';

  @override
  String get start_auto_steps => '啟動背景自動步數';

  @override
  String get notification_channel_name => 'WalkGo 背景服務';

  @override
  String get notification_channel_description => 'WalkGo 正在後台模擬步數...';

  @override
  String get notification_title => 'WalkGo';

  @override
  String get notification_content => '背景服務正在運行';

  @override
  String get notification_update_title => 'WalkGo 步數更新';

  @override
  String get theme => '外觀';

  @override
  String get system_theme => '跟隨系統';

  @override
  String get light_theme => '淺色模式';

  @override
  String get dark_theme => '深色模式';

  @override
  String get logs_cleared => '日誌已清除。';

  @override
  String get about_walkgo => '關於 WalkGo';

  @override
  String get about_walkgo_content => '本應用程式旨在幫助使用者自動記錄步數，以達成其健康目標。\n\n版本：1.0.0';

  @override
  String get close => '關閉';

  @override
  String get write_logs => '寫入日誌';

  @override
  String get clear_all_logs => '清除所有日誌';

  @override
  String get no_logs => '尚無日誌。';

  @override
  String get about => '關於';

  @override
  String get rerun_setup => '重新運行歡迎與設定流程';

  @override
  String get rerun_setup_confirm_title => '確認操作';

  @override
  String get rerun_setup_confirm_content =>
      '您確定要重新運行設定流程嗎？這將會讓您返回歡迎畫面，並需要重新授予權限。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get welcome_to_walkgo => '歡迎使用 WalkGo';

  @override
  String get welcome_message => '本應用能幫助您自動將步數寫入您的健康數據，讓您輕鬆達成每日目標。';

  @override
  String get get_started => '開始使用';

  @override
  String get permission_health_title => '健康數據存取權限';

  @override
  String get permission_health_desc => 'WalkGo 需要存取您的健康數據以讀寫步數，這是應用程式的核心功能。';

  @override
  String get permission_activity_title => '體能活動權限';

  @override
  String get permission_activity_desc =>
      '在某些 Android 版本上，此權限能讓應用在背景更精確地運行，以偵測您的活動。';

  @override
  String get permission_notification_title => '通知權限';

  @override
  String get permission_notification_desc => '我們需要顯示通知以維持背景服務的運行，並在步數成功寫入時通知您。';

  @override
  String get permission_battery_title => '停用電池優化';

  @override
  String get permission_battery_desc =>
      '為確保 WalkGo 能穩定在背景運行，不被作業系統終止，請為本應用停用電池優化。';

  @override
  String get grant_permission => '授予權限';

  @override
  String get setup_complete => '完成設定';

  @override
  String get next_step => '下一步';

  @override
  String get clear_data_button => '清除權限與資料';

  @override
  String get clear_data_confirm_title => '確認刪除資料';

  @override
  String get clear_data_confirm_content =>
      '此操作將會清除所有權限與已儲存的資料（包含步數設定、日誌），並停止所有背景服務。App 將恢復到初始狀態，確定要繼續嗎？';

  @override
  String get clear_data_success_toast => '資料已清除，App 即將重啟。';

  @override
  String get language => '語言';

  @override
  String get chinese => '中文';

  @override
  String get english => '英文';

  @override
  String get systemDefault => '跟隨系統';

  @override
  String get settings => '設定';

  @override
  String get settings_tooltip => '設定';

  @override
  String get manage_permissions => '管理應用程式權限';

  @override
  String get manage_permissions_desc => '打開系統設定，手動授予或撤銷所有應用程式權限。';

  @override
  String get language_settings => '語言設定';

  @override
  String get log_type_manual => '手動';

  @override
  String get log_type_automatic => '自動';

  @override
  String get status_initializing => '初始化中...';
}
