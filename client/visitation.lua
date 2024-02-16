-- Variables
local hasRequest

-- Functions
local function respondVisitation(accept)
    if not hasRequest then return end
    exports['qb-core']:KeyPressed()
    TriggerServerEvent('prison:server:respondVisitation', hasRequest, accept)
    hasRequest = nil
end

-- Commands & keymapping
RegisterCommand('prisonvisitaccept', function()
    respondVisitation(true)
end)

RegisterCommand('prisonvisitdeny', function()
    respondVisitation(false)
end)

RegisterKeyMapping('prisonvisitaccept', 'Prison visitation: Accept', 'keyboard', 'e')
RegisterKeyMapping('prisonvisitdeny', 'Prison visitation: Deny', 'keyboard', 'g')

-- Events
RegisterNetEvent('prison:client:visitation:list', function()
    QBCore.Functions.TriggerCallback('prison:server:getPrisoners', function(prisoners)
        local menu = {{
            header = 'Prisoner List',
            txt = 'Select prisoner to visit',
            isMenuHeader = true,
            icon = 'fas fa-handcuffs',
        }}

        for i = 1, #prisoners do
            menu[#menu+1] = {
                header = prisoners[i].name,
                txt = 'Request visitation',
                icon = 'fas fa-people-arrows',
                params = {
                    isServer = true,
                    event = 'prison:server:requestVisitation',
                    args = {
                        target = prisoners[i].source,
                    }
                },
            }
        end

        exports['qb-menu']:openMenu(menu)
    end)
end)

RegisterNetEvent('prison:client:visitation:request', function(visitor)
    hasRequest = visitor
    exports['qb-core']:DrawText(([[
        %s would like to visit. <br />
        [E] - Accept <br />
        [G] - Deny
    ]]):format(visitor.name))
end)

RegisterNetEvent('prison:client:visitation:getResponse', function(accepted)
    if not accepted then
        QBCore.Functions.Notify("The person doesn't want visitors right now.", 'error')
        return
    end

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    local plyPed = PlayerPedId()
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
    SetEntityCoords(plyPed, Config.Locations.visitation.exit.coords.xyz, true, false, false, false)
    SetEntityHeading(plyPed, Config.Locations.visitation.exit.coords.w)
    DoScreenFadeIn(500)
end)
