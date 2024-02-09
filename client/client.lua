local robstateatm = false
local hacked = false
local norob = true
local atm1 = {}
local atm2 = {}
local checkatm = false
local alarm = false
local alarmsound = GetSoundId()
scansound = GetSoundId()
local delaynotify = OptionsATM.delaynotify
local delayblip = OptionsATM.delayblip
local RobberyCooldown = OptionsATM.RobberyCooldown
local hacktime = OptionsATM.hacktime
local stealtime = OptionsATM.stealtime
local track = OptionsATM.tracking
local tracktimer = OptionsATM.trackingtime
local interval = OptionsATM.trackinginterval

lib.locale()							-- start ox_lib locale translations

DeleteObject(props)						-- delete props if script is restarting for example

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	Citizen.Wait(1000)
	initrobatm()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

--------------------------------------------------------------------------
------------------------------- dispatchatm ---------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('hw_atmrobbery:dispatchatm')
AddEventHandler('hw_atmrobbery:dispatchatm', function(act, coordatm)
    local coord = GetEntityCoords(PlayerPedId(), true)
    local zonesnorob1 = {name = 'sandyshore', coordZ = vector3(1270.46, 3359.40, 46.89), radiusZ = 800.0,}
    local zonesnorob2 = {name = 'paleto', coordZ = vector3(852.12, 6505.71, 22.15), radiusZ = 1300.0,}
    local zonesnorob3 = {name = 'chumach', coordZ = vector3(-3129.04, 765.09, 10.43), radiusZ = 500.0,}
    local zonesnorob4 = {name = 'tataviam', coordZ = vector3(2545.14, 339.03, 108.46), radiusZ = 800.0,}
    local distatm1 = #(coordatm - zonesnorob1.coordZ)
    local distatm2 = #(coordatm - zonesnorob2.coordZ)
    local distatm3 = #(coordatm - zonesnorob3.coordZ)
    local distatm4 = #(coordatm - zonesnorob4.coordZ)
    if distatm1 > zonesnorob1.radiusZ and distatm2 > zonesnorob2.radiusZ and distatm3 > zonesnorob3.radiusZ and distatm4 > zonesnorob4.radiusZ then
        norob = false
    end
    if distatm1 < zonesnorob1.radiusZ or distatm2 < zonesnorob2.radiusZ or distatm3 < zonesnorob3.radiusZ or distatm4 < zonesnorob4.radiusZ then
        TriggerEvent('hw_atmrobbery:msgnorob')
        norob = true
    end
    if not robstateatm and not norob then  
        TriggerServerEvent('hw_atmrobbery:onrobatm', coord, act, coordatm)
    end
    if robstateatm and not norob then
        TriggerEvent('hw_atmrobbery:actionsatm', act, coordatm)
    end 
end)

--------------------------------------------------------------------------
-------------------------- State robstateatm -----------------------------
--------------------------------------------------------------------------
RegisterNetEvent('hw_atmrobbery:robstateatm')
AddEventHandler('hw_atmrobbery:robstateatm', function()
	robstateatm = true
    Citizen.Wait(RobberyCooldown)
    robstateatm = false
	hacked = false
	stole = false
    checkatm = false
end)

--------------------------------------------------------------------------
------------------------------- actionsatm -------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('hw_atmrobbery:actionsatm')
AddEventHandler('hw_atmrobbery:actionsatm', function(act, coordatm)
    TriggerEvent('hw_atmrobbery:checkatm', act, coordatm)
    Citizen.Wait(500)
    if act == 'hack' and hacked then
		TriggerEvent('hw_atmrobbery:msgalreadyhack')
    elseif act == 'hack' and not hacked then
		hackanimation(coordatm)
        hacked = true
        TriggerEvent('hw_atmrobbery:alarm', coordatm)
	end
    if act == 'steal' and not hacked then
		TriggerEvent('hw_atmrobbery:msghackfirst')
	elseif act == 'steal' and stole then
		TriggerEvent('hw_atmrobbery:msgalreadystole')
    elseif act == 'steal' and not stole and checkatm then
        stole = true
        stealanimation()
		TriggerServerEvent('hw_atmrobbery:lootmoney_s')
	end
end)

--------------------------------------------------------------------------
------------------------------- alarm -------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('hw_atmrobbery:alarm')
AddEventHandler('hw_atmrobbery:alarm', function(coordatm)
    PlaySoundFromCoord(alarmsound, "VEHICLES_HORNS_AMBULANCE_WARNING", coordatm.x, coordatm.y, coordatm.z, '', true, 1, false ) 
    Citizen.Wait(60000)
    StopSound(alarmsound)
end)

--------------------------------------------------------------------------
------------------------------- checkatm ---------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('hw_atmrobbery:checkatm')
AddEventHandler('hw_atmrobbery:checkatm', function(act, coordatm)
    if act == 'hack' and hacked then return end
    if act == 'hack' and not hacked then atm1 = coordatm end
    if act == 'steal' and stole then return end
    if act == 'steal' and not stole and not hacked then return end
    if act == 'steal' and  not stole and hacked then 
        atm2 = coordatm
        if atm1 == atm2 then
            checkatm = true
        else
            checkatm = false
            TriggerEvent('hw_atmrobbery:msgnoglitch')
        end
    end
end)

