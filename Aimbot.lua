local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/legitrussia/mm2-script/main/Menu%20library.lua"))()

library.rank = "developer"
local Wm = library:Watermark("Shoot SS v2 | v" .. library.version ..  " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)
coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)

local Notif = library:InitNotifications()

for i = 20,0,-1 do 
    task.wait(0.05)
    local LoadingXSX = Notif:Notify("Shoot SS v2, please be patient.", 3, "information") -- notification, alert, error, success, information
end 

library.title = "Shoot SS"

library:Introduction()
wait(1)
local Init = library:Init()

local Tab1 = Init:NewTab("Aimbot Tab")

local Section1 = Tab1:NewSection("Example Components")

local aimbotEnabled = false -- Variável para rastrear o estado do aimbot

local function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        -- Ativa o aimbot
        local aimbotScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-Script/main/Aimbot%20Script%20(Without%20FOV).lua"))
        aimbotScript()
    else
        -- Desativa o aimbot
        -- Implemente aqui a lógica para desativar o aimbot, se necessário
    end
    print("Aimbot ativado: " .. tostring(aimbotEnabled))
end

local Toggle1 = Tab1:NewToggle("Aimbot", false, function(value)
    ToggleAimbot()
end)

local Button1 = Tab1:NewButton("Button", function()
    print("one")
end)

local Keybind1 = Tab1:NewKeybind("Keybind 1", Enum.KeyCode.RightAlt, function(key)
    Init:UpdateKeybind(Enum.KeyCode[key])
end)

local Textbox1 = Tab1:NewTextbox("Text box 1 [auto scales // small]", "", "1", "all", "small", true, false, function(val)
    print(val)
end)

local Textbox2 = Tab1:NewTextbox("Text box 2 [medium]", "", "2", "all", "medium", true, false, function(val)
    print(val)
end)

local Textbox3 = Tab1:NewTextbox("Text box 3 [large]", "", "3", "all", "large", true, false, function(val)
    print(val)
end)

local Selector1 = Tab1:NewSelector("Selector 1", "bungie", {"fg", "fge", "fg", "fg"}, function(d)
    print(d)
end):AddOption("fge")

local Slider1 = Tab1:NewSlider("Slider 1", "", true, "/", {min = 1, max = 100, default = 20}, function(value)
    print(value)
end)

local FinishedLoading = Notif:Notify("Loaded xsx example", 4, "success")
