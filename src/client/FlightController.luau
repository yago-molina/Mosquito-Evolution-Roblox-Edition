--!strict
-- Controle de voo desktop (Fase 2), com camera em terceira pessoa.
-- Nao envia recompensas, sangue ou progresso: recursos serao gerenciados no servidor.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local FlightController = {}
local SPEED = 21
local SPRINT_SPEED = 36
local STAMINA_MAX = 100
local STAMINA_DRAIN = 28
local STAMINA_RECOVERY = 19
local CAMERA_DISTANCE = 7.5
local CAMERA_HEIGHT = 2.6
local SENSITIVITY = 0.0028

local active = false
local keys: {[Enum.KeyCode]: boolean} = {}
local stamina = STAMINA_MAX
local sprinting = false
local yaw = 0
local pitch = -0.15
local root: BasePart? = nil
local humanoid: Humanoid? = nil
local wings: {{motor: Motor6D, base: CFrame, side: number}} = {}
local timeAlive = 0
local updated: RBXScriptConnection? = nil
local mouseConnection: RBXScriptConnection? = nil
local inputBeganConnection: RBXScriptConnection? = nil
local inputEndedConnection: RBXScriptConnection? = nil
local controls: any = nil

local function pressed(code: Enum.KeyCode): boolean
    return keys[code] == true
end

local function cleanup(): ()
    active = false
    if updated then updated:Disconnect(); updated = nil end
    if mouseConnection then mouseConnection:Disconnect(); mouseConnection = nil end
    if inputBeganConnection then inputBeganConnection:Disconnect(); inputBeganConnection = nil end
    if inputEndedConnection then inputEndedConnection:Disconnect(); inputEndedConnection = nil end
    table.clear(keys)
    for _, wing in wings do
        if wing.motor.Parent then
            wing.motor.C0 = wing.base
        end
    end
    table.clear(wings)
    if controls then controls:Enable(); controls = nil end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    local cam = Workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
end

