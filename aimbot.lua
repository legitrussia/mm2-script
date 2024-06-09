PLAYER = game.Players.LocalPlayer
MOUSE = PLAYER:GetMouse()
CC = game.Workspace.CurrentCamera

ENABLED = false
ESP_ENABLED = false

_G.FREE_FOR_ALL = true
_G.ESP_BIND = 52
_G.CHANGE_AIM = 'q'
_G.AIM_AT = 'Head'
_G.SMOOTHING = 0.2  -- Ajuste para suavizar o movimento do mouse (0-1)

wait(1)

function IsEquippedWithWeapon()
    local character = PLAYER.Character
    if character and character:FindFirstChildOfClass("Tool") then
        return true
    end
    return false
end

function GetNearestPlayerToMouse()
    local players = game.Players:GetPlayers()
    local nearestPlayer
    local shortestDistance = math.huge

    for _, v in pairs(players) do
        if v ~= PLAYER and v.Character and v.Character:FindFirstChild(_G.AIM_AT) then
            local aimPart = v.Character[_G.AIM_AT]
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

function MoveMouseToTarget(targetPosition)
    local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
    local screenTargetPos = CC:WorldToViewportPoint(targetPosition)

    local moveVector = Vector2.new(screenTargetPos.X, screenTargetPos.Y) - mouseLocation
    moveVector = moveVector * _G.SMOOTHING

    mousemoveabs(mouseLocation.X + moveVector.X, mouseLocation.Y + moveVector.Y)
end

GUI_MAIN = Instance.new('ScreenGui', game.CoreGui)
GUI_TARGET = Instance.new('TextLabel', GUI_MAIN)
GUI_AIM_AT = Instance.new('TextLabel', GUI_MAIN)

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

local TRACK = false

function CREATE(BASE)
    local ESP_MAIN = Instance.new('BillboardGui', PLAYER.PlayerGui)
    local ESP_DOT = Instance.new('Frame', ESP_MAIN)
    local ESP_NAME = Instance.new('TextLabel', ESP_MAIN)
    
    ESP_MAIN.Name = 'ESP'
    ESP_MAIN.Adornee = BASE
    ESP_MAIN.AlwaysOnTop = true
    ESP_MAIN.ExtentsOffset = Vector3.new(0, 1, 0)
    ESP_MAIN.Size = UDim2.new(0, 5, 0, 5)
    
    ESP_DOT.Name = 'DOT'
    ESP_DOT.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ESP_DOT.BackgroundTransparency = 0.3
    ESP_DOT.BorderSizePixel = 0
    ESP_DOT.Position = UDim2.new(-0.5, 0, -0.5, 0)
    ESP_DOT.Size = UDim2.new(2, 0, 2, 0)
    ESP_DOT.Visible = true
    ESP_DOT.ZIndex = 10
    
    ESP_NAME.Name = 'NAME'
    ESP_NAME.BackgroundTransparency = 1
    ESP_NAME.BorderSizePixel = 0
    ESP_NAME.Position = UDim2.new(0, 0, 0, -40)
    ESP_NAME.Size = UDim2.new(1, 0, 10, 0)
    ESP_NAME.Visible = true
    ESP_NAME.ZIndex = 10
    ESP_NAME.Font = Enum.Font.ArialBold
    ESP_NAME.TextSize = 14
    ESP_NAME.Text = BASE.Parent.Name:upper()
    ESP_NAME.TextColor3 = Color3.fromRGB(255, 0, 0)
end

function CLEAR()
    for _, v in pairs(PLAYER.PlayerGui:GetChildren()) do
        if v.Name == 'ESP' and v:IsA('BillboardGui') then
            v:Destroy()
        end
    end
end

function FIND()
    CLEAR()
    TRACK = true
    spawn(function()
        while TRACK do
            wait(1)
            CLEAR()
            for _, v in pairs(game.Players:GetChildren()) do
                if v.Character and v.Character:FindFirstChild('Head') then
                    if _G.FREE_FOR_ALL == false then
                        if v.TeamColor ~= PLAYER.TeamColor then
                            CREATE(v.Character.Head)
                        end
                    else
                        CREATE(v.Character.Head)
                    end
                end
            end
        end
    end)
end

MOUSE.Button2Down:Connect(function()
    if IsEquippedWithWeapon() then
        ENABLED = true
    end
end)

MOUSE.Button2Up:Connect(function()
    ENABLED = false
end)

MOUSE.KeyDown:Connect(function(KEY)
    if KEY == _G.ESP_BIND then
        if not ESP_ENABLED then
            FIND()
            ESP_ENABLED = true
            print('ESP : ON')
        else
            CLEAR()
            TRACK = false
            ESP_ENABLED = false
            print('ESP : OFF')
        end
    elseif KEY == string.byte(_G.CHANGE_AIM) then
        if _G.AIM_AT == 'Head' then
            _G.AIM_AT = 'Torso'
            GUI_AIM_AT.Text = 'AIMING : TORSO'
        else
            _G.AIM_AT = 'Head'
            GUI_AIM_AT.Text = 'AIMING : HEAD'
        end
    end
end)

game:GetService('RunService').RenderStepped:Connect(function()
    if ENABLED then
        local TARGET = GetNearestPlayerToMouse()
        if TARGET then
            local AIM = TARGET.Character:FindFirstChild(_G.AIM_AT)
            if AIM then
                MoveMouseToTarget(AIM.Position)
                GUI_TARGET.Text = 'AIMBOT : ' .. TARGET.Name:sub(1, 5)
            end
        else
            GUI_TARGET.Text = 'AIMBOT : OFF'
        end
    end
end)

repeat
    wait()
    if ESP_ENABLED then
        FIND()
    end
until not ESP_ENABLED
