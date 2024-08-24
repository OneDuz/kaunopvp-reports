ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local reports = {}
local lastKillers = {}

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    if data.killedByPlayer then
        local victimServerId = source
        local killerServerId = data.killerServerId
        local killerIdentifier = GetPlayerIdentifiers(killerServerId)[1]
        local killerSteamName = GetPlayerName(killerServerId)
        lastKillers[victimServerId] = { serverId = killerServerId, identifier = killerIdentifier, steamName = killerSteamName }
    end
end)

RegisterCommand('aimboter', function(source, args, rawCommand)
    local reporterServerId = source
    local lastKiller = lastKillers[reporterServerId]

    if not lastKiller then
        TriggerClientEvent('chat:addMessage', reporterServerId, { args = { 'No recent death by a player or killer not found.' } })
        return
    end

    local killerIdentifier = lastKiller.identifier

    if not reports[killerIdentifier] then
        reports[killerIdentifier] = { count = 0, serverId = lastKiller.serverId, steamName = lastKiller.steamName, reports = {} }
    end

    local reporterIdentifier = GetPlayerIdentifiers(reporterServerId)[1]

    if reports[killerIdentifier].reports[reporterIdentifier] then
        TriggerClientEvent('chat:addMessage', reporterServerId, { args = { 'You have already reported this player.' } })
        return
    end

    reports[killerIdentifier].count = reports[killerIdentifier].count + 1
    reports[killerIdentifier].reports[reporterIdentifier] = { time = os.date('%Y-%m-%d %H:%M:%S'), reporterSteamName = GetPlayerName(reporterServerId) }

    if reports[killerIdentifier].count == 8 then
        NotifyAdminsForAimboter(killerIdentifier, reports[killerIdentifier].steamName)
    end

    TriggerClientEvent('chat:addMessage', reporterServerId, { args = { 'Player reported for aimbot.' } })
end, false)

AddEventHandler('playerDropped', function(reason)
    local droppedPlayerIdentifier = GetPlayerIdentifiers(source)[1]
    if reports[droppedPlayerIdentifier] then
        reports[droppedPlayerIdentifier] = nil
    end
end)

function NotifyAdminsForAimboter(identifier, steamName)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" then
            TriggerClientEvent('ox_lib:notify', xPlayers[i], {
                title = '/aimboters',
                description = 'Player ' .. steamName .. ' (' .. identifier .. ') has been reported for aimbot 8 times.',
                position = 'top',
                type = 'warning'
            })
        end
    end
end

RegisterCommand('aimboters', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer.getGroup() == "superadmin" or not xPlayer.getGroup() == "admin" then
        print("This command can only be used from the server console or by server admins.")
        return
    end
    TriggerClientEvent('aimbot:showReports', source, reports)
end, false)
