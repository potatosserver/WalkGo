# Flutter 專案開發與建置指南

本文件旨在提供一個清晰、完整的 Flutter 指令集，涵蓋從專案初始化到最終發佈的各個階段。

---

## 1. 專案設定與套件管理

在開始開發或設定新環境時，首先需要確保專案的依賴項目都已正確安裝。

- **取得或更新套件**
  此指令會根據 `pubspec.yaml` 檔案下載所有需要的套件。這是設定新專案或拉取遠端更新後的第一步。
  ```bash
  flutter pub get
  ```

---

## 2. 開發與除錯

在開發過程中，你會頻繁使用以下指令來運行、測試和分析你的程式碼。

- **在特定設備上運行應用**
  將應用程式安裝並運行於指定的模擬器或實體設備。
  ```bash
  # 將 'emulator-5554' 替換為你的設備 ID
  flutter run -d emulator-5554
  ```

- **靜態程式碼分析**
  在提交程式碼前，強烈建議執行此指令來檢查潛在的語法錯誤、風格問題或效能陷阱。
  ```bash
  flutter analyze
  ```

---

## 3. 程式碼與資源生成

當專案使用到程式碼生成或多國語言功能時，需要執行以下指令。

- **生成多國語言 (L10n)**
  根據 `lib/l10n` 目錄下的 `.arb` 檔案，自動生成或更新本地化所需的 Dart 程式碼。
  ```bash
  flutter gen-l10n
  ```

---

## 4. 建置與發佈 (Production Build)

準備將應用程式發佈時，需要生成經過優化的正式版本。

- **清理專案**
  在進行正式建置前，建議先清除舊的建置快取，以避免潛在的衝突。
  ```bash
  flutter clean
  ```

- **通用 APK 建置**
  此指令會為所有主流的 Android 架構生成對應的 APK 檔案。這是最通用且推薦的發佈方式。
  - `--split-per-abi`: 為不同的 CPU 架構（ARM 32-bit, ARM 64-bit, x86_64）分別建立 APK，讓使用者只下載符合其設備的版本。
  - `--obfuscate`: 對 Dart 程式碼進行混淆，增加逆向工程的難度，保護你的商業邏輯。
  - `--split-debug-info`: 將偵錯資訊分離到獨立的檔案中，以便在需要時（如分析 Crash 報告）使用，同時減小正式版 APK 的體積。
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

## 5. 版本控制

- **GitHub 身份驗證**
  此指令用於登入 GitHub CLI，以便執行 `git push`、`git pull` 等需要身份驗證的操作，確保你對遠端儲存庫有存取權限。
  ```bash
  gh auth login
  ```
