cam = nil
hided = false
spawnedCamera = nil
choosePed = {}
pedSelected = nil
sex = nil
zoom = 4.0
offset = 0.2
DeleteeEntity = true

local InterP = true
local adding = true

local showroomHorse_entity
local showroomHorse_model

local MyHorse_entity
local IdMyHorse
cameraUsing = {
    {
        name = "Horse",
        x = 0.2,
        y = 0.0,
        z = 1.8
    },
    {
        name = "Olhos",
        x = 0.0,
        y = -0.4,
        z = 0.65
    }
}

local saddlecloths = {}
local acshorn = {}
local bags = {}
local horsetails = {}
local manes = {}
local saddles = {}
local stirrups = {}
local acsluggage = {}

Citizen.CreateThread(
    function()
        while adding do
            Citizen.Wait(0)
            for i, v in ipairs(HorseComp) do
                if v.category == "Saddlecloths" then
                    table.insert(saddlecloths, v.Hash)
                elseif v.category == "AcsHorn" then
                    table.insert(acshorn, v.Hash)
                elseif v.category == "Bags" then
                    table.insert(bags, v.Hash)
                elseif v.category == "HorseTails" then
                    table.insert(horsetails, v.Hash)
                elseif v.category == "Manes" then
                    table.insert(manes, v.Hash)
                elseif v.category == "Saddles" then
                    table.insert(saddles, v.Hash)
                elseif v.category == "Stirrups" then
                    table.insert(stirrups, v.Hash)
                elseif v.category == "AcsLuggage" then
                    table.insert(acsluggage, v.Hash)
                end
            end
            adding = false
        end
    end
)

RegisterCommand(
    "estabulo",
    function()
        OpenStable()
    end
)

function OpenStable()
    inCustomization = true
    horsesp = true

    local playerHorse = MyHorse_entity

    SetEntityHeading(playerHorse, 334)
    DeleteeEntity = true
    SetNuiFocus(true, true)
    InterP = true

    local hashm = GetEntityModel(playerHorse)

    if hashm ~= nil and IsPedOnMount(PlayerPedId()) then
        createCamera(PlayerPedId())
    else
        createCamera(PlayerPedId())
    end
    --  SetEntityVisible(PlayerPedId(), false)
    if not alreadySentShopData then
        SendNUIMessage(
            {
                action = "show",
                shopData = getShopData()
            }
        )
    else
        SendNUIMessage(
            {
                action = "show"
            }
        )
    end
    TriggerServerEvent("VP:STABLE:AskForMyHorses")
end

local promptGroup
local varStringCasa = CreateVarString(10, "LITERAL_STRING", "Estabulo")
local blip
local prompts = {}
local SpawnPoint = {}
local StablePoint = {}
local HeadingPoint
local CamPos = {}


Citizen.CreateThread(
    function()
        while true do
            Wait(1)
            local coords = GetEntityCoords(PlayerPedId())
            for _, prompt in pairs(prompts) do
                if PromptIsJustPressed(prompt) then
                    for k, v in pairs(Config.Stables) do
                        if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 7 then
                            HeadingPoint = v.Heading
                            StablePoint = {v.Pos.x, v.Pos.y, v.Pos.z}
                            CamPos = {v.SpawnPoint.CamPos.x, v.SpawnPoint.CamPos.y}
                            SpawnPoint = {x = v.SpawnPoint.Pos.x, y = v.SpawnPoint.Pos.y, z = v.SpawnPoint.Pos.z, h = v.SpawnPoint.Heading}
                            Wait(300)
                        end
                    end
                    OpenStable()
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        for _, v in pairs(Config.Stables) do
            -- blip = N_0x554d9d53f696d002(1664425300, v.Pos.x, v.Pos.y, v.Pos.z)
            SetBlipSprite(blip, -145868367, 1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Stable")
            local prompt = PromptRegisterBegin()
            PromptSetActiveGroupThisFrame(promptGroup, varStringCasa)
            PromptSetControlAction(prompt, 0xE8342FF2)
            PromptSetText(prompt, CreateVarString(10, "LITERAL_STRING", "Open Stable"))
            PromptSetStandardMode(prompt, true)
            PromptSetEnabled(prompt, 1)
            PromptSetVisible(prompt, 1)
            PromptSetHoldMode(prompt, 1)
            PromptSetPosition(prompt, v.Pos.x, v.Pos.y, v.Pos.z)
            N_0x0c718001b77ca468(prompt, 3.0)
            PromptSetGroup(prompt, promptGroup)
            PromptRegisterEnd(prompt)
            table.insert(prompts, prompt)
        end
    end
)

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if resourceName == GetCurrentResourceName() then
            for _, prompt in pairs(prompts) do
                PromptDelete(prompt)
                RemoveBlip(blip)
            end
        end
    end
)

