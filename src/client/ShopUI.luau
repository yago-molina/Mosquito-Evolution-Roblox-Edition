--!strict
-- Loja de upgrades: GUI local, custos calculados do config, servidor valida compras.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("MosquitoShared"):WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("MosquitoRemotes")
local buyRequest = remotes:WaitForChild("BuyUpgrade") :: RemoteEvent
local feedback = remotes:WaitForChild("UpgradeFeedback") :: RemoteEvent
local ShopUI = {}
local ids = {"wings", "proboscis", "stomach", "body"}
local icons = {"ASAS", "TROMBA", "ESTOMAGO", "CORPO"}

local function rounded(parent: Instance, radius: number)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function makeLabel(parent: Instance, name: string, text: string, pos: UDim2, size: UDim2, fontSize: number): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = pos
    label.Size = size
    label.Font = Enum.Font.GothamBold
    label.TextSize = fontSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(247, 226, 230)
    label.Text = text
    label.Parent = parent
    return label
end

function ShopUI.mount(gui: ScreenGui)
    local opener = Instance.new("TextButton")
    opener.Name = "AbrirLoja"
    opener.AnchorPoint = Vector2.new(1, 0)
    opener.Position = UDim2.new(1, -14, 0, 18)
    opener.Size = UDim2.fromOffset(130, 44)
    opener.BackgroundColor3 = Color3.fromRGB(116, 39, 68)
    opener.Text = "UPGRADES [U]"
    opener.Font = Enum.Font.GothamBold
    opener.TextSize = 13
    opener.TextColor3 = Color3.new(1, 1, 1)
    opener.Parent = gui
    rounded(opener, 10)

    local panel = Instance.new("Frame")
    panel.Name = "Loja"
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -14, 0, 70)
    panel.Size = UDim2.new(0.92, 0, 0, 342)
    panel.BackgroundColor3 = Color3.fromRGB(24, 19, 32)
    panel.Visible = false
    panel.Parent = gui
    rounded(panel, 12)
    local limit = Instance.new("UISizeConstraint")
    limit.MaxSize = Vector2.new(320, 342)
    limit.Parent = panel

    makeLabel(panel, "Titulo", "MELHORIAS DO MOSQUITO", UDim2.fromOffset(12, 10), UDim2.new(1, -24, 0, 26), 16)
    local stageText = makeLabel(panel, "Estagio", "Nível total 0 | Larva voadora", UDim2.fromOffset(12, 37), UDim2.new(1, -24, 0, 30), 11)
    stageText.TextWrapped = true
    stageText.TextColor3 = Color3.fromRGB(255, 197, 125)
    local messages = makeLabel(panel, "Feedback", "Teclas 1-4 ou toque para comprar", UDim2.fromOffset(12, 310), UDim2.new(1, -24, 0, 24), 11)
    messages.TextColor3 = Color3.fromRGB(216, 198, 205)

    local buttons: {[string]: TextButton} = {}
    for index, id in ids do
        local btn = Instance.new("TextButton")
        btn.Name = "Comprar_" .. id
        btn.Size = UDim2.new(1, -24, 0, 51)
        btn.Position = UDim2.fromOffset(12, 62 + (index - 1) * 60)
        btn.BackgroundColor3 = Color3.fromRGB(75, 52, 70)
        btn.TextColor3 = Color3.fromRGB(255, 248, 250)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextWrapped = true
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.Parent = panel
        rounded(btn, 8)
        btn.Activated:Connect(function()
            buyRequest:FireServer(id)
        end)
        buttons[id] = btn
    end

    local open = false
    local function toggle()
        open = not open
        panel.Visible = open
        opener.Text = if open then "FECHAR [U]" else "UPGRADES [U]"
        if not UserInputService.TouchEnabled then
            UserInputService.MouseBehavior = if open then Enum.MouseBehavior.Default else Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = open
        end
    end
    opener.Activated:Connect(toggle)

    UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.U then
            toggle()
        elseif open then
            local index = if input.KeyCode == Enum.KeyCode.One then 1
                elseif input.KeyCode == Enum.KeyCode.Two then 2
                elseif input.KeyCode == Enum.KeyCode.Three then 3
                elseif input.KeyCode == Enum.KeyCode.Four then 4 else nil
            if index then buyRequest:FireServer(ids[index]) end
        end
    end)

    local function update()
        local money = player:GetAttribute("Blood")
        local total = player:GetAttribute("UpgradeTotal")
        local stage = player:GetAttribute("EvolutionStage")
        local balance = if typeof(money) == "number" then money else 0
        stageText.Text = string.format("Nível total %d | %s", if typeof(total) == "number" then total else 0, if typeof(stage) == "string" then stage else "Larva voadora")
        for index, id in ids do
            local def = Config.UPGRADES[id]
            local attr = player:GetAttribute("Upgrade_" .. id)
            local level = if typeof(attr) == "number" then attr else 0
            local cost = math.floor(def.baseCost * Config.UPGRADE_GROWTH ^ level)
            local maxed = level >= def.maxLevel
            buttons[id].Text = string.format("%d. %s  |  Nv %d/30  |  %s", index, icons[index], level, if maxed then "MAX" else tostring(cost) .. " sangue")
            buttons[id].BackgroundColor3 = if maxed then Color3.fromRGB(64, 65, 69)
                elseif balance >= cost then Color3.fromRGB(101, 53, 81) else Color3.fromRGB(65, 49, 61)
        end
    end
    player:GetAttributeChangedSignal("Blood"):Connect(update)
    player:GetAttributeChangedSignal("UpgradeTotal"):Connect(update)
    player:GetAttributeChangedSignal("EvolutionStage"):Connect(update)
    for _, id in ids do player:GetAttributeChangedSignal("Upgrade_" .. id):Connect(update) end
    feedback.OnClientEvent:Connect(function(success: boolean, message: string)
        messages.Text = message
        messages.TextColor3 = if success then Color3.fromRGB(149, 241, 162) else Color3.fromRGB(255, 152, 152)
    end)
    update()
    print("[MOSQUITO] Loja inicializada: tecla U, compras 1-4 ou toque")
end

return ShopUI
