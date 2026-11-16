--!strict
-- Fase 3C: personalizacao visual nao destrutiva dos modelos da Fase 2.
-- A escala e apenas visual: nao modifica raiz fisica, asa motor C0 ou camera.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local EvolutionVisual = {}

local palette = {
    Color3.fromRGB(255, 180, 92),
    Color3.fromRGB(255, 51, 85),
    Color3.fromRGB(216, 60, 255),
    Color3.fromRGB(57, 217, 255),
    Color3.fromRGB(85, 255, 85),
    Color3.fromRGB(255, 136, 51),
    Color3.fromRGB(255, 34, 102),
    Color3.fromRGB(255, 216, 77),
    Color3.fromRGB(153, 0, 255),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(50, 47, 75),
    Color3.fromRGB(0, 255, 204),
    Color3.fromRGB(255, 0, 0),
}
local highlights = { Torax = true, Cabeca = true, Abdomen = true, PontaAbdomen = true }

local function findStage(total: number): number
    local stageIndex = 1
    for index, stage in Config.STAGES do
        if total >= stage.minimum then stageIndex = index else break end
    end
    return stageIndex
end

function EvolutionVisual.apply(character: Model, total: number, animate: boolean)
    local visual = character:FindFirstChild("MosquitoVisual")
    if not visual or not visual:IsA("Model") then return end
    local index = findStage(math.clamp(total, 0, 120))
    local previous = character:GetAttribute("EvolutionIndex")
    if previous == index then return end

    -- 1.0x a 1.65x: crescimento visual gradual sem mudar a geometria fisica.
    -- Detalhes pequenos aumentam menos para preservar a silhueta.
    local scale = 1 + (index - 1) * (0.65 / (#Config.STAGES - 1))
    local tint = palette[index]
    for _, item in visual:GetDescendants() do
        if item:IsA("BasePart") then
            local base = item:GetAttribute("OriginalSize")
            if typeof(base) == "Vector3" then
                local localScale = if highlights[item.Name] then scale else 1 + (scale - 1) * 0.6
                item.Size = base * localScale
            end
            if item:GetAttribute("OriginalColor") == nil then
                item:SetAttribute("OriginalColor", item.Color)
            end
            local oldColor = item:GetAttribute("OriginalColor")
            if typeof(oldColor) == "Color3" then
                local strength = if highlights[item.Name] then 0.7 else 0.25
                item.Color = if index == 1 then oldColor else oldColor:Lerp(tint, strength)
            end
        end
    end
    character:SetAttribute("EvolutionIndex", index)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        local glow = root:FindFirstChild("EvolutionGlow")
        if not glow then
            glow = Instance.new("PointLight")
            glow.Name = "EvolutionGlow"
            glow.Range = 5
            glow.Brightness = 0
            glow.Parent = root
        end
        if glow:IsA("PointLight") then
            glow.Color = tint
            glow.Brightness = if index == 1 then 0 else math.min(0.65, 0.12 + index * 0.045)
        end
        if animate and previous ~= nil then
            local particles = Instance.new("ParticleEmitter")
            particles.Name = "EvolutionBurst"
            particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            particles.Rate = 0
            particles.Lifetime = NumberRange.new(0.35, 0.75)
            particles.Speed = NumberRange.new(3, 7)
            particles.SpreadAngle = Vector2.new(180, 180)
            particles.Color = ColorSequence.new(tint)
            particles.LightEmission = 0.8
            particles.Parent = root
            particles:Emit(36)
            game:GetService("Debris"):AddItem(particles, 2)
        end
    end
    print(string.format("[MOSQUITO] Evolucao visual: %s (indice %d)", Config.STAGES[index].name, index))
end

return EvolutionVisual