-- function deletePrompt()
--     if prompt ~= nil then
--         PromptSetVisible(prompt, false)
--         PromptSetEnabled(prompt, false)
--         PromptDelete(prompt)
--         prompt = nil
--         promptGroup = nil
--     end
-- end

function rotation(dir)
    local playerHorse = MyHorse_entity
    local pedRot = GetEntityHeading(playerHorse) + dir
    SetEntityHeading(playerHorse, pedRot % 360)
end

RegisterNUICallback(
    "rotate",
    function(data, cb)
        if (data["key"] == "left") then
            rotation(20)
        else
            rotation(-20)
        end
        cb("ok")
    end
)

-- AddEventHandler(
--     'onResourceStop',
--     function(resourceName)
--         if resourceName == GetCurrentResourceName() then
--             for _, prompt in pairs(prompts) do
--                 PromptDelete(prompt)
-- 			end
--         end
--     end
-- )

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end
        SetNuiFocus(false, false)
        SendNUIMessage(
            {
                action = "hide"
            }
        )
    end
)

function createCam(creatorType)
    for k, v in pairs(cams) do
        if cams[k].type == creatorType then
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cams[k].x, cams[k].y, cams[k].z, cams[k].rx, cams[k].ry, cams[k].rz, cams[k].fov, false, 0) -- CAMERA COORDS
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 3000, true, false)
            createPeds()
        end
    end
end

RegisterNUICallback(
    "Saddles",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            SaddlesUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xBAA7E618, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. saddles[num])
            setcloth(hash)
            SaddlesUsing = ("0x" .. saddles[num])
        end
    end
)

RegisterNUICallback(
    "Saddlecloths",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            SaddleclothsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. saddlecloths[num])
            setcloth(hash)
            SaddleclothsUsing = ("0x" .. saddlecloths[num])
        end
    end
)

RegisterNUICallback(
    "Stirrups",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            StirrupsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xDA6DADCA, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. stirrups[num])
            setcloth(hash)
            StirrupsUsing = ("0x" .. stirrups[num])
        end
    end
)

RegisterNUICallback(
    "Bags",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            BagsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x80451C25, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. bags[num])
            setcloth(hash)
            BagsUsing = ("0x" .. bags[num])
        end
    end
)

RegisterNUICallback(
    "Manes",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            ManesUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xAA0217AB, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. manes[num])
            setcloth(hash)
            ManesUsing = ("0x" .. manes[num])
        end
    end
)

RegisterNUICallback(
    "HorseTails",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            HorseTailsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. horsetails[num])
            setcloth(hash)
            HorseTailsUsing = ("0x" .. horsetails[num])
        end
    end
)

RegisterNUICallback(
    "AcsHorn",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            AcsHornUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x5447332, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. acshorn[num])
            setcloth(hash)
            AcsHornUsing = ("0x" .. acshorn[num])
        end
    end
)

RegisterNUICallback(
    "AcsLuggage",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            AcsLuggageUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xEFB31921, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. acsluggage[num])
            setcloth(hash)
            AcsLuggageUsing = ("0x" .. acsluggage[num])
        end
    end
)

