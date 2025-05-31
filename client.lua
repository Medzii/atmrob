local QBCore = exports['qb-core']:GetCoreObject()

local atmModels = {
    `prop_atm_01`, `prop_atm_02`, `prop_atm_03`, `prop_fleeca_atm`,
    `prop_atm_04`, `prop_atm_05`, `prop_atm_06`, `prop_atm_07`
}

local hackingInProgress = false
local loginStep = 0 -- 0=boot,1=login,2=connected,3=cmd1,4=cmd2
local phoneProp = nil

-- Animation config
local animDict = "anim@heists@prison_heiststation@cop_reactions"
local animName = "cop_b_idle"

Citizen.CreateThread(function()
    for _, model in pairs(atmModels) do
        exports['qb-target']:AddTargetModel(model, {
            options = {
                {
                    type = "client",
                    event = "atmrobbery:attemptHack",
                    icon = "fas fa-laptop-code",
                    label = "Hack ATM",
                }
            },
            distance = 1.5,
        })
    end
end)

local function playHackAnimation()
    local playerPed = PlayerPedId()

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8, -1, 49, 0, false, false, false)

    local model = GetHashKey("prop_phone_ing")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    phoneProp = CreateObject(model, GetEntityCoords(playerPed), true, true, true)
    local boneIndex = GetPedBoneIndex(playerPed, 28422)
    AttachEntityToEntity(phoneProp, playerPed, boneIndex, 0.03, 0.0, 0.0, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
end

local function stopHackAnimation()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    if phoneProp and DoesEntityExist(phoneProp) then
        DeleteEntity(phoneProp)
        phoneProp = nil
    end
end

RegisterNetEvent("atmrobbery:attemptHack", function()
    if hackingInProgress then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local isNearATM = false

    for _, model in pairs(atmModels) do
        local atm = GetClosestObjectOfType(playerCoords, 1.5, model, false, false, false)
        if atm ~= 0 then
            isNearATM = true
            break
        end
    end

    if not isNearATM then
        QBCore.Functions.Notify("Du är inte nära en ATM.", "error")
        return
    end

    if not QBCore.Functions.HasItem("hackerphone") then
        QBCore.Functions.Notify("Du behöver en Hacker Phone för att hacka!", "error")
        return
    end

    QBCore.Functions.TriggerCallback('atmrobbery:canHack', function(canHack)
        if not canHack then
            QBCore.Functions.Notify("Den här ATM:n har nyligen hackats. Vänta lite.", "error")
            return
        end

        hackingInProgress = true
        loginStep = 0
        playHackAnimation()
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "startBoot" })
    end)
end)

RegisterNUICallback("submitLogin", function(data, cb)
    if loginStep ~= 1 then cb("ok") return end

    local username = data.username or ""
    local password = data.password or ""

    if username == "Admin" and password == "Root" then
        loginStep = 2
        SendNUIMessage({ action = "showConnected" })
    else
        hackingInProgress = false
        loginStep = 0
        SetNuiFocus(false, false)
        stopHackAnimation()
        SendNUIMessage({ action = "close" })
        QBCore.Functions.Notify("Fel användarnamn eller lösenord!", "error")
    end
    cb("ok")
end)

RegisterNUICallback("submitCommand", function(data, cb)
    if loginStep < 2 then cb("ok") return end

    local cmd = data.command:lower()
    if loginStep == 2 then
        if cmd == "bruteforce.exe" then
            loginStep = 3
            SendNUIMessage({ action = "command2" })
        else
            hackingInProgress = false
            loginStep = 0
            SetNuiFocus(false, false)
            stopHackAnimation()
            SendNUIMessage({ action = "close" })
            QBCore.Functions.Notify("Fel kommando! Börja om.", "error")
        end
    elseif loginStep == 3 then
        if cmd == "hack-atm.exe" then
            loginStep = 4
            QBCore.Functions.Notify("Hackningen pågår... Vänta 30 sekunder.", "info")
            TriggerServerEvent("atmrobbery:startHackAttempt")
        else
            hackingInProgress = false
            loginStep = 0
            SetNuiFocus(false, false)
            stopHackAnimation()
            SendNUIMessage({ action = "close" })
            QBCore.Functions.Notify("Fel kommando! Börja om.", "error")
        end
    end

    cb("ok")
end)

RegisterNetEvent("atmrobbery:hackingResult", function(success)
    hackingInProgress = false
    loginStep = 0
    SetNuiFocus(false, false)
    stopHackAnimation()
    SendNUIMessage({ action = success and "success" or "fail" })

    if success then
        QBCore.Functions.Notify("Hackningen lyckades! Du fick pengar.", "success")
    else
        QBCore.Functions.Notify("Hackningen misslyckades!", "error")
    end
end)

RegisterNUICallback("closeUI", function(data, cb)
    hackingInProgress = false
    loginStep = 0
    SetNuiFocus(false, false)
    stopHackAnimation()
    SendNUIMessage({ action = "close" })
    cb("ok")
end)

-- ESC stängning
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if hackingInProgress and IsControlJustPressed(0, 322) then -- ESC knapp
            hackingInProgress = false
            loginStep = 0
            SetNuiFocus(false, false)
            stopHackAnimation()
            SendNUIMessage({ action = "close" })
            QBCore.Functions.Notify("Hackningen avbröts.", "error")
        end
    end
end)
