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

local function wing(root: BasePart, model: Model, name: string, side: number): ()
    local pivot = CFrame.new(side * 0.5, 0.47, 0.05)
    local wingPart = newPart(
        model, name, Vector3.new(2.3, 0.08, 0.85),
        root.CFrame * pivot * CFrame.new(side * 1.0, 0, 0),
        Color3.fromRGB(182, 227, 245), Enum.Material.Glass, 0.38
    )
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

    fixed(root, model, "Torax", Vector3.new(0.85, 0.75, 1.05), CFrame.new(0, 0, 0), Color3.fromRGB(95, 54, 59), 0, Enum.PartType.Ball)
    fixed(root, model, "Cabeca", Vector3.new(0.72, 0.7, 0.72), CFrame.new(0, 0.05, -0.8), Color3.fromRGB(132, 69, 77), 0, Enum.PartType.Ball)
    fixed(root, model, "Abdomen", Vector3.new(0.8, 0.72, 1.7), CFrame.new(0, -0.08, 1.12), Color3.fromRGB(156, 49, 77), 0, Enum.PartType.Ball)
    fixed(root, model, "Tromba", Vector3.new(0.10, 0.1, 1.22), CFrame.new(0, -0.05, -1.72), Color3.fromRGB(45, 29, 40), 0, Enum.PartType.Cylinder)
    for _, side in {-1, 1} do
        fixed(root, model, "Olho", Vector3.new(0.25, 0.3, 0.22), CFrame.new(side * 0.32, 0.16, -1.06), Color3.fromRGB(235, 54, 72), 0, Enum.PartType.Ball)
        for index = 1, 3 do
            fixed(root, model, "Perna", Vector3.new(0.06, 0.85, 0.06),
                CFrame.new(side * (0.65 + index * 0.07), -0.47, (index - 2) * 0.37) * CFrame.Angles(0, 0, math.rad(side * 25)),
                Color3.fromRGB(37, 29, 39), 0, Enum.PartType.Cylinder)
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