myHorses = {}

function setcloth(hash)
    local model2 = GetHashKey(tonumber(hash))
    if not HasModelLoaded(model2) then
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model2)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(hash), true, true, true)
end

RegisterNUICallback(
    "selectHorse",
    function(data)
        TriggerServerEvent("VP:STABLE:SelectHorseWithId", tonumber(data.horseID))
    end
)

RegisterNUICallback(
    "sellHorse",
    function(data)
        DeleteEntity(showroomHorse_entity)
        TriggerServerEvent("VP:STABLE:SellHorseWithId", tonumber(data.horseID))
        TriggerServerEvent("VP:STABLE:AskForMyHorses")
        alreadySentShopData = false
        Wait(300)

        SendNUIMessage(
            {
                action = "show",
                shopData = getShopData()
            }
        )
        TriggerServerEvent("VP:STABLE:AskForMyHorses")

    end
)



RegisterNetEvent("VP:STABLE:ReceiveHorsesData")
AddEventHandler(
    "VP:STABLE:ReceiveHorsesData",
    function(dataHorses)
        SendNUIMessage(
            {
                myHorsesData = dataHorses
            }
        )
    end
)


SaddlesUsing = nil
SaddleclothsUsing = nil
StirrupsUsing = nil
BagsUsing = nil
ManesUsing = nil
HorseTailsUsing = nil
AcsHornUsing = nil
AcsLuggageUsing = nil

--- /// ARRASTAR CAVALO

local alreadySentShopData = false



function getShopData()
    alreadySentShopData = true

    local ret = Config.Horses

    return ret
end


RegisterNUICallback(
    "loadHorse",
    function(data)
        local horseModel = data.horseModel

        if showroomHorse_model == horseModel then
            return
        end

        if MyHorse_entity ~= nil then
            DeleteEntity(MyHorse_entity)
            MyHorse_entity = nil
        end		

        local modelHash = GetHashKey(horseModel)

        if IsModelValid(modelHash) then
            if not HasModelLoaded(modelHash) then
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do
                    Citizen.Wait(10)
                end
            end
        end    

        if showroomHorse_entity ~= nil then    
            DeleteEntity(showroomHorse_entity)
            showroomHorse_entity = nil
        end

        showroomHorse_model = horseModel

        showroomHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
        Citizen.InvokeNative(0x283978A15512B2FE, showroomHorse_entity, true)
        Citizen.InvokeNative(0x58A850EAEE20FAA3, showroomHorse_entity)

        NetworkSetEntityInvisibleToNetwork(showroomHorse_entity, true)
        SetVehicleHasBeenOwnedByPlayer(showroomHorse_entity, true)

        -- SetModelAsNoLongerNeeded(modelHash)
		
        interpCamera("Horse", showroomHorse_entity)
    end
)


RegisterNUICallback(
    "loadMyHorse",
    function(data)
        local horseModel = data.horseModel
        IdMyHorse = data.IdHorse
		
        if showroomHorse_model == horseModel then
            return
        end

        if showroomHorse_entity ~= nil then
            DeleteEntity(showroomHorse_entity)
            showroomHorse_entity = nil
        end

        if MyHorse_entity ~= nil then
            DeleteEntity(MyHorse_entity)
            MyHorse_entity = nil
        end

        showroomHorse_model = horseModel

        local modelHash = GetHashKey(showroomHorse_model)

        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(10)
            end
        end

        MyHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
        Citizen.InvokeNative(0x283978A15512B2FE, MyHorse_entity, true)
        Citizen.InvokeNative(0x58A850EAEE20FAA3, MyHorse_entity)
        NetworkSetEntityInvisibleToNetwork(MyHorse_entity, true)
        SetVehicleHasBeenOwnedByPlayer(MyHorse_entity, true)
               

        local componentsHorse = json.decode(data.HorseComp)

        if componentsHorse ~= '[]' then
            for _, Key in pairs(componentsHorse) do
                local model2 = GetHashKey(tonumber(Key))
                if not HasModelLoaded(model2) then
                    Citizen.InvokeNative(0xFA28FE3A6246FC30, model2)
                end
                Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(Key), true, true, true)
            end
        end

        -- SetModelAsNoLongerNeeded(modelHash)

        interpCamera("Horse", MyHorse_entity)
    end
)

