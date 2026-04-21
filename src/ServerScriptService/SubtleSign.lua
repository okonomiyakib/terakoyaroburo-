-- SubtleSign.lua
-- 配置場所: ServerScriptService
-- Studio に何も置かなくてよい。スクリプトが自動で生成する。

local campfire = workspace:FindFirstChild("Campfire")
local basePos  = campfire and campfire.Position or Vector3.new(0, 0, 0)

-- ── 設定（ここだけ触る）──────────────────────────────────
local TEXT              = "ここにいていい"
local POSITION          = Vector3.new(8, 0.55, 2)   -- 焚き火からの相対位置
local TEXT_COLOR        = Color3.fromRGB(210, 190, 155)
local TEXT_TRANSPARENCY = 0.3

-- ── 柱 ───────────────────────────────────────────────────
local stake = Instance.new("Part")
stake.Size       = Vector3.new(0.12, 1.1, 0.12)
stake.Material   = Enum.Material.Wood
stake.Color      = Color3.fromRGB(100, 75, 55)
stake.Anchored   = true
stake.CanCollide = false
stake.Position   = basePos + POSITION
stake.Parent     = workspace

-- ── 文字（BillboardGui）──────────────────────────────────
local billboard = Instance.new("BillboardGui", stake)
billboard.Size        = UDim2.new(0, 300, 0, 60)
billboard.StudsOffset = Vector3.new(0, 1.5, 0)
billboard.AlwaysOnTop = false
billboard.LightInfluence = 1

local label = Instance.new("TextLabel", billboard)
label.Size                   = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text                   = TEXT
label.Font                   = Enum.Font.GothamMedium
label.TextSize               = 24
label.TextColor3             = TEXT_COLOR
label.TextTransparency       = TEXT_TRANSPARENCY
label.TextScaled             = false
