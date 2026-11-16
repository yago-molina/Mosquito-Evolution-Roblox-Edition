--!strict
-- HUD de voo e inicializacao do controlador local.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local FlightController = require(script.Parent:WaitForChild("FlightController"))
local ShopUI = require(script.Parent:WaitForChild("ShopUI"))

local parent = player:WaitForChild("PlayerGui")
local previous = parent:FindFirstChild("MosquitoBootstrapHUD")
if previous then previous:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "MosquitoBootstrapHUD"
gui.ResetOnSpawn = false
gui.Parent = parent

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.9, 0, 0, 132)
local maxPanel = Instance.new("UISizeConstraint")
maxPanel.MaxSize = Vector2.new(360, 132)
maxPanel.Parent = panel
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(22, 16, 28)
panel.BackgroundTransparency = 0.06
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(232, 41, 75)
outline.Thickness = 1.5
outline.Parent = panel

local function label(name: string, content: string, y: number, height: number, size: number, color: Color3): TextLabel
    local obj = Instance.new("TextLabel")
    obj.Name = name
    obj.BackgroundTransparency = 1
    obj.Position = UDim2.fromOffset(13, y)
    obj.Size = UDim2.new(1, -26, 0, height)
    obj.Text = content
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = size
    obj.TextColor3 = color
    obj.TextWrapped = true
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = panel
    return obj
end

label("Titulo", "MOSQUITO EVOLUTION", 8, 29, 19, Color3.fromRGB(255, 114, 144))
label("Status", string.format("Fase %d | Mosquito jogavel | v%s", Config.PROJECT_PHASE, Config.VERSION), 40, 22, 13, Color3.fromRGB(237, 232, 230))
label("Controles", "WASD mover • Mouse olhar • Espaco/Ctrl altura • Shift sprint (toque no celular)", 63, 28, 11, Color3.fromRGB(204, 197, 201))
local barBack = Instance.new("Frame")
barBack.Size = UDim2.new(1, -26, 0, 10)
barBack.Position = UDim2.fromOffset(13, 107)
barBack.BackgroundColor3 = Color3.fromRGB(75, 58, 71)
barBack.Parent = panel
local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBack
local bar = Instance.new("Frame")
bar.Name = "Stamina"
bar.Size = UDim2.fromScale(1, 1)
bar.BackgroundColor3 = Color3.fromRGB(255, 187, 78)
bar.Parent = barBack
local barRound = Instance.new("UICorner")
barRound.CornerRadius = UDim.new(1, 0)
barRound.Parent = bar

-- HUD economico separado, para preservar a barra e os controles validados.
local moneyPanel = Instance.new("Frame")
moneyPanel.Name = "BloodPanel"
moneyPanel.Size = UDim2.fromOffset(247, 119)
moneyPanel.Position = UDim2.fromOffset(18, 160)
moneyPanel.BackgroundColor3 = Color3.fromRGB(22, 16, 28)
moneyPanel.BackgroundTransparency = 0.06
moneyPanel.Parent = gui
local moneyCorner = Instance.new("UICorner")
moneyCorner.CornerRadius = UDim.new(0, 12)
moneyCorner.Parent = moneyPanel

local bloodText = Instance.new("TextLabel")
bloodText.Name = "Saldo"
bloodText.Size = UDim2.new(1, -20, 0, 43)
bloodText.Position = UDim2.fromOffset(10, 4)
bloodText.BackgroundTransparency = 1
bloodText.TextColor3 = Color3.fromRGB(255, 100, 125)
bloodText.Font = Enum.Font.GothamBold
bloodText.TextSize = 23
bloodText.TextXAlignment = Enum.TextXAlignment.Left
bloodText.Parent = moneyPanel

local comboText = Instance.new("TextLabel")
comboText.Name = "Combo"
comboText.Size = UDim2.new(1, -20, 0, 30)
comboText.Position = UDim2.fromOffset(10, 49)
comboText.BackgroundTransparency = 1
comboText.TextColor3 = Color3.fromRGB(255, 207, 115)
comboText.Font = Enum.Font.Gotham
comboText.TextSize = 14
comboText.TextXAlignment = Enum.TextXAlignment.Left
comboText.Parent = moneyPanel

local evolutionText = Instance.new("TextLabel")
evolutionText.Name = "Evolucao"
evolutionText.Size = UDim2.new(1, -20, 0, 28)
evolutionText.Position = UDim2.fromOffset(10, 84)
evolutionText.BackgroundTransparency = 1
evolutionText.TextColor3 = Color3.fromRGB(255, 209, 123)
evolutionText.Font = Enum.Font.GothamBold
evolutionText.TextSize = 12
evolutionText.TextXAlignment = Enum.TextXAlignment.Left
evolutionText.TextTruncate = Enum.TextTruncate.AtEnd
evolutionText.Parent = moneyPanel

local previousEvolution: string? = nil
local function updateEvolution()
    local stage = player:GetAttribute("EvolutionStage")
    local total = player:GetAttribute("UpgradeTotal")
    local current = if typeof(stage) == "string" then stage else "Larva voadora"
    evolutionText.Text = string.format("EVOLUÇÃO %d | %s", if typeof(total) == "number" then total else 0, current)
    if previousEvolution and previousEvolution ~= current then
        print("[MOSQUITO] Novo estagio desbloqueado: " .. current)
    end
    previousEvolution = current
end
player:GetAttributeChangedSignal("EvolutionStage"):Connect(updateEvolution)
player:GetAttributeChangedSignal("UpgradeTotal"):Connect(updateEvolution)
updateEvolution()

local function updateBlood()
    local total = player:GetAttribute("Blood")
    local combo = player:GetAttribute("BloodCombo")
    local gained = player:GetAttribute("LastBloodGain")
    bloodText.Text = "SANGUE  " .. tostring(if typeof(total) == "number" then total else 0)
    comboText.Text = string.format("Combo x%d  |  +%d", if typeof(combo) == "number" then combo else 0, if typeof(gained) == "number" then gained else 0)
end
player:GetAttributeChangedSignal("Blood"):Connect(updateBlood)
player:GetAttributeChangedSignal("BloodCombo"):Connect(updateBlood)
player:GetAttributeChangedSignal("LastBloodGain"):Connect(updateBlood)
updateBlood()
ShopUI.mount(gui)

local function setup(character: Model)
    FlightController.stop()
    FlightController.start(character, function(fraction: number, sprint: boolean)
        bar.Size = UDim2.fromScale(math.clamp(fraction, 0, 1), 1)
        bar.BackgroundColor3 = if sprint then Color3.fromRGB(232, 68, 89) else Color3.fromRGB(255, 187, 78)
    end)
end

player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup, player.Character) end
print("[MOSQUITO] Cliente iniciado: HUD e controlador de voo carregados")
