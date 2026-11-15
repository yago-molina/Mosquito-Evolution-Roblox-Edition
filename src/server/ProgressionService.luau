--!strict
-- Estado de sessao para a primeira etapa da Fase 3.
-- O servidor e o unico responsavel por conceder sangue.
local Players = game:GetService("Players")
local ProgressionService = {}
type BloodState = {
    blood: number,
    combo: number,
    comboUntil: number,
}
local states: {[Player]: BloodState} = {}
local MAX_BLOOD = 1_000_000_000
local COMBO_WINDOW = 4
local MAX_COMBO = 5

local function publish(player: Player, state: BloodState, lastGain: number)
    -- Attributes replicam do servidor para o cliente sem RemoteEvent de compra.
    player:SetAttribute("Blood", state.blood)
    player:SetAttribute("BloodCombo", state.combo)
    player:SetAttribute("LastBloodGain", lastGain)
end

function ProgressionService.init(player: Player)
    if states[player] then return end
    local state: BloodState = {blood = 0, combo = 0, comboUntil = 0}
    states[player] = state
    publish(player, state, 0)
end

function ProgressionService.grantDrop(player: Player, golden: boolean): number
    local state = states[player]
    if not state then return 0 end
    local now = os.clock()
    state.combo = if now <= state.comboUntil then math.min(MAX_COMBO, state.combo + 1) else 1
    state.comboUntil = now + COMBO_WINDOW
    local amount = (if golden then 5 else 1) * state.combo
    local granted = math.min(amount, MAX_BLOOD - state.blood)
    state.blood += granted
    publish(player, state, granted)
    return granted
end

function ProgressionService.remove(player: Player)
    states[player] = nil
end

function ProgressionService.start()
    Players.PlayerAdded:Connect(ProgressionService.init)
    Players.PlayerRemoving:Connect(ProgressionService.remove)
    for _, player in Players:GetPlayers() do
        ProgressionService.init(player)
    end
    print("[MOSQUITO] ProgressionService pronto: saldo de sangue no servidor")
end

return ProgressionService
