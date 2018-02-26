ESX					= nil
local vehicleOwner  = nil
local xPlayer		= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
			-- gets if player is entering vehicle
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
				vehicleOwner = nil
				
				-- gets vehicle player is trying to enter and its lock status
				local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
				local plate = GetVehicleNumberPlateText(veh)
				local lock = GetVehicleDoorLockStatus(veh)
				
				-- gets your character information
				xPlayer = ESX.GetPlayerData()

				-- determine if this car is owned by someone, or if it's public
				ESX.TriggerServerCallback('esx_nocarjack:getVehicleOwnerInfo', function (vehOwner)
					if not vehOwner then
						vehicleOwner = "public"
					else
						vehicleOwner = vehOwner
					end
				end, plate)
				
				-- Get the conductor door angle, open if value > 0.0
				local doorAngle = GetVehicleDoorAngleRatio(veh, 0)
			
				-- normalizes chance
				if cfg.chance > 100 then
					cfg.chance = 100
				elseif cfg.chance < 0 then
					cfg.chance = 0
				end
			
				-- check if got lucky
				local lucky = (math.random(100) < cfg.chance)
			
				-- Set lucky if conductor door is open
				if doorAngle > 0.0 then
					lucky = true
				end
			
				-- check if vehicle is in whitelist, set lucky true
				for k,model in pairs(cfg.whitelist) do
					if IsVehicleModel(veh, GetHashKey(model)) then
						 lucky = true
					end
				end
								
								
				-- check if vehicle is in blacklist
				local backlisted = false
				for k,model in pairs(cfg.blacklist) do
					if IsVehicleModel(veh, GetHashKey(model)) then
						blacklisted = true
					end
				end
				
				-- gets ped that is driving the vehicle
				local pedd = GetPedInVehicleSeat(veh, -1)
				
				-- wait for vehicle ownership to be determined... this shouldn't hold the script up
				while vehicleOwner == nil do
					Citizen.Wait(0)
				end
				
				print ("Vehicle owner: " .. vehicleOwner)
				
				-- If the vehicle is owned, determine if this player is the owner
				local doesOwnVehicle = false
				if vehicleOwner ~= "public" then
					if xPlayer.identifier == vehicleOwner then
						doesOwnVehicle = true
					end
				end
				
				if (lock == 7 or pedd) then
					-- lock doors if car is publicly owned, and you're not lucky or the car is blacklisted
					if vehicleOwner == "public" then
						if not lucky or blacklisted then
							TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', veh, 2)
						-- Otherwise, unlock the car
						else
							TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', veh, 1)
						end
					-- Handle an owned car
					else
						-- If this player owns the vehicle, unlock it for just them and lock it for everyone else
						if doesOwnVehicle then
							TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', veh, 2)
							TriggerEvent('esx_nocarjack:setVehicleDoors',veh,1)
						-- Otherwise, it can remain locked
						else
							TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', veh, 2)
							ESX.ShowNotification("You do not own this vehicle.")
						end
					end
				end
			end
		Citizen.Wait(0)
	end
end)

-- Toggle door locks command (/lock)
RegisterNetEvent('esx_nocarjack:toggleLocks')
AddEventHandler('esx_nocarjack:toggleLocks', function()
	veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	if veh then
		locks = GetVehicleDoorLockStatus(veh)
		if locks == 0 or locks == 1 then
			TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', veh, 2)
			TriggerEvent("chatMessage", "INFO", {255, 255, 0}, "Door is now ^1locked^0.")
		else
			TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', veh, 1)
			TriggerEvent("chatMessage", "INFO", {255, 255, 0}, "Door is now ^2unlocked^0.")
		end
	end	
end)

RegisterNetEvent('esx_nocarjack:setVehicleDoors')
AddEventHandler('esx_nocarjack:setVehicleDoors', function(veh, doors)
	SetVehicleDoorsLocked(veh, doors)
end)
