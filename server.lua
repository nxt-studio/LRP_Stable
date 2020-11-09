local SelectedHorseId = {}

Citizen.CreateThread(function()
	if GetCurrentResourceName() ~= "LRP_Stable" then
		print("^1=====================================")
		print("^1SCRIPT NAME OTHER THAN ORIGINAL")
		print("^1YOU SHOULD STOP SCRIPT")
		print("^1CHANGE NAME TO: ^2LRP_Stable^1")
		print("^1=====================================^0")
	end
end)

RegisterNetEvent("VP:STABLE:UpdateHorseComponents")
AddEventHandler(
    "VP:STABLE:UpdateHorseComponents",
    function(components, idhorse, MyHorse_entity)
        local _source = source
        local encodedComponents = json.encode(components)  

        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
            local id = idhorse
            MySQL.Async.execute("UPDATE horses SET `components`='".. encodedComponents .."' WHERE `identifier`=@identifier AND `id`=@id", {identifier = identifier, id = id}, function(done)
                TriggerClientEvent("VP:STABLE:UpdadeHorseComponents", _source, MyHorse_entity, components)
            end)
        end)       
    end
)


RegisterNetEvent("VP:STABLE:CheckSelectedHorse")
AddEventHandler(
    "VP:STABLE:CheckSelectedHorse",
    function()
        local _source = source       
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
            MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(horses)
                if #horses ~= 0 then
                    for i = 1, #horses do
                        if horses[i].selected == 1 then
                            TriggerClientEvent("VP:HORSE:SetHorseInfo", _source, horses[i].model, horses[i].name, horses[i].components)
                        end
                    end                    
                end
            end)
        end)       
    end
)

RegisterNetEvent("VP:STABLE:AskForMyHorses")
AddEventHandler(
    "VP:STABLE:AskForMyHorses",
    function()
        local _source = source
        local horseId = nil
        local components = nil
        
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")

            MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(horses)
                if horses[1]then
                    horseId = horses[1].id
                else
                    horseId = nil
                end
    
                MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(components)
                    if components[1] then
                        components = components[1].components
                    end
                end)
                TriggerClientEvent("VP:STABLE:ReceiveHorsesData", _source, horses)
            end)      
        end)    
    end
)

local Horses

RegisterNetEvent("VP:STABLE:BuyHorse")
AddEventHandler(
    "VP:STABLE:BuyHorse",
    function(data, name)
        local _source = source     

        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
            MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(horses)

                if #horses >= 3 then
                    print('Stable limit')
                    return
                end
    
                Wait(200)                
    
                if data.IsGold then
                    if user.getGold() < data.Gold then
                        --TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Gold insuficiente!', 5000)
                        print("You not have gold")
                        return
                    end
                    user.removeGold(tonumber(data.Gold))
                else
                    if user.getMoney() < data.Dollar then
                        --TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Dollar insuficiente!', 5000)
                        print("You not have Money")
                        return
                    end
                    user.removeMoney(tonumber(data.Dollar))
                end
    
                MySQL.Async.execute('INSERT INTO horses (`identifier`, `charid`, `name`, `model`) VALUES (@identifier, @charid, @name, @model);',
                {
                    identifier = identifier,
                    charid = charid,
                    name = tostring(name),
                    model = data.ModelH
                }, function(rowsChanged)

                end)
                

            end)
        end)
    end
)

RegisterNetEvent("VP:STABLE:SelectHorseWithId")
AddEventHandler(
    "VP:STABLE:SelectHorseWithId",
    function(id)
        local _source = source
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")

            MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(horse)
                
                for i = 1, #horse do  
                    local horseID = horse[i].id
                    MySQL.Async.execute("UPDATE horses SET `selected`='0' WHERE `identifier`=@identifier AND `id`=@id", {identifier = identifier,  id = horseID}, function(done)            
                    end)

                    Wait(300)
                    
                    if horse[i].id == id then      
                        MySQL.Async.execute("UPDATE horses SET `selected`='1' WHERE `identifier`=@identifier AND `id`=@id", {identifier = identifier, id = id}, function(done)                        
                            TriggerClientEvent("VP:HORSE:SetHorseInfo", _source, horse[i].model, horse[i].name, horse[i].components)
                            -- TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Horse selected')                  
                        end)            
                    end
                end
               
           
            end)
        end)        
    end
)

RegisterNetEvent("VP:STABLE:SellHorseWithId")
AddEventHandler(
    "VP:STABLE:SellHorseWithId",
    function(id)
        local modelHorse = nil
        local _source = source        
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")

            MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(horses)

                for i = 1, #horses do
                   if tonumber(horses[i].id) == tonumber(id) then
                        modelHorse = horses[i].model
                        MySQL.Async.fetchAll('DELETE FROM horses WHERE `identifier`=@identifier AND `charid`=@charid AND`id`=@id;', {identifier = identifier, charid = charid,  id = id}, function(result)
                        end)                   
                    end
                end

                for k,v in pairs(Config.Horses) do
                    for models,values in pairs(v) do
                        if models ~= "name" then                
                            if models == modelHorse then
                                user.addMoney(tonumber(values[3]*0.6))
                                print('horse sold')
                                -- TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Horse sold')
                            end
                        end
                    end
                end
            end)                           
        end)
    end
)
