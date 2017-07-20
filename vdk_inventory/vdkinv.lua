ITEMS = {}
-- flag to keep track of whether player died to prevent
-- multiple runs of player dead code
local playerdead = false
local maxCapacity = 70

-- register events, only needs to be done once
RegisterNetEvent("item:reset")
RegisterNetEvent("item:getItems")
RegisterNetEvent("item:updateQuantity")
RegisterNetEvent("item:setItem")
RegisterNetEvent("item:sell")
RegisterNetEvent("gui:getItems")

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
    item = tonumber(item)
    if (ITEMS[item] == nil) then
        new(item, quantity)
    else
        add({ item, quantity })
    end
end)

AddEventHandler("player:looseItem", function(item, quantity)
    item = tonumber(item)
    if (ITEMS[item].quantity >= quantity) then
        delete({ item, quantity })
    end
end)

AddEventHandler("player:sellItem", function(item, price)
    item = tonumber(item)
    if (ITEMS[item].quantity > 0) then
        sell({ item, price })
    end
end)

function sell(arg)
    local itemId = tonumber(arg[1])
    local price = arg[2]
    local item = ITEMS[itemId]
    item.quantity = item.quantity - 1
    TriggerServerEvent("item:sell", itemId, item.quantity, price)
    InventoryMenu()
end

function delete(arg)
    local itemId = tonumber(arg[1])
    local qty = arg[2]
    local item = ITEMS[itemId]
    item.quantity = item.quantity - qty
    TriggerServerEvent("item:updateQuantity", item.quantity, itemId)
    InventoryMenu()
end

function add(arg)
    local itemId = tonumber(arg[1])
    local qty = arg[2]
    local item = ITEMS[itemId]
    item.quantity = item.quantity + qty
    TriggerServerEvent("item:updateQuantity", item.quantity, itemId)
    InventoryMenu()
end

function new(item, quantity)
    TriggerServerEvent("item:setItem", item, quantity)
    TriggerServerEvent("item:getItems")
end

function getQuantity(itemId)
	if(not ITEMS[tonumber(itemId)]) then
		return 0
	else
		return ITEMS[tonumber(itemId)].quantity
	end
end

function notFull()
    local pods = 0
    for _, v in pairs(ITEMS) do
        pods = pods + v.quantity
    end
    if (pods < maxCapacity) then return true end
end

function InventoryMenu()
    ped = GetPlayerPed(-1);
    MenuTitle = "Items:"
    ClearMenu()
    for ind, value in pairs(ITEMS) do
        if (value.quantity > 0) then
            Menu.addButton(tostring(value.libelle) .. " : " .. tostring(value.quantity), "ItemMenu", ind)
        end
    end
end

function ItemMenu(itemId)
    MenuTitle = "Details:"
    ClearMenu()
    Menu.addButton("Supprimer 1", "delete", { itemId, 1 })
    --Menu.addButton("Ajouter 1", "add", { itemId, 1 })
end

function give(item)
    
    player, distance = GetClosestPlayer()
    
    --Chat(distance)
    --Chat(player)
    
    if(distance ~= -1 and distance < 3) and (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
        DisplayOnscreenKeyboard(1, "Quantité :", "", "", "", "", "", 3)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local res = 1
            res = tonumber(GetOnscreenKeyboardResult())
            if res ~= nil then
                if res < 0 then
                        res = res - res
                    end
                if (ITEMS[item].quantity - res >= 0) then
                    TriggerServerEvent("player:giveItem", item, ITEMS[item].libelle, res, GetPlayerServerId(player))
                    local ped = GetPlayerPed(-1)
                    if ped then
                        TaskStartScenarioInPlace(ped, "PROP_HUMAN_PARKING_METER", 0, false)
                        Citizen.Wait(1500)
                        ClearPedTasks(GetPlayerPed(-1))
                    end
                end
            end
        end
    else
        TriggerEvent("es_freeroam:notify", "CHAR_MP_STRIPCLUB_PR", 1, "Mairie", false, "Pas de joueur proche ou dans un vehicule")
    end
end

--Citizen.CreateThread(function()
  --  while true do
    --    Citizen.Wait(0)
      --  if IsControlJustPressed(1, 311) then
        --    InventoryMenu() -- Menu to draw
          --  Menu.hidden = not Menu.hidden -- Hide/Show the menu
        --end
        --Menu.renderGUI() -- Draw menu on each tick if Menu.hidden = false
        --if IsEntityDead(PlayerPedId()) then
            --PlayerIsDead()
            -- prevent the death check from overloading the server
            --playerdead = true
        --end
    --end
--end)

function PlayerIsDead()
    -- do not run if already ran
    if playerdead then
        return
    end
    TriggerServerEvent("item:reset")
end

Citizen.CreateThread(function()
    while true do
	Citizen.Wait(0)
	
		if gps == 1 then
			DisplayRadar(true)
		else gps
			DisplayRadar(false)
		end
    end
end)