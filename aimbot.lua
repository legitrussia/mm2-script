-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local AimbotEnabled = false
local AimPart = "Head"
local Sensitivity = 0.1

-- Functions
local function GetNearestPlayer()
    local NearestPlayer = nil
    local ShortestDistance = math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
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

local function MoveMouseToTarget(Target)
    local AimPart = GetAimPart(Target.Character)
    if AimPart then
        local MousePosition = Mouse.Hit.p
        local AimPartPosition = AimPart.Position

        local MoveVector = (AimPartPosition - MousePosition) * Sensitivity

        Mousemoverel(MoveVector.X, MoveVector.Y)
    end
end
-- Events
UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = not AimbotEnabled
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local NearestPlayer = GetNearestPlayer()

        if NearestPlayer then
            MoveMouseToTarget(NearestPlayer)
        end
    end
end)
