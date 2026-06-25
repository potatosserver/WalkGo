# 🤖 WalkGo AI 共同協作知識庫 (ai.md)

本文件是 WalkGo 專案的**唯一真理來源 (Single Source of Truth)**。所有參與本專案的 AI 代理人必須嚴格遵守此文件中的規範與流程。

---

## 📜 第一章：AI 合作條約 (Collaboration Treaty)

### 1.1 核心運作原則
- **工作前閱讀**：任何 AI 在開始執行任務前，**必須**首先閱讀 `ai.md` 以同步最新的專案上下文與技術標準。
- **工作後寫回**：任務完成後，若產生了新的技術共識、解決了特定 Bug 或更新了實作邏輯，**必須**將其更新至 `ai.md` 的「專案共享記憶」區塊中。**寫入紀錄時必須附上簽名（例如：`[AI-Name]`），以標記該項紀錄由誰建立。**
- **更新禁止覆蓋**：更新 `ai.md` 時採取**追加 (Additive)** 原則。除非原內容明確錯誤，否則禁止刪除或覆蓋既有知識。
- **語言協議**：所有對話、解釋、計畫與文件輸出**必須全程使用繁體中文 (zh-TW)**。除非是程式碼、必要技術術語或使用者明確要求英文，否則嚴禁使用英文輸出。

### 1.2 新代理人加入流程
1. 閱讀本條約 $\rightarrow$ 閱讀 `ai.md` 全文 $\rightarrow$ 查閱 `blueprint.md` $\rightarrow$ 確認開發標準 $\rightarrow$ 開始工作。

---

## 🏗️ 第二章：專案概觀與環境 (Project Overview & Environment)

### 2.1 專案定位
- **名稱**：WalkGo
- **目標**：開發一個高效、自動化且具備強大健康追蹤能力的 Flutter 應用。
- **AI 角色**：技術型 Pair-Programmer。提供精準、可執行且符合最小變更原則的修改建議。

### 2.2 環境配置
- **開發環境**：Firebase Studio (Code OSS-based IDE)。
- **環境定義**：`.idx/dev.nix` 是環境的唯一來源。定義了系統工具 (`pkgs.flutter`, `pkgs.dart`)、擴充功能與啟動指令。
- **預覽伺服器**：支援 Hot Reload。重大變更後應執行手動全量重新載入。
- **Firebase 整合**：使用 `firebase_options.dart` 及 Firebase SDK。
- **MCP 設定**：Firebase MCP 伺服器配置於 `.idx/mcp.json`：
```json
{
    "mcpServers": {
        "firebase": {
            "command": "npx",
            "args": [
                "-y",
                "firebase-tools@latest",
                "experimental:mcp"
            ]
        }
    }
}
```

---

## ⚙️ 第三章：核心技術模式 (Core Technical Patterns)

### 3.1 背景 Isolate 架構 (Background Isolate)
- **隔離性**：使用 `flutter_background_service` 運行獨立 Isolate。UI 與背景 Isolate **不共享狀態**。
- **通訊機制**：
  - 發送數據：`service.invoke('event', data)`
  - 接收數據：`service.on('event').listen(...)`
- **本地化 (Localization)**：背景 Isolate 無法存取 `AppLocalizations`。必須由 UI Isolate 將翻譯字串以 `Map<String, String>` 形式透過事件傳遞。
- **狀態同步**：在背景 Isolate 讀取 `SharedPreferences` 前，**必須**執行 `await prefs.reload()` 以避免讀取快取過時數據。
- **Health SDK 限制**：**禁止**將 `Health` 實例儲存為成員變數。必須在每個方法調用內部重新實例化 `Health()`，以防止 Isolate 崩潰。

### 3.2 核心業務邏輯
- **步數模擬**：`background_service.dart` 中的 `writeStepsLogic` 應結合基礎步數與隨機偏移量，並檢查 `autoPauseThreshold` 以決定是否暫停更新。

### 3.3 建構與部署
- **混淆 (Obfuscation)**：生產環境 APK 必須使用 `--obfuscate --split-debug-info=./debug-info --split-per-abi`。
- **發佈流程**：使用 `gh` CLI 進行 Tag 標記與 Release 建立（詳細指令參考 `Flutter指令參考.md`）。

---

## 🎨 第四章：開發標準與設計指南 (Coding Standards & Design)

### 4.1 視覺美學與 UI
- **設計原則**：遵循 Material Design 3。追求現代感、視覺平衡、乾淨的間距與精緻的樣式。
- **配色方案**：優先使用 `ColorScheme.fromSeed` 生成和諧調色盤，支援動態色彩。
- **字體設計**：使用 `google_fonts` 建立階層感。
  - 安裝：`flutter pub add google_fonts`
  - 範例：
    ```dart
    final TextTheme myTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );
    ```
- **視覺效果**：
  - 背景使用微量噪點紋理增加高級感。
  - 使用多層陰影 (Multi-layered drop shadows) 營造深度。
  - 互動元件 (按鈕/滑塊) 應有優雅的色彩光暈效果。
- **響應式**：確保在 Mobile 與 Web 之間完美適應。

