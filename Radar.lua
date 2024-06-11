-- Radar Hack Script

-- Services
local Players = game:service("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = game:service("Workspace").CurrentCamera
local RS = game:service("RunService")
local UIS = game:service("UserInputService")

-- Radar Info
local RadarInfo = {
    Position = Vector2.new(200, 200),
    Radius = 100,
    Scale = 1,
    RadarBack = Color3.fromRGB(10, 10, 10),
    RadarBorder = Color3.fromRGB(75, 75, 75),
    LocalPlayerDot = Color3.fromRGB(255, 255, 255),
    PlayerDot = Color3.fromRGB(60, 170, 255),
    Team = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Health_Color = true,
    Team_Check = true
}

-- Radar Background and Border
local RadarBackground = Drawing.new("Circle")
RadarBackground.Transparency = 0.9
RadarBackground.Color = RadarInfo.RadarBack
RadarBackground.Radius = RadarInfo.Radius
RadarBackground.Position = RadarInfo.Position
RadarBackground.Visible = true

local RadarBorder = Drawing.new("Circle")
RadarBorder.Transparency = 0.75
RadarBorder.Color = RadarInfo.RadarBorder
RadarBorder.Radius = RadarInfo.Radius
RadarBorder.Position = RadarInfo.Position
RadarBorder.Visible = true

-- Function to get relative position
local function GetRelative(pos)
    local char = Player.Character
    if char ~= nil and char.PrimaryPart ~= nil then
        local pmpart = char.PrimaryPart
        local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
        local newcf = CFrame.new(pmpart.Position, camerapos)
        local r = newcf:PointToObjectSpace(pos)
        return r.X, r.Z
    else
        return 0, 0
    end
end

-- Function to place dot on radar
local function PlaceDot(plr)
    local PlayerDot = Drawing.new("Circle")
    PlayerDot.Transparency = 1
    PlayerDot.Color = RadarInfo.PlayerDot
    PlayerDot.Radius = 3
    PlayerDot.Position = Vector2.new(0, 0)
    PlayerDot.Visible = false

    local function Update()
        local c = RS.RenderStepped:Connect(function()
            local char = plr.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.PrimaryPart ~= nil and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local scale = RadarInfo.Scale
                local relx, rely = GetRelative(char.PrimaryPart.Position)
                local newpos = RadarInfo.Position - Vector2.new(relx * scale, rely * scale)

                if (newpos - RadarInfo.Position).magnitude < RadarInfo.Radius - 2 then
                    PlayerDot.Radius = 3
                    PlayerDot.Position = newpos
                    PlayerDot.Visible = true
                else
                    local dist = (RadarInfo.Position - newpos).magnitude
                    local calc = (RadarInfo.Position - newpos).unit * (dist - RadarInfo.Radius)
                    local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
                    PlayerDot.Radius = 2
                    PlayerDot.Position = inside
                    PlayerDot.Visible = true
                end

                PlayerDot.Color = RadarInfo.PlayerDot
                if RadarInfo.Team_Check then
                    if plr.TeamColor == Player.TeamColor then
                        PlayerDot.Color = RadarInfo.Team
                    else
                        PlayerDot.Color = RadarInfo.Enemy
                    end
                end

                if RadarInfo.Health_Color then
                    PlayerDot.Color = HealthBarLerp(hum.Health / hum.MaxHealth)
                end
            else
                PlayerDot.Visible = false
                if Players:FindFirstChild(plr.Name) == nil then
                    PlayerDot:Remove()
                    c:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Function to create local player dot
local function NewLocalDot()
    local d = Drawing.new("Triangle")
    d.Visible = true
    d.Thickness = 1
    d.Filled = true
    d.Color = RadarInfo.LocalPlayerDot
    d.PointA = RadarInfo.Position + Vector2.new(0, -6)
    d.PointB = RadarInfo.Position + Vector2.new(-3, 6)
    d.PointC = RadarInfo.Position + Vector2.new(3, 6)
    return d
end

-- Create local player dot
local LocalPlayerDot = NewLocalDot()

-- Loop
coroutine.wrap(function()
    local c = RS.RenderStepped:Connect(function()
        if LocalPlayerDot ~= nil then
            LocalPlayerDot.Color = RadarInfo.LocalPlayerDot
            LocalPlayerDot.PointA = RadarInfo.Position + Vector2.new(0, -6)
            LocalPlayerDot.PointB = RadarInfo.Position + Vector2.new(-3, 6)
            LocalPlayerDot.PointC = RadarInfo.Position + Vector2.new(3, 6)
        end
        RadarBackground.Position = RadarInfo.Position
        RadarBackground.Radius = RadarInfo.Radius
        RadarBackground.Color = RadarInfo.RadarBack

        RadarBorder.Position = RadarInfo.Position
        RadarBorder.Radius = RadarInfo.Radius
        RadarBorder.Color = RadarInfo.RadarBorder
    end)
end)()

-- Draggable
local inset = game:GetService("GuiService")

local dragging = false
local offset = Vector2.new(0, 0)
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - RadarInfo.Position).magnitude < RadarInfo.Radius then
        offset = RadarInfo.Position - Vector2.new(Mouse.X, Mouse.Y)
        dragging = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

coroutine.wrap(function()
    local dot = Drawing.new("Circle")
    dot.Transparency = 1
    dot.Color = Color3.fromRGB(255, 255, 255)
    dot.Radius = 3
    dot.Position = Vector2.new(0, 0)
    dot.Visible = false

    local c = RS.RenderStepped:Connect(function()
        if (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - RadarInfo.Position).magnitude < RadarInfo.Radius then
            dot.Position = Vector2.new(Mouse.X, Mouse.Y + inset.Y)
            dot.Visible = true
        else
            dot.Visible = false
        end
        if dragging then
            RadarInfo.Position = Vector2.new(Mouse.X, Mouse.Y) + offset
        end
    end)
end)()

-- Radar Hack Toggle
local RadarHackEnabled = true
local RadarHackToggle = false

-- Function to toggle Radar Hack
local function ToggleRadarHackMenu()
    RadarHackToggle = not RadarHackToggle
    if RadarHackToggle then
        RadarHackEnabled = true
        ToggleRadarHack(RadarHackEnabled)
    else
        RadarHackEnabled = false
        ToggleRadarHack(RadarHackEnabled)
    end
end

-- Function to toggle Radar Hack
local function ToggleRadarHack(enabled)
    RadarBackground.Visible = enabled
    RadarBorder.Visible = enabled
    for _, dot in pairs(Player.PlayerGui:GetDescendants()) do
        if dot:IsA("Drawing") then
            dot.Visible = enabled
        end
    end
end

-- Bind the function to a key or button press to toggle Radar Hack
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Y then
        ToggleRadarHackMenu()
    end
end)

-- Example usage: Activate Radar Hack by default
ToggleRadarHack(RadarHackEnabled)
