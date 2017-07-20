--
-- Created by IntelliJ IDEA.
-- User: Djyss
-- Date: 17/05/2017
-- Time: 16:50
-- To change this template use File | Settings | File Templates.
--

--------------------------------------------------- VARS MENU ----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local options = {
    x = 0.1,
    y = 0.2,
    width = 0.2,
    height = 0.04,
    scale = 0.4,
    font = 0,
    menu_title = "Inventaire Personnel",
    menu_subtitle = "Categories",
    color_r = 0,
    color_g = 0,
    color_b = 0,
}

--------------------------------------------------- VARS PHONE ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local openKey = 289
local current_steam_id = ''
local phone_number = ''

NUMBERS_LIST = {}
OLDS_MSG = {}

------------------------------------------------- FUNCTIONS HELPERS ----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function drawTxt(options)
    SetTextFont(options.font)
    SetTextProportional(0)
    SetTextScale(options.scale, options.scale)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(0)
    SetTextEntry('STRING')
    AddTextComponentString(options.text)
    DrawRect(options.xBox,options.y,options.width,options.height,0,0,0,150)
    DrawText(options.selectedbutton.."/"..tablelength(menu.buttons),0,0,options.x + options.width/2 - 0.0385,options.y + 0.067,0.4, 255,255,255,255)    
end
function DisplayHelpText(str)
    SetTextComponentFormat('STRING')
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
function notifs(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString( msg )
    DrawNotification(false, false)
end

--------------------------------------------------- NUI CALLBACKS ------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, openKey) then
            TriggerEvent('phone:toggleInventoryMenu')
        end
        Menu.renderGUI(options)
    end
end)



RegisterNetEvent('phone:toggleInventoryMenu')
AddEventHandler('phone:toggleInventoryMenu', function()
    inventoryMenu() -- Menu to draw-- Hide/Show the menu
    Menu.hidden = not Menu.hidden 
end)

--------------------------------------------------- BASE MENU ----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("item:reset")
RegisterNetEvent("item:getItems")
RegisterNetEvent("item:updateQuantity")
RegisterNetEvent("item:setItem")
RegisterNetEvent("item:sell")
RegisterNetEvent("gui:getItems")
RegisterNetEvent("player:receiveItem")
RegisterNetEvent("player:looseItem")
RegisterNetEvent("player:sellItem")

ITEMS = {}
local playerdead = false
local maxCapacity = 80

-- handles when a player spawns either from joining or after death
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("item:getItems")
    -- reset player dead flag
    playerdead = false
end)

AddEventHandler("gui:getItems", function(THEITEMS)
    ITEMS = {}
    ITEMS = THEITEMS
end)

AddEventHandler("player:receiveItem", function(item, quantity)
    if (inventoryGetPods() + quantity <= maxCapacity) then
        item = tonumber(item)
        if (ITEMS[item] == nil) then
            inventoryNew(item, quantity)
        else
            inventoryAdd({ item, quantity })
        end
    end
end)

AddEventHandler("player:looseItem", function(item, quantity)
    item = tonumber(item)
    if (ITEMS[item].quantity >= quantity) then
        inventoryDelete({ item, quantity })
    end
end)

AddEventHandler("player:sellItem", function(item, price)
    item = tonumber(item)
    if (ITEMS[item].quantity > 0) then
        inventorySell({ item, price })
    end
end)

-- Menu de l'inventaire
function inventoryMenu()                 
    ped = GetPlayerPed(-1);
    options.menu_subtitle = "Items  "
    options.rightText = (inventoryGetPods() or 0) .. "/" .. maxCapacity
    ClearMenu()
    for ind, value in pairs(ITEMS) do
        if (value.quantity > 0) then
            Menu.addButton(tostring(value.quantity) .. " " ..tostring(value.libelle), "inventoryItemMenu", ind)
        end         
    end
    Menu.addButton("Fermer l'inventaire", "closeInv", nil)
end

function closeInv()
    Menu.hidden = not Menu.hidden
end

function inventoryItemMenu(itemId)
    ClearMenu()
    options.menu_subtitle = "Details "
    Menu.addButton("Utiliser", "use", itemId)
    Menu.addButton("Ouvrir", "lire", itemId)	
    Menu.addButton("Supprimer", "inventoryDelete", {itemId , 1})    
end

function use(item)
	TriggerServerEvent("item:updateQuantity", 1, item)
    if (ITEMS[item].quantity - 1 >= 0) then
        if ITEMS[item].type == 3 then
            rien(itemId)
        elseif ITEMS[item].type == 6 then 
            joint(itemId)        
            TriggerEvent("player:looseItem", item, 1) 
        elseif ITEMS[item].type == 5 then
            drink(itemId)
            TriggerEvent("player:looseItem", item, 1)  
        elseif ITEMS[item].type == 4 then
		    smoke(itemId)
        	TriggerEvent("player:looseItem", item, 1)  
        elseif ITEMS[item].type == 0 then
        	rien(itemId)
        elseif ITEMS[item].type == 2 then
            TriggerEvent("food:eat", ITEMS[item])
            TriggerEvent("player:looseItem", item, 1)   
        elseif ITEMS[item].type == 1 then
            TriggerEvent("food:drink", ITEMS[item])
            TriggerEvent("player:looseItem", item, 1) 
        else 
			Toxicated()
       	    Citizen.Wait(7000)
        	ClearPedTasks(GetPlayerPed(-1))
       	    Reality()	
      	end
    end
