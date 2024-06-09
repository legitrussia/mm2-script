local PLAYER = game.Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()
local CC = game.Workspace.CurrentCamera

local ENABLED = false
local AIM_PART = 'Head'
local SMOOTHING = 1  -- Ajuste inicial de suavização

-- Configurações da interface gráfica
local GUI_MAIN = Instance.new('ScreenGui', game.CoreGui)
local GUI_TARGET = Instance.new('TextLabel', GUI_MAIN)
local GUI_AIM_AT = Instance.new('TextLabel', GUI_MAIN)

GUI_MAIN.Name = 'AIMBOT'

GUI_TARGET.Size = UDim2.new(0, 200, 0, 30)
GUI_TARGET.BackgroundTransparency = 0.5
GUI_TARGET.BackgroundColor3 = Color3.fromRGB(69, 69, 69)
GUI_TARGET.BorderSizePixel = 0
GUI_TARGET.Position = UDim2.new(0.5, -100, 0, 0)
GUI_TARGET.Text = 'AIMBOT : OFF'
GUI_TARGET.TextColor3 = Color3.new(1, 1, 1)
GUI_TARGET.TextWrapped = true
GUI_TARGET.Font = Enum.Font.SourceSansBold
GUI_TARGET.TextSize = 24

GUI_AIM_AT.Size = UDim2.new(0, 200, 0, 20)
GUI_AIM_AT.BackgroundTransparency = 0.5
GUI_AIM_AT.BackgroundColor3 = Color3.fromRGB(69, 69, 69)
GUI_AIM_AT.BorderSizePixel = 0
GUI_AIM_AT.Position = UDim2.new(0.5, -100, 0, 30)
GUI_AIM_AT.Text = 'AIMING : HEAD'
GUI_AIM_AT.TextColor3 = Color3.new(1, 1, 1)
GUI_AIM_AT.TextWrapped = true
GUI_AIM_AT.Font = Enum.Font.SourceSansBold
GUI_AIM_AT.TextSize = 18

-- Função para verificar se o jogador está equipado com uma arma
local function IsEquippedWithWeapon()
    local character = PLAYER.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                return true
            end
        end
    end
    return false
end

-- Função para encontrar o jogador mais próximo ao cursor do mouse
local function GetNearestPlayerToMouse()
    local players = game.Players:GetPlayers()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, v in pairs(players) do
        if v ~= PLAYER and v.Character and v.Character:FindFirstChild(AIM_PART) then
            local aimPart = v.Character[AIM_PART]
            local distance = (aimPart.Position - CC.CFrame.p).magnitude
            local screenPoint = CC:WorldToViewportPoint(aimPart.Position)
            local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(MOUSE.X, MOUSE.Y)).magnitude

            if mouseDistance < shortestDistance then
                shortestDistance = mouseDistance
                nearestPlayer = v
            end
        end
    end

    if shortestDistance > 300 then  -- Ajuste a distância máxima conforme necessário
        return nil
    end

    return nearestPlayer
end

-- Função para mover o mouse suavemente em direção ao alvo
local function MoveMouseToTarget(targetPosition)
    local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
    local screenTargetPos = CC:WorldToViewportPoint(targetPosition)

    local moveVector = Vector2.new(screenTargetPos.X, screenTargetPos.Y) - mouseLocation
    moveVector = moveVector / (11 - SMOOTHING)  -- Ajustar suavização com base no valor do slider

    mousemoveabs(mouseLocation.X + moveVector.X, mouseLocation.Y + moveVector.Y)
end

-- Configuração dos eventos do mouse
MOUSE.Button2Down:Connect(function()
    if IsEquippedWithWeapon() then
        ENABLED = true
    end
end)

MOUSE.Button2Up:Connect(function()
    ENABLED = false
end)

MOUSE.KeyDown:Connect(function(KEY)
    if KEY == string.byte('q') then
        if AIM_PART == 'Head' then
            AIM_PART = 'Neck'
            GUI_AIM_AT.Text = 'AIMING : NECK'
        elseif AIM_PART == 'Neck' then
            AIM_PART = 'Torso'
            GUI_AIM_AT.Text = 'AIMING : TORSO'
        elseif AIM_PART == 'Torso' then
            AIM_PART = 'Head'
            GUI_AIM_AT.Text = 'AIMING : HEAD'
        end
    end
end)

-- Loop principal do aimbot
game:GetService('RunService').RenderStepped:Connect(function()
    if ENABLED then
        local TARGET = GetNearestPlayerToMouse()
        if TARGET then
            local AIM = TARGET.Character:FindFirstChild(AIM_PART)
            if AIM then
                MoveMouseToTarget(AIM.Position)
                GUI_TARGET.Text = 'AIMBOT : '.. TARGET.Name:sub(1, 5)
            end
        else
            GUI_TARGET.Text = 'AIMBOT : OFF'
        end
    end
end)
