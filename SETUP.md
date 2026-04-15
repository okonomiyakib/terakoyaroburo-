# テラコヤ Roblox — Studio 配置手順

## ファイル構成

```
src/
  ServerScriptService/
    CampfireSit.lua      ← 焚き火に座る
    WhisperSystem.lua    ← つぶやきを空間に浮かばせる（サーバー）
    FireflySystem.lua    ← ほたるを飛ばす（サーバー）
  StarterPlayerScripts/
    WhisperUI.lua        ← つぶやき入力UI（クライアント）
    FireflyUI.lua        ← クリックでほたる送信＋受け取り演出（クライアント）
```

---

## Step 1 — Workspace の準備

### 焚き火パーツを作る
1. Workspace に `Part` を追加 → 名前を **Campfire** にする
2. Campfire の下に `ProximityPrompt` を追加
   - ActionText: `座る`
   - HoldDuration: `0`
   - MaxActivationDistance: `8`
3. Campfire に `Fire`（炎エフェクト）と `PointLight` を追加
   - PointLight.Color: `255, 180, 80`（橙色）
   - PointLight.Brightness: `3`
   - PointLight.Range: `20`

### 空間の雰囲気
- Lighting.ClockTime を `19`（夕暮れ）に設定
- Lighting に `Atmosphere` を追加
  - Density: `0.4`
  - Haze: `0.3`
- `Sound`（BGM）を Workspace に追加: 虫の音など

---

## Step 2 — スクリプトの配置

各 `.lua` ファイルの内容を、対応する場所に Script / LocalScript として貼り付ける。

| ファイル | Roblox上の場所 | 種類 |
|---------|--------------|------|
| CampfireSit.lua | ServerScriptService | Script |
| WhisperSystem.lua | ServerScriptService | Script |
| FireflySystem.lua | ServerScriptService | Script |
| WhisperUI.lua | StarterPlayerScripts | LocalScript |
| FireflyUI.lua | StarterPlayerScripts | LocalScript |

---

## 操作方法（プレイヤー視点）

| 操作 | 動作 |
|-----|------|
| 焚き火に近づいて `E` | 座る / 立つ |
| `T` キー | つぶやき入力欄を開く |
| テキスト入力 → `Enter` | つぶやきが空間に浮かぶ（60秒で消える） |
| 他プレイヤーをクリック | ほたるを送る（5秒クールダウン） |

---

## 今後の拡張候補（優先度低）

- 座席を `Seat` オブジェクトに変えてアニメーションを改善
- つぶやきの色を時間帯で変える（夜は青白く）
- ほたるの数を増やして「複数人から届いた」を表現
