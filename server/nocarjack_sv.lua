ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('es:addGroupCommand', 'lock', 'user', function(source)
	TriggerClientEvent('esx_nocarjack:toggleLocks', source)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = "Toggle the logs in the current car", params = {}})

ESX.RegisterServerCallback('esx_nocarjack:getVehicleOwnerInfo', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM `owned_vehicles` WHERE `vehicle` LIKE @plate', {
		['@plate'] = "%" .. plate .. "%"
    },function(result)
		if result[1] ~= nil then
			local vehicle      = result[1]
			local owner   = vehicle['owner']
			--print ("Owner: " .. owner )
			cb(owner)
		else
			--print("No owner.")
			cb(false)
		end
	end)
end)

RegisterNetEvent("esx_nocarjack:setVehicleDoorsForEveryone")
AddEventHandler("esx_nocarjack:setVehicleDoorsForEveryone", function(veh, doors)
	TriggerClientEvent("esx_nocarjack:setVehicleDoors", -1, veh, doors)
end)

