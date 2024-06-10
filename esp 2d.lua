-- Configurações do ESP
local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom", -- Middle or Bottom, se FollowMouse estiver ativado, isso não importa...
    Tracer_FollowMouse = false,
    Tracers = true
}
local Team_Check = {
    TeamCheck = false, -- Se TeamColor estiver ativado, isso não importa...
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}
local TeamColor = true

-- Variáveis principais
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()

-- Funções utilitárias
local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0, 0)
    quad.PointB = Vector2.new(0, 0)
    quad.PointC = Vector2.new(0, 0)
    quad.PointD = Vector2.new(0, 0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    for _, item in pairs(lib) do
        item.Visible = state
    end
end

local black = Color3.fromRGB(0, 0, 0)
local function ESP(plr)
    local library = {
        -- Tracer e Tracer Preto (borda preta)
        blacktracer = NewLine(Settings.Tracer_Thickness * 2, black),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        -- Caixa e Caixa Preta (borda preta)
        black = NewQuad(Settings.Box_Thickness * 2, black),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        -- Barra de Saúde e Barra de Saúde Verde (parte que se move para cima/baixo)
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black)
    }

    local function Colorize(color)
        for _, item in pairs(library) do
            if item ~= library.healthbar and item ~= library.greenhealth and item ~= library.blacktracer and item ~= library.black then
                item.Color = color
            end
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                    local function Size(item)
                        item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY * 2)
                        item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2)
                        item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)
                        item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY * 2)
                    end
                    Size(library.box)
                    Size(library.black)

                    -- Barra de Saúde
                    local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)).magnitude
                    local healthoffset = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * d

                    library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                    library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2 - healthoffset)

                    library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                    library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY * 2)

                    local green = Color3.fromRGB(0, 255, 0)
                    local red = Color3.fromRGB(255, 0, 0)

                    library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)

                    if Team_Check.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            Colorize(Team_Check.Green)
                        else
                            Colorize(Team_Check.Red)
                        end
                    else
                        library.tracer.Color = Settings.Tracer_Color
                        library.box.Color = Settings.Box_Color
                    end
                    if TeamColor then
                        Colorize(plr.TeamColor.Color)
                    end
                    Visibility(true, library)
                else
                    Visibility(false, library)
                end
            else
                Visibility(false, library)
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= player.Name then
        coroutine.wrap(ESP)(v)
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name then
        coroutine.wrap(ESP)(newplr)
    end
end)

-- Menu para ESP
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()
local Main = library:CreateWindow("Menu", "Crimson")
local tab2 = Main:CreateTab("Esp")

local ESP_ENABLED = false
local ESP_TYPE = "Box 2D" -- Valor padrão

local function destroyESP()
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        for _, obj in pairs(v.PlayerGui:GetChildren()) do
            if obj:IsA("Drawing") then
                obj:Remove()
            end
        end
    end
end

tab2:CreateCheckbox("ESP", function(state)
    ESP_ENABLED = state
    if ESP_ENABLED then
        if ESP_TYPE == "Box 2D" then
            for _, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v.Name ~= player.Name then
                    coroutine.wrap(ESP)(v)
                end
            end
            game.Players.PlayerAdded:Connect(function(newplr)
                if newplr.Name ~= player.Name then
                    coroutine.wrap(ESP)(newplr)
                end
            end)
        end
        print("ESP ativado:", ESP_TYPE)
    else
        destroyESP()
        print("ESP desativado")
    end
end)

tab2:CreateDropdown("ESP Options", {"Box 2D", "Box 3D", "Glow"}, function(option)
    destroyESP() -- Destrua o ESP ativo antes de ativar o novo
    ESP_TYPE = option
    if ESP_ENABLED then
        if ESP_TYPE == "Box 2D" then
            for _, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v.Name ~= player.Name then
                    coroutine.wrap(ESP)(v)
                end
            end
            game.Players.PlayerAdded:Connect(function(newplr)
                if newplr.Name ~= player.Name then
                    coroutine.wrap(ESP)(newplr)
                end
            end)
        end
        print("ESP ativado:", ESP_TYPE)
    end
end)

Main:Show()
