# Flutter 專案開發與建置指南

本文件旨在提供一個清晰、完整的 Flutter 指令集，涵蓋從專案初始化到最終發佈的各個階段。

---

## 1. 專案初始化 (Project Initialization)

當您首次設定專案或在新環境中工作時，請執行此指令。

- **取得或更新套件**
  此指令會根據 `pubspec.yaml` 檔案下載所有需要的套件。這是設定新專案或拉取遠端更新後的第一步。
  ```bash
  flutter pub get
  ```

---

## 2. 開發工作流程 (Development Workflow)

這是日常開發中會反覆循環的步驟。

### 步驟 1: 程式碼與資源生成 (Code & Asset Generation)

當專案使用到程式碼生成或多國語言功能時，需要執行以下指令。

- **生成多國語言 (L10n)**
  根據 `lib/l10n` 目錄下的 `.arb` 檔案，自動生成或更新本地化所需的 Dart 程式碼。
  ```bash
  flutter gen-l10n
  ```

### 步驟 2: 除錯與程式碼分析 (Debugging & Analysis)

撰寫或生成程式碼後，執行靜態分析來確保程式碼品質。

- **靜態程式碼分析**
  執行此指令來檢查潛在的語法錯誤、風格問題或效能陷阱。
  ```bash
  flutter analyze
  ```

- **掃描未使用的檔案**
  此工具可以幫助您找到專案中未被引用的檔案，以保持程式碼庫的整潔。如果您尚未安裝，請先執行安裝指令。
  ```bash
  # 1. (如果尚未安裝) 安裝工具
  dart pub global activate dart_unused_files

  # 2. 執行掃描
  dart_unused_files scan
  ```

### 步驟 3: 運行與測試 (Running & Testing)

在模擬器或實體設備上運行應用，以進行功能測試和 UI 驗證。

- **在模擬器上運行應用**
  將應用程式安裝並運行於指定的模擬器。
  ```bash
  flutter run -d emulator-5554
  ```

---

## 3. 建置與發佈 (Build & Release)

當開發完成並準備發佈時，需要生成經過優化的正式版本。

- **清理專案**
  在進行正式建置前，建議先清除舊的建置快取，以避免潛在的衝突。
  ```bash
  flutter clean
  ```

- **通用 APK 建置**
  此指令會為所有主流的 Android 架構生成對應的 APK 檔案，並進行程式碼混淆與偵錯資訊分離，這是推薦的發佈方式。
  ```bash
  flutter build apk --split-per-abi --obfuscate --split-debug-info=./debug-info
  ```

### 針對特定平台的 APK 建置

在某些特定情境下，你可能只需要為單一平台建置 APK。

- **現代手機 (ARM 64-bit)**
  適用於目前絕大多數 Android 手機，提供最佳效能。
  ```bash
  flutter build apk --target-platform android-arm64 --obfuscate --split-debug-info=./debug-info
  ```

- **舊款手機 (ARM 32-bit)**
  若需要支援較舊的 32 位元設備，請使用此指令。
  ```bash
  flutter build apk --target-platform android-arm --obfuscate --split-debug-info=./debug-info
  ```

- **Android 模擬器 (x86_64)**
  此版本主要用於在電腦的 Android 模擬器上測試。
  ```bash
  flutter build apk --target-platform android-x64 --obfuscate --split-debug-info=./debug-info
  ```

---

## 4. 版本控制 (Version Control)

完成建置與測試後，將您的程式碼推送到遠端儲存庫。

- **推送變更至 GitHub**
  如果您尚未登入 GitHub，請先執行登入指令。然後，使用標準的 Git 流程來提交並推送您的變更。
  ```bash
  # 1. (如果尚未登入) 進行 GitHub 身份驗證
  gh auth login

  # 2. 提交並推送程式碼
  git add .
  git commit -m "您的提交訊息"
  git push
  ```
