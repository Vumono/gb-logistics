RegisterNetEvent('gb-logistics:Payment')
AddEventHandler('gb-logistics:Payment', function(payment)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(payment)

end)