--------------------------------------------------------------------------
------------------------------- tracking ---------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('hw_atmrobbery:tracking_c')
AddEventHandler('hw_atmrobbery:tracking_c', function()
    while true do
        if GetGameTimer() <= trackingtimer then
            local coordsPt = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('hw_atmrobbery:tracking_s', coordsPt)
            Citizen.Wait(interval)    
        else
            RemoveBlip(BlipT)
            break
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('hw_atmrobbery:bliptracking')
AddEventHandler('hw_atmrobbery:bliptracking', function(coordsPt)
    if BlipT then
        SetBlipCoords(BlipT, coordsPt.x, coordsPt.y, coordsPt.z)
    else
    BlipT = AddBlipForCoord(coordsPt.x,coordsPt.y,coordsPt.z)
    SetBlipSprite(BlipT,  1)
    SetBlipColour(BlipT,  1)
    SetBlipAlpha(BlipT,  250)
    SetBlipDisplay(BlipT, 4)
    SetBlipScale(BlipT, 0.6)
    SetBlipFlashes(BlipT, true)
    SetBlipAsShortRange(BlipT,  true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Robber tracking')
    EndTextCommandSetBlipName(BlipT)
    end
end)

--------------------------------------------------------------------------
-------------------------- progress hack ---------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:progresshack')
AddEventHandler('hw_atmrobbery:progresshack', function()
    ------------------**notification**----------------------
    lib.progressCircle({
        duration = hacktime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })
    ------------------**fin notification**-----------------
    TriggerEvent('hw_atmrobbery:msghacksuccess')
end)

--------------------------------------------------------------------------
-------------------------- progress steal --------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:progresssteal')
AddEventHandler('hw_atmrobbery:progresssteal', function()
    ------------------**notification**----------------------
    lib.progressCircle({
        duration = stealtime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })
    ------------------**fin notification**-----------------
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    PlaySound(-1, 'ROBBERY_MONEY_TOTAL', 'HUD_FRONTEND_CUSTOM_SOUNDSET', 0, 0, 1)
    TriggerEvent('hw_atmrobbery:msgstealsuccess')
    if track then
        trackingtimer = GetGameTimer() + tracktimer
        TriggerEvent('hw_atmrobbery:tracking_c')    
    end
end)

--------------------------------------------------------------------------
-------------------------- msg noglitch--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:msgnoglitch')
AddEventHandler('hw_atmrobbery:msgnoglitch', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_glitch'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(10000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg norob--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:msgnorob')
AddEventHandler('hw_atmrobbery:msgnorob', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_robhere'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(10000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg nocard--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:msgnocard')
AddEventHandler('hw_atmrobbery:msgnocard', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_card'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg hackfirst ---------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:msghackfirst')
AddEventHandler('hw_atmrobbery:msghackfirst', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('hack_first'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg alreadyhack -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:msgalreadyhack')
AddEventHandler('hw_atmrobbery:msgalreadyhack', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('already_hack'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg alreadystole -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:msgalreadystole')
AddEventHandler('hw_atmrobbery:msgalreadystole', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('already_stole'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg steal--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("hw_atmrobbery:msglootmoney_c")
AddEventHandler("hw_atmrobbery:msglootmoney_c", function(count)
    ------------------**notification**----------------------
    lib.showTextUI(locale('stole')..count..' $', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg hacksuccess -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("hw_atmrobbery:msghacksuccess")
AddEventHandler("hw_atmrobbery:msghacksuccess", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('hack_success'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg stealsuccess -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("hw_atmrobbery:msgstealsuccess")
AddEventHandler("hw_atmrobbery:msgstealsuccess", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('steal_success'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------ msg timer --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("hw_atmrobbery:msgnottimer")
AddEventHandler("hw_atmrobbery:msgnottimer", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('robbing_inprogress'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------ msg nbcops -------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:msgnocops")
AddEventHandler("toffleeca:msgnocops", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_cops') {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------- msg LSPD --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("hw_atmrobbery:msgpolice")
AddEventHandler("hw_atmrobbery:msgpolice", function(coordsP)
    ------------------**notification**----------------------
    lib.showTextUI(locale('alarm_notify'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = 'red',
            color = 'white'
        }
    })
    Citizen.Wait(30000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
	Citizen.Wait(delaynotify)
    TriggerEvent('hw_atmrobbery:blipPolice', coordsP)
end)

-------------------------------------------------------------------------
------------------------ blip LSPD --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent('hw_atmrobbery:blipPolice')
AddEventHandler('hw_atmrobbery:blipPolice', function(coordsP)
    Blip = AddBlipForCoord(coordsP.x,coordsP.y,coordsP.z)
    SetBlipSprite(Blip,  500)
    SetBlipColour(Blip,  1)
    SetBlipAlpha(Blip,  250)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 1.2)
    SetBlipFlashes(Blip, true)
    SetBlipAsShortRange(Blip,  true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('ATM Robbery')
    EndTextCommandSetBlipName(Blip)
    Wait(delayblip)
    RemoveBlip(Blip)
end)

-------------------------- Command dev ------------------------------------

RegisterCommand('robatm', function(source, args, rawCommand)
    initrobatm()
end)