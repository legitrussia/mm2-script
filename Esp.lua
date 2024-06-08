local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local roles
local highlightsEnabled = true -- Variável para controlar se os destaques devem ser atualizados ou não

function CreateHighlight()
    for i, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and not v.Character:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight", v.Character)
            highlight.Name = "Highlight" -- Definindo o nome para facilitar a busca posteriormente
        end
    end
end

function UpdateHighlights()
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Highlight") then
            local highlight = v.Character:FindFirstChild("Highlight")
            if v.Name == Sheriff and IsAlive(v) then
                highlight.FillColor = Color3.fromRGB(0, 0, 225)
            elseif v.Name == Murder and IsAlive(v) then
                highlight.FillColor = Color3.fromRGB(225, 0, 0)
            elseif v.Name == Hero and IsAlive(v) and not IsAlive(game.Players[Sheriff]) then
                highlight.FillColor = Color3.fromRGB(255, 250, 0)
            else
                highlight.FillColor = Color3.fromRGB(0, 225, 0)
            end
        end
    end
end

function IsAlive(Player)
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

RunService.RenderStepped:connect(function()
    if not highlightsEnabled then
        return -- Se os destaques estiverem desativados, não faz nada
    end

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

-- Função para ativar ou desativar os destaques
function ToggleHighlights(enabled)
    highlightsEnabled = enabled
    if not enabled then
        -- Se os destaques foram desativados, remova todos os destaques
        for _, player in ipairs(Players:GetPlayers()) do
            local highlight = player.Character and player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Exemplo de uso para ativar ou desativar os destaques (você pode chamar isso do seu menu)
ToggleHighlights(true) -- Ativa os destaques
--ToggleHighlights(false) -- Desativa os destaques
