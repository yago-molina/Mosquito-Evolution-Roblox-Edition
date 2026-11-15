--!strict
-- Converte o avatar Roblox num mosquito voador com partes soldadas.
-- Os objetos sao criados no servidor, portanto visiveis para outros jogadores.
local MosquitoCharacter = {}

local function newPart(parent: Instance, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?, shape: Enum.PartType?): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Transparency = transparency or 0
    part.Shape = shape or Enum.PartType.Block
    part.Anchored = false
    part.Massless = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.CFrame = offset
    part.Parent = parent
    return part
end

local function weld(root: BasePart, part: BasePart): WeldConstraint
    local connection = Instance.new("WeldConstraint")
    connection.Part0 = root
    connection.Part1 = part
    connection.Parent = part
    return connection
end

local function fixed(root: BasePart, model: Model, name: string, size: Vector3, localFrame: CFrame, color: Color3, transparency: number?, shape: Enum.PartType?): Part
    local p = newPart(model, name, size, root.CFrame * localFrame, color, nil, transparency, shape)
    weld(root, p)
    return p
end

-- Geometria alongada entre dois pontos locais, mantendo os segmentos conectados.
local function segment(root: BasePart, model: Model, name: string, from: Vector3, to: Vector3, thickness: number, color: Color3): Part
    local delta = to - from
    local frame = CFrame.lookAt((from + to) * 0.5, to)
    return fixed(root, model, name, Vector3.new(thickness, thickness, delta.Magnitude), frame, color, 0, Enum.PartType.Ball)
end

-- Detalhes presos a uma asa continuam acompanhando o Motor6D.
local function wingDetail(wingPart: Part, name: string, from: Vector3, to: Vector3, thickness: number): ()
    local delta = to - from
    local detail = Instance.new("Part")
    detail.Name = name
    detail.Shape = Enum.PartType.Ball
    detail.Size = Vector3.new(thickness, thickness, delta.Magnitude)
    detail.Material = Enum.Material.SmoothPlastic
    detail.Color = Color3.fromRGB(225, 243, 250)
    detail.Transparency = 0.25
    detail.CanCollide = false
    detail.CanTouch = false
    detail.CanQuery = false
    detail.CastShadow = false
    detail.Massless = true
    detail.Anchored = false
    detail.CFrame = wingPart.CFrame * CFrame.lookAt((from + to) * 0.5, to)
    detail.Parent = wingPart.Parent
    weld(wingPart, detail)
end

local function wing(root: BasePart, model: Model, name: string, side: number): ()
    local pivot = CFrame.new(side * 0.5, 0.47, 0.05)
    local wingPart = newPart(
        model, name, Vector3.new(2.3, 0.08, 0.85),
        root.CFrame * pivot * CFrame.new(side * 1.0, 0, 0),
        Color3.fromRGB(182, 227, 245), Enum.Material.Glass, 0.38
    )
    wingPart.Shape = Enum.PartType.Ball
    -- Nervuras e bordas discretas da asa, usando coordenadas locais.
    wingDetail(wingPart, "NervuraPrincipal", Vector3.new(-side * 0.94, 0, 0), Vector3.new(side * 0.94, 0, 0), 0.045)
    wingDetail(wingPart, "NervuraFrontal", Vector3.new(-side * 0.70, 0, -0.04), Vector3.new(side * 0.55, 0, -0.31), 0.028)
    wingDetail(wingPart, "NervuraTraseira", Vector3.new(-side * 0.65, 0, 0.03), Vector3.new(side * 0.48, 0, 0.30), 0.028)
    local motor = Instance.new("Motor6D")
    motor.Name = "WingMotor"
    motor.Part0 = root
    motor.Part1 = wingPart
    motor.C0 = pivot
    motor.C1 = CFrame.new(-side * 1.0, 0, 0)
    motor.Parent = root
    wingPart:SetAttribute("Side", side)
end

