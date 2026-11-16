--!strict
-- DataStore v1. Falha de leitura significa gravacoes desativadas nesta sessao.
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local PersistenceService = {}
local store = DataStoreService:GetDataStore("MosquitoEvolution_Progress_v1")
local ids = {"wings", "proboscis", "stomach", "body"}
local access: {[number]: boolean} = {}
local lastSaved: {[number]: number} = {}
local inFlight: {[number]: boolean} = {}

local function valid(data: any): boolean
    if typeof(data) ~= "table" or data.schema ~= 1 then return false end
    local blood = data.blood
    if typeof(blood) ~= "number" or blood ~= math.floor(blood) or blood < 0 or blood > 1e9 then return false end
    if typeof(data.levels) ~= "table" then return false end
    for _, id in ids do
        local level = data.levels[id]
        if typeof(level) ~= "number" or level ~= math.floor(level) or level < 0 or level > 30 then return false end
    end
    return true
end

local function payload(snapshot: any)
    local levels = {}
    for _, id in ids do levels[id] = snapshot.levels[id] end
    return {schema = 1, blood = snapshot.blood, levels = levels}
end

function PersistenceService.load(player: Player): (string, any?)
    if RunService:IsStudio() and game.GameId == 0 then
        warn("[MOSQUITO] Lugar nao publicado: DataStore indisponivel")
        return "Offline", nil
    end
    local ok, data = pcall(function()
        return store:GetAsync("Player_" .. player.UserId)
    end)
    if not ok then
        warn("[MOSQUITO] Falha de leitura do save de " .. player.Name .. ": " .. tostring(data))
        return "Offline", nil
    end
    if data ~= nil and not valid(data) then
        warn("[MOSQUITO] Save invalido para " .. player.Name .. "; escrita bloqueada")
        return "Invalid", nil
    end
    access[player.UserId] = true
    lastSaved[player.UserId] = 0
    print("[MOSQUITO] Save carregado: " .. player.Name .. (if data == nil then " (novo)" else " (existente)"))
    return "Ready", if data then payload(data) else nil
end

function PersistenceService.save(player: Player, snapshot: any): boolean
    local id = player.UserId
    if not access[id] or not valid(snapshot) then return false end
    local revision = snapshot.revision
    if typeof(revision) ~= "number" then return false end
    if revision <= (lastSaved[id] or 0) then return true end
    local start = os.clock()
    while inFlight[id] do
        if os.clock() - start > 12 then return false end
        task.wait(0.1)
    end
    if revision <= (lastSaved[id] or 0) then return true end
    inFlight[id] = true
    local data = payload(snapshot)
    local ok, err = pcall(function()
        store:UpdateAsync("Player_" .. id, function(previous: any)
            if previous ~= nil and not valid(previous) then error("Registro anterior invalido") end
            return data
        end)
    end)
    inFlight[id] = nil
    if not ok then
        warn("[MOSQUITO] Erro ao salvar " .. player.Name .. ": " .. tostring(err))
        return false
    end
    lastSaved[id] = revision
    print(string.format("[MOSQUITO] Save confirmado: %s (rev %d)", player.Name, revision))
    return true
end

function PersistenceService.clear(player: Player)
    local id = player.UserId
    access[id] = nil
    lastSaved[id] = nil
    inFlight[id] = nil
end

return PersistenceService
