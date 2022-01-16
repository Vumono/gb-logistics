RegisterNetEvent('gb-logistics:Payment')
AddEventHandler('gb-logistics:Payment', function(payment)
    if payment ~= nil then
        local amount = Config.moneypermeter*payment
        if amount <= 10000 then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer ~= nil then
                xPlayer.addMoney(amount)
            end
        else
            print(xPlayer 'hackeroo')

        end
    end

end)
