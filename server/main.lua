function GetItemFromShop(itemName, zone)
    local zoneItems = Config.Zones[zone].Items

    for _, item in pairs(zoneItems) do
        if item.name == itemName then
            return true, item.price, item.name
        end
    end
end

function PlayerPosCheck(playerCoords, zone) 
    for _, pos in ipairs(Config.Zones[zone].Pos) do 
        if #(playerCoords - pos) < 5.0 then 
            return true 
        end 
    end
end

RegisterNetEvent("esx_shops:buyItem", function(itemName, amount, zone)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local exists, price, name = GetItemFromShop(itemName, zone)

    if not exists then
        return print(('[^3WARNING^7] Player ^5%s^7 attempted to exploit the shop!'):format(source))
    end

    if amount < 0 or not PlayerPosCheck(xPlayer.getCoords(true), zone) then
        return print(('[^3WARNING^7] Player ^5%s^7 attempted to exploit the shop!'):format(source))
    end

    price *= amount
    
    if not xPlayer.canCarryItem(name, amount) then
        return xPlayer.showNotification(TranslateCap('player_cannot_hold'))
    end

    for _, account in ipairs(Config.PaymentAccounts) do
        local account = xPlayer.getAccount(account)

        if account.money >= price then
            xPlayer.removeAccountMoney(account.name, price, ("%s %s"):format(name, TranslateCap('purchase')))
            xPlayer.addInventoryItem(name, amount)
            return xPlayer.showNotification(TranslateCap('bought', amount, name, ESX.Math.GroupDigits(price)))
        end
    end

    local missingMoney = price - xPlayer.getMoney()
    xPlayer.showNotification(TranslateCap('not_enough', ESX.Math.GroupDigits(missingMoney)))
end)