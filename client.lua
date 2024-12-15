-- Změňte locale podle potřeby (např. cs nebo en)
local Locale = require('locales.en') -- Nebo require('locales.en')

local npcModel = `s_m_m_autoshop_01` -- Model NPC mechanika
local npcCoords = vec3(258.4378, -777.1488, 30.6166) -- Souřadnice mechanika
local heading = 84.9326 -- Směr, kterým se mechanik dívá
local mechanicPed = nil

-- Funkce pro opravu vozidla
local function repairVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false) -- Získání vozidla, ve kterém hráč sedí

    -- Kontrola, zda hráč sedí ve vozidle
    if not vehicle or vehicle == 0 then
        exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.mustBeInVehicle, 5000, 'error')
        return
    end

    -- Zmrazení vozidla
    FreezeEntityPosition(vehicle, true)

    lib.callback('npcMechanic:pay', false, function(success)
        if success then
            TaskStartScenarioInPlace(mechanicPed, "WORLD_HUMAN_WELDING", 0, true)
            local completed = lib.progressCircle({
                duration = 5000,
                label = Locale.mechanic.repairing,
                position = 'bottom',
                canCancel = false
            })
            if completed then
                SetVehicleFixed(vehicle)
                exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.repairSuccess, 5000, 'success')
            end
        else
            exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.notEnoughMoney, 5000, 'error')
        end

        -- Uvolnění zmrazení vozidla
        FreezeEntityPosition(vehicle, false)
        ClearPedTasks(mechanicPed)
    end, 'repair')
end

-- Funkce pro umytí vozidla
local function washVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false) -- Získání vozidla, ve kterém hráč sedí

    -- Kontrola, zda hráč sedí ve vozidle
    if not vehicle or vehicle == 0 then
        exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.mustBeInVehicle, 5000, 'error')
        return
    end

    -- Zmrazení vozidla
    FreezeEntityPosition(vehicle, true)

    lib.callback('npcMechanic:pay', false, function(success)
        if success then
            TaskStartScenarioInPlace(mechanicPed, "WORLD_HUMAN_MAID_CLEAN", 0, true)
            local completed = lib.progressCircle({
                duration = 3000,
                label = Locale.mechanic.washing,
                position = 'bottom',
                canCancel = false
            })
            if completed then
                WashDecalsFromVehicle(vehicle, 1.0)
                exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.washSuccess, 5000, 'success')
            end
        else
            exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.notEnoughMoney, 5000, 'error')
        end

        -- Uvolnění zmrazení vozidla
        FreezeEntityPosition(vehicle, false)
        ClearPedTasks(mechanicPed)
    end, 'wash')
end

-- Funkce pro otevření menu
local function openMechanicMenu()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    -- Kontrola, zda hráč sedí ve vozidle
    if not vehicle or vehicle == 0 then
        exports['okokNotify']:Alert("NPC mechanic", Locale.mechanic.mustBeInVehicle, 5000, 'error')
        return
    end

    lib.registerMenu({
        id = 'mechanic_menu',
        title = Locale.mechanic.menuTitle,
        position = 'top-right',
        options = {
            { label = Locale.mechanic.menuRepair, icon = 'tools', args = 'repair' },
            { label = Locale.mechanic.menuWash, icon = 'shower', args = 'wash' },
        }
    }, function(selected, scrollIndex, args)
        if args == 'repair' then
            repairVehicle()
        elseif args == 'wash' then
            washVehicle()
        end
    end)

    lib.showMenu('mechanic_menu')
end

-- Funkce pro vytvoření blipu
local function createBlip()
    local blip = AddBlipForCoord(npcCoords)
    SetBlipSprite(blip, 402)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<font face='RussoOne'>" .. Locale.mechanic.blipName .. "</font>")
    EndTextCommandSetBlipName(blip)
end


-- Funkce pro spawn mechanika
local function spawnMechanic()
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do Wait(10) end

    mechanicPed = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, heading, false, false)
    SetEntityAsMissionEntity(mechanicPed, true, true)
    SetBlockingOfNonTemporaryEvents(mechanicPed, true)
    FreezeEntityPosition(mechanicPed, true)

    -- Přidání ox_target interakce
    exports.ox_target:addLocalEntity(mechanicPed, {
        {
            name = 'mechanic_interact',
            icon = 'fa-solid fa-wrench',
            label = Locale.mechanic.targetLabel,
            onSelect = function()
                openMechanicMenu()
            end
        }
    })
end

-- Spuštění skriptu
CreateThread(function()
    spawnMechanic()
    createBlip()
end)
