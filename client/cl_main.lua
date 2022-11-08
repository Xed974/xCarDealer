ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Function
local categories = {}
local function getCategories()
    ESX.TriggerServerCallback("xCarDealer:getCategories", function(result) 
        categories = result
    end)
end

local vehicles = {}
local function getVehicles(name)
    ESX.TriggerServerCallback("xCarDealer:getVehicles", function(result) 
        vehicles = result
    end, name)
end

local weight = 0
local function getStockage(name)
    for _,v in pairs(xCarDealer.Stockage) do
        if v.name == name then
            weight = v.weight
        end
    end
end

local entity, car = nil, false
local function TestCar(pPos)
    local test = true
    local result = xCarDealer.TimeForTest * 60
    RageUI.CloseAll()
    FreezeEntityPosition(PlayerPedId(), false)

    while test do
        result = result - 1

        while IsPedInAnyVehicle(PlayerPedId()) == false do
            DeleteEntity(GetClosestVehicle(GetEntityCoords(PlayerPedId()), 15.0, 0, 70))
            ESX.ShowNotification("~r~Vous êtes descendu du véhicule.")
            test = false
            SetEntityCoords(PlayerPedId(), pPos.x, pPos.y, pPos.z)
            break
        end
        if result == 0 then
            DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
            ESX.ShowNotification("~r~Test terminé.")
            test = false
            SetEntityCoords(PlayerPedId(), pPos.x, pPos.y, pPos.z)
            break
        end
        Wait(1000)
    end
end

-- Menu

local heading = 0
local select = {}
local open  = false
local mainMenu = RageUI.CreateMenu("Concessionnaire", "Categories", nil, nil, "root_cause5", "img_red")
local show_car = RageUI.CreateSubMenu(mainMenu, "Concessionnaire", "Vehicules")
local selection = RageUI.CreateSubMenu(show_car, "Concessionnaire", "Interaction")
mainMenu.Display.Header = true
selection.EnableMouse = true
mainMenu.Closed = function()
    open = false
    FreezeEntityPosition(PlayerPedId(), false)
    select = {} DeleteEntity(entity) entity = nil car = false weight = 0
end
selection.Closed = function() select = {} DeleteEntity(entity) entity = nil car = false end show_car.Closed = function() weight = 0 select = {} DeleteEntity(entity) entity = nil car = false end

local Customs = { List1 = 1, List2 = 1, List3 = 1 }

