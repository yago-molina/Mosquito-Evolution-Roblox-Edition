--!strict
-- Fase 1: HUD de verificação. NÃO implementa o voo ainda.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local guiParent = player:WaitForChild("PlayerGui")
local previous = guiParent:FindFirstChild("MosquitoBootstrapHUD")
if previous then previous:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MosquitoBootstrapHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = guiParent

local panel = Instance.new("Frame")
panel.Name = "Painel"
panel.Size = UDim2.fromOffset(340, 106)
panel.Position = UDim2.new(0, 18, 0, 18)
panel.BackgroundColor3 = Color3.fromRGB(22, 16, 28)
panel.BackgroundTransparency = 0.08
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(232, 41, 75)
border.Thickness = 1.5
border.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Titulo"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 8)
title.Size = UDim2.new(1, -28, 0, 32)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 114, 144)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "MOSQUITO EVOLUTION"
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Status"
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(14, 43)
subtitle.Size = UDim2.new(1, -28, 0, 48)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(242, 231, 228)
subtitle.TextWrapped = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.Text = string.format("Fase %d • Ambiente de testes\nLuau + Rojo sincronizados | v%s", Config.PROJECT_PHASE, Config.VERSION)
subtitle.Parent = panel

print("[MOSQUITO] Cliente iniciado: HUD de teste carregado")
