ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local carlist = {}

RegisterNetEvent('karamel-cardealer:CheckJob', function()
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer.job.name == 'bilforhandler' then
        TriggerClientEvent('karamel-cardealer:OpenComputer', source)
    end
end)

RegisterNetEvent('karamel-cardealer:AddCar', function(car)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer.job.name == 'bilforhandler' then
        local result = MySQL.query.await('SELECT * FROM cardealer WHERE car = ?', {car})
        if #result == 0 then
            MySQL.query.await('INSERT INTO cardealer (car) VALUES (?)', {car})
            TriggerClientEvent('karamel-cardealer:CarAdded', source, car)
            table.insert(carlist, car)
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Denne bil findes allerede!', style = { ['background-color'] = '#FF0000', ['color'] = '#000000' } })
        end
    end
end)

RegisterNetEvent('karamel-cardealer:RemoveCar', function(car)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer.job.name == 'bilforhandler' then
        local result = MySQL.query.await('SELECT * FROM cardealer WHERE car = ?', {car})
        if #result == 0 then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du fjernede en ' ..car.. ' fra kataloget!', style = { ['background-color'] = '#FF0000', ['color'] = '#000000' } })
        else
            MySQL.Async.execute("DELETE FROM cardealer WHERE car = ?", {car})
            for i,v in pairs(carlist) do
                if v == car then
                    table.remove(carlist, i)
                end
            end
            TriggerClientEvent('karamel-cardealer:CarRemoved', source, car)
        end
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du har ikke adgang til dette.', style = { ['background-color'] = '#FF0000', ['color'] = '#000000' } })
    end
end)

RegisterNetEvent('karamel-cardealer:CheckJobMechanic', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == 'bilforhandler' then
    end
end)

RegisterNetEvent('karamel-cardealer:ServerGetCars', function()
    local source = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM cardealer', {})
    local cars = {}

    for k,v in pairs(result) do
        table.insert(cars, v.car)
    end
    TriggerClientEvent('karamel-cardealer:GetCars', source, cars or {})

end)

RegisterNetEvent('karamel-cardealer:TakeMoneyOfDrivingTest', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeMoney(7500)
end)