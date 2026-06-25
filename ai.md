# 🤖 WalkGo AI 共同協作知識庫 (ai.md)

本文件是 WalkGo 專案的**唯一真理來源 (Single Source of Truth)**。所有參與本專案的 AI 代理人必須嚴格遵守此文件中的規範與流程。

---

## 📜 第一章：AI 合作條約 (Collaboration Treaty)

### 1.1 核心運作原則
- **工作前閱讀**：任何 AI 在開始執行任務前，**必須**首先閱讀 `ai.md` 以同步最新的專案上下文與技術標準。
- **工作後寫回**：任務完成後，若產生了新的技術共識、解決了特定 Bug 或更新了實作邏輯，**必須**將其更新至 `ai.md` 的「專案共享記憶」區塊中。
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
- **[待添加]** ...
