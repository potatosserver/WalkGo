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
  
  1. 安裝工具(如果尚未安裝) 
  ```bash
  dart pub global activate dart_unused_files
  ```
  
  2. 執行掃描
  ```bash
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
  
  1. 進行 GitHub 身份驗證(如果尚未登入) 
  ```bash
  gh auth login
  ```
  
  2. 提交並推送程式碼
  ```
  git add .
  git commit -m "您的提交訊息"
  git push
  ```

---

## 5. 發布到 GitHub Release (Publishing to GitHub Release)

將建置好的 APK 檔案發布到 GitHub Release，方便使用者或測試人員下載。

### 步驟 1: 認證與建立版本

環境重建完成後，您就可以開始發布流程。

1.  **登入您的 GitHub 帳號** (每次在新環境或重建後都需要)
    ```bash
    gh auth login
    ```
    按照螢幕指示，在瀏覽器中完成授權。

2.  **建立版本標籤 (Tag)**
    為您的 Release 建立一個獨一無二的 Git 標籤，例如 `v1.0.2`。
    ```bash
    git tag v1.0.2
    ```

3.  **將標籤推送到 GitHub**
    ```bash
    git push origin v1.0.2
    ```

### 步驟 2: 產生校驗和並發布

為了確保檔案的完整性與安全性，建議為您的 APK 產生校驗和 (Checksum)。

1.  **建立 Release 並上傳所有檔案**
    這個指令會找到您剛剛推送的標籤，建立一個 Release 頁面，並上傳所有 `.apk` 和 `.sha256` 檔案。
    `--generate-notes` 參數會自動幫您產生版本說明。
    ```bash
    gh release create v1.0.2 \
    build/app/outputs/flutter-apk/*.apk \
    build/app/outputs/flutter-apk/*.sha1 \
    --generate-notes \
    --title "Version 1.0.2"
    ```

完成後，您就可以在 GitHub 專案的 "Releases" 頁面看到您發布的新版本了。
