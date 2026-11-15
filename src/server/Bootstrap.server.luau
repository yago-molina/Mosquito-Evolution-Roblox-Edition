--!strict
-- Fase 1: valida a sincronização e monta uma área TEMPORÁRIA de testes.
-- O mundo definitivo será construído no Roblox Studio nas próximas fases.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local shared = ReplicatedStorage:WaitForChild("MosquitoShared")
local Config = require(shared:WaitForChild("GameConfig"))

local DEMO_NAME = "Mosquito_Fase1_Demo"
local old = workspace:FindFirstChild(DEMO_NAME)
if old then old:Destroy() end

local stage = Instance.new("Folder")
stage.Name = DEMO_NAME
stage.Parent = workspace

local function part(name: string, size: Vector3, cf: CFrame, color: Color3, transparency: number?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Anchored = true
    p.CanCollide = name == "Plataforma"
    p.Transparency = transparency or 0
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = stage
    return p
end

-- O avatar padrão do Roblox continua controlável nesta fase.
part("Plataforma", Vector3.new(72, 1, 72), CFrame.new(0, -1, 0), Color3.fromRGB(34, 42, 55))
local stand = part("Expositor", Vector3.new(8, 1, 8), CFrame.new(0, 1, -18), Color3.fromRGB(80, 45, 60))
stand.Material = Enum.Material.Metal
local body = part("Corpo_do_Mosquito", Vector3.new(2, 1.5, 3.5), CFrame.new(0, 4, -18), Color3.fromRGB(140, 55, 75))
body.Shape = Enum.PartType.Ball
local head = part("Cabeca", Vector3.new(1.3, 1.3, 1.3), CFrame.new(0, 4.2, -20.1), Color3.fromRGB(210, 85, 95))
head.Shape = Enum.PartType.Ball
for _, x in { -1.3, 1.3 } do
    local wing = part("Asa", Vector3.new(2.8, 0.12, 1.4), CFrame.new(x, 5.1, -18.1) * CFrame.Angles(0, 0, math.rad(x < 0 and -15 or 15)), Color3.fromRGB(185, 236, 255), 0.35)
    wing.CanCollide = false
end

-- Pasta reservada para os futuros sistemas persistentes.
if not ServerStorage:FindFirstChild("MosquitoServerData") then
    local serverData = Instance.new("Folder")
    serverData.Name = "MosquitoServerData"
    serverData.Parent = ServerStorage
end

print(string.format("[MOSQUITO] Servidor iniciado | versão %s | fase %d", Config.VERSION, Config.PROJECT_PHASE))
