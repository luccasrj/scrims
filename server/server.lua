local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vrp")

Match = {}

local function generateRandomCode(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local code = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        code = code .. chars:sub(rand, rand)
    end

    return code
end

local function getRandomMap()
    local keys = {}
    for key in pairs(Config.mapPool) do
        table.insert(keys, key)
    end

    return keys[math.random(#keys)]
end

local function generateRandomDimension()
    local dimension
    local exists
    repeat
        dimension = math.random(1000, 9999)
        exists = false

        for _, match in pairs(Match) do
            if match.dimension == dimension then
                exists = true
                break
            end
        end
    until not exists

    return dimension
end

local function generateMatch()
    local code
    repeat
        code = generateRandomCode(6)
    until not Match[code]

    local map = getRandomMap()
    local dimension = generateRandomDimension()

    Match[code] = {
        gameStarted = false,
        roundActive = false,
        roundTime = Config.roundTime,
        map = map,
        dimension = dimension,
        team1 = { players = {}, points = 0 },
        team2 = { players = {}, points = 0 }
    }

    return code
end

local function isPlayerInAnyMatch(source)
    for code, match in pairs(Match) do
        for _, player in ipairs(match.team1.players) do
            if player.source == source then
                return true
            end
        end
        
        for _, player in ipairs(match.team2.players) do
            if player.source == source then
                return true
            end
        end
    end

    return false
end

local function getPlayerTeam(source)
    for code, match in pairs(Match) do
        for _, player in ipairs(match.team1.players) do
            if player.source == source then
                return "team1"
            end
        end

        for _, player in ipairs(match.team2.players) do
            if player.source == source then
                return "team2"
            end
        end
    end

    return nil, nil
end

local function startRound(code)
    local match = Match[code]
    if not match then
        print("[^3SCRIMS^7] Tentativa de iniciar round em partida inexistente: ".. code ..".")
        return
    end

    if match.roundActive then
        print("[^3SCRIMS^7] Round já está ativo na partida: ".. code ..".")
        return
    end

    match.roundActive = true

    local allPlayers = {}

    for _, player in ipairs(match.team1.players) do
        table.insert(allPlayers, {source = player.source, team = "team1"})
    end

    for _, player in ipairs(match.team2.players) do
        table.insert(allPlayers, {source = player.source, team = "team2"})
    end

    Citizen.CreateThread(function()
        for _, p in ipairs(allPlayers) do
            TriggerClientEvent("scrims:startRound", p.source, p.team, match.map)
        end
    end)
end

local function joinMatch(source, code)
    if not Match[code] then return end

    if isPlayerInAnyMatch(source) then
        return
    end

    local team1 = Match[code].team1.players
    local team2 = Match[code].team2.players
        
    if #team1 < 5 and (#team1 <= #team2) then
        table.insert(team1, { source = source, userId = "getUserId", nickname = "getUserIdentity", kills = 0, deaths = 0, assists = 0 })
    elseif #team2 < 5 then
        table.insert(team2, { source = source, userId = "getUserId", nickname = "getUserIdentity", kills = 0, deaths = 0, assists = 0 })
    else
        print("[^3SCRIMS^7] O jogador " .. source .. " nao pode ser adicionado pois ambos os times estao cheios.")
        return
    end

    local teamJoined = getPlayerTeam(source)
    SetPlayerRoutingBucket(source, Match[code].dimension)
    TriggerClientEvent("scrims:joinMatch", source, Match[code], teamJoined)
    print("[^3SCRIMS^7] O jogador " .. source .. " entrou na partida " .. code .. ".")

    if #team1 + #team2 == 10 then
        startRound(code)
    end
end

local function cleanupMatchIfEmpty(code)
    local match = Match[code]
    if match.gameStarted then
        if #match.team1.players == 0 and #match.team2.players == 0 then
            Match[code] = nil
            print("[^3SCRIMS^7] Partida " .. code .. " foi encerrada (vazia).")
        end
    end
end

local function leaveMatch(source)
    for code, match in pairs(Match) do
        for i, player in ipairs(match.team1.players) do
            if player.source == source then
                table.remove(match.team1.players, i)
                print("[^3SCRIMS^7] O jogador " .. source .. " saiu da partida " .. code .. ".")
                cleanupMatchIfEmpty(code)
                return true
            end
        end

        for i, player in ipairs(match.team2.players) do
            if player.source == source then
                table.remove(match.team2.players, i)
                print("[^3SCRIMS^7] O jogador " .. source .. " saiu da partida " .. code .. ".")
                cleanupMatchIfEmpty(code)
                return true
            end
        end
    end

    return false
end

RegisterCommand("join-match", function(source, args)
    local code = args[1]
    if code and Match[code] then
        joinMatch(source, code)
    else
        print("[^3SCRIMS^7] Codigo invalido ou inexistente.")
    end
end)

RegisterCommand("leave-match", function(source)
    if not leaveMatch(source) then
        print("[^3SCRIMS^7] Você não está em nenhuma partida.")
    else
        SetPlayerRoutingBucket(source, 0)
        TriggerClientEvent("scrims:leaveMatch", source)
    end
end)

RegisterCommand("generate-match", function()
    local code = generateMatch()
    print("[^3SCRIMS^7] Partida criada com o codigo: ".. code ..".")
end)

RegisterCommand("actives-match", function()
    local hasMatch = false

    for k in pairs(Match) do
        hasMatch = true
        break
    end

    if not hasMatch then
        print("[^3SCRIMS^7] Nenhuma partida ativa no momento.")
    else
        print(json.encode(Match))
    end
end)

print("[^3SCRIMS^7] Sistema on-line.")