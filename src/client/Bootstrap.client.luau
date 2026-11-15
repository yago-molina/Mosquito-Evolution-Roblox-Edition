--!strict
-- HUD de voo e inicializacao do controlador local.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local FlightController = require(script.Parent:WaitForChild("FlightController"))

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
