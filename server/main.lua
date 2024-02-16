local QBCore = exports['qb-core']:GetCoreObject()
local GotItems = {}
local AlarmActivated = false

RegisterNetEvent('prison:server:SetJailStatus', function(jailTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData('injail', jailTime)
    if jailTime > 0 then
        Player.Functions.SetMetaData('jailOutTime', os.time() + (jailTime * 60))
    else
        Player.Functions.SetMetaData('jailOutTime', nil)
        GotItems[source] = nil
    end
end)

RegisterNetEvent('prison:server:SaveJailItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Player.PlayerData.metadata['jailitems'] or table.type(Player.PlayerData.metadata['jailitems']) == 'empty' then
        Player.Functions.SetMetaData('jailitems', Player.PlayerData.items)
        Player.Functions.AddMoney('cash', 80, 'jail money')
        Wait(2000)
        Player.Functions.ClearInventory()
    end
end)

RegisterNetEvent('prison:server:GiveJailItems', function(escaped)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if escaped then
        Player.Functions.SetMetaData('jailitems', {})
        return
    end
    for _, v in pairs(Player.PlayerData.metadata['jailitems']) do
        Player.Functions.AddItem(v.name, v.amount, false, v.info)
    end
    Player.Functions.SetMetaData('jailitems', {})
end)

RegisterNetEvent('prison:server:ResetJailItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData('jailitems', {})
end)

RegisterNetEvent('prison:server:SecurityLockdown', function()
    TriggerClientEvent('prison:client:SetLockDown', -1, true)
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then
            if Player.PlayerData.job.name == 'police' and Player.PlayerData.job.onduty then
                TriggerClientEvent('prison:client:PrisonBreakAlert', v)
            end
        end
    end
end)

RegisterNetEvent('prison:server:SetGateHit', function(key)
    TriggerClientEvent('prison:client:SetGateHit', -1, key, true)
    if math.random(1, 100) <= 50 then
        for _, v in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(v)
            if Player then
                if Player.PlayerData.job.name == 'police' and Player.PlayerData.job.onduty then
                    TriggerClientEvent('prison:client:PrisonBreakAlert', v)
                end
            end
        end
    end
end)

RegisterNetEvent('prison:server:CheckRecordStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local CriminalRecord = Player.PlayerData.metadata['criminalrecord']
    local currentDate = os.date('*t')

    if (CriminalRecord['date'].month + 1) == 13 then
        CriminalRecord['date'].month = 0
    end

    if CriminalRecord['hasRecord'] then
        if currentDate.month == (CriminalRecord['date'].month + 1) or currentDate.day == (CriminalRecord['date'].day - 1) then
            CriminalRecord['hasRecord'] = false
            CriminalRecord['date'] = nil
        end
    end
end)

RegisterNetEvent('prison:server:JailAlarm', function()
    if AlarmActivated then return end
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    local middle = vec2(Config.Locations['middle'].coords.x, Config.Locations['middle'].coords.y)
    if #(coords.xy - middle) < 200 then return error('"prison:server:JailAlarm" triggered whilst the player was too close to the prison, cancelled event') end
    TriggerClientEvent('prison:client:JailAlarm', -1, true)
    SetTimeout(5 * 60000, function()
        TriggerClientEvent('prison:client:JailAlarm', -1, false)
    end)
end)

RegisterNetEvent('prison:server:CheckChance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.metadata.injail == 0 or GotItems[src] then return end
    local chance = math.random(100)
    local odd = math.random(100)
    if chance ~= odd then return end
    if not Player.Functions.AddItem('phone', 1) then return end
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['phone'], 'add')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.found_phone'), 'success')
    GotItems[src] = true
end)

RegisterNetEvent('prison:server:ReduceTime', function(reduction)
    local QPlayer = QBCore.Functions.GetPlayer(source)
    QPlayer.Functions.SetMetaData('jailOutTime', QPlayer.PlayerData.metadata.jailOutTime - reduction)
end)

RegisterNetEvent('prison:server:requestVisitation', function(args)
    if not args.target then return end
    local QPlayer = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('prison:client:visitation:request', args.target, {
        source = QPlayer.PlayerData.source,
        name = QPlayer.PlayerData.charinfo?.firstname .. ' ' .. QPlayer.PlayerData.charinfo?.lastname,
    })
    TriggerClientEvent('QBCore:Notify', QPlayer.PlayerData.source, "Visitation requested. Please wait for a response.")
end)

RegisterNetEvent('prison:server:respondVisitation', function(visitor, accept)
    TriggerClientEvent('prison:client:visitation:getResponse', visitor.source, accept)
end)

QBCore.Functions.CreateCallback('prison:server:IsAlarmActive', function(_, cb)
    cb(AlarmActivated)
end)

QBCore.Functions.CreateCallback('prison:server:checkTime', function(source, cb)
    local QPlayer = QBCore.Functions.GetPlayer(source)
    local outTime = QPlayer.PlayerData.metadata.jailOutTime and QPlayer.PlayerData.metadata.jailOutTime or 0
    cb(math.ceil((outTime - os.time()) / 60))
end)

QBCore.Functions.CreateCallback('prison:server:getPrisoners', function(source, cb)
    local players, prisoners = QBCore.Functions.GetPlayers(), {}
    for i = 1, #players do
        if Player(players[i]).state.inJail then
            local QPlayer = QBCore.Functions.GetPlayer(players[i])
            prisoners[#prisoners+1] = {
                source = players[i],
                name = QPlayer.PlayerData.charinfo?.firstname .. ' ' .. QPlayer.PlayerData.charinfo?.lastname,
            }
        end
    end
    cb(prisoners)
end)
