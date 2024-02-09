------------------------------------- ** configurable Options ** ----------------------------------------
OptionsATM = {}
Config = {}
OptionsATM.inventory = 'default'					-- configure here the invenotry use (oxinventory | default)
OptionsATM.props = 	921401054					        -- model props
OptionsATM.delaynotify = math.random(5000, 10000)	    -- delay in ms for the cops notify appears for them
OptionsATM.delayblip = 15000							-- delay in ms for the cops blip
OptionsATM.hacktime = 35000							    -- time in ms to hack the atm
OptionsATM.stealtime = 55000							-- time in ms to steal money in the atm
OptionsATM.RobberyCooldown = 1800000                    -- configure the cooldown in ms between 2 atmrobbery  
OptionsATM.mincops = 0                                  -- configure the minimum count of police to start the robbery
OptionsATM.tracking = true                              -- configure if the player is tracking at the end of the robbery
OptionsATM.trackingtime = 60000                         -- configure in ms how much time the player in tracking
OptionsATM.trackinginterval = 6000                      -- configure in ms the interval between 2 blips
OptionsATM.item = 'hacking_laptop'                      -- configure item needed to hack the atm

Config.DiscordWebhookUrl = "https://discord.com/api/webhooks/1203754429275308094/VpkbnodJawtd3Sm1KJb-pK2Z7jIljmg4xayLi7FbKpZLmMWkAhIzUao-1Gx-EIRBEozT"          -- configure webhook for ATM logging

Config.Debug = true                                     -- configure debug mode "true" or "false"

------------------------------------** end configurable Options **---------------------------------------

--------------------------------------------------------------------------------------------------------
------------------------------------- ** DON'T MODIFY CODE BELOW ** ------------------------------------
--------------------------------------------------------------------------------------------------------

local props = OptionsATM.props
local hacktimer = OptionsATM.hacktime
local stealtimer = OptionsATM.stealtime

----------------------------- ** init function ** ---------------------------
function initrobatm()
    Citizen.CreateThread(function()
        -- you can modify / add jobs here --
        local jobs = {
            {name = 'police'},          -- Politie 
        }
        for a = 1, #jobs, 1 do
            local jobsname = jobs[a].name
            if ESX.PlayerData.job.name ~= jobsname then     -- test on jobname
                exports.qtarget:AddTargetModel({-1364697528, 506770882, -870868698, -1126237515}, {
                    options = {
                        {
                            icon = "fas fa-box-circle-check",
                            label = locale('hack_atm'),
                            action = function(entity)
                                local act = 'hack'
                                local coordatm = GetEntityCoords(entity)
                                TriggerEvent('hw_atmrobbery:dispatchatm', act, coordatm)
                            end,
                        },
                        {
                            icon = "fas fa-box-circle-check",
                            label = locale('steal_money'),
                            action = function(entity)
                                local act = 'steal'
                                local coordatm = GetEntityCoords(entity)
                                TriggerEvent('hw_atmrobbery:dispatchatm', act, coordatm)
                            end,
                        },
                    },
                    distance = 1.5
                })	
            else
                return										-- return if the player's job is in local jobs
            end
        end
    end)
end
------------------- ** tracking function ** --------------------
function trackingP(coordPt)
    local copsOnline = ESX.GetExtendedPlayers('job', 'police')
    for k=1, #copsOnline, 1 do
        local xPlayerx = copsOnline[k]
        TriggerClientEvent('hw_atmrobbery:bliptracking', xPlayerx.source, coordPt)
    end
end

------------------- ** steal animation ** --------------------
function stealanimation()
    FreezeEntityPosition(ped, true)
    loaddict('anim@heists@prison_heistig1_p1_guard_checks_bus')
    Citizen.Wait(500)
    TriggerEvent('hw_atmrobbery:progresssteal')
    playerAnim(PlayerPedId(), 'anim@heists@prison_heistig1_p1_guard_checks_bus', 'loop')
    Citizen.Wait(stealtimer)
end
------------------- ** hack animation ** --------------------
function hackanimation(coordatm)
    loadmodel('p_ld_id_card_01')
    local ped = PlayerPedId()
    local pedco = GetEntityCoords(PlayerPedId())
    IdProp = CreateObject(GetHashKey('p_ld_id_card_01'), pedco, 1, 1, 0)
    local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
    AttachEntityToEntity(IdProp, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_ATM', 0, true)
    Citizen.Wait(1500)
    DetachEntity(IdProp, false, false)
    DeleteEntity(IdProp)
    Wait(6000)
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(ped, true)
    loaddict('amb@world_human_tourist_map@male@base')
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
	prop = CreateObject(props, x, y, z, true, true, true)
	AttachEntityToEntity(prop, PlayerPedId(), boneIndex, 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)
    Citizen.Wait(500)
    PlaySoundFromEntity(scansound, 'SCAN', prop, 'EPSILONISM_04_SOUNDSET', true, 0)
    TriggerEvent('hw_atmrobbery:progresshack')
    playerAnim(PlayerPedId(), 'amb@world_human_tourist_map@male@base', 'base')
    Citizen.Wait(hacktimer)
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(ped, false)
    DeleteObject(prop)
    StopSound(scansound)
end
------------------- ** loadmodel ** --------------------
function loadmodel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
end
------------------- ** loadanimdict ** --------------------
function loaddict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end
------------------- ** playanim ** --------------------
function playerAnim(ped, animDictionary, animationName)
    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
        loaddict(animDictionary)
        TaskPlayAnim(ped, animDictionary, animationName, 1.0, -1.0, -1, 1, 1, true, true, true)
    end
end
------------------- ** round ** --------------------
function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end