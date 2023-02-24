local PlayerPoints = 0

RegisterNetEvent("gfx-points:Update", function(value)
    PlayerPoints = value
end)

function GetPoints()
    return PlayerPoints
end

function HasEnoughPoint(amount)
    return PlayerPoints >= amount
end

exports("GetPoints", GetPoints)

exports("HasEnoughPoint", HasEnoughPoint)

if Config.Points.Kill ~= 0 or Config.Points.Death ~= 0 then
    AddEventHandler('gameEventTriggered', function(name, eventData)
        if name == "CEventNetworkEntityDamage" then
            local ped, victim, killer, isFatal = PlayerPedId(), eventData[1], eventData[2], eventData[6] == 1
            local killerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killer))
            local victimId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)) or tostring(victim==-1 and " " or victim)
            if ped == victim and isFatal then
                TriggerServerEvent("gfx-points:playerKilled", killerId, victimId)
            end
        end
    end)
end