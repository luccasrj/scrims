local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vrp")

LocalPlayer.state.inScrim = false

RegisterNetEvent("scrims:joinMatch",function(matchData,teamJoined)
    local ped = PlayerPedId()
    local map = matchData.map

    SetEntityHealth(ped, 400)
    FreezeEntityPosition(ped, true)
    if teamJoined == "team1" then
        SetEntityCoords(ped, Config.mapPool[map].spawnTeam1.coords)
    else
        SetEntityCoords(ped, Config.mapPool[map].spawnTeam2.coords)
    end

    giveWeapons()
    LocalPlayer.state.inScrim = true
end)

RegisterNetEvent("scrims:leaveMatch",function(matchData,teamJoined)
    LocalPlayer.state.inScrim = false
end)

function giveWeapons()
    local ped = PlayerPedId()

    for weaponName, weaponData in pairs(Config.scrimWeapons) do
        local weaponHash = GetHashKey(weaponName)

        GiveWeaponToPed(ped, weaponHash, -1, false, false)

        if weaponData["attachments"] then
            for _, attachmentName in ipairs(weaponData["attachments"]) do
                local attachmentHash = GetHashKey(attachmentName)
                if not HasPedGotWeaponComponent(ped, weaponHash, attachmentHash) then
                    GiveWeaponComponentToPed(ped, weaponHash, attachmentHash)
                end
            end
        end
    end
end