### 4.2 完整主題實作範例
使用 `provider` 進行主題切換，並整合 `google_fonts`：
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.dark),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'WalkGo',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}
```

### 4.3 應用架構與狀態管理
- **狀態管理選擇**：
  - **本地狀態 (Built-in)**:
    - `ValueNotifier` & `ValueListenableBuilder`: 用於單一值。
      ```dart
      final ValueNotifier<int> _counter = ValueNotifier<int>(0);
      ValueListenableBuilder<int>(
        valueListenable: _counter,
        builder: (context, value, child) => Text('Count: $value'),
      );
      ```
    - `Streams` & `StreamBuilder`: 用於非同步事件流 (Firebase)。
    - `Futures` & `FutureBuilder`: 用於單次非同步操作 (API 請求)。
  - **全域狀態 & 依賴注入**:
    - `ChangeNotifier` & `ChangeNotifierProvider`: 用於複雜狀態共享。
    - `Provider`: 推薦用於中大型應用，實現解耦與依賴注入。
- **數據流向**：單向流 (Data Source $\rightarrow$ Repository/Service $\rightarrow$ State Management $\rightarrow$ UI)。
- **分層結構**：
  - `presentation` (UI, widgets, pages) $\rightarrow$ `domain` (business logic, models) $\rightarrow$ `data` (repositories, API) $\rightarrow$ `core` (utilities)。
- **專案組織**：採用「功能優先 (Feature-first)」結構。

### 4.4 程式碼品質與日誌
- **原則**：關注點分離、一致命名、有效使用 `const`。
- **非同步**：嚴格使用 `async/await` 並搭配 `try-catch`。
- **日誌記錄**：使用 `dart:developer` 的 `log` 函數進行結構化記錄：
  ```dart
  import 'dart:developer' as developer;
  developer.log('Message', name: 'my_app.network', level: 900, error: e, stackTrace: s);
  ```

---

## 🛠️ 第五章：功能實作指南 (Implementation Guides)

### 5.1 路由與導航
- **基礎導航**：`Navigator.push`, `Navigator.pop`, `Navigator.pushReplacement`。
- **宣告式導航 (go_router)**：用於複雜路由、深層連結與 Web 支援。
  ```dart
  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'details/:id',
            builder: (context, state) => DetailScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
  ```

### 5.2 資產與圖標
- `pubspec.yaml` 必須正確宣告 `assets/` 目錄。
- `Image.asset` (本地), `Image.network` (遠端), `Icon` (Material), `ImageIcon` (自定義)。

### 5.3 生成式 AI (Firebase AI)
- **模型選擇**：預設 `gemini-2.5-flash`。
- **安全性**：禁止硬編碼 API Key，使用 Firebase App Check。
- **實作範例**：
  - **文本生成**：
    ```dart
    final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.5-pro');
    final response = await model.generateContent([Content.text(promptText)]);
    ```
  - **多模態 (Vision)**：
    ```dart
    final content = Content.multi([TextPart(promptText), DataPart('image/jpeg', imageData)]);
    final response = await model.generateContent([content]);
    ```
  - **圖片生成 (Imagen)**：
    ```dart
    final imagenModel = FirebaseVertexAI.instance.imagenModel();
    final result = await imagenModel.generateImages(prompt: prompt, numberOfImages: 1);
    ```
  - **文本嵌入 (Gecko)**：使用 `text-embedding-004` 進行語意搜尋。

### 5.4 測試規範
- 優先編寫單元測試 (`package:test`)。
- 使用 `mockito` 進行依賴隔離。
- 流程：撰寫測試 $\rightarrow$ `flutter test` $\rightarrow$ 修正代碼 $\rightarrow$ 驗證。

---

## 🔄 第六章：迭代開發流程 (Iterative Workflow)

### 6.1 標準執行步驟
1. **計畫階段**：生成清晰的計畫 $\rightarrow$ 更新 `blueprint.md`。
2. **實作階段**：修改程式碼 $\rightarrow$ 執行 `dart format .`。
3. **依賴更新**：若修改 `pubspec.yaml` $\rightarrow$ 執行 `flutter pub get`。
4. **代碼生成**：若涉及 freezed/json_serializable $\rightarrow$ 執行 `dart run build_runner build --delete-conflicting-outputs`。
5. **靜態分析**：執行 `flutter analyze` 檢查錯誤。
6. **動態驗證**：監控預覽伺服器輸出 $\rightarrow$ 執行 `flutter test`。
7. **修正與報告**：自動嘗試修復 $\rightarrow$ 若失敗則詳細報告給使用者。

---

## 🧠 第七章：專案共享記憶 (Project Shared Memory)
*(此區域由 AI 共同維護，記錄開發過程中的關鍵決策、解決方案與坑洞)*

- **[2026-06-25]** 建立統一的 AI 協作知識庫 `ai.md`，將所有碎片化指引整合，並實施繁體中文輸出協定。
- **[2026-06-25]** 發現 `background_service.dart` 違反 `Health` 實例化規範，將實例儲存為成員變數導致潛在 Isolate 崩潰 $\rightarrow$ 應將 `HealthService` 的實例化移至方法內部。 [Hermes-Agent]
- **[待添加]** ...


⚠️ [Error Found]: Analyzing lib...

  error - app_router.dart:1:8 - Target of URI doesn't exist: 'package:go_router/go_router.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - app_router.dart:13:14 - Undefined class 'GoRouter'. Try changing the name to the name of an existing class, or creating a class with the name 'GoRouter'. - undefined_class
  error - app_router.dart:16:14 - The method 'GoRouter' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRouter'. - undefined_method
  error - app_router.dart:19:9 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:23:9 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:27:9 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:31:9 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:32:9 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:36:13 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:40:13 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:44:13 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - app_router.dart:47:9 - The method 'GoRoute' isn't defined for the type 'AppRouter'. Try correcting the name to the name of an existing method, or defining a method named 'GoRoute'. - undefined_method
  error - l10n/app_localizations.dart:3:8 - Target of URI doesn't exist: 'package:flutter/foundation.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - l10n/app_localizations.dart:4:8 - Target of URI doesn't exist: 'package:flutter/widgets.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - l10n/app_localizations.dart:5:8 - Target of URI doesn't exist: 'package:flutter_localizations/flutter_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - l10n/app_localizations.dart:6:8 - Target of URI doesn't exist: 'package:intl/intl.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - l10n/app_localizations.dart:70:31 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - l10n/app_localizations.dart:71:12 - Undefined name 'Localizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - l10n/app_localizations.dart:74:16 - Undefined class 'LocalizationsDelegate'. Try changing the name to the name of an existing class, or creating a class with the name 'LocalizationsDelegate'. - undefined_class
  error - l10n/app_localizations.dart:87:21 - The name 'LocalizationsDelegate' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'LocalizationsDelegate'. - non_type_as_type_argument
  error - l10n/app_localizations.dart:88:8 - The name 'LocalizationsDelegate' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'LocalizationsDelegate'. - non_type_as_type_argument
  error - l10n/app_localizations.dart:90:5 - Const variables must be initialized with a constant value. Try changing the initializer to be a constant expression. - const_initialized_with_non_constant_value
  error - l10n/app_localizations.dart:90:5 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - l10n/app_localizations.dart:90:5 - Undefined name 'GlobalMaterialLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - l10n/app_localizations.dart:91:5 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - l10n/app_localizations.dart:91:5 - Undefined name 'GlobalCupertinoLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - l10n/app_localizations.dart:92:5 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - l10n/app_localizations.dart:92:5 - Undefined name 'GlobalWidgetsLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - l10n/app_localizations.dart:96:21 - The name 'Locale' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Locale'. - non_type_as_type_argument
  error - l10n/app_localizations.dart:96:49 - The name 'Locale' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Locale'. - non_type_as_type_argument
  error - l10n/app_localizations.dart:97:5 - Const variables must be initialized with a constant value. Try changing the initializer to be a constant expression. - const_initialized_with_non_constant_value
  error - l10n/app_localizations.dart:97:5 - The method 'Locale' isn't defined for the type 'AppLocalizations'. Try correcting the name to the name of an existing method, or defining a method named 'Locale'. - undefined_method
  error - l10n/app_localizations.dart:97:5 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - l10n/app_localizations.dart:98:5 - The method 'Locale' isn't defined for the type 'AppLocalizations'. Try correcting the name to the name of an existing method, or defining a method named 'Locale'. - undefined_method
  error - l10n/app_localizations.dart:98:5 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - l10n/app_localizations.dart:1129:13 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - l10n/app_localizations.dart:1133:33 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - l10n/app_localizations.dart:1134:12 - The method 'SynchronousFuture' isn't defined for the type '_AppLocalizationsDelegate'. Try correcting the name to the name of an existing method, or defining a method named 'SynchronousFuture'. - undefined_method
  error - l10n/app_localizations.dart:1138:20 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - l10n/app_localizations.dart:1145:41 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - l10n/app_localizations.dart:1154:9 - The function 'FlutterError' isn't defined. Try importing the library that defines 'FlutterError', correcting the name to the name of an existing function, or defining a function named 'FlutterError'. - undefined_function
  error - l10n/app_localizations_en.dart:2:8 - Target of URI doesn't exist: 'package:intl/intl.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - l10n/app_localizations_zh.dart:2:8 - Target of URI doesn't exist: 'package:intl/intl.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:1:8 - Target of URI doesn't exist: 'dart:ui'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:3:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:4:8 - Target of URI doesn't exist: 'package:flutter_background_service/flutter_background_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:5:8 - Target of URI doesn't exist: 'package:flutter_local_notifications/flutter_local_notifications.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:6:8 - Target of URI doesn't exist: 'package:flutter_localizations/flutter_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:7:8 - Target of URI doesn't exist: 'package:in_app_update/in_app_update.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:8:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:9:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - main.dart:22:7 - Undefined class 'FlutterLocalNotificationsPlugin'. Try changing the name to the name of an existing class, or creating a class with the name 'FlutterLocalNotificationsPlugin'. - undefined_class
  error - main.dart:23:5 - The function 'FlutterLocalNotificationsPlugin' isn't defined. Try importing the library that defines 'FlutterLocalNotificationsPlugin', correcting the name to the name of an existing function, or defining a function named 'FlutterLocalNotificationsPlugin'. - undefined_function
  error - main.dart:27:3 - Undefined class 'NotificationResponse'. Try changing the name to the name of an existing class, or creating a class with the name 'NotificationResponse'. - undefined_class
  error - main.dart:30:21 - The function 'FlutterBackgroundService' isn't defined. Try importing the library that defines 'FlutterBackgroundService', correcting the name to the name of an existing function, or defining a function named 'FlutterBackgroundService'. - undefined_function
  error - main.dart:31:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:33:5 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - main.dart:35:16 - The function 'Locale' isn't defined. Try importing the library that defines 'Locale', correcting the name to the name of an existing function, or defining a function named 'Locale'. - undefined_function
  error - main.dart:37:16 - Undefined name 'PlatformDispatcher'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:50:22 - The name 'Locale' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - main.dart:73:19 - The function 'FlutterBackgroundService' isn't defined. Try importing the library that defines 'FlutterBackgroundService', correcting the name to the name of an existing function, or defining a function named 'FlutterBackgroundService'. - undefined_function
  error - main.dart:75:9 - Undefined class 'AndroidNotificationChannel'. Try changing the name to the name of an existing class, or creating a class with the name 'AndroidNotificationChannel'. - undefined_class
  error - main.dart:75:46 - Const variables must be initialized with a constant value. Try changing the initializer to be a constant expression. - const_initialized_with_non_constant_value
  error - main.dart:75:46 - The function 'AndroidNotificationChannel' isn't defined. Try importing the library that defines 'AndroidNotificationChannel', correcting the name to the name of an existing function, or defining a function named 'AndroidNotificationChannel'. - undefined_function
  error - main.dart:79:17 - Undefined name 'Importance'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:84:11 - The name 'AndroidFlutterLocalNotificationsPlugin' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AndroidFlutterLocalNotificationsPlugin'. - non_type_as_type_argument
  error - main.dart:88:27 - The function 'AndroidConfiguration' isn't defined. Try importing the library that defines 'AndroidConfiguration', correcting the name to the name of an existing function, or defining a function named 'AndroidConfiguration'. - undefined_function
  error - main.dart:97:23 - The function 'IosConfiguration' isn't defined. Try importing the library that defines 'IosConfiguration', correcting the name to the name of an existing function, or defining a function named 'IosConfiguration'. - undefined_function
  error - main.dart:102:3 - Undefined name 'WidgetsFlutterBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:103:3 - Undefined name 'DartPluginRegistrant'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:105:9 - Undefined class 'AndroidInitializationSettings'. Try changing the name to the name of an existing class, or creating a class with the name 'AndroidInitializationSettings'. - undefined_class
  error - main.dart:106:7 - Const variables must be initialized with a constant value. Try changing the initializer to be a constant expression. - const_initialized_with_non_constant_value
  error - main.dart:106:7 - The function 'AndroidInitializationSettings' isn't defined. Try importing the library that defines 'AndroidInitializationSettings', correcting the name to the name of an existing function, or defining a function named 'AndroidInitializationSettings'. - undefined_function
  error - main.dart:108:9 - Undefined class 'InitializationSettings'. Try changing the name to the name of an existing class, or creating a class with the name 'InitializationSettings'. - undefined_class
  error - main.dart:108:57 - Const variables must be initialized with a constant value. Try changing the initializer to be a constant expression. - const_initialized_with_non_constant_value
  error - main.dart:108:57 - The function 'InitializationSettings' isn't defined. Try importing the library that defines 'InitializationSettings', correcting the name to the name of an existing function, or defining a function named 'InitializationSettings'. - undefined_function
  error - main.dart:118:23 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:120:3 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - main.dart:122:14 - The function 'Locale' isn't defined. Try importing the library that defines 'Locale', correcting the name to the name of an existing function, or defining a function named 'Locale'. - undefined_function
  error - main.dart:124:14 - Undefined name 'PlatformDispatcher'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:137:20 - The name 'Locale' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - main.dart:146:3 - The function 'runApp' isn't defined. Try importing the library that defines 'runApp', correcting the name to the name of an existing function, or defining a function named 'runApp'. - undefined_function
  error - main.dart:149:25 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - main.dart:150:26 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - main.dart:153:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - main.dart:156:31 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - main.dart:159:11 - The method 'initState' isn't defined in a superclass of '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - main.dart:167:27 - The name 'AppUpdateInfo' isn't defined, so it can't be used in an 'is' expression. Try changing the name to the name of an existing type, or creating a type with the name 'AppUpdateInfo'. - type_test_with_undefined_name
  error - main.dart:169:17 - Undefined name 'UpdateAvailability'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:179:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - main.dart:179:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - main.dart:182:25 - The method 'DialogThemeData' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'DialogThemeData'. - undefined_method
  error - main.dart:183:14 - The method 'RoundedRectangleBorder' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - main.dart:184:23 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:186:29 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - main.dart:187:21 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:192:24 - The method 'ThemeData' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ThemeData'. - undefined_method
  error - main.dart:194:24 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:195:19 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:199:23 - The method 'ThemeData' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ThemeData'. - undefined_method
  error - main.dart:201:24 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:202:19 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:206:12 - The method 'MultiProvider' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'MultiProvider'. - undefined_method
  error - main.dart:208:9 - The method 'ChangeNotifierProvider' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ChangeNotifierProvider'. - undefined_method
  error - main.dart:209:9 - The method 'ChangeNotifierProvider' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ChangeNotifierProvider'. - undefined_method
  error - main.dart:210:9 - The method 'ChangeNotifierProvider' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ChangeNotifierProvider'. - undefined_method
  error - main.dart:211:9 - The method 'ChangeNotifierProvider' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ChangeNotifierProvider'. - undefined_method
  error - main.dart:212:9 - The method 'ChangeNotifierProxyProvider' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'ChangeNotifierProxyProvider'. - undefined_method
  error - main.dart:215:13 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:221:14 - The method 'Consumer' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'Consumer'. - undefined_method
  error - main.dart:223:18 - The method 'Consumer' isn't defined for the type '_WalkGoAppState'. Try correcting the name to the name of an existing method, or defining a method named 'Consumer'. - undefined_method
  error - main.dart:225:22 - Undefined name 'MaterialApp'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:235:19 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - main.dart:235:19 - Undefined name 'GlobalMaterialLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:236:19 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - main.dart:236:19 - Undefined name 'GlobalWidgetsLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - main.dart:237:19 - The values in a const list literal must be constants. Try removing the keyword 'const' from the list literal. - non_constant_list_element
  error - main.dart:237:19 - Undefined name 'GlobalCupertinoLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/advanced_parameters_page.dart:2:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/advanced_parameters_page.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/viewmodels/advanced_settings_viewmodel.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/advanced_parameters_page.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/advanced_parameters_page.dart:5:8 - Target of URI doesn't exist: 'package:walkgo/pages/debug_log_page.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/advanced_parameters_page.dart:7:38 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/advanced_parameters_page.dart:8:39 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/advanced_parameters_page.dart:11:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - pages/advanced_parameters_page.dart:14:44 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/advanced_parameters_page.dart:15:14 - Undefined class 'TextEditingController'. Try changing the name to the name of an existing class, or creating a class with the name 'TextEditingController'. - undefined_class
  error - pages/advanced_parameters_page.dart:16:14 - Undefined class 'TextEditingController'. Try changing the name to the name of an existing class, or creating a class with the name 'TextEditingController'. - undefined_class
  error - pages/advanced_parameters_page.dart:17:14 - Undefined class 'FocusNode'. Try changing the name to the name of an existing class, or creating a class with the name 'FocusNode'. - undefined_class
  error - pages/advanced_parameters_page.dart:18:14 - Undefined class 'FocusNode'. Try changing the name to the name of an existing class, or creating a class with the name 'FocusNode'. - undefined_class
  error - pages/advanced_parameters_page.dart:22:11 - The method 'initState' isn't defined in a superclass of '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - pages/advanced_parameters_page.dart:23:23 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:23:35 - The name 'AdvancedSettingsViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AdvancedSettingsViewModel'. - non_type_as_type_argument
  error - pages/advanced_parameters_page.dart:24:7 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:28:30 - The method 'TextEditingController' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextEditingController'. - undefined_method
  error - pages/advanced_parameters_page.dart:29:37 - The method 'TextEditingController' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextEditingController'. - undefined_method
  error - pages/advanced_parameters_page.dart:33:29 - The method 'FocusNode' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'FocusNode'. - undefined_method
  error - pages/advanced_parameters_page.dart:34:36 - The method 'FocusNode' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'FocusNode'. - undefined_method
  error - pages/advanced_parameters_page.dart:55:11 - The method 'dispose' isn't defined in a superclass of '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass. - undefined_super_member
  error - pages/advanced_parameters_page.dart:59:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/advanced_parameters_page.dart:59:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/advanced_parameters_page.dart:60:5 - The method 'debugPrint' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'debugPrint'. - undefined_method
  error - pages/advanced_parameters_page.dart:61:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:62:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:64:12 - The method 'Scaffold' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/advanced_parameters_page.dart:65:15 - The method 'AppBar' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/advanced_parameters_page.dart:65:29 - The method 'Text' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/advanced_parameters_page.dart:66:29 - Undefined name 'FloatingActionButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:68:11 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:70:13 - The method 'MaterialPageRoute' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'MaterialPageRoute'. - undefined_method
  error - pages/advanced_parameters_page.dart:70:59 - The name 'DebugLogPage' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/advanced_parameters_page.dart:73:22 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/advanced_parameters_page.dart:73:27 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:76:13 - The method 'SafeArea' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/advanced_parameters_page.dart:77:16 - The method 'Consumer' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Consumer'. - undefined_method
  error - pages/advanced_parameters_page.dart:77:25 - The name 'AdvancedSettingsViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AdvancedSettingsViewModel'. - non_type_as_type_argument
  error - pages/advanced_parameters_page.dart:89:20 - The method 'AbsorbPointer' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'AbsorbPointer'. - undefined_method
  error - pages/advanced_parameters_page.dart:91:22 - The method 'Opacity' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Opacity'. - undefined_method
  error - pages/advanced_parameters_page.dart:93:24 - The method 'Column' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/advanced_parameters_page.dart:96:23 - The method 'Container' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Container'. - undefined_method
  error - pages/advanced_parameters_page.dart:97:40 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:100:32 - The method 'Text' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/advanced_parameters_page.dart:102:38 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:103:34 - The method 'TextStyle' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - pages/advanced_parameters_page.dart:105:41 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:109:21 - The method 'Expanded' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - pages/advanced_parameters_page.dart:110:30 - The method 'GestureDetector' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'GestureDetector'. - undefined_method
  error - pages/advanced_parameters_page.dart:111:38 - Undefined name 'FocusScope'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:112:32 - The method 'ListView' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListView'. - undefined_method
  error - pages/advanced_parameters_page.dart:113:42 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:122:41 - The method 'Switch' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Switch'. - undefined_method
  error - pages/advanced_parameters_page.dart:130:38 - The method 'Visibility' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Visibility'. - undefined_method
  error - pages/advanced_parameters_page.dart:132:40 - The method 'Padding' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/advanced_parameters_page.dart:133:50 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:153:41 - The method 'Switch' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Switch'. - undefined_method
  error - pages/advanced_parameters_page.dart:161:38 - The method 'Visibility' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Visibility'. - undefined_method
  error - pages/advanced_parameters_page.dart:163:40 - The method 'Padding' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/advanced_parameters_page.dart:164:50 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:194:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/advanced_parameters_page.dart:195:5 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/advanced_parameters_page.dart:198:5 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/advanced_parameters_page.dart:199:14 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/advanced_parameters_page.dart:201:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:202:12 - The method 'Card' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Card'. - undefined_method
  error - pages/advanced_parameters_page.dart:203:21 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:205:14 - The method 'RoundedRectangleBorder' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - pages/advanced_parameters_page.dart:206:23 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:207:15 - The method 'BorderSide' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'BorderSide'. - undefined_method
  error - pages/advanced_parameters_page.dart:209:14 - The method 'Column' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/advanced_parameters_page.dart:210:29 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:212:11 - The method 'Padding' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/advanced_parameters_page.dart:213:28 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:214:20 - The method 'Row' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Row'. - undefined_method
  error - pages/advanced_parameters_page.dart:215:34 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:217:17 - The method 'Expanded' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - pages/advanced_parameters_page.dart:218:26 - The method 'Column' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/advanced_parameters_page.dart:219:41 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:221:23 - The method 'Text' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/advanced_parameters_page.dart:224:39 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:228:25 - The method 'Padding' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/advanced_parameters_page.dart:229:42 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:230:34 - The method 'Text' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/advanced_parameters_page.dart:241:19 - The method 'Padding' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/advanced_parameters_page.dart:242:36 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:254:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/advanced_parameters_page.dart:255:14 - Undefined class 'TextEditingController'. Try changing the name to the name of an existing class, or creating a class with the name 'TextEditingController'. - undefined_class
  error - pages/advanced_parameters_page.dart:258:5 - Undefined class 'FocusNode'. Try changing the name to the name of an existing class, or creating a class with the name 'FocusNode'. - undefined_class
  error - pages/advanced_parameters_page.dart:261:12 - The method 'TextFormField' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextFormField'. - undefined_method
  error - pages/advanced_parameters_page.dart:264:21 - Undefined name 'TextInputType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:266:19 - The method 'InputDecoration' isn't defined for the type '_AdvancedParametersPageState'. Try correcting the name to the name of an existing method, or defining a method named 'InputDecoration'. - undefined_method
  error - pages/advanced_parameters_page.dart:269:23 - The name 'OutlineInputBorder' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/advanced_parameters_page.dart:270:25 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/advanced_parameters_page.dart:270:42 - Undefined name 'Radius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/appearance_settings_page.dart:2:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/appearance_settings_page.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/theme_provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/appearance_settings_page.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/appearance_settings_page.dart:5:8 - Target of URI doesn't exist: 'package:group_radio_button/group_radio_button.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/appearance_settings_page.dart:7:38 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/appearance_settings_page.dart:8:39 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/appearance_settings_page.dart:10:10 - The body might complete normally, causing 'null' to be returned, but the return type, 'String', is a potentially non-nullable type. Try adding either a return or a throw statement at the end. - body_might_complete_normally
  error - pages/appearance_settings_page.dart:10:28 - Undefined class 'ThemeMode'. Try changing the name to the name of an existing class, or creating a class with the name 'ThemeMode'. - undefined_class
  error - pages/appearance_settings_page.dart:10:44 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - pages/appearance_settings_page.dart:12:12 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:14:12 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:16:12 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:22:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/appearance_settings_page.dart:22:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/appearance_settings_page.dart:23:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:24:41 - The name 'ThemeProvider' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'ThemeProvider'. - non_type_as_type_argument
  error - pages/appearance_settings_page.dart:27:12 - The method 'Scaffold' isn't defined for the type 'AppearanceSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/appearance_settings_page.dart:28:15 - The method 'AppBar' isn't defined for the type 'AppearanceSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/appearance_settings_page.dart:28:29 - The method 'Text' isn't defined for the type 'AppearanceSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/appearance_settings_page.dart:29:13 - The method 'SafeArea' isn't defined for the type 'AppearanceSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/appearance_settings_page.dart:30:16 - The method 'Padding' isn't defined for the type 'AppearanceSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/appearance_settings_page.dart:31:26 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:32:18 - The name 'RadioGroup' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/appearance_settings_page.dart:32:29 - The name 'ThemeMode' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'ThemeMode'. - non_type_as_type_argument
  error - pages/appearance_settings_page.dart:34:25 - Undefined class 'ThemeMode'. Try changing the name to the name of an existing class, or creating a class with the name 'ThemeMode'. - undefined_class
  error - pages/appearance_settings_page.dart:39:20 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/appearance_settings_page.dart:41:17 - The method 'RadioButtonBuilder' isn't defined for the type 'AppearanceSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'RadioButtonBuilder'. - undefined_method
  error - pages/appearance_settings_page.dart:42:30 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/debug_log_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/debug_log_page.dart:2:8 - Target of URI doesn't exist: 'package:flutter/services.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/debug_log_page.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/services/debug_log_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/debug_log_page.dart:5:28 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/debug_log_page.dart:6:29 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/debug_log_page.dart:9:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/debug_log_page.dart:9:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/debug_log_page.dart:10:12 - The method 'Scaffold' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/debug_log_page.dart:11:15 - The method 'AppBar' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/debug_log_page.dart:12:22 - The name 'Text' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/debug_log_page.dart:14:11 - The method 'IconButton' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'IconButton'. - undefined_method
  error - pages/debug_log_page.dart:15:25 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/debug_log_page.dart:15:30 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:17:30 - The method 'DebugLogService' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'DebugLogService'. - undefined_method
  error - pages/debug_log_page.dart:19:11 - The method 'IconButton' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'IconButton'. - undefined_method
  error - pages/debug_log_page.dart:20:25 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/debug_log_page.dart:20:30 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:23:31 - The method 'DebugLogService' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'DebugLogService'. - undefined_method
  error - pages/debug_log_page.dart:24:21 - Undefined name 'Clipboard'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:24:39 - The method 'ClipboardData' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'ClipboardData'. - undefined_method
  error - pages/debug_log_page.dart:26:17 - Undefined name 'ScaffoldMessenger'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:27:25 - The name 'SnackBar' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/debug_log_page.dart:27:43 - The method 'Text' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/debug_log_page.dart:34:13 - The method 'ValueListenableBuilder' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'ValueListenableBuilder'. - undefined_method
  error - pages/debug_log_page.dart:35:26 - The method 'DebugLogService' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'DebugLogService'. - undefined_method
  error - pages/debug_log_page.dart:38:26 - The name 'Center' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/debug_log_page.dart:38:40 - The method 'Text' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/debug_log_page.dart:40:18 - Undefined name 'ListView'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:41:28 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:44:22 - The method 'Padding' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/debug_log_page.dart:45:32 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/debug_log_page.dart:46:24 - The method 'Text' isn't defined for the type 'DebugLogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/debug_log_page.dart:48:32 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:2:8 - Target of URI doesn't exist: 'package:flutter/services.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:3:8 - Target of URI doesn't exist: 'package:flutter_background_service/flutter_background_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:4:8 - Target of URI doesn't exist: 'package:fluttertoast/fluttertoast.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:5:8 - Target of URI doesn't exist: 'package:go_router/go_router.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:6:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:7:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:8:8 - Target of URI doesn't exist: 'package:walkgo/viewmodels/home_page_viewmodel.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:9:8 - Target of URI doesn't exist: 'package:walkgo/widgets/status_card.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:10:8 - Target of URI doesn't exist: 'package:walkgo/widgets/parameter_settings_card.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:11:8 - Target of URI doesn't exist: 'package:walkgo/widgets/update_flow_dialog.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/home_page.dart:13:24 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/home_page.dart:14:25 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/home_page.dart:17:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - pages/home_page.dart:20:30 - Mixin can only be applied to class. - mixin_with_non_class_superclass
  error - pages/home_page.dart:20:51 - Classes can only mix in mixins and classes. - mixin_of_non_class
  error - pages/home_page.dart:23:11 - The method 'initState' isn't defined in a superclass of '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - pages/home_page.dart:24:5 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:25:21 - The method 'FlutterBackgroundService' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - pages/home_page.dart:27:12 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:31:20 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:31:40 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:32:7 - Undefined name 'Fluttertoast'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:36:7 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:36:19 - The name 'HomePageViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'HomePageViewModel'. - non_type_as_type_argument
  error - pages/home_page.dart:37:9 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:43:5 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:44:7 - Undefined name 'UpdateFlowDialog'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:44:28 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:50:5 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:51:11 - The method 'dispose' isn't defined in a superclass of '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass. - undefined_super_member
  error - pages/home_page.dart:55:35 - Undefined class 'AppLifecycleState'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLifecycleState'. - undefined_class
  error - pages/home_page.dart:56:11 - The method 'didChangeAppLifecycleState' isn't defined in a superclass of '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'didChangeAppLifecycleState' in a superclass. - undefined_super_member
  error - pages/home_page.dart:57:18 - Undefined name 'AppLifecycleState'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:58:25 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:58:37 - The name 'HomePageViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'HomePageViewModel'. - non_type_as_type_argument
  error - pages/home_page.dart:58:56 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:64:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/home_page.dart:64:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/home_page.dart:65:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:66:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:67:45 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:70:34 - The method 'SystemUiOverlayStyle' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'SystemUiOverlayStyle'. - undefined_method
  error - pages/home_page.dart:71:23 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:72:46 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:72:64 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:75:25 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:75:43 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:78:12 - The method 'Scaffold' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/home_page.dart:80:15 - The method 'AppBar' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/home_page.dart:81:16 - The method 'Text' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/home_page.dart:85:11 - The method 'IconButton' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'IconButton'. - undefined_method
  error - pages/home_page.dart:86:25 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:86:30 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:94:26 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:97:13 - The method 'SafeArea' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/home_page.dart:99:16 - The method 'Consumer' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'Consumer'. - undefined_method
  error - pages/home_page.dart:99:25 - The name 'HomePageViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'HomePageViewModel'. - non_type_as_type_argument
  error - pages/home_page.dart:101:13 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:104:20 - The method 'GestureDetector' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'GestureDetector'. - undefined_method
  error - pages/home_page.dart:105:28 - Undefined name 'FocusScope'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:106:22 - The method 'ListView' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListView'. - undefined_method
  error - pages/home_page.dart:107:26 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:110:24 - Undefined name 'MediaQuery'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:115:25 - The name 'StatusCard' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:116:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:117:25 - The name 'ParameterSettingsCard' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:118:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:119:19 - Undefined name 'ElevatedButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:120:33 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:120:38 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:121:28 - The method 'Text' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/home_page.dart:122:28 - Undefined name 'ElevatedButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:123:38 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:124:30 - The method 'RoundedRectangleBorder' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - pages/home_page.dart:125:39 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:128:29 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:129:29 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:131:41 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:131:56 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:137:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/home_page.dart:138:19 - Undefined name 'FilledButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:139:27 - The method 'Icon' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'Icon'. - undefined_method
  error - pages/home_page.dart:141:29 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:142:29 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:144:28 - The method 'Text' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/home_page.dart:149:28 - Undefined name 'FilledButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:150:38 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:151:30 - The method 'RoundedRectangleBorder' isn't defined for the type '_HomePageState'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - pages/home_page.dart:152:39 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:155:29 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:156:29 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/home_page.dart:157:40 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/language_settings_page.dart:1:8 - Target of URI doesn't exist: 'dart:ui'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/language_settings_page.dart:3:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/language_settings_page.dart:4:8 - Target of URI doesn't exist: 'package:flutter_background_service/flutter_background_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/language_settings_page.dart:5:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/language_settings_page.dart:6:8 - Target of URI doesn't exist: 'package:group_radio_button/group_radio_button.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/language_settings_page.dart:10:36 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/language_settings_page.dart:11:37 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/language_settings_page.dart:32:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/language_settings_page.dart:32:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/language_settings_page.dart:37:16 - The name 'Locale' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Locale'. - non_type_as_type_argument
  error - pages/language_settings_page.dart:40:26 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - pages/language_settings_page.dart:54:12 - The method 'Scaffold' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/language_settings_page.dart:55:15 - The method 'AppBar' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/language_settings_page.dart:55:29 - The method 'Text' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/language_settings_page.dart:56:13 - The method 'SafeArea' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/language_settings_page.dart:57:16 - The method 'Padding' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/language_settings_page.dart:58:26 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/language_settings_page.dart:59:18 - The name 'RadioGroup' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/language_settings_page.dart:59:29 - The name 'Locale' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Locale'. - non_type_as_type_argument
  error - pages/language_settings_page.dart:61:25 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - pages/language_settings_page.dart:69:42 - Undefined name 'PlatformDispatcher'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/language_settings_page.dart:78:15 - The method 'FlutterBackgroundService' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - pages/language_settings_page.dart:84:36 - The method 'RadioButtonBuilder' isn't defined for the type 'LanguageSettingsPage'. Try correcting the name to the name of an existing method, or defining a method named 'RadioButtonBuilder'. - undefined_method
  error - pages/language_settings_page.dart:85:30 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/log_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/log_page.dart:2:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/log_page.dart:3:8 - Target of URI doesn't exist: 'package:fluttertoast/fluttertoast.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/log_page.dart:6:8 - Target of URI doesn't exist: 'package:intl/intl.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/log_page.dart:9:23 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/log_page.dart:10:24 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/log_page.dart:13:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/log_page.dart:13:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/log_page.dart:19:29 - The method 'showDialog' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - pages/log_page.dart:24:22 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:26:15 - The method 'TextButton' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/log_page.dart:27:34 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:28:24 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:30:15 - The method 'TextButton' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/log_page.dart:31:34 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:32:24 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:34:26 - The method 'TextStyle' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - pages/log_page.dart:35:28 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:47:11 - Undefined name 'Fluttertoast'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:52:12 - The method 'Scaffold' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/log_page.dart:53:15 - The method 'AppBar' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/log_page.dart:54:16 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:56:11 - The method 'IconButton' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'IconButton'. - undefined_method
  error - pages/log_page.dart:57:25 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/log_page.dart:57:30 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:63:13 - The method 'SafeArea' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/log_page.dart:65:15 - The method 'Center' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Center'. - undefined_method
  error - pages/log_page.dart:65:29 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:66:15 - Undefined name 'ListView'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:67:32 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:75:19 - Undefined class 'IconData'. Try changing the name to the name of an existing class, or creating a class with the name 'IconData'. - undefined_class
  error - pages/log_page.dart:76:19 - Undefined class 'Color'. Try changing the name to the name of an existing class, or creating a class with the name 'Color'. - undefined_class
  error - pages/log_page.dart:80:32 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:81:33 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:84:32 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:85:33 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:89:46 - The method 'DateFormat' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'DateFormat'. - undefined_method
  error - pages/log_page.dart:93:26 - The method 'Card' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Card'. - undefined_method
  error - pages/log_page.dart:95:35 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:99:28 - The method 'ListTile' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/log_page.dart:100:32 - The method 'Icon' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Icon'. - undefined_method
  error - pages/log_page.dart:101:30 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:103:38 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/log_page.dart:103:60 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/log_page.dart:105:33 - The method 'Text' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/log_page.dart:107:32 - The method 'TextStyle' isn't defined for the type 'LogPage'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - pages/log_page.dart:108:34 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/permission_handler_page.dart:2:8 - Target of URI doesn't exist: 'package:flutter/services.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/permission_handler_page.dart:3:8 - Target of URI doesn't exist: 'package:go_router/go_router.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/permission_handler_page.dart:4:8 - Target of URI doesn't exist: 'package:health/health.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/permission_handler_page.dart:5:8 - Target of URI doesn't exist: 'package:permission_handler/permission_handler.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/permission_handler_page.dart:10:37 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/permission_handler_page.dart:11:38 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/permission_handler_page.dart:14:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - pages/permission_handler_page.dart:17:43 - Mixin can only be applied to class. - mixin_with_non_class_superclass
  error - pages/permission_handler_page.dart:18:10 - Classes can only mix in mixins and classes. - mixin_of_non_class
  error - pages/permission_handler_page.dart:19:9 - Undefined class 'PageController'. Try changing the name to the name of an existing class, or creating a class with the name 'PageController'. - undefined_class
  error - pages/permission_handler_page.dart:19:42 - The method 'PageController' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'PageController'. - undefined_method
  error - pages/permission_handler_page.dart:22:19 - The method 'Health' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Health'. - undefined_method
  error - pages/permission_handler_page.dart:26:11 - The method 'initState' isn't defined in a superclass of '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - pages/permission_handler_page.dart:27:5 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:33:11 - The method 'dispose' isn't defined in a superclass of '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass. - undefined_super_member
  error - pages/permission_handler_page.dart:37:35 - Undefined class 'AppLifecycleState'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLifecycleState'. - undefined_class
  error - pages/permission_handler_page.dart:38:18 - Undefined name 'AppLifecycleState'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:44:20 - Undefined name 'HealthDataType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:45:26 - Undefined name 'HealthDataAccess'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:52:8 - Undefined name 'HealthDataType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:53:21 - Undefined name 'HealthDataAccess'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:58:39 - Undefined class 'Permission'. Try changing the name to the name of an existing class, or creating a class with the name 'Permission'. - undefined_class
  error - pages/permission_handler_page.dart:64:7 - Undefined class 'Permission'. Try changing the name to the name of an existing class, or creating a class with the name 'Permission'. - undefined_class
  error - pages/permission_handler_page.dart:65:5 - Undefined class 'PermissionStatus'. Try changing the name to the name of an existing class, or creating a class with the name 'PermissionStatus'. - undefined_class
  error - pages/permission_handler_page.dart:75:25 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:77:32 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:88:38 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:89:5 - The method 'showDialog' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - pages/permission_handler_page.dart:90:16 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:93:18 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:95:11 - The method 'TextButton' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/permission_handler_page.dart:96:30 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:97:20 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:99:11 - The method 'TextButton' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/permission_handler_page.dart:101:15 - The method 'openAppSettings' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'openAppSettings'. - undefined_method
  error - pages/permission_handler_page.dart:102:15 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:104:20 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:115:38 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:116:5 - The method 'showDialog' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - pages/permission_handler_page.dart:117:16 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:120:18 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:122:11 - The method 'TextButton' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/permission_handler_page.dart:123:30 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:124:20 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:126:11 - The method 'TextButton' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/permission_handler_page.dart:128:15 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:131:20 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:132:30 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:132:47 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:140:9 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:141:7 - The method 'setState' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - pages/permission_handler_page.dart:149:16 - Undefined name 'Curves'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:152:7 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:157:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/permission_handler_page.dart:157:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/permission_handler_page.dart:160:20 - The name 'Scaffold' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:160:35 - The method 'Center' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Center'. - undefined_method
  error - pages/permission_handler_page.dart:160:49 - The method 'CircularProgressIndicator' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'CircularProgressIndicator'. - undefined_method
  error - pages/permission_handler_page.dart:163:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:164:45 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:166:34 - The method 'SystemUiOverlayStyle' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'SystemUiOverlayStyle'. - undefined_method
  error - pages/permission_handler_page.dart:167:46 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:167:64 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:169:25 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:169:43 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:172:12 - The method 'AnnotatedRegion' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'AnnotatedRegion'. - undefined_method
  error - pages/permission_handler_page.dart:172:28 - The name 'SystemUiOverlayStyle' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'SystemUiOverlayStyle'. - non_type_as_type_argument
  error - pages/permission_handler_page.dart:174:14 - The method 'Scaffold' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/permission_handler_page.dart:175:15 - The method 'SafeArea' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/permission_handler_page.dart:176:18 - Undefined name 'PageView'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:179:28 - The name 'NeverScrollableScrollPhysics' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:181:19 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:182:17 - The method 'setState' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - pages/permission_handler_page.dart:192:27 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:202:27 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:207:29 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:209:48 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:217:27 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:222:29 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:224:25 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:230:32 - Undefined name 'SizedBox'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:239:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/permission_handler_page.dart:241:16 - Undefined class 'IconData'. Try changing the name to the name of an existing class, or creating a class with the name 'IconData'. - undefined_class
  error - pages/permission_handler_page.dart:249:38 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:250:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:250:28 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:253:12 - The method 'FutureBuilder' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'FutureBuilder'. - undefined_method
  error - pages/permission_handler_page.dart:258:16 - The method 'Column' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/permission_handler_page.dart:260:13 - The method 'Expanded' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - pages/permission_handler_page.dart:261:22 - The method 'Padding' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/permission_handler_page.dart:262:32 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:263:24 - The method 'Column' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/permission_handler_page.dart:264:38 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:266:21 - The method 'Icon' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Icon'. - undefined_method
  error - pages/permission_handler_page.dart:267:27 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:268:21 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:271:50 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:272:34 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:274:27 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:275:21 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:278:34 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:280:27 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:282:23 - Undefined name 'ElevatedButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:283:37 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:283:42 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:284:32 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:286:32 - Undefined name 'ElevatedButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:287:42 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:294:25 - The method 'Padding' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/permission_handler_page.dart:295:42 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:296:34 - The method 'TextButton' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/permission_handler_page.dart:317:36 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:318:46 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:318:63 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:326:13 - The method 'Padding' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/permission_handler_page.dart:327:30 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:328:22 - The method 'SizedBox' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - pages/permission_handler_page.dart:330:24 - The method 'ElevatedButton' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ElevatedButton'. - undefined_method
  error - pages/permission_handler_page.dart:332:26 - Undefined name 'ElevatedButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:333:36 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:334:34 - The name 'StadiumBorder' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:337:31 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/permission_handler_page.dart:344:26 - The method 'Text' isn't defined for the type '_PermissionHandlerPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/permission_handler_page.dart:348:34 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/permission_handler_page.dart:350:35 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:2:8 - Target of URI doesn't exist: 'package:fluttertoast/fluttertoast.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:3:8 - Target of URI doesn't exist: 'package:font_awesome_flutter/font_awesome_flutter.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:4:8 - Target of URI doesn't exist: 'package:go_router/go_router.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:5:8 - Target of URI doesn't exist: 'package:in_app_update/in_app_update.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:6:8 - Target of URI doesn't exist: 'package:package_info_plus/package_info_plus.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:7:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:8:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:9:8 - Target of URI doesn't exist: 'package:url_launcher/url_launcher.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/settings_page.dart:19:28 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/settings_page.dart:20:29 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/settings_page.dart:23:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - pages/settings_page.dart:26:34 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/settings_page.dart:31:11 - The method 'initState' isn't defined in a superclass of '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - pages/settings_page.dart:37:33 - Undefined name 'PackageInfo'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:38:11 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:39:9 - The method 'setState' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - pages/settings_page.dart:44:11 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:45:9 - The method 'setState' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - pages/settings_page.dart:53:10 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:54:5 - Undefined name 'Fluttertoast'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:56:34 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:56:43 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:63:25 - The name 'AppUpdateInfo' isn't defined, so it can't be used in an 'is' expression. Try changing the name to the name of an existing type, or creating a type with the name 'AppUpdateInfo'. - type_test_with_undefined_name
  error - pages/settings_page.dart:64:44 - Undefined name 'UpdateAvailability'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:75:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/settings_page.dart:75:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/settings_page.dart:77:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:80:12 - The method 'Scaffold' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/settings_page.dart:81:15 - The method 'AppBar' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'AppBar'. - undefined_method
  error - pages/settings_page.dart:81:29 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:82:13 - The method 'SafeArea' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/settings_page.dart:83:16 - The method 'ListView' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListView'. - undefined_method
  error - pages/settings_page.dart:84:26 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:90:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:91:34 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:91:39 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:92:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:93:35 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:93:40 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:96:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:97:34 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:97:39 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:98:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:99:35 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:99:40 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:108:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:109:34 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:109:39 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:110:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:111:35 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:111:40 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:114:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:115:34 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:115:39 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:116:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:117:35 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:117:40 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:121:19 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:122:36 - The name 'FaIcon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:122:43 - Undefined name 'FontAwesomeIcons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:123:28 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:124:37 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:124:42 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:129:33 - The method 'canLaunchUrl' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'canLaunchUrl'. - undefined_method
  error - pages/settings_page.dart:130:31 - The method 'launchUrl' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'launchUrl'. - undefined_method
  error - pages/settings_page.dart:132:33 - Undefined name 'LaunchMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:137:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:138:34 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:138:39 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:139:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:150:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:151:34 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:151:39 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:152:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:156:19 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:157:36 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:157:41 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:158:28 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:161:17 - The method 'ListTile' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ListTile'. - undefined_method
  error - pages/settings_page.dart:162:28 - The method 'Icon' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Icon'. - undefined_method
  error - pages/settings_page.dart:163:21 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:166:26 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:168:28 - The method 'TextStyle' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - pages/settings_page.dart:170:29 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:172:28 - The method 'TextStyle' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - pages/settings_page.dart:186:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/settings_page.dart:187:5 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/settings_page.dart:189:19 - The name 'Widget' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Widget'. - non_type_as_type_argument
  error - pages/settings_page.dart:191:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:192:12 - The method 'Card' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Card'. - undefined_method
  error - pages/settings_page.dart:193:21 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:194:14 - The method 'Padding' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/settings_page.dart:195:24 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:196:16 - The method 'Column' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/settings_page.dart:197:31 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:199:13 - The method 'Padding' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/settings_page.dart:200:30 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:201:22 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:205:31 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:216:25 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/settings_page.dart:218:5 - The method 'showDialog' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - pages/settings_page.dart:222:18 - The method 'ConstrainedBox' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'ConstrainedBox'. - undefined_method
  error - pages/settings_page.dart:223:24 - The method 'BoxConstraints' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'BoxConstraints'. - undefined_method
  error - pages/settings_page.dart:224:24 - Undefined name 'MediaQuery'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:226:18 - The method 'Scrollbar' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Scrollbar'. - undefined_method
  error - pages/settings_page.dart:227:20 - The method 'SingleChildScrollView' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'SingleChildScrollView'. - undefined_method
  error - pages/settings_page.dart:228:22 - The method 'Column' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/settings_page.dart:229:31 - Undefined name 'MainAxisSize'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:230:37 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:232:19 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:234:28 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:236:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:239:33 - The name 'FaIcon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:239:40 - Undefined name 'FontAwesomeIcons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:241:37 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:241:42 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:246:33 - The method 'canLaunchUrl' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'canLaunchUrl'. - undefined_method
  error - pages/settings_page.dart:247:31 - The method 'launchUrl' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'launchUrl'. - undefined_method
  error - pages/settings_page.dart:248:35 - Undefined name 'LaunchMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:252:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:255:33 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:255:38 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:258:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:261:33 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:261:38 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:265:27 - The name 'Divider' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:268:35 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:268:40 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:279:11 - The method 'TextButton' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/settings_page.dart:280:30 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:281:20 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:288:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/settings_page.dart:289:5 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/settings_page.dart:290:14 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/settings_page.dart:292:5 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/settings_page.dart:293:5 - Undefined class 'VoidCallback'. Try changing the name to the name of an existing class, or creating a class with the name 'VoidCallback'. - undefined_class
  error - pages/settings_page.dart:295:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:296:12 - The method 'InkWell' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'InkWell'. - undefined_method
  error - pages/settings_page.dart:298:21 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:299:14 - The method 'Padding' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/settings_page.dart:300:24 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:301:16 - The method 'Row' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Row'. - undefined_method
  error - pages/settings_page.dart:303:13 - The method 'IconTheme' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'IconTheme'. - undefined_method
  error - pages/settings_page.dart:304:21 - The method 'IconThemeData' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'IconThemeData'. - undefined_method
  error - pages/settings_page.dart:310:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:311:13 - The method 'Expanded' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - pages/settings_page.dart:312:22 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:320:21 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/settings_page.dart:321:15 - The method 'IconTheme' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'IconTheme'. - undefined_method
  error - pages/settings_page.dart:322:23 - The method 'IconThemeData' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'IconThemeData'. - undefined_method
  error - pages/settings_page.dart:332:26 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/settings_page.dart:340:9 - The method 'showDialog' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - pages/settings_page.dart:353:29 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/settings_page.dart:354:20 - Undefined name 'GoRouter'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:355:5 - The method 'showDialog' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - pages/settings_page.dart:358:28 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:362:27 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:365:20 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:367:13 - The method 'TextButton' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/settings_page.dart:369:22 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:371:13 - The method 'TextButton' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - pages/settings_page.dart:373:37 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/settings_page.dart:382:22 - The method 'Text' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/settings_page.dart:384:24 - The method 'TextStyle' isn't defined for the type '_SettingsPageState'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - pages/settings_page.dart:385:26 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/splash_screen.dart:2:8 - Target of URI doesn't exist: 'package:go_router/go_router.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/splash_screen.dart:3:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/splash_screen.dart:7:28 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/splash_screen.dart:8:29 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/splash_screen.dart:11:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - pages/splash_screen.dart:14:34 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/splash_screen.dart:17:11 - The method 'initState' isn't defined in a superclass of '_SplashScreenState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - pages/splash_screen.dart:22:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:27:11 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:27:20 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:30:11 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:32:11 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:34:11 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/splash_screen.dart:41:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/splash_screen.dart:41:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/splash_screen.dart:42:18 - The name 'Scaffold' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/splash_screen.dart:42:33 - The method 'Center' isn't defined for the type '_SplashScreenState'. Try correcting the name to the name of an existing method, or defining a method named 'Center'. - undefined_method
  error - pages/splash_screen.dart:42:47 - The method 'CircularProgressIndicator' isn't defined for the type '_SplashScreenState'. Try correcting the name to the name of an existing method, or defining a method named 'CircularProgressIndicator'. - undefined_method
  error - pages/welcome_page.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/welcome_page.dart:2:8 - Target of URI doesn't exist: 'package:flutter/services.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/welcome_page.dart:3:8 - Target of URI doesn't exist: 'package:flutter_svg/flutter_svg.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/welcome_page.dart:4:8 - Target of URI doesn't exist: 'package:go_router/go_router.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - pages/welcome_page.dart:7:27 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - pages/welcome_page.dart:8:28 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - pages/welcome_page.dart:10:22 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/welcome_page.dart:15:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - pages/welcome_page.dart:15:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - pages/welcome_page.dart:17:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:18:45 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:21:34 - The method 'SystemUiOverlayStyle' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'SystemUiOverlayStyle'. - undefined_method
  error - pages/welcome_page.dart:22:46 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:22:64 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:24:25 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:24:43 - Undefined name 'Brightness'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:27:12 - The method 'AnnotatedRegion' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'AnnotatedRegion'. - undefined_method
  error - pages/welcome_page.dart:27:28 - The name 'SystemUiOverlayStyle' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'SystemUiOverlayStyle'. - non_type_as_type_argument
  error - pages/welcome_page.dart:29:14 - The method 'Scaffold' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Scaffold'. - undefined_method
  error - pages/welcome_page.dart:31:15 - The method 'SafeArea' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'SafeArea'. - undefined_method
  error - pages/welcome_page.dart:32:18 - The method 'Center' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Center'. - undefined_method
  error - pages/welcome_page.dart:33:20 - The method 'Padding' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - pages/welcome_page.dart:34:30 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:35:22 - The method 'Column' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - pages/welcome_page.dart:36:36 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:37:28 - The name 'Widget' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Widget'. - non_type_as_type_argument
  error - pages/welcome_page.dart:38:19 - Undefined name 'SvgPicture'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:39:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/welcome_page.dart:40:19 - The method 'Text' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/welcome_page.dart:42:28 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:43:39 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:45:32 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:47:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/welcome_page.dart:48:19 - The method 'Text' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - pages/welcome_page.dart:50:28 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:51:32 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:53:25 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - pages/welcome_page.dart:54:19 - The method 'ElevatedButton' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'ElevatedButton'. - undefined_method
  error - pages/welcome_page.dart:56:28 - Undefined name 'ElevatedButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:57:38 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - pages/welcome_page.dart:62:28 - The method 'Text' isn't defined for the type 'WelcomePage'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - services/background_service.dart:4:8 - Target of URI doesn't exist: 'dart:ui'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/background_service.dart:6:8 - Target of URI doesn't exist: 'package:flutter_background_service/flutter_background_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/background_service.dart:7:8 - Target of URI doesn't exist: 'package:flutter_local_notifications/flutter_local_notifications.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/background_service.dart:8:8 - Target of URI doesn't exist: 'package:intl/intl.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/background_service.dart:9:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/background_service.dart:17:14 - Undefined class 'ServiceInstance'. Try changing the name to the name of an existing class, or creating a class with the name 'ServiceInstance'. - undefined_class
  error - services/background_service.dart:18:3 - Undefined name 'DartPluginRegistrant'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:36:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:60:11 - Undefined class 'AndroidNotificationDetails'. Try changing the name to the name of an existing class, or creating a class with the name 'AndroidNotificationDetails'. - undefined_class
  error - services/background_service.dart:61:9 - The function 'AndroidNotificationDetails' isn't defined. Try importing the library that defines 'AndroidNotificationDetails', correcting the name to the name of an existing function, or defining a function named 'AndroidNotificationDetails'. - undefined_function
  error - services/background_service.dart:65:19 - Undefined name 'Importance'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:66:17 - Undefined name 'Priority'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:69:17 - The name 'AndroidNotificationAction' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'AndroidNotificationAction'. - non_type_as_type_argument
  error - services/background_service.dart:70:9 - The function 'AndroidNotificationAction' isn't defined. Try importing the library that defines 'AndroidNotificationAction', correcting the name to the name of an existing function, or defining a function named 'AndroidNotificationAction'. - undefined_function
  error - services/background_service.dart:78:11 - Undefined class 'NotificationDetails'. Try changing the name to the name of an existing class, or creating a class with the name 'NotificationDetails'. - undefined_class
  error - services/background_service.dart:78:49 - The function 'NotificationDetails' isn't defined. Try importing the library that defines 'NotificationDetails', correcting the name to the name of an existing function, or defining a function named 'NotificationDetails'. - undefined_function
  error - services/background_service.dart:94:21 - The function 'DateFormat' isn't defined. Try importing the library that defines 'DateFormat', correcting the name to the name of an existing function, or defining a function named 'DateFormat'. - undefined_function
  error - services/background_service.dart:152:27 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:172:11 - The function 'DateFormat' isn't defined. Try importing the library that defines 'DateFormat', correcting the name to the name of an existing function, or defining a function named 'DateFormat'. - undefined_function
  error - services/background_service.dart:230:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:260:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/background_service.dart:332:29 - The function 'DateFormat' isn't defined. Try importing the library that defines 'DateFormat', correcting the name to the name of an existing function, or defining a function named 'DateFormat'. - undefined_function
  error - services/debug_log_service.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/debug_log_service.dart:9:9 - Undefined class 'ValueNotifier'. Try changing the name to the name of an existing class, or creating a class with the name 'ValueNotifier'. - undefined_class
  error - services/debug_log_service.dart:9:52 - The method 'ValueNotifier' isn't defined for the type 'DebugLogService'. Try correcting the name to the name of an existing method, or defining a method named 'ValueNotifier'. - undefined_method
  error - services/debug_log_service.dart:24:5 - The method 'debugPrint' isn't defined for the type 'DebugLogService'. Try correcting the name to the name of an existing method, or defining a method named 'debugPrint'. - undefined_method
  error - services/error_log_service.dart:2:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/error_log_service.dart:12:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/error_log_service.dart:32:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/error_log_service.dart:49:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/health_service.dart:1:8 - Target of URI doesn't exist: 'package:health/health.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/health_service.dart:2:8 - Target of URI doesn't exist: 'package:walkgo/services/error_log_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/health_service.dart:16:22 - The method 'Health' isn't defined for the type 'HealthService'. Try correcting the name to the name of an existing method, or defining a method named 'Health'. - undefined_method
  error - services/health_service.dart:20:40 - Undefined name 'HealthDataType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/health_service.dart:23:11 - Undefined name 'HealthDataType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/health_service.dart:35:7 - The method 'ErrorLogService' isn't defined for the type 'HealthService'. Try correcting the name to the name of an existing method, or defining a method named 'ErrorLogService'. - undefined_method
  error - services/health_service.dart:48:22 - The method 'Health' isn't defined for the type 'HealthService'. Try correcting the name to the name of an existing method, or defining a method named 'Health'. - undefined_method
  error - services/health_service.dart:51:15 - Undefined name 'HealthDataType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/health_service.dart:57:7 - The method 'ErrorLogService' isn't defined for the type 'HealthService'. Try correcting the name to the name of an existing method, or defining a method named 'ErrorLogService'. - undefined_method
  error - services/health_service.dart:67:20 - The method 'Health' isn't defined for the type 'HealthService'. Try correcting the name to the name of an existing method, or defining a method named 'Health'. - undefined_method
  error - services/health_service.dart:68:20 - Undefined name 'HealthDataType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/language_service.dart:1:8 - Target of URI doesn't exist: 'dart:ui'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/language_service.dart:2:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/language_service.dart:3:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/language_service.dart:6:28 - Classes can only mix in mixins and classes. - mixin_of_non_class
  error - services/language_service.dart:9:3 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - services/language_service.dart:10:9 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - services/language_service.dart:10:32 - Undefined name 'PlatformDispatcher'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/language_service.dart:13:3 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - services/language_service.dart:16:3 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - services/language_service.dart:36:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/language_service.dart:39:25 - The method 'Locale' isn't defined for the type 'LanguageService'. Try correcting the name to the name of an existing method, or defining a method named 'Locale'. - undefined_method
  error - services/language_service.dart:43:5 - The method 'notifyListeners' isn't defined for the type 'LanguageService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/language_service.dart:47:26 - Undefined class 'Locale'. Try changing the name to the name of an existing class, or creating a class with the name 'Locale'. - undefined_class
  error - services/language_service.dart:48:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/language_service.dart:50:23 - The method 'Locale' isn't defined for the type 'LanguageService'. Try correcting the name to the name of an existing method, or defining a method named 'Locale'. - undefined_method
  error - services/language_service.dart:52:5 - The method 'notifyListeners' isn't defined for the type 'LanguageService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/language_service.dart:57:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/language_service.dart:60:5 - The method 'notifyListeners' isn't defined for the type 'LanguageService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/log_service.dart:2:8 - Target of URI doesn't exist: 'package:flutter/foundation.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/log_service.dart:3:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/log_service.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/constants.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/log_service.dart:5:8 - Target of URI doesn't exist: 'package:flutter_background_service/flutter_background_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/log_service.dart:7:26 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - services/log_service.dart:20:23 - The method 'FlutterBackgroundService' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - services/log_service.dart:27:11 - Undefined name 'kDebugMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:43:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:61:5 - The method 'notifyListeners' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/log_service.dart:68:21 - The method 'FlutterBackgroundService' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - services/log_service.dart:79:27 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:105:7 - The method 'notifyListeners' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/log_service.dart:113:5 - The method 'notifyListeners' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/log_service.dart:116:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:118:24 - Undefined name 'prefSessionTotalSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:121:21 - The method 'FlutterBackgroundService' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - services/log_service.dart:128:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:129:24 - Undefined name 'prefSessionTotalSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/log_service.dart:131:21 - The method 'FlutterBackgroundService' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - services/log_service.dart:136:5 - The method 'notifyListeners' isn't defined for the type 'LogService'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - services/log_utils.dart:2:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/log_utils.dart:13:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/permission_service.dart:1:8 - Target of URI doesn't exist: 'package:permission_handler/permission_handler.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/permission_service.dart:9:38 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/permission_service.dart:10:33 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/permission_service.dart:40:13 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/permission_service.dart:44:13 - Undefined name 'Permission'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/preference_service.dart:1:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/preference_service.dart:12:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/preference_service.dart:17:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/preference_service.dart:22:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/preference_service.dart:27:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/preference_service.dart:32:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:5:8 - Target of URI doesn't exist: 'package:crypto/crypto.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:6:8 - Target of URI doesn't exist: 'package:device_info_plus/device_info_plus.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:7:8 - Target of URI doesn't exist: 'package:dio/dio.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:8:8 - Target of URI doesn't exist: 'package:in_app_update/in_app_update.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:9:8 - Target of URI doesn't exist: 'package:open_filex/open_filex.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:10:8 - Target of URI doesn't exist: 'package:package_info_plus/package_info_plus.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:11:8 - Target of URI doesn't exist: 'package:path_provider/path_provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:12:8 - Target of URI doesn't exist: 'package:pub_semver/pub_semver.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:13:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:14:8 - Target of URI doesn't exist: 'package:walkgo/constants.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - services/update_service.dart:45:23 - The method 'BaseOptions' isn't defined for the type 'UpdateService'. Try correcting the name to the name of an existing method, or defining a method named 'BaseOptions'. - undefined_method
  error - services/update_service.dart:49:30 - The method 'Dio' isn't defined for the type 'UpdateService'. Try correcting the name to the name of an existing method, or defining a method named 'Dio'. - undefined_method
  error - services/update_service.dart:54:10 - The name 'DioException' isn't a type and can't be used in an on-catch clause. Try correcting the name to match an existing class. - non_type_in_catch_clause
  error - services/update_service.dart:55:21 - Undefined name 'DioExceptionType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:56:21 - Undefined name 'DioExceptionType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:65:9 - Undefined name 'updateChannel'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:67:15 - Undefined class 'AppUpdateInfo'. Try changing the name to the name of an existing class, or creating a class with the name 'AppUpdateInfo'. - undefined_class
  error - services/update_service.dart:67:48 - Undefined name 'InAppUpdate'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:69:13 - Undefined name 'UpdateAvailability'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:86:37 - Undefined name 'PackageInfo'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:89:15 - Undefined name 'Version'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:89:46 - Undefined name 'Version'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:100:38 - Undefined class 'AppUpdateInfo'. Try changing the name to the name of an existing class, or creating a class with the name 'AppUpdateInfo'. - undefined_class
  error - services/update_service.dart:101:36 - Undefined name 'UpdateAvailability'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:102:13 - Undefined name 'InAppUpdate'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:114:26 - The method 'DeviceInfoPlugin' isn't defined for the type 'UpdateService'. Try correcting the name to the name of an existing method, or defining a method named 'DeviceInfoPlugin'. - undefined_method
  error - services/update_service.dart:154:26 - Undefined name 'OpenFilex'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - services/update_service.dart:164:5 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - services/update_service.dart:190:29 - The method 'getTemporaryDirectory' isn't defined for the type 'UpdateService'. Try correcting the name to the name of an existing method, or defining a method named 'getTemporaryDirectory'. - undefined_method
  error - services/update_service.dart:195:13 - The method 'Dio' isn't defined for the type 'UpdateService'. Try correcting the name to the name of an existing method, or defining a method named 'Dio'. - undefined_method
  error - services/update_service.dart:207:15 - The method 'Dio' isn't defined for the type 'UpdateService'. Try correcting the name to the name of an existing method, or defining a method named 'Dio'. - undefined_method
  error - services/update_service.dart:232:10 - The name 'DioException' isn't a type and can't be used in an on-catch clause. Try correcting the name to match an existing class. - non_type_in_catch_clause
  error - services/update_service.dart:258:24 - Undefined name 'sha1'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - theme_provider.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - theme_provider.dart:2:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - theme_provider.dart:6:26 - Classes can only mix in mixins and classes. - mixin_of_non_class
  error - theme_provider.dart:7:3 - Undefined class 'ThemeMode'. Try changing the name to the name of an existing class, or creating a class with the name 'ThemeMode'. - undefined_class
  error - theme_provider.dart:7:26 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - theme_provider.dart:9:3 - Undefined class 'ThemeMode'. Try changing the name to the name of an existing class, or creating a class with the name 'ThemeMode'. - undefined_class
  error - theme_provider.dart:16:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - theme_provider.dart:19:20 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - theme_provider.dart:21:20 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - theme_provider.dart:23:23 - Undefined name 'ThemeMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - theme_provider.dart:26:5 - The method 'notifyListeners' isn't defined for the type 'ThemeProvider'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - theme_provider.dart:29:29 - Undefined class 'ThemeMode'. Try changing the name to the name of an existing class, or creating a class with the name 'ThemeMode'. - undefined_class
  error - theme_provider.dart:32:5 - The method 'notifyListeners' isn't defined for the type 'ThemeProvider'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - theme_provider.dart:33:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/advanced_settings_viewmodel.dart:2:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/advanced_settings_viewmodel.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/constants.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/advanced_settings_viewmodel.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/viewmodels/home_page_viewmodel.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/advanced_settings_viewmodel.dart:5:8 - Target of URI doesn't exist: 'package:walkgo/services/debug_log_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/advanced_settings_viewmodel.dart:7:41 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - viewmodels/advanced_settings_viewmodel.dart:9:9 - Undefined class 'HomePageViewModel'. Try changing the name to the name of an existing class, or creating a class with the name 'HomePageViewModel'. - undefined_class
  error - viewmodels/advanced_settings_viewmodel.dart:33:3 - The method 'DebugLogService' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'DebugLogService'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:40:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:47:11 - The method 'dispose' isn't defined in a superclass of 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass. - undefined_super_member
  error - viewmodels/advanced_settings_viewmodel.dart:52:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:53:36 - Undefined name 'prefOffsetEnabled'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:54:34 - Undefined name 'prefOffsetSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:55:34 - Undefined name 'prefManualSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:56:39 - Undefined name 'prefAutoPauseEnabled'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:58:23 - Undefined name 'prefAutoPauseThreshold'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:60:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:75:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:76:25 - Undefined name 'prefOffsetEnabled'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:78:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:85:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:86:24 - Undefined name 'prefOffsetSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:88:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:96:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:97:24 - Undefined name 'prefManualSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:99:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:107:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:108:25 - Undefined name 'prefAutoPauseEnabled'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:110:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/advanced_settings_viewmodel.dart:118:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:119:24 - Undefined name 'prefAutoPauseThreshold'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/advanced_settings_viewmodel.dart:121:5 - The method 'notifyListeners' isn't defined for the type 'AdvancedSettingsViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:2:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:3:8 - Target of URI doesn't exist: 'package:flutter_background_service/flutter_background_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:4:8 - Target of URI doesn't exist: 'package:fluttertoast/fluttertoast.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:5:8 - Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:6:8 - Target of URI doesn't exist: 'package:walkgo/services/health_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:7:8 - Target of URI doesn't exist: 'package:walkgo/constants.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:8:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:9:8 - Target of URI doesn't exist: 'package:walkgo/services/log_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:10:8 - Target of URI doesn't exist: 'package:walkgo/services/debug_log_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - viewmodels/home_page_viewmodel.dart:12:33 - Mixin can only be applied to class. - mixin_with_non_class_superclass
  error - viewmodels/home_page_viewmodel.dart:12:53 - Classes can only mix in mixins and classes. - mixin_of_non_class
  error - viewmodels/home_page_viewmodel.dart:13:9 - Undefined class 'FlutterBackgroundService'. Try changing the name to the name of an existing class, or creating a class with the name 'FlutterBackgroundService'. - undefined_class
  error - viewmodels/home_page_viewmodel.dart:13:45 - The method 'FlutterBackgroundService' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'FlutterBackgroundService'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:40:3 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - viewmodels/home_page_viewmodel.dart:42:16 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - viewmodels/home_page_viewmodel.dart:47:9 - The method 'notifyListeners' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:54:5 - The method 'LogService' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'LogService'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:55:5 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:60:3 - The method 'DebugLogService' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'DebugLogService'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:65:5 - Undefined name 'WidgetsBinding'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:66:11 - The method 'dispose' isn't defined in a superclass of 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass. - undefined_super_member
  error - viewmodels/home_page_viewmodel.dart:70:35 - Undefined class 'AppLifecycleState'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLifecycleState'. - undefined_class
  error - viewmodels/home_page_viewmodel.dart:71:18 - Undefined name 'AppLifecycleState'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:124:7 - The method 'notifyListeners' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:135:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:138:32 - Undefined name 'prefBaseSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:139:31 - Undefined name 'prefInterval'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:140:39 - Undefined name 'prefAutoPauseEnabled'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:141:40 - Undefined name 'prefAutoPauseThreshold'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:142:36 - Undefined name 'prefOffsetEnabled'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:143:33 - Undefined name 'prefOffsetSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:146:41 - Undefined name 'prefSessionTotalSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:147:40 - Undefined name 'prefLastStepsWritten'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:156:5 - The method 'notifyListeners' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:161:30 - The method 'HealthService' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'HealthService'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:163:5 - The method 'notifyListeners' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:186:5 - Undefined name 'Fluttertoast'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:188:24 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:193:5 - Undefined name 'Fluttertoast'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:199:25 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:200:41 - Undefined name 'prefAutoPauseThreshold'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:215:27 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:216:26 - Undefined name 'prefBaseSteps'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:219:5 - The method 'notifyListeners' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:226:27 - Undefined name 'SharedPreferences'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:227:26 - Undefined name 'prefInterval'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - viewmodels/home_page_viewmodel.dart:230:5 - The method 'notifyListeners' isn't defined for the type 'HomePageViewModel'. Try correcting the name to the name of an existing method, or defining a method named 'notifyListeners'. - undefined_method
  error - viewmodels/home_page_viewmodel.dart:266:31 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/app_dialog.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/app_dialog.dart:3:25 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/app_dialog.dart:5:9 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/app_dialog.dart:6:14 - The name 'Widget' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Widget'. - non_type_as_type_argument
  error - widgets/app_dialog.dart:7:9 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/app_dialog.dart:10:11 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - widgets/app_dialog.dart:18:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/app_dialog.dart:18:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/app_dialog.dart:19:25 - Undefined name 'MediaQuery'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:25:12 - The method 'Center' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Center'. - undefined_method
  error - widgets/app_dialog.dart:26:14 - The method 'SizedBox' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - widgets/app_dialog.dart:28:16 - The method 'Dialog' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Dialog'. - undefined_method
  error - widgets/app_dialog.dart:29:25 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:31:15 - The method 'RoundedRectangleBorder' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - widgets/app_dialog.dart:31:52 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:32:18 - The method 'Column' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/app_dialog.dart:33:27 - Undefined name 'MainAxisSize'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:34:33 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:37:17 - The method 'Padding' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - widgets/app_dialog.dart:38:34 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:40:23 - The method 'Text' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/app_dialog.dart:42:32 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:43:43 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:47:15 - The method 'Flexible' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Flexible'. - undefined_method
  error - widgets/app_dialog.dart:48:24 - The method 'Padding' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - widgets/app_dialog.dart:49:34 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:50:26 - The method 'SizedBox' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - widgets/app_dialog.dart:57:17 - The method 'Padding' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - widgets/app_dialog.dart:58:34 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/app_dialog.dart:59:26 - The method 'Row' isn't defined for the type 'AppDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Row'. - undefined_method
  error - widgets/app_dialog.dart:60:40 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/parameter_settings_card.dart:2:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/parameter_settings_card.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/parameter_settings_card.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/viewmodels/home_page_viewmodel.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/parameter_settings_card.dart:5:8 - Target of URI doesn't exist: 'package:walkgo/pages/advanced_parameters_page.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/parameter_settings_card.dart:7:37 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/parameter_settings_card.dart:8:38 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - widgets/parameter_settings_card.dart:11:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - widgets/parameter_settings_card.dart:14:43 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/parameter_settings_card.dart:15:8 - Undefined class 'TextEditingController'. Try changing the name to the name of an existing class, or creating a class with the name 'TextEditingController'. - undefined_class
  error - widgets/parameter_settings_card.dart:16:8 - Undefined class 'TextEditingController'. Try changing the name to the name of an existing class, or creating a class with the name 'TextEditingController'. - undefined_class
  error - widgets/parameter_settings_card.dart:17:3 - Undefined class 'HomePageViewModel'. Try changing the name to the name of an existing class, or creating a class with the name 'HomePageViewModel'. - undefined_class
  error - widgets/parameter_settings_card.dart:21:11 - The method 'initState' isn't defined in a superclass of '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - widgets/parameter_settings_card.dart:22:28 - The method 'TextEditingController' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'TextEditingController'. - undefined_method
  error - widgets/parameter_settings_card.dart:23:27 - The method 'TextEditingController' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'TextEditingController'. - undefined_method
  error - widgets/parameter_settings_card.dart:30:11 - The method 'dispose' isn't defined in a superclass of '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass. - undefined_super_member
  error - widgets/parameter_settings_card.dart:35:11 - The method 'didChangeDependencies' isn't defined in a superclass of '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'didChangeDependencies' in a superclass. - undefined_super_member
  error - widgets/parameter_settings_card.dart:36:23 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:36:35 - The name 'HomePageViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'HomePageViewModel'. - non_type_as_type_argument
  error - widgets/parameter_settings_card.dart:36:54 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:57:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/parameter_settings_card.dart:57:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/parameter_settings_card.dart:59:23 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:59:35 - The name 'HomePageViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'HomePageViewModel'. - non_type_as_type_argument
  error - widgets/parameter_settings_card.dart:63:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:64:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:67:12 - The method 'Card' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Card'. - undefined_method
  error - widgets/parameter_settings_card.dart:69:14 - The method 'RoundedRectangleBorder' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - widgets/parameter_settings_card.dart:70:23 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:71:15 - The method 'BorderSide' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'BorderSide'. - undefined_method
  error - widgets/parameter_settings_card.dart:73:14 - The method 'Padding' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - widgets/parameter_settings_card.dart:74:24 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:75:16 - The method 'Column' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/parameter_settings_card.dart:76:31 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:78:13 - The method 'Text' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/parameter_settings_card.dart:81:29 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:84:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/parameter_settings_card.dart:88:21 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:92:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/parameter_settings_card.dart:96:21 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:100:13 - The method 'Align' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Align'. - undefined_method
  error - widgets/parameter_settings_card.dart:101:26 - Undefined name 'Alignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:102:22 - Undefined name 'TextButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:103:29 - The name 'Icon' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/parameter_settings_card.dart:103:34 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:104:24 - The method 'Text' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/parameter_settings_card.dart:105:24 - Undefined name 'TextButton'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:108:26 - The method 'RoundedRectangleBorder' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'RoundedRectangleBorder'. - undefined_method
  error - widgets/parameter_settings_card.dart:109:35 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:111:34 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:116:34 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:118:19 - The method 'MaterialPageRoute' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'MaterialPageRoute'. - undefined_method
  error - widgets/parameter_settings_card.dart:119:49 - The name 'AdvancedParametersPage' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/parameter_settings_card.dart:130:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/parameter_settings_card.dart:131:14 - Undefined class 'TextEditingController'. Try changing the name to the name of an existing class, or creating a class with the name 'TextEditingController'. - undefined_class
  error - widgets/parameter_settings_card.dart:133:14 - Undefined class 'IconData'. Try changing the name to the name of an existing class, or creating a class with the name 'IconData'. - undefined_class
  error - widgets/parameter_settings_card.dart:134:14 - Undefined class 'ValueChanged'. Try changing the name to the name of an existing class, or creating a class with the name 'ValueChanged'. - undefined_class
  error - widgets/parameter_settings_card.dart:137:12 - The method 'TextFormField' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'TextFormField'. - undefined_method
  error - widgets/parameter_settings_card.dart:139:21 - Undefined name 'TextInputType'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:141:19 - The method 'InputDecoration' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'InputDecoration'. - undefined_method
  error - widgets/parameter_settings_card.dart:143:21 - The method 'Icon' isn't defined for the type '_ParameterSettingsCardState'. Try correcting the name to the name of an existing method, or defining a method named 'Icon'. - undefined_method
  error - widgets/parameter_settings_card.dart:144:23 - The name 'OutlineInputBorder' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/parameter_settings_card.dart:145:25 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/parameter_settings_card.dart:145:42 - Undefined name 'Radius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/release_notes_dialog.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/release_notes_dialog.dart:2:8 - Target of URI doesn't exist: 'package:flutter_markdown_plus/flutter_markdown_plus.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/release_notes_dialog.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/release_notes_dialog.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/services/update_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/release_notes_dialog.dart:5:8 - Target of URI doesn't exist: 'package:walkgo/widgets/app_dialog.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/release_notes_dialog.dart:7:34 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/release_notes_dialog.dart:8:9 - Undefined class 'ReleaseInfo'. Try changing the name to the name of an existing class, or creating a class with the name 'ReleaseInfo'. - undefined_class
  error - widgets/release_notes_dialog.dart:10:35 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - widgets/release_notes_dialog.dart:13:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/release_notes_dialog.dart:13:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/release_notes_dialog.dart:14:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/release_notes_dialog.dart:16:12 - The method 'AppDialog' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'AppDialog'. - undefined_method
  error - widgets/release_notes_dialog.dart:18:16 - The method 'ConstrainedBox' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'ConstrainedBox'. - undefined_method
  error - widgets/release_notes_dialog.dart:19:22 - The method 'BoxConstraints' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'BoxConstraints'. - undefined_method
  error - widgets/release_notes_dialog.dart:20:22 - Undefined name 'MediaQuery'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/release_notes_dialog.dart:22:16 - The method 'Scrollbar' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Scrollbar'. - undefined_method
  error - widgets/release_notes_dialog.dart:23:18 - The method 'SingleChildScrollView' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'SingleChildScrollView'. - undefined_method
  error - widgets/release_notes_dialog.dart:24:20 - The method 'SizedBox' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - widgets/release_notes_dialog.dart:27:22 - The method 'Markdown' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Markdown'. - undefined_method
  error - widgets/release_notes_dialog.dart:31:32 - The name 'NeverScrollableScrollPhysics' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/release_notes_dialog.dart:38:9 - The method 'TextButton' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - widgets/release_notes_dialog.dart:39:28 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/release_notes_dialog.dart:40:18 - The method 'Text' isn't defined for the type 'ReleaseNotesDialog'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/status_card.dart:2:8 - Target of URI doesn't exist: 'package:provider/provider.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/status_card.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/status_card.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/viewmodels/home_page_viewmodel.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/status_card.dart:6:26 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/status_card.dart:7:27 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - widgets/status_card.dart:10:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/status_card.dart:10:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/status_card.dart:11:23 - Undefined name 'Provider'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:11:35 - The name 'HomePageViewModel' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'HomePageViewModel'. - non_type_as_type_argument
  error - widgets/status_card.dart:12:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:13:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:24:12 - The method 'AnimatedContainer' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'AnimatedContainer'. - undefined_method
  error - widgets/status_card.dart:26:14 - Undefined name 'Curves'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:27:19 - The method 'BoxDecoration' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'BoxDecoration'. - undefined_method
  error - widgets/status_card.dart:29:23 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:31:14 - The method 'Padding' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Padding'. - undefined_method
  error - widgets/status_card.dart:32:24 - Undefined name 'EdgeInsets'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:33:16 - The method 'Column' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/status_card.dart:34:25 - Undefined name 'MainAxisSize'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:37:13 - The method 'SizedBox' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - widgets/status_card.dart:39:22 - The method 'Column' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/status_card.dart:40:36 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:43:21 - The method 'Icon' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Icon'. - undefined_method
  error - widgets/status_card.dart:44:23 - Undefined name 'Icons'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:48:27 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/status_card.dart:49:21 - The method 'Text' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:51:34 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:54:37 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:59:21 - The method 'Text' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:63:37 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:66:27 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/status_card.dart:67:21 - The method 'Text' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:71:37 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:79:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/status_card.dart:81:13 - The method 'SizedBox' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - widgets/status_card.dart:83:22 - The method 'AnimatedCrossFade' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'AnimatedCrossFade'. - undefined_method
  error - widgets/status_card.dart:84:29 - The method 'Container' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Container'. - undefined_method
  error - widgets/status_card.dart:86:30 - Undefined name 'Alignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:87:31 - The method 'BoxDecoration' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'BoxDecoration'. - undefined_method
  error - widgets/status_card.dart:89:35 - Undefined name 'BorderRadius'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:91:26 - The method 'Column' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/status_card.dart:92:40 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:94:23 - The method 'Text' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:98:36 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:101:39 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:107:30 - The method 'Column' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/status_card.dart:108:38 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:110:21 - The method 'Divider' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Divider'. - undefined_method
  error - widgets/status_card.dart:111:27 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/status_card.dart:112:21 - The method 'Row' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Row'. - undefined_method
  error - widgets/status_card.dart:113:42 - Undefined name 'MainAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:114:43 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:116:25 - The method 'Expanded' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - widgets/status_card.dart:124:25 - The method 'Expanded' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - widgets/status_card.dart:132:25 - The method 'Expanded' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Expanded'. - undefined_method
  error - widgets/status_card.dart:147:23 - Undefined name 'CrossFadeState'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:148:23 - Undefined name 'CrossFadeState'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:158:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/status_card.dart:161:14 - Undefined class 'ThemeData'. Try changing the name to the name of an existing class, or creating a class with the name 'ThemeData'. - undefined_class
  error - widgets/status_card.dart:162:14 - Undefined class 'Color'. Try changing the name to the name of an existing class, or creating a class with the name 'Color'. - undefined_class
  error - widgets/status_card.dart:164:12 - The method 'Column' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/status_card.dart:165:27 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:167:9 - The method 'Container' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Container'. - undefined_method
  error - widgets/status_card.dart:169:22 - Undefined name 'Alignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:170:18 - The method 'Text' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:172:24 - Undefined name 'TextAlign'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:175:27 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/status_card.dart:179:15 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/status_card.dart:180:9 - The method 'Text' isn't defined for the type 'StatusCard'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/status_card.dart:184:25 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_dialog.dart:2:8 - Target of URI doesn't exist: 'package:flutter_markdown_plus/flutter_markdown_plus.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_dialog.dart:3:8 - Target of URI doesn't exist: 'package:url_launcher/url_launcher.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_dialog.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_dialog.dart:5:8 - Target of URI doesn't exist: 'package:walkgo/services/update_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_dialog.dart:6:8 - Target of URI doesn't exist: 'package:walkgo/widgets/app_dialog.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_dialog.dart:8:28 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/update_dialog.dart:9:9 - Undefined class 'ReleaseInfo'. Try changing the name to the name of an existing class, or creating a class with the name 'ReleaseInfo'. - undefined_class
  error - widgets/update_dialog.dart:11:29 - No associated named super constructor parameter. Try changing the name to the name of an existing named super constructor parameter, or creating such named parameter. - super_formal_parameter_without_associated_named
  error - widgets/update_dialog.dart:13:20 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/update_dialog.dart:13:42 - Undefined class 'ReleaseInfo'. Try changing the name to the name of an existing class, or creating a class with the name 'ReleaseInfo'. - undefined_class
  error - widgets/update_dialog.dart:14:5 - The method 'showDialog' isn't defined for the type 'UpdateDialog'. Try correcting the name to the name of an existing method, or defining a method named 'showDialog'. - undefined_method
  error - widgets/update_dialog.dart:22:3 - Undefined class 'State'. Try changing the name to the name of an existing class, or creating a class with the name 'State'. - undefined_class
  error - widgets/update_dialog.dart:27:34 - Classes can only extend other classes. Try specifying a different superclass, or removing the extends clause. - extends_non_class
  error - widgets/update_dialog.dart:35:26 - The method 'UpdateService' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'UpdateService'. - undefined_method
  error - widgets/update_dialog.dart:39:11 - The method 'initState' isn't defined in a superclass of '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'initState' in a superclass. - undefined_super_member
  error - widgets/update_dialog.dart:45:9 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:46:7 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:53:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/update_dialog.dart:53:16 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/update_dialog.dart:54:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:55:12 - The method 'AppDialog' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'AppDialog'. - undefined_method
  error - widgets/update_dialog.dart:57:16 - The method 'ConstrainedBox' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'ConstrainedBox'. - undefined_method
  error - widgets/update_dialog.dart:58:22 - The method 'BoxConstraints' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'BoxConstraints'. - undefined_method
  error - widgets/update_dialog.dart:59:22 - Undefined name 'MediaQuery'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:61:16 - The method 'SingleChildScrollView' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'SingleChildScrollView'. - undefined_method
  error - widgets/update_dialog.dart:62:18 - The method 'SizedBox' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'SizedBox'. - undefined_method
  error - widgets/update_dialog.dart:72:20 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - widgets/update_dialog.dart:82:3 - Undefined class 'Widget'. Try changing the name to the name of an existing class, or creating a class with the name 'Widget'. - undefined_class
  error - widgets/update_dialog.dart:82:24 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/update_dialog.dart:82:46 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - widgets/update_dialog.dart:83:19 - Undefined name 'Theme'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:87:16 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:89:18 - The method 'TextStyle' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'TextStyle'. - undefined_method
  error - widgets/update_dialog.dart:93:16 - The method 'Column' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/update_dialog.dart:94:25 - Undefined name 'MainAxisSize'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:95:31 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:97:13 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:98:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/update_dialog.dart:99:13 - The method 'LinearProgressIndicator' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'LinearProgressIndicator'. - undefined_method
  error - widgets/update_dialog.dart:104:16 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:109:18 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:112:16 - The method 'Column' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/update_dialog.dart:113:25 - Undefined name 'MainAxisSize'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:114:31 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:116:13 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:117:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/update_dialog.dart:118:13 - The method 'SelectableText' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'SelectableText'. - undefined_method
  error - widgets/update_dialog.dart:120:28 - The name 'TextStyle' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/update_dialog.dart:120:50 - Undefined name 'FontWeight'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:126:16 - The method 'Column' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Column'. - undefined_method
  error - widgets/update_dialog.dart:127:25 - Undefined name 'MainAxisSize'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:128:31 - Undefined name 'CrossAxisAlignment'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:130:13 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:130:45 - Undefined name 'widget'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:131:19 - The name 'SizedBox' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/update_dialog.dart:132:13 - The method 'Markdown' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Markdown'. - undefined_method
  error - widgets/update_dialog.dart:133:21 - Undefined name 'widget'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:135:30 - The name 'NeverScrollableScrollPhysics' isn't a class. Try correcting the name to match an existing class. - creation_with_non_type
  error - widgets/update_dialog.dart:142:8 - The name 'Widget' isn't a type, so it can't be used as a type argument. Try correcting the name to an existing type, or defining a type named 'Widget'. - non_type_as_type_argument
  error - widgets/update_dialog.dart:142:30 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/update_dialog.dart:142:52 - Undefined class 'AppLocalizations'. Try changing the name to the name of an existing class, or creating a class with the name 'AppLocalizations'. - undefined_class
  error - widgets/update_dialog.dart:150:11 - The method 'TextButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - widgets/update_dialog.dart:151:30 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:152:20 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:154:11 - The method 'ElevatedButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'ElevatedButton'. - undefined_method
  error - widgets/update_dialog.dart:154:60 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:159:11 - The method 'TextButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - widgets/update_dialog.dart:160:30 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:161:20 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:163:11 - The method 'ElevatedButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'ElevatedButton'. - undefined_method
  error - widgets/update_dialog.dart:163:60 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:168:11 - The method 'TextButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - widgets/update_dialog.dart:170:15 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:172:20 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:174:11 - The method 'ElevatedButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'ElevatedButton'. - undefined_method
  error - widgets/update_dialog.dart:175:30 - The method 'launchUrl' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'launchUrl'. - undefined_method
  error - widgets/update_dialog.dart:176:25 - Undefined name 'widget'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:177:21 - Undefined name 'LaunchMode'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:179:20 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:186:11 - The method 'TextButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - widgets/update_dialog.dart:187:30 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:188:20 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:190:11 - The method 'TextButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'TextButton'. - undefined_method
  error - widgets/update_dialog.dart:192:15 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:196:20 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:198:11 - The method 'ElevatedButton' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'ElevatedButton'. - undefined_method
  error - widgets/update_dialog.dart:198:60 - The method 'Text' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'Text'. - undefined_method
  error - widgets/update_dialog.dart:204:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:204:38 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:206:7 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:213:5 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:220:7 - Undefined name 'widget'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:224:13 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:225:11 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:231:13 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:232:11 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:238:13 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:239:11 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:247:35 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:248:7 - The method 'setState' isn't defined for the type '_UpdateDialogState'. Try correcting the name to the name of an existing method, or defining a method named 'setState'. - undefined_method
  error - widgets/update_dialog.dart:261:9 - Undefined name 'mounted'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:262:7 - Undefined name 'Navigator'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_dialog.dart:262:21 - Undefined name 'context'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_flow_dialog.dart:1:8 - Target of URI doesn't exist: 'package:flutter/material.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_flow_dialog.dart:2:8 - Target of URI doesn't exist: 'package:fluttertoast/fluttertoast.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_flow_dialog.dart:3:8 - Target of URI doesn't exist: 'package:walkgo/l10n/app_localizations.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_flow_dialog.dart:4:8 - Target of URI doesn't exist: 'package:walkgo/services/update_service.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_flow_dialog.dart:5:8 - Target of URI doesn't exist: 'package:walkgo/widgets/update_dialog.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - widgets/update_flow_dialog.dart:8:27 - Undefined class 'BuildContext'. Try changing the name to the name of an existing class, or creating a class with the name 'BuildContext'. - undefined_class
  error - widgets/update_flow_dialog.dart:9:18 - Undefined name 'AppLocalizations'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_flow_dialog.dart:14:29 - The method 'UpdateService' isn't defined for the type 'UpdateFlowDialog'. Try correcting the name to the name of an existing method, or defining a method named 'UpdateService'. - undefined_method
  error - widgets/update_flow_dialog.dart:17:41 - The name 'ReleaseInfo' isn't defined, so it can't be used in an 'is' expression. Try changing the name to the name of an existing type, or creating a type with the name 'ReleaseInfo'. - type_test_with_undefined_name
  error - widgets/update_flow_dialog.dart:19:9 - Undefined name 'UpdateDialog'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_flow_dialog.dart:25:13 - Undefined name 'UpdateDialog'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_flow_dialog.dart:42:5 - Undefined name 'Fluttertoast'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
  error - widgets/update_flow_dialog.dart:44:34 - Undefined name 'Colors'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
warning - l10n/app_localizations.dart:1133:28 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - l10n/app_localizations.dart:1138:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - l10n/app_localizations.dart:1142:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - main.dart:153:20 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - main.dart:158:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - main.dart:179:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/advanced_parameters_page.dart:11:33 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/advanced_parameters_page.dart:21:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/advanced_parameters_page.dart:50:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/advanced_parameters_page.dart:59:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/appearance_settings_page.dart:22:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/debug_log_page.dart:9:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/home_page.dart:17:19 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/home_page.dart:22:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/home_page.dart:49:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/home_page.dart:55:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/home_page.dart:64:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/language_settings_page.dart:32:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/log_page.dart:13:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/permission_handler_page.dart:14:32 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/permission_handler_page.dart:25:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/permission_handler_page.dart:31:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/permission_handler_page.dart:37:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/permission_handler_page.dart:157:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/settings_page.dart:23:23 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/settings_page.dart:30:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/settings_page.dart:75:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/splash_screen.dart:11:23 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/splash_screen.dart:16:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/splash_screen.dart:41:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - pages/welcome_page.dart:15:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - viewmodels/advanced_settings_viewmodel.dart:44:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - viewmodels/home_page_viewmodel.dart:64:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - viewmodels/home_page_viewmodel.dart:70:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/app_dialog.dart:18:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/parameter_settings_card.dart:11:32 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/parameter_settings_card.dart:20:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/parameter_settings_card.dart:27:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/parameter_settings_card.dart:34:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/parameter_settings_card.dart:57:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/release_notes_dialog.dart:13:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/status_card.dart:10:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/update_dialog.dart:22:23 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/update_dialog.dart:38:8 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member
warning - widgets/update_dialog.dart:53:10 - The method doesn't override an inherited method. Try updating this class to match the superclass, or removing the override annotation. - override_on_non_overriding_member

1362 issues found.



⚠️ [Error Found]: Analyzing lib...
No issues found!