RegisterNetEvent('VP:STABLE:UpdadeHorseComponents')
AddEventHandler('VP:STABLE:UpdadeHorseComponents', function(horseEntity, components)
    for _, value in pairs(components) do
        NativeSetPedComponentEnabled(horseEntity, value)
    end
end)

RegisterNUICallback(
    "BuyHorse",
    function(data)
        SetHorseName(data)

        
    end
)

function SetHorseName(data)

        
    SetNuiFocus(false, false)
    SendNUIMessage(
        {
            action = "hide"
        }
    )

    Wait(200)
   
    local HorseName = ""

	Citizen.CreateThread(function()
		AddTextEntry('FMMC_MPM_NA', "Name your horse:")
		DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
		while (UpdateOnscreenKeyboard() == 0) do
			DisableAllControlActions(0);
			Citizen.Wait(0);
		end
		if (GetOnscreenKeyboardResult()) then
            HorseName = GetOnscreenKeyboardResult()
            TriggerServerEvent('VP:STABLE:BuyHorse', data, HorseName)


            SetNuiFocus(true, true)
            SendNUIMessage(
            {
                action = "show",
                shopData = getShopData()
            }
        )

        Wait(1000)

        TriggerServerEvent("VP:STABLE:AskForMyHorses") 
		end	
    end)
    
end

RegisterNUICallback(
    "CloseStable",
    function()
        SetNuiFocus(false, false)
        SendNUIMessage(
            {
                action = "hide"
            }
        )
        SetEntityVisible(PlayerPedId(), true)

        showroomHorse_model = nil

        if showroomHorse_entity ~= nil then
            DeleteEntity(showroomHorse_entity)
        end

        if MyHorse_entity ~= nil then
            DeleteEntity(MyHorse_entity)
        end

        DestroyAllCams(true)
        showroomHorse_entity = nil
        CloseStable()
    end
)

function CloseStable()
        local dados = {
            -- ['saddles'] = SaddlesUsing,
            -- ['saddlescloths'] = SaddleclothsUsing,
            -- ['stirrups'] = StirrupsUsing,
            -- ['bags'] = BagsUsing,
            -- ['manes'] = ManesUsing,
            -- ['horsetails'] = HorseTailsUsing,
            -- ['acshorn'] = AcsHornUsing,
            -- ['ascluggage'] = AcsLuggageUsing
            SaddlesUsing,
            SaddleclothsUsing,
            StirrupsUsing,
            BagsUsing,
            ManesUsing,
            HorseTailsUsing,
            AcsHornUsing,
            AcsLuggageUsing
        }
        local DadosEncoded = json.encode(dados)

        if DadosEncoded ~= "[]" then            
            TriggerServerEvent("VP:STABLE:UpdateHorseComponents", dados, IdMyHorse, MyHorse_entity ) 
        end

       
end

Citizen.CreateThread(
    function()
       while true do
        Citizen.Wait(100)
            if MyHorse_entity ~= nil then
                SendNUIMessage(
                    {
                        EnableCustom = "true"
                    }
                )
            else
                SendNUIMessage(
                    {
                        EnableCustom = "false"
                    }
                )
            end
       end
    end
)

local SpawnplayerHorse = 0

local horseModel
local horseName
local horseComponents = {}

local initializing = false

function SetHorseInfo(horse_model, horse_name, horse_components)
    horseModel = horse_model
    horseName = horse_name
    horseComponents = horse_components
end

function NativeSetPedComponentEnabled(ped, component)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, component, true, true, true)
end

