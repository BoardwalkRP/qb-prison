QBCore = exports['qb-core']:GetCoreObject() -- Used Globally
CellsBlip, TimeBlip, ShopBlip = 0, 0, 0
local insidecanteen, insidefreedom, canteen_ped, freedom_ped, reception_ped, visitation_ped = false, false, 0, 0, 0, 0
local freedom, canteen, prisonZone

-- Functions

--- This will create the blips for the cells, time check and shop
--- @return nil
local function CreateCellsBlip()
	if CellsBlip then
		RemoveBlip(CellsBlip)
	end
	CellsBlip = AddBlipForCoord(Config.Locations["yard"].coords.x, Config.Locations["yard"].coords.y, Config.Locations["yard"].coords.z)

	SetBlipSprite(CellsBlip, 238)
	SetBlipDisplay(CellsBlip, 4)
	SetBlipScale(CellsBlip, 0.8)
	SetBlipAsShortRange(CellsBlip, true)
	SetBlipColour(CellsBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Lang:t("info.cells_blip"))
	EndTextCommandSetBlipName(CellsBlip)

	if TimeBlip then
		RemoveBlip(TimeBlip)
	end
	TimeBlip = AddBlipForCoord(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z)

	SetBlipSprite(TimeBlip, 466)
	SetBlipDisplay(TimeBlip, 4)
	SetBlipScale(TimeBlip, 0.8)
	SetBlipAsShortRange(TimeBlip, true)
	SetBlipColour(TimeBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Lang:t("info.freedom_blip"))
	EndTextCommandSetBlipName(TimeBlip)

	if ShopBlip then
		RemoveBlip(ShopBlip)
	end
	ShopBlip = AddBlipForCoord(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z)

	SetBlipSprite(ShopBlip, 52)
	SetBlipDisplay(ShopBlip, 4)
	SetBlipScale(ShopBlip, 0.5)
	SetBlipAsShortRange(ShopBlip, true)
	SetBlipColour(ShopBlip, 0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Lang:t("info.canteen_blip"))
	EndTextCommandSetBlipName(ShopBlip)
end

local function removeBlips()
	RemoveBlip(JobBlip)
	RemoveBlip(CellsBlip)
	RemoveBlip(TimeBlip)
	RemoveBlip(ShopBlip)
	TimeBlip = 0
	ShopBlip = 0
	CellsBlip = 0
	JobBlip = 0
end

-- Add clothes to prisioner

local function ApplyClothes()
	local playerPed = PlayerPedId()
	if DoesEntityExist(playerPed) then
		Citizen.CreateThread(function()
			SetPedArmour(playerPed, 0)
			ClearPedBloodDamage(playerPed)
			ResetPedVisibleDamage(playerPed)
			ClearPedLastWeaponDamage(playerPed)
			ResetPedMovementClipset(playerPed, 0)
			local gender = QBCore.Functions.GetPlayerData().charinfo.gender
			if gender == 0 then
				TriggerEvent('illenium-appearance:client:loadJobOutfit', Config.Uniforms.male)
			else
				TriggerEvent('illenium-appearance:client:loadJobOutfit', Config.Uniforms.female)
			end
		end)
	end
end

local function solitaryLoop()
	CreateThread(function()
		while LocalPlayer.state.inJail do
			TriggerEvent('prison:client:Leave')
			Wait(5 * 60 * 1000)
		end
	end)
end

local function disableControlsSolitary()
	CreateThread(function()
		while LocalPlayer.state.inJail do
			DisableControlAction(1, 22, true)
			SetPedCanRagdoll(PlayerPedId(), false)
			Wait(1)
		end
	end)
end