end

function drink(item)
    TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_DRINKING", 0, 1)
    Citizen.Wait(10000)
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    ClearPedTasksImmediately(GetPlayerPed(-1))
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(GetPlayerPed(-1), true)
    TriggerEvent("project:notify", "~h~~o~Tu viens fumer un joint !")
    SetPedMovementClipset(GetPlayerPed(-1), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
    SetPedIsDrunk(GetPlayerPed(-1), true)
    DoScreenFadeIn(500)
    Citizen.Wait(90000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedIsDrunk(GetPlayerPed(-1), false)
    SetPedMotionBlur(GetPlayerPed(-1), false)
end

function joint(item)
    TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(20000)
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    ClearPedTasksImmediately(GetPlayerPed(-1))
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
    SetPedIsDrunk(GetPlayerPed(-1), true)
    DoScreenFadeIn(500)
    Citizen.Wait(90000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedIsDrunk(GetPlayerPed(-1), false)
    SetPedMotionBlur(GetPlayerPed(-1), false)
end

function smoke(item)   
  Citizen.CreateThread(function()

      local ped = GetPlayerPed(-1);

      if ped then
          local pos = GetEntityCoords(ped);
          local head = GetEntityHeading(ped);
          TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING", 0, 1) 
      end

  end)
end

function animsWithModelsSpawn(object)

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))

    RequestModel(object.object)
    while not HasModelLoaded(object.object) do
        Wait(1)
    end

    local object = CreateObject(object.object, x, y+2, z, true, true, true)
    -- local vX, vY, vZ = table.unpack(GetEntityCoords(object,  true))

    -- AttachEntityToEntity(object, PlayerId(), GetPedBoneIndex(PlayerId()), vX,  vY,  vZ, -90.0, 0, -90.0, true, true, true, false, 0, true)
    PlaceObjectOnGroundProperly(object)

end

function rien(item)
    TriggerEvent("project:notify", "~h~~s~Erreur : ~h~~r~Tu ne peux pas faire sa !")
    ClearMenu()
    inventoryMenu()
end

function inventorySell(arg)
    local itemId = tonumber(arg[1])
    local price = arg[2]
    local item = ITEMS[itemId]
    item.quantity = item.quantity - 1
    TriggerServerEvent("item:sell", itemId, item.quantity, price)
    inventoryMenu()
end

function inventoryDelete(arg)
    local itemId = tonumber(arg[1])
    local qty = arg[2]
    local item = ITEMS[itemId]
    item.quantity = item.quantity - qty
    TriggerServerEvent("item:updateQuantity", item.quantity, itemId)
    inventoryMenu()
end

function inventoryAdd(arg)
    local itemId = tonumber(arg[1])
    local qty = arg[2]
    local item = ITEMS[itemId]
    item.quantity = item.quantity + qty
    TriggerServerEvent("item:updateQuantity", item.quantity, itemId)
    InventoryMenu()
end

function inventoryNew(item, quantity)
    TriggerServerEvent("item:setItem", item, quantity)
    TriggerServerEvent("item:getItems")
end

function inventoryGetQuantity(itemId)
    return ITEMS[tonumber(itemId)].quantity
end

function inventoryGetPods()
    local pods = 0
    for _, v in pairs(ITEMS) do
        pods = pods + v.quantity
    end
    return pods
end

function notFull()
    if (inventoryGetPods() < maxCapacity) then return true end
end

function PlayerIsDead()
    -- do not run if already ran
    if playerdead then
        return
    end
    TriggerServerEvent("item:reset")
end

function getPlayers()
    local playerList = {}
    for i = 0, 32 do
        local player = GetPlayerFromServerId(i)
        if NetworkIsPlayerActive(player) then
            table.insert(playerList, player)
        end
    end
    return playerList
end

function getNearPlayer()
    local players = getPlayers()
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local pos2
    local distance
    local minDistance = 3
    local playerNear
    for _, player in pairs(players) do
        pos2 = GetEntityCoords(GetPlayerPed(player))
        distance = GetDistanceBetweenCoords(pos["x"], pos["y"], pos["z"], pos2["x"], pos2["y"], pos2["z"], true)
        if (pos ~= pos2 and distance < minDistance) then
            playerNear = player
            minDistance = distance
        end
    end
    if (minDistance < 3) then
        return playerNear
    end
end
------------------------------------------------ REPERTORY MENU --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
