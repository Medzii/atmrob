local QBCore = exports['qb-core']:GetCoreObject()

local hackedATMs = {}

QBCore.Functions.CreateCallback('atmrobbery:canHack', function(source, cb)
    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)

    -- Kolla om ATM nyligen hackats nära (inom 10 meter)
    for _, v in pairs(hackedATMs) do
        if #(pos - v) < 10.0 then
            cb(false)
            return
        end
    end
    cb(true)
end)

RegisterNetEvent("atmrobbery:startHackAttempt")
AddEventHandler("atmrobbery:startHackAttempt", function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)

    -- 65% chans att lyckas
    local success = math.random(1, 100) <= 65

    table.insert(hackedATMs, pos)

    Citizen.SetTimeout(30000, function()
        if success then
            -- Ge cash direkt istället för item
            player.Functions.AddMoney("cash", math.random(5000, 15000), "atm-hack")
            TriggerClientEvent("atmrobbery:hackingResult", src, true)
        else
            TriggerClientEvent("atmrobbery:hackingResult", src, false)
        end
    end)
end)