RegisterNetEvent("VP:HORSE:SetHorseInfo")
AddEventHandler("VP:HORSE:SetHorseInfo", SetHorseInfo)

function InitiateHorse(atCoords)
    if initializing then
        return
    end

    initializing = true

    if horseModel == nil and horseName == nil then
        TriggerServerEvent("VP:HORSE:RequestMyHorseInfo")

        local timeoutatgametimer = GetGameTimer() + (3 * 1000)

        while horseModel == nil and timeoutatgametimer > GetGameTimer() do
            Citizen.Wait(0)
        end

        if horseModel == nil and horseName == nil then
            horseModel = "A_C_Horse_MP_Mangy_Backup"
            horseName = "Pangaré"
            horseComponents = nil
        end
    end

    if SpawnplayerHorse ~= 0 then
        DeleteEntity(SpawnplayerHorse)
        SpawnplayerHorse = 0
    end

    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    local modelHash = GetHashKey(horseModel)

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end

    local spawnPosition

    if atCoords == nil then
        local x, y, z = table.unpack(pCoords)
        local bool, nodePosition = GetClosestVehicleNode(x, y, z, 1, 3.0, 0.0)

        local index = 0
        while index <= 25 do
            local _bool, _nodePosition = GetNthClosestVehicleNode(x, y, z, index, 1, 3.0, 2.5)
            if _bool == true or _bool == 1 then
                bool = _bool
                nodePosition = _nodePosition
                index = index + 3
            else
                break
            end
        end

        spawnPosition = nodePosition
    else
        spawnPosition = atCoords
    end

    if spawnPosition == nil then
        initializing = false
        return
    end

    local entity = CreatePed(modelHash, spawnPosition, GetEntityHeading(ped), true, true)
    SetModelAsNoLongerNeeded(modelHash)

    Citizen.InvokeNative(0x9587913B9E772D29, entity, 0)
    Citizen.InvokeNative(0x4DB9D03AC4E1FA84, entity, -1, -1, 0)
    Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, entity)
    Citizen.InvokeNative(0xBCC76708E5677E1D9, entity, 0)
    Citizen.InvokeNative(0xB8B6430EAD2D2437, entity, GetHashKey("PLAYER_HORSE"))
    Citizen.InvokeNative(0xFD6943B6DF77E449, entity, false)

    SetPedConfigFlag(entity, 324, true)
    SetPedConfigFlag(entity, 211, true)
    SetPedConfigFlag(entity, 208, true)
    SetPedConfigFlag(entity, 209, true)
    SetPedConfigFlag(entity, 400, true)
    SetPedConfigFlag(entity, 297, true)
    SetPedConfigFlag(entity, 136, false)
    SetPedConfigFlag(entity, 312, false)
    SetPedConfigFlag(entity, 113, false)
    SetPedConfigFlag(entity, 301, false)
    SetPedConfigFlag(entity, 277, true)
    SetPedConfigFlag(entity, 319, true)
    SetPedConfigFlag(entity, 6, true)

    SetAnimalTuningBoolParam(entity, 25, false)
    SetAnimalTuningBoolParam(entity, 24, false)

    TaskAnimalUnalerted(entity, -1, false, 0, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)

    SpawnplayerHorse = entity

    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)

    -- SetVehicleHasBeenOwnedByPlayer(playerHorse, true)
    SetPedNameDebug(entity, horseName)
    SetPedPromptName(entity, horseName)

    --CreatePrompts(PromptGetGroupIdForTargetEntity(entity))

    if horseComponents ~= nil and horseComponents ~= "0" then
        for _, componentHash in pairs(json.decode(horseComponents)) do
            NativeSetPedComponentEnabled(entity, tonumber(componentHash))
        end
    end

    if horseModel == "A_C_Horse_MP_Mangy_Backup" then     
        NativeSetPedComponentEnabled(entity, 0x106961A8) --sela
        NativeSetPedComponentEnabled(entity, 0x508B80B9) --blanket
    end

    TaskGoToEntity(entity, ped, -1, 7.2, 2.0, 0, 0)

    SetPedConfigFlag(entity, 297, true) -- Enable_Horse_Leadin

    initializing = false
