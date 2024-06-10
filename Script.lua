local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Color = Color3.new(1, 1, 1)
FOV_CIRCLE.Transparency = 0.7
FOV_CIRCLE.Filled = false
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Thickness = 1

local function updateFOVCircle(radius)
    FOV_CIRCLE.Radius = radius
    print("FOV atualizado para:", radius)
end

local function toggleFOVCircle(enabled)
    FOV_CIRCLE.Visible = enabled
end

local function createMenu()
    local Main = library:CreateWindow("Menu", "Crimson")

    local tab = Main:CreateTab("Aimbot")
    local tab2 = Main:CreateTab("Esp")
    local tab3 = Main:CreateTab("Misc")

local function ToggleAimbot(enabled)
    _G.AimbotEnabled = enabled
    print("Aimbot ativado:", enabled)
    
    if enabled then
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/aimbot.lua"))()
    else
        _G.AimbotEnabled = false
        print("Aimbot desativado")
    end
end

    tab:CreateCheckbox("Aimbot", function(state)
        ToggleAimbot(state)
    end)

    tab:CreateCheckbox("Fov View", function(state)
        toggleFOVCircle(state)
        _G.FOVEnabled = state
        print("FOV View ativado:", state)
    end)

    tab:CreateSlider("Smoothness", 1, 10, function(value)
        _G.SMOOTHING = value
        print("Smoothness set to:", value)
    end)

    tab:CreateDropdown("Aim Part", {"Head", "Neck", "Torso"}, function(selected)
        _G.AimPart = selected
        print("Aim Part set to:", selected)
    end)

    local fovSlider
    fovSlider = tab:CreateSlider("FOV", 0, 180, function(value)
        _G.CircleRadius = value
        updateFOVCircle(value)
        print("FOV set to:", value)
    end)

    local ESP_ENABLED = false

    tab2:CreateCheckbox("Esp", function(state)
        if state then
            ESP_ENABLED = true
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/esp.lua"))()
            print("ESP ativado")
        else
            ESP_ENABLED = false
            -- Destrua todos os elementos de GUI com o nome 'ESP'
            for _, v in pairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
                if v.Name == 'ESP' then
                    v:Destroy()
                end
            end
            print("ESP desativado")
        end
    end)

    tab2:CreateDropdown("options",{"Box 2D","Box 3D","glow"},function(a)
        print(a)
    end)

    tab:Show()

    -- Loop para atualizar o círculo FOV
    RunService.RenderStepped:Connect(function()
        if _G.FOVEnabled and FOV_CIRCLE.Visible then
            FOV_CIRCLE.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        end
    end)
end

createMenu()