function FlightController.start(character: Model, onStamina: (number, boolean) -> ()): ()
    cleanup()
    local hrp = character:WaitForChild("HumanoidRootPart", 10)
    local hum = character:WaitForChild("Humanoid", 10)
    if not hrp or not hum then warn("[MOSQUITO] Avatar incompleto"); return end
    root = hrp :: BasePart
    humanoid = hum :: Humanoid
    local visual = character:WaitForChild("MosquitoVisual", 10)
    if not visual then warn("[MOSQUITO] Modelo MosquitoVisual nao encontrado"); return end
    -- Os Motor6D das asas foram criados dentro do HumanoidRootPart,
    -- nao dentro do MosquitoVisual.
    for _, obj in character:GetDescendants() do
        if obj:IsA("Motor6D") and obj.Name == "WingMotor" and obj.Part1 then
            local side = obj.Part1:GetAttribute("Side")
            if typeof(side) == "number" then
                table.insert(wings, {
                    motor = obj,
                    base = obj.C0,
                    side = side,
                })
            end
        end
    end
    print(string.format("[MOSQUITO] Articulacoes das asas encontradas: %d/2", #wings))
    if #wings ~= 2 then
        warn("[MOSQUITO] Asas incompletas: conferir WingMotor no HumanoidRootPart")
    end

    -- PlayerModule pode nao existir no Studio (custom StarterPlayerScripts).
    -- NUNCA usar WaitForChild sem limite para esse modulo opcional.
    -- A falta dele nao deve impedir inicializacao de voo, input ou animacao.
    local playerScripts = player:FindFirstChild("PlayerScripts")
    local module = if playerScripts then playerScripts:FindFirstChild("PlayerModule") else nil
    if module and module:IsA("ModuleScript") then
        local success, result = pcall(function()
            return require(module)
        end)
        if success and type(result) == "table" and type(result.GetControls) == "function" then
            local ok, controller = pcall(function() return result:GetControls() end)
            if ok and controller then
                controls = controller
                controls:Disable()
            end
        else
            warn("[MOSQUITO] PlayerModule indisponivel; usando movimento proprio.")
        end
    else
        print("[MOSQUITO] PlayerModule ausente: controle de voo independente ativado.")
    end

    local camera = Workspace.CurrentCamera
    if not camera then warn("[MOSQUITO] Camera indisponivel"); return end
    camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false

    local forward = root.CFrame.LookVector
    yaw = math.atan2(-forward.X, -forward.Z)
    pitch = -0.15
    stamina = STAMINA_MAX
    timeAlive = 0
    active = true

    inputBeganConnection = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keys[input.KeyCode] = true
        end
    end)
    inputEndedConnection = UserInputService.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keys[input.KeyCode] = false
        end
    end)
    mouseConnection = UserInputService.InputChanged:Connect(function(input: InputObject, processed: boolean)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement and active then
            yaw -= input.Delta.X * SENSITIVITY
            pitch = math.clamp(pitch - input.Delta.Y * SENSITIVITY, -1.15, 1.15)
        end
    end)

    updated = RunService.PreSimulation:Connect(function(dt: number)
        if not active or not root or not root.Parent or not humanoid or humanoid.Health <= 0 then return end
        local forwardFlat = Vector3.new(-math.sin(yaw), 0, -math.cos(yaw))
        local rightFlat = Vector3.new(math.cos(yaw), 0, -math.sin(yaw))
        local direction = Vector3.zero
        if pressed(Enum.KeyCode.W) then direction += forwardFlat end
        if pressed(Enum.KeyCode.S) then direction -= forwardFlat end
        if pressed(Enum.KeyCode.D) then direction += rightFlat end
        if pressed(Enum.KeyCode.A) then direction -= rightFlat end
        if pressed(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if pressed(Enum.KeyCode.LeftControl) or pressed(Enum.KeyCode.RightControl) then direction -= Vector3.yAxis end
        if direction.Magnitude > 0 then direction = direction.Unit end

        sprinting = pressed(Enum.KeyCode.LeftShift) and direction.Magnitude > 0 and stamina > 0
        if sprinting then
            stamina = math.max(0, stamina - STAMINA_DRAIN * dt)
        else
            stamina = math.min(STAMINA_MAX, stamina + STAMINA_RECOVERY * dt)
        end
        root.AssemblyLinearVelocity = direction * (if sprinting then SPRINT_SPEED else SPEED)
        root.AssemblyAngularVelocity = Vector3.zero
        -- A frente do mosquito acompanha o olhar da camera no eixo horizontal.
        root.CFrame = CFrame.lookAt(root.Position, root.Position + forwardFlat)
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        onStamina(stamina / STAMINA_MAX, sprinting)
    end)
    RunService:BindToRenderStep("MosquitoCamera", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
        if not active or not root or not root.Parent then return end
        timeAlive += dt
        local cameraForward = Vector3.new(-math.sin(yaw) * math.cos(pitch), math.sin(pitch), -math.cos(yaw) * math.cos(pitch))
        local focus = root.Position + Vector3.new(0, 0.45, 0)
        local desiredPosition = focus - cameraForward * CAMERA_DISTANCE + Vector3.new(0, CAMERA_HEIGHT, 0)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}
        local ray = Workspace:Raycast(focus, desiredPosition - focus, params)
        if ray and ray.Instance and not ray.Instance:IsDescendantOf(character) then
            desiredPosition = ray.Position + ray.Normal * 0.25
        end
        local desired = CFrame.lookAt(desiredPosition, focus + cameraForward * 1.5)
        camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(dt * 12, 0, 1))
        camera.Focus = CFrame.new(focus)
        -- Animar C0, nao Transform: Animator/Humanoid pode sobrescrever
        -- Transform no ciclo de animacao. C0 gira a asa no proprio encaixe.
        -- Frequencia de ~3,5 batidas/s: suficientemente visivel a 60 FPS.
        local flap = 0.16 + math.sin(timeAlive * 22) * 0.82
        for _, wing in wings do
            if wing.motor.Parent then
                wing.motor.C0 = wing.base * CFrame.Angles(0, 0, wing.side * flap)
            end
        end
    end)
    print("[MOSQUITO] Voo local ativo: WASD, Espaco, Ctrl, Shift, mouse")
end

function FlightController.stop(): ()
    RunService:UnbindFromRenderStep("MosquitoCamera")
    cleanup()
    UserInputService.MouseIconEnabled = true
end

return FlightController