end

function WhistleHorse()
    if SpawnplayerHorse ~= 0 then
        if GetScriptTaskStatus(SpawnplayerHorse, 0x4924437D, 0) ~= 0 then
            local pcoords = GetEntityCoords(PlayerPedId())
            local hcoords = GetEntityCoords(SpawnplayerHorse)
            local caldist = Vdist(pcoords.x, pcoords.y, pcoords.z, hcoords.x, hcoords.y, hcoords.z)
            if caldist >= 100 then
                DeleteEntity(SpawnplayerHorse)
                Wait(1000)
                SpawnplayerHorse = 0
            else
                TaskGoToEntity(SpawnplayerHorse, PlayerPedId(), -1, 7.2, 2.0, 0, 0)
            end
        end   
    else
        TriggerServerEvent('VP:STABLE:CheckSelectedHorse')
        Wait(100)
        InitiateHorse()
    end
end

function fleeHorse(playerHorse)
    TaskAnimalFlee(SpawnplayerHorse, PlayerPedId(), -1)
    Wait(5000)
    DeleteEntity(SpawnplayerHorse)    
    Wait(1000)
    SpawnplayerHorse = 0
end

Citizen.CreateThread(function()
	while true do
		local getHorseMood = Citizen.InvokeNative(0x42688E94E96FD9B4, SpawnplayerHorse, 3, 0, Citizen.ResultAsFloat())
		if getHorseMood >= 0.60 then
		Citizen.InvokeNative(0x06D26A96CA1BCA75, SpawnplayerHorse, 3, PlayerPedId())
		Citizen.InvokeNative(0xA1EB5D029E0191D3, SpawnplayerHorse, 3, 0.99)
		end
		Citizen.Wait(30000)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x24978A28) then -- Control =  H
			WhistleHorse()
			Citizen.Wait(10000) --Flood Protection? i think yes zoot
        end
		
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x4216AF06) then -- Control = Horse Flee            
         --   local horseCheck = Citizen.InvokeNative(0x7912F7FC4F6264B6, PlayerPedId(), myHorse[4])            
			if SpawnplayerHorse ~= 0 then
				fleeHorse(SpawnplayerHorse)
			end
		end		
    end    
end)

function interpCamera(cameraName, entity)
    for k, v in pairs(cameraUsing) do
        if cameraUsing[k].name == cameraName then
            tempCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
            AttachCamToEntity(tempCam, entity, cameraUsing[k].x + CamPos[1], cameraUsing[k].y + CamPos[2], cameraUsing[k].z)
            SetCamActive(tempCam, true)
            SetCamRot(tempCam, -30.0, 0, HeadingPoint + 50.0)
            if InterP then
                SetCamActiveWithInterp(tempCam, fixedCam, 1200, true, true)
                InterP = false
            end
        end
    end
end

function createCamera(entity)
    groundCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(groundCam, StablePoint[1] + 0.5, StablePoint[2] - 3.6, StablePoint[3] )
    SetCamRot(groundCam, -20.0, 0.0, HeadingPoint + 20)
    SetCamActive(groundCam, true)
    RenderScriptCams(true, false, 1, true, true)
    --Wait(3000)
    -- last camera, create interpolate
    fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(fixedCam, StablePoint[1] + 0.5, StablePoint[2] - 3.6, StablePoint[3] +1.8)
    SetCamRot(fixedCam, -20.0, 0, HeadingPoint + 50.0)
    SetCamActive(fixedCam, true)
    SetCamActiveWithInterp(fixedCam, groundCam, 3900, true, true)
    Wait(3900)
    DestroyCam(groundCam)
end

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if GetCurrentResourceName() == resourceName then
            DeleteEntity(SpawnplayerHorse)
            SpawnplayerHorse = 0
        end
    end
)

