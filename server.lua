RegisterNetEvent('gb-logistics:Paymentcash')
AddEventHandler('gb-logistics:Paymentcash', function(payment)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(payment)

end)

RegisterNetEvent('gb-logistics:Paymentbank')
AddEventHandler('gb-logistics:Paymentbank', function(payment)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney('bank', payment)
end)
