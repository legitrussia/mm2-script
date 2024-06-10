local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

_G.AimbotEnabled = true
_G.TeamCheck = false -- If set to true then the script would only lock your aim at enemy team members.
_G.AimPart = "Head" -- Where the aimbot script would lock at.
_G.Sensitivity = 0 -- How many seconds it takes for the aimbot script to officially lock onto the target's aimpart.
_G.FOV = 50 -- Field of View (em graus)

local function GetClosestPlayer()
  local MaximumDistance = math.huge
  local Target = nil
  
  coroutine.wrap(function()
    wait(20); MaximumDistance = math.huge -- Reset the MaximumDistance so that the Aimbot doesn't remember it as a very small variable and stop capturing players...
  end)()

  for _, v in next, Players:GetPlayers() do
    if v.Name ~= LocalPlayer.Name then
      if _G.TeamCheck == true then
        if v.Team ~= LocalPlayer.Team then
          if v.Character ~= nil then
            if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
              if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                
                -- Verificar se o jogador está dentro do FOV
                local direction = (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position).unit
                local angle = math.deg(math.acos(direction:Dot(Camera.CFrame.LookVector)))
                if angle < _G.FOV then
                  if VectorDistance < MaximumDistance then
                    Target = v
                    MaximumDistance = VectorDistance
                  end
                end
              end
            end
          end
        end
      else
        if v.Character ~= nil then
          if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
              local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
              local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
              
              -- Verificar se o jogador está dentro do FOV
              local direction = (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position).unit
              local angle = math.deg(math.acos(direction:Dot(Camera.CFrame.LookVector)))
              if angle < _G.FOV then
                if VectorDistance < MaximumDistance then
                  Target = v
                  MaximumDistance = VectorDistance
                end
              end
            end
          end
        end
      end
    end
  end

  return Target
end

UserInputService.InputBegan:Connect(function(Input)
  if Input.UserInputType == Enum.UserInputType.MouseButton2 then
    Holding = true
  end
end)

UserInputService.InputEnded:Connect(function(Input)
  if Input.UserInputType == Enum.UserInputType.MouseButton2 then
    Holding = false
  end
end)

RunService.RenderStepped:Connect(function()
  if Holding == true and _G.AimbotEnabled == true then
    local target = GetClosestPlayer()
    if target then
      TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, target.Character[_G.AimPart].Position)}):Play()
    end
  end
end)
