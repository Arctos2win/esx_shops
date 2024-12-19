local currentZone, textUi, inMenu
local function openShopMenu(zone)
    if not Config.Zones[zone] then return end
    local elements = {}
    for i, item in ipairs(Config.Zones[zone].Items) do
        elements[i] = {
            label = ('%s - <span style="color:green;">%s</span>'):format(item.label,
                TranslateCap('shop_item', ESX.Math.GroupDigits(item.price))),
            name = item.name,
            value = 1,
            type = "slider",
            min = Config.QuantityRange.Min,
            max = Config.QuantityRange.Max
        }
    end

    inMenu = true
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "SHOP_MENU", {
        title = TranslateCap('shop'),
        align = Config.MenuAlign,
        elements = elements
    }, function(data, menu)
        if not currentZone then 
            return menu.close() 
        end 

        TriggerServerEvent("esx_shops:buyItem", data.current.name, data.current.value, currentZone)
    end, function(data, menu)
        inMenu = false
        menu.close()
    end) 
end

function AddShopBlip(pos, settings)
    if not settings.ShowBlip then return end

    local blip = AddBlipForCoord(pos)

    SetBlipSprite(blip, settings.Type)
    SetBlipScale(blip, settings.Size)
    SetBlipColour(blip, settings.Color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(TranslateCap('shops'))
    EndTextCommandSetBlipName(blip)
end

function createShopPoint(pos, zone, showMarker)
    Point:constructor({
        coords = pos,
        distance = Config.DrawDistance,
        enter = function()
        end,
        leave = function()
            ESX.HideUI()
        end,            

        inside = function(point)
            if showMarker then
                DrawMarker(Config.MarkerType, point.coords.x, point.coords.y, point.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x,
                    Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g,
                    Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
            end

            currentZone = point.currDistance < Config.MarkerSize.x and zone
            if currentZone and not inMenu and not textUi then
                textUi = true
                ESX.textUi(Translate("press_menu", ESX.GetInteractKey()))  
            elseif (not currentZone or inMenu) then
                if not currentZone and inMenu then
                    ESX.UI.Menu.Close("default", GetCurrentResourceName(), "SHOP_MENU")    
                    inMenu = false
                end

                if textUi then 
                    ESX.HideUI()
                    textUi = false
                end
            end
        end
    })
end

ESX.RegisterInteraction("shop_menu", function()
    openShopMenu(currentZone)
end, function()
    return not inMenu
end)

for zone, v in pairs(Config.Zones) do
    for i = 1, #v.Pos, 1 do
        local pos = v.Pos[i]
        AddShopBlip(pos, v)
        createShopPoint(pos, zone, v.ShowMarker) 
    end
end