function MosquitoCharacter.setup(character: Model): ()
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local root = character:WaitForChild("HumanoidRootPart") :: BasePart
    if character:FindFirstChild("MosquitoVisual") then return end

    -- Deixar o avatar original invisivel. O Humanoid continua existindo.
    for _, descendant in character:GetDescendants() do
        if descendant:IsA("BasePart") then
            descendant.Transparency = 1
            descendant.CanCollide = false
            if descendant:IsA("MeshPart") then descendant.TextureID = "" end
        elseif descendant:IsA("Decal") then
            descendant.Transparency = 1
        end
    end

    local model = Instance.new("Model")
    model.Name = "MosquitoVisual"
    model.Parent = character

    -- Cabeca, torax e abdomen: silhueta organica vista de tras da camera.
    fixed(root, model, "Torax", Vector3.new(0.86, 0.78, 1.10), CFrame.new(0, 0.04, 0), Color3.fromRGB(84, 56, 66), 0, Enum.PartType.Ball)
    fixed(root, model, "Cabeca", Vector3.new(0.72, 0.69, 0.74), CFrame.new(0, 0.10, -0.82), Color3.fromRGB(109, 70, 78), 0, Enum.PartType.Ball)
    fixed(root, model, "Pescoco", Vector3.new(0.31, 0.28, 0.38), CFrame.new(0, 0.02, -0.49), Color3.fromRGB(54, 39, 49), 0, Enum.PartType.Ball)
    fixed(root, model, "Abdomen", Vector3.new(0.83, 0.73, 1.77), CFrame.new(0, -0.12, 1.13), Color3.fromRGB(143, 48, 72), 0, Enum.PartType.Ball)
    fixed(root, model, "PontaAbdomen", Vector3.new(0.38, 0.37, 0.53), CFrame.new(0, -0.17, 2.02), Color3.fromRGB(101, 39, 57), 0, Enum.PartType.Ball)
    -- Anéis em segmentos alongados; detalhes não colidem com o cenário.
    for index = 1, 5 do
        local z = 0.45 + index * 0.24
        local size = 0.79 - index * 0.06
        fixed(root, model, "AnelAbdominal_" .. index, Vector3.new(size, size * 0.87, 0.085), CFrame.new(0, -0.12, z), Color3.fromRGB(202, 115, 125), 0.18, Enum.PartType.Ball)
    end

    -- A tromba é um tubo horizontal voltado para a frente (-Z).
    segment(root, model, "Tromba", Vector3.new(0, -0.06, -1.12), Vector3.new(0, -0.11, -2.10), 0.095, Color3.fromRGB(46, 30, 42))
    segment(root, model, "PontaTromba", Vector3.new(0, -0.11, -2.10), Vector3.new(0, -0.13, -2.31), 0.055, Color3.fromRGB(215, 113, 125))

    for _, side in {-1, 1} do
        -- Olhos compostos e antenas com dois trechos.
        fixed(root, model, "Olho_" .. side, Vector3.new(0.31, 0.34, 0.27), CFrame.new(side * 0.29, 0.19, -1.10), Color3.fromRGB(227, 65, 88), 0, Enum.PartType.Ball)
        fixed(root, model, "BrilhoOlho_" .. side, Vector3.new(0.10, 0.12, 0.08), CFrame.new(side * 0.34, 0.29, -1.23), Color3.fromRGB(255, 191, 199), 0, Enum.PartType.Ball)
        local antennaBase = Vector3.new(side * 0.22, 0.36, -1.04)
        local antennaJoint = Vector3.new(side * 0.36, 0.73, -1.36)
        segment(root, model, "AntenaBase_" .. side, antennaBase, antennaJoint, 0.055, Color3.fromRGB(46, 35, 44))
        segment(root, model, "AntenaPonta_" .. side, antennaJoint, Vector3.new(side * 0.54, 0.83, -1.64), 0.04, Color3.fromRGB(60, 42, 49))

        -- Cada perna tem femur, articulacao (joelho) e tibia.
        -- 3 pernas por lado = 6 pernas; cada conjunto preso ao torax.
        for index = 1, 3 do
            local z = (index - 2) * 0.36
            local start = Vector3.new(side * 0.39, -0.23, z)
            local knee = Vector3.new(side * (0.96 + index * 0.08), -0.45, z + (index - 2) * 0.25)
            local tip = Vector3.new(side * (1.18 + index * 0.12), -1.05, z + (index - 2) * 0.44)
            segment(root, model, "Femur_" .. side .. "_" .. index, start, knee, 0.075, Color3.fromRGB(51, 38, 44))
            fixed(root, model, "Joelho_" .. side .. "_" .. index, Vector3.new(0.11, 0.11, 0.11), CFrame.new(knee), Color3.fromRGB(208, 169, 163), 0, Enum.PartType.Ball)
            segment(root, model, "Tibia_" .. side .. "_" .. index, knee, tip, 0.055, Color3.fromRGB(38, 31, 40))
        end
        wing(root, model, if side == -1 then "AsaEsquerda" else "AsaDireita", side)
    end

    -- Forca equivalente ao peso, permitindo deslocamento livre pelo ar.
    local attachment = Instance.new("Attachment")
    attachment.Name = "FlightAttachment"
    attachment.Parent = root
    local antiGravity = Instance.new("VectorForce")
    antiGravity.Name = "AntiGravity"
    antiGravity.Attachment0 = attachment
    antiGravity.RelativeTo = Enum.ActuatorRelativeTo.World
    antiGravity.ApplyAtCenterOfMass = true
    antiGravity.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
    antiGravity.Parent = root

    humanoid.AutoRotate = false
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    character:SetAttribute("MosquitoReady", true)
end

return MosquitoCharacter
