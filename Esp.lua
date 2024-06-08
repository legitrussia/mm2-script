local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local roles

-- > Functions <--

function CreateHighlight() -- make any new highlights for new players
    for i, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and not v.Character:FindFirstChild("Highlight") then
            Instance.new("Highlight", v.Character)
        end
    end
end

function UpdateHighlights() -- Get Current Role Colors (messy)
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Highlight") then
            Highlight = v.Character:FindFirstChild("Highlight")
            if v.Name == Sheriff and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(0, 0, 225)
            elseif v.Name == Murder and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(225, 0, 0)
            elseif v.Name == Hero and IsAlive(v) and not IsAlive(game.Players[Sheriff]) then
                Highlight.FillColor = Color3.fromRGB(255, 250, 0)
            else
                Highlight.FillColor = Color3.fromRGB(0, 225, 0)
            end
        end
    end
end

function IsAlive(Player) -- Simple sexy function
    for i, v in pairs(roles) do
        if Player.Name == i then
            if not v.Killed and not v.Dead then
                return true
            else
                return false
            end
        end
    end
end

-- > Variables to control the ESP state <--
local espConnection
local espEnabled = false

function activateGlow()
    if not espEnabled then
        espEnabled = true
        espConnection = RunService.RenderStepped:Connect(function()
            roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
            for i, v in pairs(roles) do
                if v.Role == "Murderer" then
                    Murder = i
                elseif v.Role == 'Sheriff'then
                    Sheriff = i
                elseif v.Role == 'Hero'then
                    Hero = i
                end
            end
            CreateHighlight()
            UpdateHighlights()
        end)
        print("ESP Glow activated")
    end
end

function deactivateGlow()
    if espEnabled then
        espEnabled = false
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        for _, v in pairs(Players:GetChildren()) do
            if v.Character and v.Character:FindFirstChild("Highlight") then
                v.Character.Highlight:Destroy()
            end
        end
        print("ESP Glow deactivated")
    end
end

return {
    activateGlow = activateGlow,
    deactivateGlow = deactivateGlow
}
