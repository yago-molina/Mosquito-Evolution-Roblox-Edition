--!strict
-- Gotas compartilhadas: servidor valida proximidade, coleta unica e respawn.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))
local BloodService = {}

local RESPAWN_SECONDS = 6
local COLLECT_RADIUS = 2.0
local CHECK_INTERVAL = 0.12
local DROP_COUNT = 22

type DropState = {
    part: Part,
    isGolden: boolean,
    active: boolean,
    respawnAt: number,
}
local drops: {DropState} = {}
local folder: Folder? = nil
local connection: RBXScriptConnection? = nil

local function makeDrop(index: number): DropState
    -- Distribuicao deterministica: inclui gotas perto do spawn x0,z18.
    local column = (index - 1) % 6
    local row = math.floor((index - 1) / 6)
    local x = -30 + column * 12
    local z = 11 - row * 12
    local y = 4.0 + ((index * 7) % 5) * 1.7
    if index == 1 then x, y, z = 0, 7, 11 end
    local isGolden = index % 7 == 0
    local part = Instance.new("Part")
    part.Name = if isGolden then "Gota_Dourada_" .. index else "Gota_Sangue_" .. index
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(0.82, 1.05, 0.82)
    part.CFrame = CFrame.new(x, y, z)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Color = if isGolden then Color3.fromRGB(255, 207, 65) else Color3.fromRGB(229, 41, 70)
    part.Parent = folder

    local light = Instance.new("PointLight")
    light.Color = part.Color
    light.Range = if isGolden then 9 else 6
    light.Brightness = if isGolden then 1.3 else 0.65
    light.Parent = part

    local icon = Instance.new("BillboardGui")
    icon.Name = "Valor"
    icon.Size = UDim2.fromOffset(66, 28)
    icon.StudsOffsetWorldSpace = Vector3.new(0, 1, 0)
    icon.AlwaysOnTop = true
    icon.MaxDistance = 38
    icon.Parent = part
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = if isGolden then "5x" else "+1"
    text.TextColor3 = part.Color
    text.TextStrokeTransparency = 0.25
    text.Font = Enum.Font.GothamBold
    text.TextSize = 17
    text.Parent = icon

    return {part = part, isGolden = isGolden, active = true, respawnAt = 0}
end

local function show(drop: DropState, visible: boolean)
    drop.active = visible
    drop.part.Transparency = if visible then 0 else 1
    local light = drop.part:FindFirstChildOfClass("PointLight")
    if light then light.Enabled = visible end
    local billboard = drop.part:FindFirstChild("Valor")
    if billboard and billboard:IsA("BillboardGui") then billboard.Enabled = visible end
end

local function collect(player: Player, drop: DropState, now: number)
    -- Mudanca de estado antes da recompensa: duas pessoas nao recebem a mesma gota.
    show(drop, false)
    drop.respawnAt = now + RESPAWN_SECONDS
    local amount = ProgressionService.grantDrop(player, drop.isGolden)
    if amount > 0 then
        print(string.format("[MOSQUITO] %s coletou %d sangue (%s)", player.Name, amount, if drop.isGolden then "dourada" else "normal"))
    end
end

function BloodService.start()
    local previous = workspace:FindFirstChild("MosquitoBloodDrops")
    if previous then previous:Destroy() end
    local worldFolder = Instance.new("Folder")
    worldFolder.Name = "MosquitoBloodDrops"
    worldFolder.Parent = workspace
    folder = worldFolder
    table.clear(drops)
    for index = 1, DROP_COUNT do
        table.insert(drops, makeDrop(index))
    end

    local accumulated = 0
    connection = RunService.Heartbeat:Connect(function(dt: number)
        accumulated += dt
        if accumulated < CHECK_INTERVAL then return end
        accumulated = 0
        local now = os.clock()
        local players = Players:GetPlayers()
        for _, drop in drops do
            if not drop.active then
                if now >= drop.respawnAt then show(drop, true) end
                continue
            end
            for _, player in players do
                local character = player.Character
                local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
                local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
                if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart")
                    and character and character:GetAttribute("MosquitoReady") == true then
                    if (root.Position - drop.part.Position).Magnitude <= COLLECT_RADIUS then
                        collect(player, drop, now)
                        break
                    end
                end
            end
        end
    end)
    print(string.format("[MOSQUITO] BloodService pronto: %d gotas, respawn %ds", DROP_COUNT, RESPAWN_SECONDS))
end

return BloodService
