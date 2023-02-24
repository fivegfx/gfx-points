PlayerPoints = {}

AddEventHandler("onResourceStart", function(name)
    if name == GetCurrentResourceName() then
        Wait(750)
        local players = GetPlayers()
        for i = 1, #players do
            LoadPlayerPoints(players[i])
        end
    end
end)

AddEventHandler("playerJoining", function()
    LoadPlayerPoints(source)
end)

function LoadPlayerPoints(source)
    local identifier = GetIdent(source)
    if identifier then
        local result = MySQL.query.await('SELECT points FROM users WHERE identifier=@identifier', {["@identifier"]=identifier})
        if result and result[1] then
            PlayerPoints[identifier] = result[1].points
        end
        UpdatePoints(source)
    end
end

function SavePoints(identifier)
    MySQL.update('UPDATE users SET points = ? WHERE identifier = ?', {
        PlayerPoints[identifier],
        identifier
    })
    PlayerPoints[identifier] = nil
end

function GetIdent(source, idType)
    idType = idType ~= nil and idType or Config.IdentifierType
    local identifiers = GetPlayerIdentifiers(source)
    for i = 1, #identifiers do
        if identifiers[i]:match(idType) then
            return identifiers[i]
        end
    end
end

function AddPoints(source, amount)
    local identifier = GetIdent(source)
    PlayerPoints[identifier] = PlayerPoints[identifier] + amount
    UpdatePoints(source)
end

function RemovePoints(source, amount)
    local identifier = GetIdent(source)
    PlayerPoints[identifier] = PlayerPoints[identifier] - amount
    UpdatePoints(source)
end

function GetPoints(source)
    local identifier = GetIdent(source)
    return PlayerPoints[identifier]
end

function UpdatePoints(source)
    local identifier = GetIdent(source)
    TriggerClientEvent("gfx-points:Update", source, PlayerPoints[identifier])
end

function HasEnoughPoint(source, amount)
    local identifier = GetIdent(source)
    return PlayerPoints[identifier] >= amount
end

exports("AddPoints", AddPoints)
exports("RemovePoints", RemovePoints)
exports("GetPoints", GetPoints)
exports("HasEnoughPoint", HasEnoughPoint)

AddEventHandler("onResourceStop", function(name)
    if name == GetCurrentResourceName() then
        for k, v in pairs(PlayerPoints) do
            SavePoints(k)
        end
    end
end)

AddEventHandler("playerDropped", function()
    local identifier = GetIdent(source)
    SavePoints(identifier)
end)

if Config.Points.Kill ~= 0 or Config.Points.Death ~= 0 then
    RegisterServerEvent('gfx-points:playerKilled', function(killerId, victimId)
        print(93, killerId, victimId)
        if killerId ~= 0 then
            AddPoints(killerId, Config.Points.Kill)
        end
        if victimId ~= 0 then
            RemovePoints(victimId, Config.Points.Death)
        end
    end)
end