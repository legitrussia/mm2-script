local Players = game:GetService("Players")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Sensitivity = 1 -- Ajuste a sensibilidade conforme necessário

local AimbotEnabled = false

local function GetAimPart(Character)
    -- Determine qual parte do personagem mirar (cabeça, torso, etc.)
    return Character:FindFirstChild("Head") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("HumanoidRootPart")
end

local function MoveMouseToTarget(Target)
    local AimPart = GetAimPart(Target.Character)
    if AimPart then
        local MousePosition = Mouse.Hit.p
        local AimPartPosition = AimPart.Position

        local MoveVector = (AimPartPosition - MousePosition) * Sensitivity

        Mousemoverel(MoveVector.X, MoveVector.Y)
    end
end

local function GetNearestPlayer()
    local NearestPlayer = nil
    local ShortestDistance = math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= Players.LocalPlayer and Player.Character then
            local Character = Player.Character
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            local MousePosition = Mouse.Hit.p
            local Distance = (MousePosition - HumanoidRootPart.Position).Magnitude

            if Distance < ShortestDistance then
                NearestPlayer = Player
                ShortestDistance = Distance
            end
        end
    end

    return NearestPlayer
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled then
        local Target = GetNearestPlayer()
        if Target then
            MoveMouseToTarget(Target)
        end
    end
end)
