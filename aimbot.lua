local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Color = Color3.new(1, 1, 1)
FOV_CIRCLE.Transparency = 0.7
FOV_CIRCLE.Filled = false
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Thickness = 1

local function updateFOVCircle(radius)
    FOV_CIRCLE.Radius = radius
end

local function toggleFOVCircle(enabled)
    FOV_CIRCLE.Visible = enabled
end

local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= Players.LocalPlayer then
            if _G.TeamCheck and v.Team ~= Players.LocalPlayer.Team then
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local ScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                        local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                        if VectorDistance < MaximumDistance then
                            Target = v
                        end
                    end
                end
            elseif not _G.TeamCheck then
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local ScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                        local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                        if VectorDistance < MaximumDistance then
                            Target = v
                        end
                    end
                end
            end
        end
    end

    return Target
end

local function AimAt(target)
    if target then
        local aimPart = target.Character:FindFirstChild(_G.AimPart)
        if aimPart then
            local fov = _G.CircleRadius  -- Obtém o valor do FOV do menu

            local mousePosition = UserInputService:GetMouseLocation()
            local aimPosition = workspace.CurrentCamera:WorldToScreenPoint(aimPart.Position)

            local moveVector = (Vector2.new(aimPosition.X, aimPosition.Y) - Vector2.new(mousePosition.X, mousePosition.Y)) * _G.Sensitivity

            -- Calcula a distância do alvo até o mouse
            local distanceToTarget = (aimPosition - mousePosition).Magnitude
            
            -- Verifica se o alvo está dentro do FOV
            if distanceToTarget <= fov then
                -- Cria um tweem para mover a câmera em direção ao alvo
                TweenService:Create(workspace.CurrentCamera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, aimPart.Position)
                }):Play()
            end
        end
    end
end

-- Aqui você pode definir _G.AimbotEnabled = true para ativar o Aimbot automaticamente ou pode ser ativado por meio de um botão no menu.
_G.AimbotEnabled = false

-- Ouvintes de evento para o botão direito do mouse
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.AimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.AimbotEnabled = false
    end
end)

-- Loop para atualizar o círculo FOV
RunService.RenderStepped:Connect(function()
    if FOV_CIRCLE.Visible then
        FOV_CIRCLE.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    end

    if _G.AimbotEnabled then
        AimAt(GetClosestPlayer())
    end
end)
