# 🚀 WalkGo 變現機制實作計畫 (Implementation Plan)

本文件定義 WalkGo 廣告獎勵系統的架構規範。所有實作必須嚴格遵守此協議，以確保跨 Isolate 的同步性與安全性。

---

## 1. 跨 Isolate 通訊協議 (Event Protocol)

### 1.1 通訊方向：UI $\rightarrow$ Background Isolate
使用 `service.invoke(method, payload)`。

| Method | Payload 結構 | 說明 |
| :--- | :--- | :--- |
| `cmd_add_rewarded_steps` | `{"amount": int, "requestId": String}` | 請求增加廣告獎勵步數。`requestId` 用於追蹤交易狀態。 |
| `cmd_sync_cooldown` | `{"timestamp": int}` | UI 端同步冷卻時間戳至背景 (若有必要)。 |

### 1.2 通訊方向：Background Isolate $\rightarrow$ UI
使用 `service.invoke(method, payload)`。

| Method | Payload 結構 | 說明 |
| :--- | :--- | :--- |
| `evt_steps_updated` | `{"currentTotal": int, "lastIncrement": int}` | 通知 UI 步數已成功更新。 |
| `evt_reward_failed` | `{"requestId": String, "reason": String}` | 通知 UI 獎勵增加失敗 (例如 amount 不在白名單內)。 |

---

## 2. AdService API 介面定義

`AdService` 應作為單例 (Singleton)，負責封裝廣告 SDK 複雜度，並向 UI 提供簡單的狀態訂閱。

### 2.1 狀態定義
```dart
enum AdStatus {
  idle,    // 初始狀態
  loading, // 正在預載廣告 (Preloading)
  ready,   // 廣告已就緒，按鈕可用
  error    // 載入失敗，按鈕 Disabled
}
```

### 2.2 介面定義 (Interface)
- **狀態訂閱**:
    - `ValueNotifier<AdStatus> status`: UI 監聽此值以切換按鈕狀態 (`Enabled` $\leftrightarrow$ `Disabled` $\leftrightarrow$ `Loading`)。
    - `Stream<Duration> cooldownStream`: 提供即時的冷卻倒數時間。
- **核心方法**:
    - `Future<void> preloadAd()`: 觸發廣告預載，更新 `status` 為 `loading` $\rightarrow$ `ready/error`。
    - `Future<bool> showRewardedAd()`: 顯示廣告並等待獎勵回調。成功則返回 `true`。
    - `void resetCooldown()`: 手動重置冷卻時間 (僅限開發測試使用)。

---

## 3. 安全與持久化機制

### 3.1 步數增量防篡改 (Anti-tamper)
為了防止惡意請求，背景服務必須實施以下驗證：
1. **白名單校驗 (Whitelist Validation)**:
   - BG 端定義 `final List<int> _allowedRewards = [2500, 5000];`。
   - 收到 `cmd_add_rewarded_steps` 時，若 `amount` 不在白名單內 $\rightarrow$ 直接拒絕並回傳 `evt_reward_failed`。
2. **頻率限制 (Rate Limiting)**:
   - BG 端記錄每次成功增加的時間戳。若兩次請求間隔小於最小冷卻時間 (例如 15 分鐘) $\rightarrow$ 判定為異常請求 $\rightarrow$ 拒絕。

### 3.2 冷卻時間準確性 (Cooldown Persistence)
為防止用戶透過修改系統時間繞過冷卻：
1. **絕對時間儲存**:
   - 儲存 `expire_timestamp` (Unix Timestamp) 至 `SharedPreferences`。
2. **時間跳變檢測 (Time-drift Detection)**:
   - 每次 App 啟動或檢查冷卻時，比對 `DateTime.now()` 與儲存的 `expire_timestamp`。
   - **檢測邏輯**: 
     - 若 `CurrentTime < LastStoredTime` $\rightarrow$ 判定為系統時間被回調 $\rightarrow$ 強制將 `expire_timestamp` 順延或保持原位，防止冷卻時間被「歸零」。
3. **權威時間源 (可選擴展)**:
   - 未來若需極高安全性，可引入簡單的 NTP 請求或 Firebase Server Timestamp 作為校準基準。

---

## 4. UI/UX 實作準則 (M3 風格)
- **按鈕行為**:
    - `status == loading` $\rightarrow$ 顯示 `CircularProgressIndicator` 或灰色佔位。
    - `status == error` $\rightarrow$ 按鈕 `Disabled`，不顯示錯誤視窗，僅在 log 記錄。
- **視覺過渡**:
    - 使用 `AnimatedSwitcher` 切換按鈕狀態，避免 UI 瞬間跳變造成不適感。
