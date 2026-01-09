# Flutter 專案常用指令集

本文件紀錄了此專案開發與建置時常用的 Flutter 指令。

## 1. 專案清理與代碼分析
在進行大型更動或建置前，建議執行以下指令：

*   **清理專案快取**：移除建置產生的暫存檔。
    ```bash
    flutter clean
    ```
*   **靜態代碼分析**：檢查代碼中的語法錯誤或潛在問題。
    ```bash
    flutter analyze
    ```

## 2. 資源與語系生成
*   **生成多國語言文件 (L10n)**：根據 `.arb` 檔案重新生成語系相關代碼。
    ```bash
    flutter gen-l10n
    ```

## 3. 測試與執行
*   **指定設備執行**：將應用程式安裝並運行於指定的模擬器（在此為 `emulator-5554`）。
    ```bash
    flutter run -d emulator-5554
    ```

## 4. 封裝與發佈 (Production Build)
此指令用於生成正式發佈用的 APK 檔案，並包含優化與安全處理：

```bash
flutter build apk --split-per-abi --obfuscate --split-debug-info=./debug-info