local function MenuConcessionnaire()
    if open then
        open = false
        RageUI.Visible(mainMenu, false)
    else
        open = true
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while open do
                Wait(0)
                RageUI.IsVisible(mainMenu, function()
                    for _,v in pairs(categories) do
                        RageUI.Button(("~r~→~s~ %s"):format(v.label), nil, {RightBadge = RageUI.BadgeStyle.Star}, true, {
                            onSelected = function()
                                getVehicles(v.name)
                                getStockage(v.name)
                            end
                        }, show_car)
                    end
                end)
                RageUI.IsVisible(show_car, function()
                    for _,v in pairs(vehicles) do
                        RageUI.Button(("~r~→~s~ %s"):format(v.name), nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, {
                            onActive = function()
                                RageUI.Info(("~r~%s~s~"):format(v.name),{"Prix:", "Coffre:"}, {("~g~%s$~s~"):format(v.price), ("~r~%skg~s~"):format(weight)})
                            end,
                            onSelected = function()
                                table.insert(select, {name = v.name, model = v.model, price = v.price})
                            end
                        }, selection)
                    end
                end)
                RageUI.IsVisible(selection, function()
                    for _,v in pairs(select) do
                        RageUI.Button(("Tester le véhicule (~r~%smin~s~)"):format(xCarDealer.TimeForTest), nil, {RightLabel = "→"}, true, {
                            onActive = function()
                                if v.model ~= "motorcycles" then
                                    heading = heading + 0.02
                                    SetEntityHeading(entity, heading)
                                end
                                if car == false then
                                    RequestModel(GetHashKey(v.model))
                                    while not HasModelLoaded(GetHashKey(v.model)) do 
                                      Wait(1) 
                                    end
                                    entity = CreateVehicle(v.model, xCarDealer.Position.Exposition.x, xCarDealer.Position.Exposition.y, xCarDealer.Position.Exposition.z, heading, true, false)
                                    car = true
                                end
                            end,
                            onSelected = function()
                                DeleteEntity(entity) entity = nil car = false
                                RequestModel(GetHashKey(v.model))
                                while not HasModelLoaded(GetHashKey(v.model)) do 
                                  Wait(1) 
                                end
                                local pPos = GetEntityCoords(PlayerPedId())
                                local vehicle = CreateVehicle(v.model, xCarDealer.Position.SpwanCarForTest.x, xCarDealer.Position.SpwanCarForTest.y, xCarDealer.Position.SpwanCarForTest.z, xCarDealer.Position.HeadingForTest, true, false)
                                SetVehicleFuelLevel(vehicle, 60.0)
                                SetVehicleDirtLevel(vehicle, 0)
                                SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                TestCar(pPos)
                                select = {}
                            end
                        })
                        RageUI.List("Acheter le véhicule", {"Liquide", "Carte Bancaire"}, Customs.List1, nil, {Preview}, true, {
                            onListChange = function(i, Index)
                                Customs.List1 = i
                            end,
                            onSelected = function()
                                local vehicle = ESX.Game.GetVehicleProperties(entity)
                                if Customs.List1 == 1 then
                                    ESX.TriggerServerCallback("xCarDealer:sellCar_E", function(can) 
                                        if can then
                                            DeleteEntity(entity) entity = nil car = false
                                            select = {}
                                            RequestModel(GetHashKey(v.model))
                                            while not HasModelLoaded(GetHashKey(v.model)) do 
                                            Wait(1) 
                                            end
                                            local car = CreateVehicle(v.model, xCarDealer.Position.SpawnCarWhenBy.x, xCarDealer.Position.SpawnCarWhenBy.y, xCarDealer.Position.SpawnCarWhenBy.z, xCarDealer.Position.HeadingWhenBy, true, false)
                                            ESX.Game.SetVehicleProperties(car, vehicle)
                                            SetPedIntoVehicle(PlayerPedId(), car, -1)
                                            RageUI.CloseAll()
                                            FreezeEntityPosition(PlayerPedId(), false)
                                        end
                                    end, vehicle, tonumber(v.price))
                                end
                                if Customs.List1 == 2 then
                                    ESX.TriggerServerCallback("xCarDealer:sellCar_CB", function(can) 
                                        if can then
                                            DeleteEntity(entity) entity = nil car = false
                                            select = {}
                                            RequestModel(GetHashKey(v.model))
                                            while not HasModelLoaded(GetHashKey(v.model)) do 
                                            Wait(1) 
                                            end
                                            local car = CreateVehicle(v.model, xCarDealer.Position.SpawnCarWhenBy.x, xCarDealer.Position.SpawnCarWhenBy.y, xCarDealer.Position.SpawnCarWhenBy.z, xCarDealer.Position.HeadingWhenBy, true, false)
                                            ESX.Game.SetVehicleProperties(car, vehicle)
                                            SetPedIntoVehicle(PlayerPedId(), car, -1)
                                            RageUI.CloseAll()
                                            FreezeEntityPosition(PlayerPedId(), false)
                                        end
                                    end, vehicle, tonumber(v.price))
                                end
                            end
                        })
                        RageUI.Line()
                        RageUI.Separator(("~r~→~s~ Nombre de place: ~r~%s~s~"):format(GetVehicleMaxNumberOfPassengers(entity) + 1))
                        RageUI.Separator(("~r~→~s~ Prix: ~g~%s$~s~"):format(v.price))
                        RageUI.Separator(("~r~→~s~ Coffre: ~r~%skg~s~"):format(weight))
                        RageUI.List("Couleur Primaire", {"Rouge", "Vert", "Bleu", "Noir"}, Customs.List2, nil, {Preview}, true, {
                            onListChange = function(i, Index)
                                Customs.List2 = i
                            end,
                            onSelected = function()
                                if Customs.List2 == 1 then SetVehicleCustomPrimaryColour(entity, 255, 0, 0) end
                                if Customs.List2 == 2 then  SetVehicleCustomPrimaryColour(entity, 0, 255, 0) end
                                if Customs.List2 == 3 then  SetVehicleCustomPrimaryColour(entity, 0, 0, 255) end
                                if Customs.List2 == 4 then  SetVehicleCustomPrimaryColour(entity, 0, 0, 0) end
                            end
                        })
                        RageUI.List("Couleur Secondaire", {"Rouge", "Vert", "Bleu", "Noir"}, Customs.List3, nil, {Preview}, true, {
                            onListChange = function(i, Index)
                                Customs.List3 = i
                            end,
                            onSelected = function()
                                if Customs.List3 == 1 then SetVehicleCustomSecondaryColour(entity, 255, 0, 0) end
                                if Customs.List3 == 2 then  SetVehicleCustomSecondaryColour(entity, 0, 255, 0) end
                                if Customs.List3 == 3 then  SetVehicleCustomSecondaryColour(entity, 0, 0, 255) end
                                if Customs.List3 == 4 then  SetVehicleCustomSecondaryColour(entity, 0, 0, 0) end
                            end
                        })
                        RageUI.StatisticPanel((GetVehicleModelEstimatedMaxSpeed(GetHashKey(v.model))/60), "Vitesse maximal")
                        RageUI.StatisticPanel((GetVehicleModelMaxBraking(GetHashKey(v.model))/2), "Freinage")
                    end
                end)
            end
        end)
    end
end

-- Initialisation

Citizen.CreateThread(function()
    while true do
        local wait = 1000

        for k in pairs(xCarDealer.Position.Menu) do
            local pos = xCarDealer.Position.Menu
            local pPos = GetEntityCoords(PlayerPedId())
            local dst = Vdist(pPos.x, pPos.y, pPos.z, pos[k].x, pos[k].y, pos[k].z)

            if dst <= 10.0 then
                wait = 0
                DrawMarker(xCarDealer.MarkerType, pos[k].x, pos[k].y, (pos[k].z) - 1.0, 0.0, 0.0, 0.0, 0.0,0.0,0.0, xCarDealer.MarkerSizeLargeur, xCarDealer.MarkerSizeEpaisseur, xCarDealer.MarkerSizeHauteur, xCarDealer.MarkerColorR, xCarDealer.MarkerColorG, xCarDealer.MarkerColorB, xCarDealer.MarkerOpacite, xCarDealer.MarkerSaute, true, p19, xCarDealer.MarkerTourne)
            end
            if dst <= 1.0 then
                wait = 0
                if (not open) then ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ~r~intéragir~s~.") end
                if IsControlJustPressed(1, 51) then
                    FreezeEntityPosition(PlayerPedId(), true)
                    MenuConcessionnaire()
                    getCategories()
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

-- Blips

Citizen.CreateThread(function()
    for k,v in pairs (xCarDealer.Position.Menu) do
        local blips = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blips, xCarDealer.Blips.Model)
        SetBlipColour(blips, xCarDealer.Blips.Couleur)
        SetBlipScale(blips, xCarDealer.Blips.Taille)
        SetBlipAsShortRange(blips, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(xCarDealer.Blips.Title)
        EndTextCommandSetBlipName(blips)
    end
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM
