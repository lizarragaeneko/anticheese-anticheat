
BlacklistedWeapons = { -- weapons that will get people banned
	"WEAPON_BALL",
	"WEAPON_RAILGUN",
	"WEAPON_GARBAGEBAG",
}

CageObjs = {
	"prop_gold_cont_01",
	"p_cablecar_s",
	"stt_prop_stunt_tube_l",
	"stt_prop_stunt_track_dwuturn",
	"hei_prop_carrier_cargo_02a",
	"p_ferris_car_01",
	"prop_cj_big_boat",
	"prop_rock_4_big2",
	"prop_steps_big_01",
	"v_ilev_lest_bigscreen",
	"prop_carcreeper",
	"apa_mp_h_bed_double_09",
	"apa_mp_h_bed_wide_05",
	"prop_cattlecrush",
	"prop_cs_documents_01",

}

CarsBL = {	--BlackListed vehicles
	"khanjali", --Example vehicles
	"avenger"
}

Citizen.CreateThread(function()
	while true do
		Wait(30000)
		TriggerServerEvent("anticheese:timer")
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(60000)
	while true do
		Citizen.Wait(0)
		local ped = PlayerPedId()
		local posx,posy,posz = table.unpack(GetEntityCoords(ped,true))
		local still = IsPedStill(ped)
		local vel = GetEntitySpeed(ped)
		local ped = PlayerPedId()
		local veh = IsPedInAnyVehicle(ped, true)
		local speed = GetEntitySpeed(ped)
		local para = GetPedParachuteState(ped)
		local flyveh = IsPedInFlyingVehicle(ped)
		local rag = IsPedRagdoll(ped)
		local fall = IsPedFalling(ped)
		local parafall = IsPedInParachuteFreeFall(ped)
		SetEntityVisible(PlayerPedId(), true) -- make sure player is visible
		Wait(3000) -- wait 3 seconds and check again

		local more = speed - 9.0 -- avarage running speed is 7.06 so just incase someone runs a bit faster it wont trigger

		local rounds = tonumber(string.format("%.2f", speed))
		local roundm = tonumber(string.format("%.2f", more))


		if not IsEntityVisible(PlayerPedId()) then
			SetEntityHealth(PlayerPedId(), -100) -- if player is invisible kill him!
		end

		newx,newy,newz = table.unpack(GetEntityCoords(ped,true))
		newPed = PlayerPedId() -- make sure the peds are still the same, otherwise the player probably respawned
		if GetDistanceBetweenCoords(posx,posy,posz, newx,newy,newz) > 200 and still == IsPedStill(ped) and vel == GetEntitySpeed(ped) and ped == newPed then
			TriggerServerEvent("AntiCheese:NoclipFlag", GetDistanceBetweenCoords(posx,posy,posz, newx,newy,newz))
		end

		if speed > 9.0 and not veh and (para == -1 or para == 0) and not flyveh and not fall and not parafall and not rag then
			--dont activate this, its broken!
			--TriggerServerEvent("AntiCheese:SpeedFlag", rounds, roundm) -- send alert along with the rounded speed and how much faster they are
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		local curPed = PlayerPedId()
		local curHealth = GetEntityHealth( curPed )
		SetEntityHealth( curPed, curHealth-2)
		local curWait = math.random(10,150)
		-- this will substract 2hp from the current player, wait 50ms and then add it back, this is to check for hacks that force HP at 200
		Citizen.Wait(curWait)

		if not IsPlayerDead(PlayerId()) then
			if PlayerPedId() == curPed and GetEntityHealth(curPed) == curHealth and GetEntityHealth(curPed) ~= 0 then
				TriggerServerEvent("AntiCheese:HealthFlag", false, curHealth-2, GetEntityHealth( curPed ),curWait )
			elseif GetEntityHealth(curPed) == curHealth-2 then
				SetEntityHealth(curPed, GetEntityHealth(curPed)+2)
			end
		end
		if GetEntityHealth(curPed) > 400 then
			TriggerServerEvent("AntiCheese:HealthFlag", false, GetEntityHealth( curPed )-200, GetEntityHealth( curPed ),curWait )
		end

		if GetPlayerInvincible( PlayerId() ) then -- if the player is invincible, flag him as a cheater and then disable their invincibility
			TriggerServerEvent("AntiCheese:HealthFlag", true, curHealth-2, GetEntityHealth( curPed ),curWait )
			SetPlayerInvincible( PlayerId(), false )
		end
	end
end)

-- prevent infinite ammo, godmode, invisibility and ped speed hacks
Citizen.CreateThread(function()
    while true do
	Citizen.Wait(1)
	SetPedInfiniteAmmoClip(PlayerPedId(), false)
	SetEntityInvincible(PlayerPedId(), false)
	SetEntityCanBeDamaged(PlayerPedId(), true)
	ResetEntityAlpha(PlayerPedId())
	local fallin = IsPedFalling(PlayerPedId())
	local ragg = IsPedRagdoll(PlayerPedId())
	local parac = GetPedParachuteState(PlayerPedId())
	if parac >= 0 or ragg or fallin then
		SetEntityMaxSpeed(PlayerPedId(), 80.0)
	else
		SetEntityMaxSpeed(PlayerPedId(), 7.1)
	end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(30000)
		for _,theWeapon in ipairs(BlacklistedWeapons) do
			Wait(1)
			if HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1 then
					TriggerServerEvent("AntiCheese:WeaponFlag", theWeapon)
					break
			end
		end
		local DetectableTextures = {
			{txd = "HydroMenu", txt = "HydroMenuHeader", name = "HydroMenu"},
			{txd = "John", txt = "John2", name = "SugarMenu"},
			{txd = "darkside", txt = "logo", name = "Darkside"},
			{txd = "ISMMENU", txt = "ISMMENUHeader", name = "ISMMENU"},
			{txd = "dopatest", txt = "duiTex", name = "Copypaste Menu"},
			{txd = "fm", txt = "menu_bg", name = "Fallout"},
			{txd = "wave", txt = "logo", name ="Wave"}
		}

		for i, data in pairs(DetectableTextures) do
			if GetTextureResolution(data.txd, data.txt).x ~= 4.0 then
				TriggerServerEvent("AntiCheese:CustomFlag", "Cheating", "Mod Menu Detected ("..data.name.." Detected via DUI Check)", true)
			end
		end
	end
end)


RegisterNetEvent("AntiCheese:RemoveInventoryWeapons")
AddEventHandler('AntiCheese:RemoveInventoryWeapons', function()
	RemoveAllPedWeapons(PlayerPedId(),false)
end)

function ReqAndDelete(object, detach)
	if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		while not NetworkHasControlOfEntity(object) do
			Citizen.Wait(1)
		end
		if detach then
			DetachEntity(object, 0, false)
		end
		SetEntityCollision(object, false, false)
		SetEntityAlpha(object, 0.0, true)
		SetEntityAsMissionEntity(object, true, true)
		SetEntityAsNoLongerNeeded(object)
		DeleteEntity(object)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local ped = PlayerPedId()
		local handle, object = FindFirstObject()
		local finished = false
		repeat
			Wait(1)
			if IsEntityAttached(object) and DoesEntityExist(object) then
				if GetEntityModel(object) == GetHashKey("prop_acc_guitar_01") then
					ReqAndDelete(object, true)
				end
			end
			for i=1,#CageObjs do
				if GetEntityModel(object) == GetHashKey(CageObjs[i]) then
					ReqAndDelete(object, false)
				end
			end
			finished, object = FindNextObject(handle)
		until not finished
		EndFindObject(handle)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsPedJumping(PlayerPedId()) then
			local jumplength = 0
			repeat
				Wait(0)
				jumplength=jumplength+1
				local isStillJumping = IsPedJumping(PlayerPedId())
			until not isStillJumping
			if jumplength > 250 then
				TriggerServerEvent("AntiCheese:JumpFlag", jumplength )
			end
		end
	end
end)

function isCarBlacklisted(model)
	for _, blacklistedCar in pairs(CarsBL) do
		if model == GetHashKey(blacklistedCar) then
			return true
		end
	end

	return false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if IsPedInAnyVehicle(GetPlayerPed(-1)) then
			v = GetVehiclePedIsIn(playerPed, false)
		end
		playerPed = GetPlayerPed(-1)
		
		if playerPed and v then
			if GetPedInVehicleSeat(v, -1) == playerPed then
				local car = GetVehiclePedIsIn(playerPed, false)
				carModel = GetEntityModel(car)
				carName = GetDisplayNameFromVehicleModel(carModel)
				if isCarBlacklisted(carModel) then
					DeleteVehicle(car)
					TriggerServerEvent('AntiCheese:CarFlag', carModel)
				end
			end
		end
	end
end)


-- generic cheat detections
RegisterNetEvent(GetCurrentResourceName().. ".verify")
AddEventHandler(GetCurrentResourceName().. ".verify", function()
	TriggerServerEvent("AntiCheese:CustomFlag", "Cheating", "Mod Menu Detected (recieved verify event)", true)
end)

RegisterNetEvent("HCheat:TempDisableDetection")
AddEventHandler("HCheat:TempDisableDetection", function()
	TriggerServerEvent("AntiCheese:CustomFlag", "Cheating", "Mod Menu Detected (recieved DisableDetection event)", true)
end)

local negativePayEvents = {
	"neweden_garage:pay",
	"projektsantos:mandathajs",
	"esx_dmvschool:pay"
}

function negativePayFunc(amount)
	if amount < 0 then
		TriggerServerEvent("AntiCheese:CustomFlag", "Cheating", "negative payment event.")
	end
end

for i, event in pairs(negativePayEvents) do
	RegisterNetEvent(event)
	AddEventHandler(event, negativePayFunc)
end

-- no longer generic cheat detections



-- specific resource detections


RegisterNetEvent("gcPhone:sendMessage")
AddEventHandler("gcPhone:sendMessage", function(message)
	if (string.find(message, "剎車剎車剎車剎車") or -1 > -1) then
		TriggerServerEvent("AntiCheese:CustomFlag", "Cheating", "GCPhone spam event.", true)
	end

end)