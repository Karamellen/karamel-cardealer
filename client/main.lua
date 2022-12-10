ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local IsMenuOpen = false
local ped = PlayerPedId()
local Cam = false
local Vehicle = nil
local ShowTimeIgang = false
local VehicleOut = false

TriggerServerEvent('karamel-cardealer:ServerGetCars')

RegisterKeyMapping('openCardealer', 'Åbn bilforhandler menu', 'keyboard', 'f6')

RegisterCommand('openCardealer', function()
    TriggerServerEvent('karamel-cardealer:CheckJob')
end)

RegisterNetEvent('karamel-cardealer:OpenComputer', function()
    if IsMenuOpen == false then
        OpenMenu()
    end
end)

local option = {
    {label = 'Køretøjsliste', value = 'carlist'},
    {label = 'Udlej Køretøjer', value = 'leascar'},
}

function OpenMenu()
    local options = {}
    local leascar = {}
    isMenuOpen = true

    for k,v in pairs(Config.VehicleList) do
        v = v:sub(1,1):upper()..v:sub(2)
        table.insert(options, {label = v, value = 'watchCar', car = v })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
        title = Config.MainMenuTitle,
        align = Config.MenuPosition,
        elements = option
    }, function(data, menu)

        if data.current.value == 'watchCar' then
            menu.close()
            if VehicleOut == false then
            local ModelHash = data.current.car
            if not IsModelInCdimage(ModelHash) then return end
            RequestModel(ModelHash)
            while not HasModelLoaded(ModelHash) do
                Wait(10)
            end
            local MyPed = PlayerPedId()
            Vehicle = CreateVehicle(ModelHash, Config.ShowRoom.x, Config.ShowRoom.y, Config.ShowRoom.z, Config.ShowRoom.h, true, false)
            SetModelAsNoLongerNeeded(ModelHash)
            exports["id_notify"]:notify({
                title = '',
                message = 'Din ' ..data.current.car.. ' blev kørt frem.',
                type = 'success'
            })
            VehicleOut = true
            TriggerServerEvent('karamel-cardealer:TakeMoneyOfDrivingTest')
            startShowtime()
            IsMenuOpen = false
        else
            exports["id_notify"]:notify({
                title = '',
                message = 'Du har allerede et køretøj ude!',
                type = 'error'
            })
            end
        end
        if data.current.value == 'carlist' then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
                title = 'Køretøjsliste',
                align = Config.MenuPosition,
                elements = options
            }, function(data, menu)
                menu.close()
            end)
        end
        if data.current.value == 'leascar' then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
                title = 'Udlej Køretøjer',
                align = Config.MenuPosition,
                elements = leascar
            }, function(data, menu)
                menu.close()
            end)
        end

    end, 
    function(data, menu)
        menu.close()
        IsMenuOpen = false
    end)
end

function startShowtime()
    ShowTimeIgang = true
    CreateThread(function()
        while ShowTimeIgang do 
            Wait(1)
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.ShowRoom.x, Config.ShowRoom.y, Config.ShowRoom.z) < Config.TextDistance then
                DrawText3Ds(Config.ShowRoom.x, Config.ShowRoom.y, Config.ShowRoom.z+0.30, '~b~E~w~ - Aflever Køretøj')
                if IsControlJustPressed(1, 38) then
                    DeleteVehicle(Vehicle)
                    Vehicle = nil
                    ShowTimeIgang = false
                    exports["id_notify"]:notify({
                        title = '',
                        message = 'Du afleverede køretøjet.',
                        type = 'error'
                    })
                    VehicleOut = false
                end
            end
        end
    end)
end

RegisterCommand('addcar', function(source, args)
    TriggerServerEvent('karamel-cardealer:AddCar', args[1])
end)

RegisterCommand('removecar', function(source, args)
    TriggerServerEvent('karamel-cardealer:RemoveCar', args[1])
end)

RegisterNetEvent('karamel-cardealer:CarAdded', function(car)
    table.insert(Config.VehicleList, car)
end)

RegisterNetEvent('karamel-cardealer:CarRemoved', function(car)
    for i,v in pairs(Config.VehicleList) do
        if v == car then
            table.remove(Config.VehicleList, i)
        end
    end
end)
RegisterNetEvent('karamel-cardealer:GetCars', function(cars)
    for k,v in pairs(cars) do
        table.insert(Config.VehicleList, v)
    end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.33, 0.33)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline() 
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end