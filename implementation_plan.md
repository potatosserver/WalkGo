# 🚀 WalkGo 實作計畫 (Implementation Plan)

本文件定義 WalkGo 各項功能的架構規範。所有實作必須嚴格遵守此協議，以確保系統的同步性、安全性與一致性。

---

## 1. 變現機制 (Rewarded Ads)

### 1.1 跨 Isolate 通訊協議 (Event Protocol)
使用 `service.invoke(method, payload)`。

#### 1.1.1 通訊方向：UI $\rightarrow$ Background Isolate
| Method | Payload 結構 | 說明 |
| :--- | :--- | :--- |
| `cmd_add_rewarded_steps` | `{"amount": int, "requestId": String}` | 請求增加廣告獎勵步數。`requestId` 用於追蹤交易狀態。 |
| `cmd_sync_cooldown` | `{"timestamp": int}` | UI 端同步冷卻時間戳至背景 (若有必要)。 |

#### 1.1.2 通訊方向：Background Isolate $\rightarrow$ UI
| Method | Payload 結構 | 說明 |
| :--- | :--- | :--- |
| `evt_steps_updated` | `{"currentTotal": int, "lastIncrement": int}` | 通知 UI 步數已成功更新。 |
| `evt_reward_failed` | `{"requestId": String, "reason": String}` | 通知 UI 獎勵增加失敗 (例如 amount 不在白名單內)。 |

### 1.2 AdService API 介面定義
`AdService` 應作為單例 (Singleton)，負責封裝廣告 SDK 複雜度，並向 UI 提供簡單的狀態訂閱。

#### 1.2.1 狀態定義
```dart
enum AdStatus {
  idle,    // 初始狀態
  loading, // 正在預載廣告 (Preloading)
  ready,   // 廣告已就就緒，按鈕可用
  error    // 載入失敗，按鈕 Disabled
}
```

#### 1.2.2 介面定義 (Interface)
- **狀態訂閱**:
    - `ValueNotifier<AdStatus> status`: UI 監聽此值以切換按鈕狀態 (`Enabled` $\leftrightarrow$ `Disabled` $\leftrightarrow$ `Loading`)。
    - `Stream<Duration> cooldownStream`: 提供即時的冷卻倒數時間。
- **核心方法**:
    - `Future<void> preloadAd()`: 觸發廣告預載，更新 `status` 為 `loading` $\rightarrow$ `ready/error`。
    - `Future<bool> showRewardedAd()`: 顯示廣告並等待獎勵回調。成功則返回 `true`。
    - `void resetCooldown()`: 手動重置冷卻時間 (僅限開發測試使用)。

### 1.3 安全與持久化機制
#### 1.3.1 步數增量防篡改 (Anti-tamper)
1. **白名單校驗 (Whitelist Validation)**:
   - BG 端定義 `final List<int> _allowedRewards = [2500, 5000];`。
   - 收到 `cmd_add_rewarded_steps` 時，若 `amount` 不在白名單內 $\rightarrow$ 直接拒絕並回傳 `evt_reward_failed`。
2. **頻率限制 (Rate Limiting)**:
   - BG 端記錄每次成功增加的時間戳。若兩次請求間隔小於最小冷卻時間 (例如 15 分鐘) $\rightarrow$ 判定為異常請求 $\rightarrow$ 拒絕。

#### 1.3.2 冷卻時間準確性 (Cooldown Persistence)
- **絕對時間儲存**: 儲存 `expire_timestamp` (Unix Timestamp) 至 `SharedPreferences`。
- **時間跳變檢測 (Time-drift Detection)**: 每次 App 啟動或檢查冷卻時，比對 `DateTime.now()` 與儲存的 `expire_timestamp`。若 `CurrentTime < LastStoredTime` $\rightarrow$ 強制將 `expire_timestamp` 順延或保持原位。

### 1.4 UI/UX 實作準則 (M3 風格)
- **按鈕行為**: `status == loading` $\rightarrow$ 顯示 `CircularProgressIndicator`；`status == error` $\rightarrow$ 按鈕 `Disabled`。
- **視覺過渡**: 使用 `AnimatedSwitcher` 切換按鈕狀態。

---

## 2. 公告系統 (Announcement System)

### 2.1 數據定義與格式
公告儲存於遠端 `.md` 檔案，採用 **YAML Frontmatter + Markdown** 格式。

**檔案格式範例 (`announcements.md`):**
```markdown
---
id: notice_20260626_01
title: "公告標題"
priority: 1 // 數字越大優先級越高
expiry: "2026-07-01" // ISO 8601 格式
---
公告內容 (Markdown)...

---
id: notice_20260627_02
...
```

### 2.2 獲取與處理邏輯
- **觸發時機**：App 啟動時，與「檢查更新」流程同步執行。
- **執行順序 (Priority Chain)**：
  1. **公告系統 $\rightarrow$ 檢查更新**。
  2. 必須在所有「未隱藏且未過期」的公告全部顯示完畢（或用戶關閉）後，才觸發檢查更新對話框。
- **解析流程**：
  - 獲取 Raw `.md` 內容 $\rightarrow$ 以 `---` 分隔符切割區塊 $\rightarrow$ 解析 YAML 標頭 $\rightarrow$ 建立 `Announcement` 物件列表。
  - **排序**：根據 `priority` 從高到低排序。

### 2.3 顯示與持久化
- **顯示機制 (Queue Mode)**：
  - 採用隊列模式。一次僅顯示一條公告 $\rightarrow$ 用戶點擊「我知道了」$\rightarrow$ 檢查下一條 $\rightarrow$ 彈出直到隊列清空。
- **「不再顯示」機制**：
  - **儲存**：在 `SharedPreferences` 中儲存已隱藏公告的 ID 集合 (`Set<String> hiddenAnnouncements`)。
  - **判定**：過濾掉 `id` 存在於 `hiddenAnnouncements` 且 `expiry` 未到的公告。
- **UI 元素 (M3)**：
  - 包含：標題、Markdown 內容、`Checkbox` (不再顯示)、`TextButton` (我知道了)。

### 2.4 公告中心 (Announcement Center)
- **入口**：設定面板 $\rightarrow$ 「公告」按鈕。
- **功能**：以列表形式顯示所有遠端公告（含已隱藏者），點擊後可查看詳情。

---

## 3. 總體啟動流程規範 (Startup Sequence)

### 3.1 啟動檢查順序
App 啟動後，應遵循以下非同步流水線：
1. **Initialization**: 初始化核心 Service 與本地儲存。
2. **Fetch Announcements**: 獲取遠端公告 $\rightarrow$ 過濾 $\rightarrow$ 依優先級排序。
3. **Announcement Display Loop**:
   - `while (announcementQueue.isNotEmpty)` $\rightarrow$ 顯示公告 $\rightarrow$ 等待用戶關閉 $\rightarrow$ 更新隱藏狀態。
4. **Check for Updates**: 當公告循環結束後 $\rightarrow$ 觸發檢查更新對話框。
5. **Main App Entry**: 進入主界面。

---

## 4. 其他通用規範

- 所有的對話框應遵循 M3 規範，優先使用 `AppDialog` 封裝。
