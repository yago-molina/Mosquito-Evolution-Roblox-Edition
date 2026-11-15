--!strict
-- Economia por jogador: servidor e autoridade sobre sangue e upgrades.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local ProgressionService = {}

type Levels = {[string]: number}
type BloodState = {
    blood: number,
    combo: number,
    comboUntil: number,
    levels: Levels,
    lastPurchase: number,
}
local states: {[Player]: BloodState} = {}
local MAX_BLOOD = 1_000_000_000
local COMBO_WINDOW = 4
local MAX_COMBO = 5
local BUY_COOLDOWN = 0.15
local buyEvent: RemoteEvent
local feedbackEvent: RemoteEvent

local UPGRADE_IDS = {"wings", "proboscis", "stomach", "body"}
local function stageFor(total: number): string
    local name = Config.STAGES[1].name
    for _, entry in Config.STAGES do
        if total >= entry.minimum then name = entry.name else break end
    end
    return name
end

local function totalLevel(state: BloodState): number
    local total = 0
    for _, id in UPGRADE_IDS do total += state.levels[id] end
    return total
end

local function publish(player: Player, state: BloodState)
    player:SetAttribute("Blood", state.blood)
    player:SetAttribute("BloodCombo", state.combo)
    player:SetAttribute("UpgradeTotal", totalLevel(state))
    player:SetAttribute("EvolutionStage", stageFor(totalLevel(state)))
    for _, id in UPGRADE_IDS do
        player:SetAttribute("Upgrade_" .. id, state.levels[id])
    end
end

function ProgressionService.init(player: Player)
    if states[player] then return end
    local levels: Levels = {}
    for _, id in UPGRADE_IDS do levels[id] = 0 end
    local state: BloodState = {
        blood = 0,
        combo = 0,
        comboUntil = 0,
        levels = levels,
        lastPurchase = -100,
    }
    states[player] = state
    player:SetAttribute("LastBloodGain", 0)
    publish(player, state)
end

function ProgressionService.grantDrop(player: Player, golden: boolean): number
    local state = states[player]
    if not state then return 0 end
    local now = os.clock()
    state.combo = if now <= state.comboUntil then math.min(MAX_COMBO, state.combo + 1) else 1
    state.comboUntil = now + COMBO_WINDOW
    local base = 1 + state.levels.stomach * 2
    local amount = base * (if golden then 5 else 1) * state.combo
    local granted = math.max(0, math.min(amount, MAX_BLOOD - state.blood))
    state.blood += granted
    player:SetAttribute("LastBloodGain", granted)
    player:SetAttribute("BloodCombo", state.combo)
    player:SetAttribute("Blood", state.blood)
    return granted
end

local function buy(player: Player, upgradeId: unknown)
    if typeof(upgradeId) ~= "string" then return end
    local definition = Config.UPGRADES[upgradeId]
    if not definition then return end
    local state = states[player]
    if not state then return end
    local now = os.clock()
    if now - state.lastPurchase < BUY_COOLDOWN then return end
    state.lastPurchase = now

    local current = state.levels[upgradeId]
    if current >= definition.maxLevel then
        feedbackEvent:FireClient(player, false, "Esse upgrade já está no nível máximo.")
        return
    end

    -- Mesmo calculo do jogo original: floor(base * 1.3 ^ nivel).
    local cost = math.floor(definition.baseCost * (Config.UPGRADE_GROWTH ^ current))
    if state.blood < cost then
        feedbackEvent:FireClient(player, false, "Sangue insuficiente para " .. definition.name .. ".")
        return
    end

    -- Nao ha yield entre validacao e transacao: o saldo nao e gasto duas vezes.
    local previousStage = stageFor(totalLevel(state))
    state.blood -= cost
    state.levels[upgradeId] = current + 1
    publish(player, state)
    local newStage = stageFor(totalLevel(state))
    if newStage ~= previousStage then
        feedbackEvent:FireClient(player, true, "EVOLUÇÃO! " .. newStage)
    else
        feedbackEvent:FireClient(player, true, definition.name .. " nível " .. state.levels[upgradeId] .. "!")
    end
    print(string.format("[MOSQUITO] %s comprou %s nv%d por %d sangue", player.Name, upgradeId, state.levels[upgradeId], cost))
end

function ProgressionService.remove(player: Player)
    states[player] = nil
end

function ProgressionService.start()
    local remotes = ReplicatedStorage:FindFirstChild("MosquitoRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "MosquitoRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local request = remotes:FindFirstChild("BuyUpgrade")
    if not request then
        request = Instance.new("RemoteEvent")
        request.Name = "BuyUpgrade"
        request.Parent = remotes
    end
    local result = remotes:FindFirstChild("UpgradeFeedback")
    if not result then
        result = Instance.new("RemoteEvent")
        result.Name = "UpgradeFeedback"
        result.Parent = remotes
    end
    buyEvent = request :: RemoteEvent
    feedbackEvent = result :: RemoteEvent
    buyEvent.OnServerEvent:Connect(buy)
    Players.PlayerAdded:Connect(ProgressionService.init)
    Players.PlayerRemoving:Connect(ProgressionService.remove)
    for _, player in Players:GetPlayers() do ProgressionService.init(player) end
    print("[MOSQUITO] ProgressionService pronto: saldo e 4 upgrades validados no servidor")
end

return ProgressionService
