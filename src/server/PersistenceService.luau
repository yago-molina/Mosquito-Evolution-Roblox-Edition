--!strict
-- Fase 3D: armazenamento autoritativo, com diagnostico e gravacao verificavel.
-- Dados antigos v1 sao preservados. Nunca gravar apos GetAsync falhar.
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local PersistenceService = {}

local STORE_NAME = "MosquitoEvolution_Progress_v1"
local KEY_PREFIX = "Player_"
local store = DataStoreService:GetDataStore(STORE_NAME)
local ids = {"wings", "proboscis", "stomach", "body"}
local access: {[number]: boolean} = {}
local inFlight: {[number]: boolean} = {}
local lastSaved: {[number]: number} = {}
local MAX_WAIT = 18

local function valid(data: any): boolean
    if typeof(data) ~= "table" or data.schema ~= 1 then return false end
    if typeof(data.blood) ~= "number" or data.blood ~= math.floor(data.blood)
        or data.blood < 0 or data.blood > 1000000000 then return false end
    if typeof(data.levels) ~= "table" then return false end
    for _, id in ids do
        local level = data.levels[id]
        if typeof(level) ~= "number" or level ~= math.floor(level)
            or level < 0 or level > 30 then return false end
    end
    return true
end

local function payload(data: any)
    local levels: {[string]: number} = {}
    for _, id in ids do levels[id] = data.levels[id] end
    return {schema = 1, blood = data.blood, levels = levels}
end

local function levelTotal(data: any): number
    local total = 0
    for _, id in ids do total += data.levels[id] end
    return total
end

function PersistenceService.load(player: Player): (string, any?)
    local id = player.UserId
    access[id] = nil
    print(string.format(
        "[MOSQUITO][SAVE] Leitura: experience=%d place=%d studio=%s store=%s",
        game.GameId, game.PlaceId, tostring(RunService:IsStudio()), STORE_NAME
    ))
    if game.GameId == 0 then
        warn("[MOSQUITO][SAVE] Experiencia nao publicada. Publique uma experiencia de teste privada.")
        return "Offline", nil
    end
    local key = KEY_PREFIX .. tostring(id)
    local ok, data = pcall(function()
        return store:GetAsync(key)
    end)
    if not ok then
        warn("[MOSQUITO][SAVE] GetAsync falhou. Studio API Services precisa estar habilitado na experiencia de teste. Detalhe: " .. tostring(data))
        return "Offline", nil
    end
    if data ~= nil and not valid(data) then
        warn("[MOSQUITO][SAVE] Registro incompatível: escrita bloqueada para nao perder dados.")
        return "Invalid", nil
    end

    access[id] = true
    lastSaved[id] = 0
    if data == nil then
        print("[MOSQUITO][SAVE] Leitura OK: jogador sem registro anterior (saldo inicial 0)")
        return "Ready", nil
    end
    print(string.format("[MOSQUITO][SAVE] Leitura OK: sangue=%d niveis=%d", data.blood, levelTotal(data)))
    return "Ready", payload(data)
end

-- O retorno deve informar sucesso REAL; pcall sozinho nao basta porque
-- UpdateAsync pode retornar nil quando a transformacao cancela a escrita.
function PersistenceService.save(player: Player, snapshot: any): (boolean, string)
    local id = player.UserId
    if not access[id] then return false, "Leitura nao autorizada ou falhou" end
    if not valid(snapshot) then return false, "Dados invalidos para salvamento" end
    local revision = snapshot.revision
    if typeof(revision) ~= "number" or revision < 0 then return false, "Revisao invalida" end
    if revision <= (lastSaved[id] or 0) then return true, "Sem alteracoes" end

    local start = os.clock()
    while inFlight[id] do
        if os.clock() - start > MAX_WAIT then return false, "Save ocupado" end
        task.wait(0.1)
    end
    if revision <= (lastSaved[id] or 0) then return true, "Ja salvo" end
    inFlight[id] = true
    local value = payload(snapshot)
    local key = KEY_PREFIX .. tostring(id)
    local ok, result = pcall(function()
        return store:UpdateAsync(key, function(previous: any)
            if previous ~= nil and not valid(previous) then
                -- Aborta sem substituir um documento de schema desconhecido.
                return nil
            end
            return value
        end)
    end)
    inFlight[id] = nil

    if not ok then
        warn("[MOSQUITO][SAVE] UpdateAsync falhou: " .. tostring(result))
        return false, tostring(result)
    end
    if result == nil or not valid(result) then
        warn("[MOSQUITO][SAVE] UpdateAsync cancelado ou retornou dado invalido; escrita NAO confirmada")
        return false, "Gravacao cancelada"
    end
    if result.blood ~= value.blood then
        warn("[MOSQUITO][SAVE] Valor retornado nao confere com saldo solicitado")
        return false, "Confirmacao divergente"
    end
    for _, name in ids do
        if result.levels[name] ~= value.levels[name] then
            return false, "Confirmacao dos upgrades divergente"
        end
    end
    lastSaved[id] = revision
    print(string.format("[MOSQUITO][SAVE] GRAVACAO CONFIRMADA: sangue=%d niveis=%d revisao=%d", value.blood, levelTotal(value), revision))
    return true, "Confirmado"
end

function PersistenceService.clear(player: Player)
    local id = player.UserId
    access[id] = nil
    lastSaved[id] = nil
    inFlight[id] = nil
end

return PersistenceService
