--!strict
-- Interface de teste para smartphones. A camera e controlada por arraste no centro.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TouchControls = {}

function TouchControls.create(onButton: (Enum.KeyCode, boolean) -> ()): ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "MosquitoTouchControls"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 5
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local function button(name: string, text: string, code: Enum.KeyCode, xScale: number, xOffset: number, yOffset: number, accent: Color3)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.fromOffset(58, 58)
        btn.AnchorPoint = Vector2.new(xScale, 1)
        btn.Position = UDim2.new(xScale, xOffset, 1, yOffset)
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 17
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = accent
        btn.BackgroundTransparency = 0.18
        btn.AutoButtonColor = false
        btn.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = btn
        local held = false
        local function setHeld(value: boolean)
            if held == value then return end
            held = value
            btn.BackgroundTransparency = if held then 0 else 0.18
            onButton(code, held)
        end
        btn.InputBegan:Connect(function(input: InputObject)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setHeld(true)
            end
        end)
        btn.InputEnded:Connect(function(input: InputObject)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setHeld(false)
            end
        end)
        return btn
    end

    local move = Color3.fromRGB(53, 56, 74)
    local action = Color3.fromRGB(146, 39, 65)
    -- Coluna esquerda, direcao: equivalente a WASD.
    button("Frente", "▲", Enum.KeyCode.W, 0, 92, -146, move)
    button("Tras", "▼", Enum.KeyCode.S, 0, 92, -18, move)
    button("Esquerda", "◀", Enum.KeyCode.A, 0, 22, -82, move)
    button("Direita", "▶", Enum.KeyCode.D, 0, 162, -82, move)
    -- Botoes da direita com espaco para arrastar a camera no centro.
    button("Subir", "SUBIR", Enum.KeyCode.Space, 1, -18, -146, action).TextSize = 11
    button("Descer", "DESCER", Enum.KeyCode.LeftControl, 1, -18, -82, action).TextSize = 10
    button("Sprint", "TURBO", Enum.KeyCode.LeftShift, 1, -88, -18, action).TextSize = 11
    return gui
end

return TouchControls
