--!strict
-- Fase 2: mundo de testes e ativacao do personagem Mosquito.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local MosquitoCharacter = require(script.Parent:WaitForChild("MosquitoCharacter"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))
local BloodService = require(script.Parent:WaitForChild("BloodService"))
local EvolutionVisual = require(script.Parent:WaitForChild("EvolutionVisual"))

local old = workspace:FindFirstChild("Mosquito_Fase1_Demo")
if old then old:Destroy() end
local previous = workspace:FindFirstChild("Mosquito_Fase2_Teste")
if previous then previous:Destroy() end
local stage = Instance.new("Folder")
stage.Name = "Mosquito_Fase2_Teste"
stage.Parent = workspace

local function createPart(name: string, size: Vector3, cf: CFrame, color: Color3): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = stage
    return p
end
createPart("Piso", Vector3.new(100, 1, 100), CFrame.new(0, -1, 0), Color3.fromRGB(34, 42, 55))
for i = 1, 6 do
    local x = (i - 3.5) * 12
    createPart("Obstaculo_" .. i, Vector3.new(3, 10 + i, 3), CFrame.new(x, 5, -22), Color3.fromRGB(79, 49, 65))
end
for i = 1, 4 do
    createPart("Aro_Teste_" .. i, Vector3.new(5, 0.3, 5), CFrame.new(-28 + i * 13, 6 + i * 2, 15), Color3.fromRGB(80, 170, 204)).CanCollide = false
end

local function onCharacter(character: Model)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    -- Aumentar a altura inicial para testar voo antes de haver controles.
    character:PivotTo(CFrame.new(0, 7, 18))
    MosquitoCharacter.setup(character)
    local owner = Players:GetPlayerFromCharacter(character)
    local total = if owner then owner:GetAttribute("UpgradeTotal") else 0
    EvolutionVisual.apply(character, if typeof(total) == "number" then total else 0, false)
end
local function onPlayer(player: Player)
    player:GetAttributeChangedSignal("UpgradeTotal"):Connect(function()
        local character = player.Character
        if not character then return end
        local level = player:GetAttribute("UpgradeTotal")
        if typeof(level) == "number" then EvolutionVisual.apply(character, level, true) end
    end)
    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end
ProgressionService.start()
BloodService.start()
Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do onPlayer(player) end
print(string.format("[MOSQUITO] Servidor iniciado | versao %s | fase %d", Config.VERSION, Config.PROJECT_PHASE))
