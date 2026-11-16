--!strict
-- Economia por jogador: servidor e autoridade sobre sangue e upgrades.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local ProgressionService = {}
local PersistenceService = require(script.Parent:WaitForChild("PersistenceService"))

type Levels = {[string]: number}
type BloodState = {
    blood: number,
    combo: number,
    comboUntil: number,
    levels: Levels,
    lastPurchase: number,
    revision: number,
    loaded: boolean,
    saveMode: string,
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
    player:SetAttribute("SaveStatus", state.saveMode)
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
        revision = 0,
        loaded = false,
        saveMode = "Loading",
    }
    states[player] = state
    player:SetAttribute("LastBloodGain", 0)
    publish(player, state)
    task.spawn(function()
        local status, data = PersistenceService.load(player)
        if states[player] ~= state then return end
        if data then
            state.blood = data.blood
            for _, id in UPGRADE_IDS do state.levels[id] = data.levels[id] end
        end
        state.saveMode = status
        state.loaded = true
        publish(player, state)
        print("[MOSQUITO] Progresso carregado para " .. player.Name .. ": " .. status)
    end)
end

function ProgressionService.snapshot(player: Player): any?
    local state = states[player]
    if not state or not state.loaded or state.saveMode ~= "Ready" then return nil end
    local levels: Levels = {}
    for _, id in UPGRADE_IDS do levels[id] = state.levels[id] end
    return {schema = 1, blood = state.blood, levels = levels, revision = state.revision}
end

function ProgressionService.grantDrop(player: Player, golden: boolean): number
    local state = states[player]
    if not state or not state.loaded then return 0 end
    local now = os.clock()
    state.combo = if now <= state.comboUntil then math.min(MAX_COMBO, state.combo + 1) else 1
    state.comboUntil = now + COMBO_WINDOW
    local base = 1 + state.levels.stomach * 2
    local amount = base * (if golden then 5 else 1) * state.combo
    local granted = math.max(0, math.min(amount, MAX_BLOOD - state.blood))
    state.blood += granted
    if granted > 0 then state.revision += 1 end
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
    if not state.loaded then
        feedbackEvent:FireClient(player, false, "Carregando progresso.")
        return
    end
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
    state.revision += 1
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
    local snap = ProgressionService.snapshot(player)
    if snap then PersistenceService.save(player, snap) end
    states[player] = nil
    PersistenceService.clear(player)
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

    task.spawn(function()
        while task.wait(90) do
            for _, player in Players:GetPlayers() do
                local snap = ProgressionService.snapshot(player)
                if snap then task.spawn(PersistenceService.save, player, snap) end
            end
        end
    end)
    game:BindToClose(function()
        local pending = 0
        for _, player in Players:GetPlayers() do
            local snap = ProgressionService.snapshot(player)
            if snap then
                pending += 1
                task.spawn(function()
                    PersistenceService.save(player, snap)
                    pending -= 1
                end)
            end
        end
        local start = os.clock()
        while pending > 0 and os.clock() - start < 25 do task.wait(0.1) end
    end)
    print("[MOSQUITO] ProgressionService pronto: upgrades e save v1")
end

return ProgressionService
