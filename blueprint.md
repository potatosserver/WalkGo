# WalkGo 應用程式藍圖

## 總覽

WalkGo 是一款 Flutter 應用程式，旨在幫助使用者追蹤和記錄他們的步行步數。它提供手動和自動步數記錄功能，以及可自訂的設定以調整使用者體驗。該應用程式利用背景服務來確保持續運作，並為使用者提供即時更新和通知。

## 專案結構

專案的目錄結構如下：

*   **l10n:** 包含支援多國語言的本地化檔案。
*   **lib:** 應用程式的主要原始碼。
    *   **api:** 包含與背景服務互動的 API。
    *   **constants:** 包含整個應用程式中使用的常數值。
    *   **l10n:** 包含應用程式的本地化代理和生成的本地化內容。
    *   **models:** 包含應用程式中使用的資料模型。
    *   **pages:** 包含應用程式的不同頁面或畫面。
    *   **providers:** 包含用於狀態管理的提供者。
    *   **services:** 包含提供特定功能的服務，例如與健康應用程式互動或管理權限。
    *   **utils:** 包含工具類別和函式。
    *   **widgets:** 包含在整個應用程式中重複使用的元件。
*   **test:** 包含應用程式的單元和元件測試。

## `lib` 檔案夾檔案結構

以下是 `lib` 檔案夾中檔案的細分及其功能：

```
lib
├── app_router.dart (應用程式路由)
├── constants.dart (應用程式常數)
├── main.dart (應用程式進入點)
├── theme_provider.dart (主題供應商)
├── l10n
│   ├── app_en.arb (英文本地化)
│   ├── app_localizations.dart (本地化基礎)
│   ├── app_localizations_en.dart (英文本地化)
│   ├── app_localizations_zh.dart (中文本地化)
│   └── app_zh.arb (中文本地化)
├── pages
│   ├── advanced_parameters_page.dart (進階參數頁面)
│   ├── appearance_settings_page.dart (外觀設定頁面)
│   ├── home_page.dart (首頁)
│   ├── language_settings_page.dart (語言設定頁面)
│   ├── log_page.dart (日誌頁面)
│   ├── permission_handler_page.dart (權限處理頁面)
│   ├── settings_page.dart (設定頁面)
│   ├── splash_screen.dart (啟動畫面)
│   └── welcome_page.dart (歡迎頁面)
├── services
│   ├── background_service.dart (背景服務)
│   ├── error_log_service.dart (錯誤日誌服務)
│   ├── health_service.dart (健康服務)
│   ├── language_service.dart (語言服務)
│   ├── log_service.dart (日誌服務)
│   └── permission_service.dart (權限服務)
├── viewmodels
│   ├── advanced_settings_viewmodel.dart (進階設定視圖模型)
│   └── home_page_viewmodel.dart (首頁視圖模型)
└── widgets
    ├── parameter_settings_card.dart (參數設定卡片)
    └── status_card.dart (狀態卡片)
```

## 風格與設計

本應用程式遵循 Material Design 3 指南，提供乾淨直觀的使用者介面。它支援淺色和深色主題，且使用者介面設計為響應式和無障礙的。主要設計元素包括：

*   **色彩配置：** 從種子顏色生成的色彩配置，確保和諧且具視覺吸引力的外觀。
*   **排版：** 使用 `google_fonts` 套件，提供一致且易讀的排版。
*   **元件主題：** 為 `AppBar` 和 `ElevatedButton` 等元件進行集中式主題設定，以在整個應用程式中保持一致的風格。
*   **圖示：** 使用有意義的圖示來增強使用者的理解和導覽。

## 編碼規範

為了確保代碼的一致性與使用者體驗，請遵循以下規範：

*   **通知與回饋 (Toast)：**
    *   所有的短暫提示（Toast）必須使用 `fluttertoast` 套件的 `Fluttertoast.showToast` 方法。
    *   **禁止** 使用 `scaffoldMessengerKey.currentState?.showSnackBar` 或 `SnackBar` 來實現短暫提示功能。
    *   **正確範例：** `Fluttertoast.showToast(msg: l10n.manual_write_success_feedback(steps.toString()));`

## 功能

### 1. 步數追蹤與記錄

*   **手動輸入步數：** 使用者可以手動輸入並記錄特定的步數。
*   **自動記錄步數：** 應用程式可以依固定間隔自動記錄步數。
*   **背景服務：** 一個持久的背景服務確保即使應用程式不在前景，步數也能被記錄。
*   **健康應用程式整合：** 應用程式與平台的健康服務整合，以寫入步數資料。

### 2. 可自訂設定

*   **參數設定：**
    *   **基礎步數：** 每個間隔中要記錄的預設步數。
    *   **偏移步數：** 從基礎步數中隨機增加或減少的偏移量。
    *   **間隔：** 自動記錄步數的時間間隔（以分鐘為單位）。
*   **進階參數：**
    *   **自動暫停：** 當步數超過指定閾值時，自動暫停服務。
    *   **偏移設定：** 啟用或禁用隨機步數偏移。
*   **外觀設定：**
    *   **主題：** 在淺色、深色和系統預設主題之間選擇。
    *   **語言：** 在英文和中文之間切換。

### 3. 使用者介面與體驗

*   **主頁：** 顯示服務的目前狀態、本次工作階段的步數，並提供啟動或停止自動模式的控制項。
*   **設定頁面：** 所有可自訂設定的集中位置。
*   **記錄頁面：** 所有已記錄步數項目的歷史視圖。
*   **歡迎與權限：** 引導式的設定過程，以授予應用程式正常運作所需的權限。
*   **通知：** 應用程式提供有關服務狀態、步數記錄和其他重要事件的通知。

### 4. 技術實現

*   **狀態管理：** 本應用程式使用 `provider` 套件進行狀態管理，確保架構清晰且易於維護。
*   **路由：** 使用 `go_router` 套件進行宣告式路由，提供強大而靈活的導覽系統。
*   **本地化：** 本應用程式使用 Flutter 的內建國際化功能支援多種語言。
*   **錯誤處理與記錄：** 已建立一個全面的記錄系統來追蹤錯誤和重要事件。
*   **權限處理：** 使用 `permission_handler` 套件來管理和向使用者請求必要的權限。

## 本次變更計畫

**目標：** 修正「檢查更新」對話框中，載入中動畫未置中且包含多餘元件的 UI 問題。

### 發現的問題

在 `lib/widgets/update_flow_dialog.dart` 中，「檢查更新」時的 `AlertDialog` 存在以下兩個 UI 瑕疵：

1.  **未置中：** `CircularProgressIndicator`（載入中動畫）被放在一個 `Row` 元件中，導致它沒有在對話框中水平置中。
2.  **多餘元件：** `Row` 中包含了一個不必要的 `Text("...")` 元件，與載入中動畫一同顯示，造成視覺上的干擾。

### 解決方案

為了提供更乾淨、專業的使用者體驗，進行了以下修改：

1.  **移除多餘的 `Text` 元件：** 刪除了 `AlertDialog` 內容中的 `Text("...")`。
2.  **置中載入中動畫：**
    *   **檔案：** `lib/widgets/update_flow_dialog.dart`
    *   **操作：** 將原本的 `Row` 替換為 `SizedBox` 和 `Center` 元件，將 `CircularProgressIndicator` 包裹其中。
    *   **結果：** 現在「檢查更新」的對話框只會顯示一個乾淨、置中的載入中動畫，符合使用者對現代化 App 的期待。
