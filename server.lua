local SelectedHorseId = {}


RegisterNetEvent("VP:STABLE:UpdateHorseComponents")
AddEventHandler(
    "VP:STABLE:UpdateHorseComponents",
    function(components, idhorse)
        local _source = source

        local encodedComponents = json.encode(components)        
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
   
            MySQL.Async.execute("UPDATE horses SET `components`='".. encodedComponents .."' WHERE `identifier`=@identifier AND `id`=@id", {identifier = identifier, id = id}, function(done)
                print('components changed')
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

RegisterNetEvent("VP:STABLE:BuyHorse")
AddEventHandler(
    "VP:STABLE:BuyHorse",
    function(data, name)
        local _source = source
        local Horses = {}

        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
            MySQL.Async.fetchAll('SELECT * FROM horses WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(horses)
                Horses = horses
            end) 

            if #Horses >= 3 then
                print('Stable limit')
                --TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Limite de estabulo alcançado!', 5000)
                return
            end

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
                if horse.id == id then            
                    MySQL.Async.execute("UPDATE horses SET `selected`='1' WHERE `identifier`=@identifier AND `id`=@id", {identifier = identifier, id = id}, function(done)  
                        print('Horse Selected')
                        TriggerClientEvent("VP:HORSE:SetHorseInfo", _source, horse.model, horse.name, horse.components)
                        -- TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Horse selected')
                    end)                    
                else
                    MySQL.Async.execute("UPDATE horses SET `selected`='0' WHERE `identifier`=@identifier AND `id`=@id", {identifier = identifier, id = id}, function(done)
                
                    end)
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
                if horses.id == id then             
                    modelHorse = horses.model
                    MySQL.Async.fetchAll('DELETE FROM outfits WHERE `identifier`=@identifier AND `charid`=@charid AND`id`=@id;', {identifier = identifier, charid = charid,  id = id}, function(result)
                    end)

                    for i, table in pairs(Config.Horses) do
                        for modelH, horseData in pairs(table) do
                            if modelH == horses.model then
                                print(tonumber(horseData[3]*0.6))                                
                            --    user.addMoney(tonumber(horseData[3]*0.6)
                                print('Horse Sold')
                            end
                        end
                    end                  


                else
                    print('error')
                    return
                end
                --    TriggerClientEvent('VP:NOTIFY:Simple', _source, 'Horse sold')
            end)
        end)
    end
)

