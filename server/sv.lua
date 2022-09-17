ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Logs

local function sendToDiscordWithSpecialURL(Color, Title, Description)
	local Content = {
	        {
	            ["color"] = Color,
	            ["title"] = Title,
	            ["description"] = Description,
		        ["footer"] = {
	            ["text"] = "Concessionnaire",
	            ["icon_url"] = nil,
	            },
	        }
	    }
	PerformHttpRequest(xCarDealer.WebHookDiscord, function(err, text, headers) end, 'POST', json.encode({username = Name, embeds = Content}), { ['Content-Type'] = 'application/json' })
end

local date = os.date('*t')

if date.day < 10 then date.day = '0' .. tostring(date.day) end
if date.month < 10 then date.month = '0' .. tostring(date.month) end
if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
if date.min < 10 then date.min = '0' .. tostring(date.min) end
if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end

-- 

ESX.RegisterServerCallback("xCarDealer:getCategories", function(source, cb)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT * FROM vehicle_categories", {}, function(result) cb(result) end)
end)

ESX.RegisterServerCallback("xCarDealer:getVehicles", function(source, cb, category)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT * FROM vehicles WHERE category = @category", { 
        ['@category'] = category
    }, function(result) cb(result) end)
end)

ESX.RegisterServerCallback("xCarDealer:sellCar_CB", function(source, cb, vehicle, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    if xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        cb(true)
        MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)", {
            ['@owner'] = xPlayer.getIdentifier(),
            ['@plate'] = vehicle.plate,
            ['vehicle'] = json.encode(vehicle)
        }, function(update)
            if update ~= nil then
                TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nVous avez acheter un véhicule.')
                sendToDiscordWithSpecialURL(0, "Vente d'un véhicule", ("Joueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
            end
        end)
    else
        cb(false)
        TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nVous n\'avez pas assez d\'argent.')
    end
end)

ESX.RegisterServerCallback("xCarDealer:sellCar_E", function(source, cb, vehicle, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    if xPlayer.getAccount('money').money >= price then
        xPlayer.removeAccountMoney('money', price)
        cb(true)
        MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)", {
            ['@owner'] = xPlayer.getIdentifier(),
            ['@plate'] = vehicle.plate,
            ['vehicle'] = json.encode(vehicle)
        }, function(update)
            if update ~= nil then
                TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nVous avez acheter un véhicule.')
                sendToDiscordWithSpecialURL(0, "Vente d'un véhicule", ("Joueur: %s\nLicense: %s\nSteam: %s\nDiscord: %s\n\nDate: %s.%s.%s, Heure: %s:%s:%s"):format(xPlayer.getName(), xPlayer.getIdentifier(), GetPlayerIdentifier(source, 0), GetPlayerIdentifier(source, 2), date.day, date.month, date.year, date.hour, date.min, date.sec))
            end
        end)
    else
        cb(false)
        TriggerClientEvent('esx:showNotification', source, '(~r~Error~s~)\nVous n\'avez pas assez d\'argent.')
    end
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM