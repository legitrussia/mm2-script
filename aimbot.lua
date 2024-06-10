-- Serviço de Input para capturar eventos de mouse
local userInputService = game:GetService("UserInputService")

-- Serviço de Workspace para acessar os objetos do jogo
local workspace = game:GetService("Workspace")

-- Variável para armazenar o jogador alvo
local targetPlayer

-- Função para capturar evento de pressionamento do mouse2
userInputService.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton2 then
    -- Obter a posição do cursor
    local mousePosition = userInputService:GetMouseLocation()

    -- Encontrar o jogador mais próximo
    targetPlayer = findClosestPlayer(mousePosition)

    -- Verificar se o jogador está dentro do FOV
    if isPlayerInFov(targetPlayer, mousePosition) then
      -- Mover o cursor para o jogador
      userInputService:MoveMouse(targetPlayer.Character.HumanoidRootPart.Position)
    end
  end
end)

-- Função para encontrar o jogador mais próximo
function findClosestPlayer(mousePosition)
  local closestPlayer
  local closestDistance = math.huge

  -- Iterar sobre todos os jogadores
  for _, player in pairs(workspace.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
      local character = player.Character
      if character then
        local distance = (character.HumanoidRootPart.Position - mousePosition).magnitude
        if distance < closestDistance then
          closestPlayer = player
          closestDistance = distance
        end
      end
    end
  end

  return closestPlayer
end

-- Função para verificar se o jogador está dentro do FOV
function isPlayerInFov(player, mousePosition)
  local fov = 50 -- Definir o FOV em graus
  local camera = workspace.CurrentCamera
  local character = player.Character
  if character then
    local direction = (character.HumanoidRootPart.Position - camera.CFrame.Position).unit
    local angle = math.deg(math.acos(direction:Dot(camera.CFrame.LookVector)))
    return angle < fov
  end
  return false
end