local function setIntoPrison(solitary)
	local plyPed = PlayerPedId()
	TriggerEvent("chat:addMessage", {
		color = { 3, 132, 252 },
		multiline = true,
		args = { "SYSTEM", Lang:t("info.seized_property") }
	})
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	local RandomStartPosition = (solitary > 0) and Config.Locations.solitary[solitary] or
		Config.Locations.spawns[math.random(1, #Config.Locations.spawns)]
	SetEntityCoords(plyPed, RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9, 0, 0, 0, false)
	SetEntityHeading(plyPed, RandomStartPosition.coords.w)
	Wait(500)

	LocalPlayer.state:set('inJail', true, true)
	if solitary > 0 then
		solitaryLoop()
		disableControlsSolitary()
	end
	local tempJobs = {}
	local i = 1
	for k in pairs(Config.Locations.jobs) do
		tempJobs[i] = k
		i += 1
	end
	CurrentJob = tempJobs[math.random(1, #tempJobs)]
	CreateJobBlip(true)
	ApplyClothes()

	TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)
	CreateCellsBlip()
	Wait(2000)
	DoScreenFadeIn(1000)
	if solitary <= 0 then QBCore.Functions.Notify(Lang:t("error.do_some_work", { currentjob = Config.Jobs[CurrentJob] }), "error") end
end

local function setOutPrison()
	local plyPed = PlayerPedId()
	TriggerServerEvent("prison:server:SetJailStatus", 0)
	TriggerServerEvent("prison:server:GiveJailItems")
	TriggerEvent("chat:addMessage", {
		color = { 3, 132, 252 },
		multiline = true,
		args = { "SYSTEM", Lang:t("info.received_property") }
	})
	LocalPlayer.state:set('inJail', false, true)
	RemoveBlip(JobBlip)
	RemoveBlip(CellsBlip)
	CellsBlip = 0
	RemoveBlip(TimeBlip)
	TimeBlip = 0
	RemoveBlip(ShopBlip)
	ShopBlip = 0
	QBCore.Functions.Notify(Lang:t("success.free_"))
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	TriggerEvent('illenium-appearance:client:reloadSkin')
	SetEntityCoords(plyPed, Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, 0, 0, 0, false)
	SetEntityHeading(plyPed, Config.Locations["outside"].coords.w)

	Wait(500)

	DoScreenFadeIn(1000)
	SetPedCanRagdoll(plyPed, true)
end

local function spawnPed(coords)
	local pedModel = `s_m_m_armoured_01`

	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do
		Wait(0)
	end

	local ped = CreatePed(0, pedModel, coords.x, coords.y, coords.z, coords.w, false, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
	return ped
end

local function onLoad()
	QBCore.Functions.TriggerCallback('prison:server:checkTime', function(time, solitary)
		LocalPlayer.state:set('inJail', (time > 0), true)
		if time > 0 then
			setIntoPrison(solitary)
		elseif time <= 0 and solitary > 0 then
			setOutPrison()
		end
	end)

	QBCore.Functions.TriggerCallback('prison:server:IsAlarmActive', function(active)
		if active then
			TriggerEvent('prison:client:JailAlarm', true)
		end
	end)

	if not DoesEntityExist(freedom_ped) then freedom_ped = spawnPed(Config.Locations["freedom"].coords) end
	if not DoesEntityExist(canteen_ped) then canteen_ped = spawnPed(Config.Locations["shop"].coords) end
	if not DoesEntityExist(reception_ped) then reception_ped = spawnPed(Config.Locations.visitation.enter.ped) end
	if not DoesEntityExist(visitation_ped) then visitation_ped = spawnPed(Config.Locations.visitation.exit.ped) end

	prisonZone = PolyZone:Create(Config.PrisonZone, {
		name = 'prison_border',
	})

	prisonZone:onPlayerInOut(function(isPointInside, point)
		if not isPointInside and LocalPlayer.state.inJail then
			removeBlips()
			LocalPlayer.state:set('inJail', false, true)
			LocalPlayer.state:set('onTheLam', true, true)
			TriggerServerEvent("prison:server:SecurityLockdown")
			exports['ps-dispatch']:PrisonBreak()
			TriggerServerEvent('prison:server:JailAlarm')
            TriggerEvent("prison:client:PrisonBreakAlert")
            TriggerServerEvent("prison:server:SetJailStatus", 0)
            TriggerServerEvent("prison:server:GiveJailItems", true)
            QBCore.Functions.Notify(Lang:t("error.escaped"), "error")
		end
	end)

	if not Config.UseTarget then return end

	exports['qb-target']:AddTargetEntity(freedom_ped, {
		options = {
			{
				type = "client",
				event = "prison:client:Leave",
				icon = 'fas fa-clipboard',
				label = Lang:t("info.target_freedom_option")
			}
		},
		distance = 2.5,
	})

	exports['qb-target']:AddTargetEntity(canteen_ped, {
		options = {
			{
				type = "client",
				event = "prison:client:canteen",
				icon = 'fas fa-clipboard',
				label = Lang:t("info.target_canteen_option"),
				canInteract = function()
					return LocalPlayer.state.inJail
				end
			}
		},
		distance = 2.5,
	})

	exports['qb-target']:AddTargetEntity(reception_ped, {
		options = {
			{
				type = "client",
				event = "prison:client:visitation:list",
				icon = 'fas fa-clipboard',
				label = 'Request visitation',
			}
		},
		distance = 2.5,
	})

	exports['qb-target']:AddTargetEntity(visitation_ped, {
		options = {
			{
				icon = 'fas fa-clipboard',
				label = 'Leave',
				action = function()
					DoScreenFadeOut(500)
					while not IsScreenFadedOut() do Wait(10) end
					local plyPed = PlayerPedId()
					---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
					SetEntityCoords(plyPed, Config.Locations.visitation.enter.coords.xyz, true, false, false, false)
					SetEntityHeading(plyPed, Config.Locations.visitation.enter.coords.w)
					DoScreenFadeIn(500)
				end,
			}
		},
		distance = 2.5,
	})
end

local function ensureSolitary()
	local solitaryCell = 0
	while solitaryCell <= 0 do
		Wait(500)
		local PlayerData = QBCore.Functions.GetPlayerData()
		solitaryCell = PlayerData.metadata.inSolitary
	end
	setIntoPrison(solitaryCell)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	onLoad()
end)

AddEventHandler('onResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then return end
	Wait(100)
	if LocalPlayer.state['isLoggedIn'] then onLoad() end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	LocalPlayer.state:set('inJail', false, true)
	CurrentJob = nil
	RemoveBlip(JobBlip)
	prisonZone:destroy()
	prisonZone = nil
end)

RegisterNetEvent('prison:client:Enter', function(time, inSolitary)
	local invokingResource = GetInvokingResource()
	if invokingResource and invokingResource ~= 'qb-policejob' and invokingResource ~= 'qb-ambulancejob' and invokingResource ~= GetCurrentResourceName() then
		-- Use QBCore.Debug here for a quick and easy way to print to the console to grab your attention with this message
		QBCore.Debug({ ('Player with source %s tried to execute prison:client:Enter manually or from another resource which is not authorized to call this, invokedResource: %s'):format(GetPlayerServerId(PlayerId()), invokingResource) })
		return
	end
	TriggerServerEvent("prison:server:SetJailStatus", time, inSolitary)
	TriggerServerEvent("prison:server:SaveJailItems")
	QBCore.Functions.Notify(Lang:t("error.injail", { Time = time }), "error")

	if inSolitary then
		ensureSolitary()
	else
		setIntoPrison(0)
	end
end)

RegisterNetEvent('prison:client:Leave', function()
	QBCore.Functions.TriggerCallback('prison:server:checkTime', function(time)
		if time > 0 then
			QBCore.Functions.Notify(Lang:t("info.timeleft", { JAILTIME = time }))
		else
			setOutPrison()
		end
	end)
end)

RegisterNetEvent('prison:client:UnjailPerson', function()
	QBCore.Functions.TriggerCallback('prison:server:checkTime', function(time)
		if time > 0 then setOutPrison() end
	end)
end)

RegisterNetEvent('prison:client:canteen', function()
	local ShopItems = {}
	ShopItems.label = "Prison Canteen"
	ShopItems.items = Config.CanteenItems
	ShopItems.slots = #Config.CanteenItems
	TriggerServerEvent("inventory:server:OpenInventory", "shop", "Canteenshop_" .. math.random(1, 99), ShopItems)
end)

-- Threads

CreateThread(function()
	if not Config.UseTarget then
		freedom = BoxZone:Create(vector3(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z), 2.75, 2.75, {
			name = "freedom",
			debugPoly = false,
		})
		freedom:onPlayerInOut(function(isPointInside)
			insidefreedom = isPointInside
			if isPointInside then
				CreateThread(function()
					while insidefreedom do
						if IsControlJustReleased(0, 38) then
							exports['qb-core']:KeyPressed()
							exports['qb-core']:HideText()
							TriggerEvent("prison:client:Leave")
							break
						end
						Wait(0)
					end
				end)
				exports['qb-core']:DrawText('[E] Check Time', 'left')
			else
				exports['qb-core']:HideText()
			end
		end)
		canteen = BoxZone:Create(vector3(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z), 2.75, 7.75, {
			name = "canteen",
			debugPoly = false,
		})
		canteen:onPlayerInOut(function(isPointInside)
			insidecanteen = isPointInside
			if isPointInside then
				CreateThread(function()
					while insidecanteen do
						if IsControlJustReleased(0, 38) then
							exports['qb-core']:KeyPressed()
							exports['qb-core']:HideText()
							TriggerEvent("prison:client:canteen")
							break
						end
						Wait(0)
					end
				end)
				exports['qb-core']:DrawText('[E] Open Canteen', 'left')
			else
				exports['qb-core']:HideText()
			end
		end)
	end
end)
