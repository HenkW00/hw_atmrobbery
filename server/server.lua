local webhookUrl = Config.DiscordWebhookUrl

function sendDiscordMessage(embed)
    local payload = json.encode({embeds = {embed}})
    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', payload, {['Content-Type'] = 'application/json'})
end

function createEmbed(title, description, color, footer)
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = {
                ["text"] = footer
            }
        }
    }
    return embed
end

local nextrobATM = 0
local mincops = OptionsATM.mincops
local inventory = OptionsATM.inventory
local item = OptionsATM.item
local RobberyCooldown = OptionsATM.RobberyCooldown

local function SetnextrobATM()
    nextrobATM = GetGameTimer() + RobberyCooldown
end

RegisterServerEvent('hw_atmrobbery:onrobatm')
AddEventHandler('hw_atmrobbery:onrobatm', function(coordP, act, coordatm)
    local xPlayer = ESX.GetPlayerFromId(source)
    if inventory == 'oxinventory' then
        card = exports.ox_inventory:GetItem(source, item, nil, false)
    elseif inventory == 'default' then
        card = xPlayer.getInventoryItem(item)
    end
    local copsOnline = ESX.GetExtendedPlayers('job', 'police')
    if #copsOnline >= mincops then
        if nextrobATM ~= 0 then
            if GetGameTimer() < nextrobATM then
                TriggerClientEvent('hw_atmrobbery:msgnottimer', xPlayer.source)
            end
            if GetGameTimer() > nextrobATM then
                if card and card.count > 0 then
                    SetnextrobATM()
                    TriggerClientEvent('hw_atmrobbery:robstateatm', xPlayer.source)
                    Citizen.Wait(300)
                    TriggerClientEvent('hw_atmrobbery:actionsatm', xPlayer.source, act, coordatm)
                    Citizen.Wait(500)
                    for j=1, #copsOnline, 1 do
                        local xPlayerx = copsOnline[j]
                        TriggerClientEvent('hw_atmrobbery:msgpolice', xPlayerx.source, coordP)
                    end
                    if act == 'hack' then
                        if inventory == 'oxinventory' then
                            exports.ox_inventory:RemoveItem(xPlayer.source, item, 1)
                        elseif inventory == 'default' then
                            xPlayer.removeInventoryItem(item, 1)
                        end
                        local embed = createEmbed("ATM Hacking Started", xPlayer.getName() .. ' has started hacking an ATM.', 16776960, "HW Scripts | Logs")
                        sendDiscordMessage(embed)

                        if Config.Debug then
                            print("^7[^1DEBUG^7] Player triggered ATM hack!")
                        end

                    end
                else
                    TriggerClientEvent('hw_atmrobbery:msgnocard', xPlayer.source)
                end
            end
        end
        if nextrobATM == 0 then
            if card and card.count > 0 then
                TriggerClientEvent('hw_atmrobbery:robstateatm', xPlayer.source)
                SetnextrobATM()
                Citizen.Wait(300)
                TriggerClientEvent('hw_atmrobbery:actionsatm', xPlayer.source, act, coordatm)
                Citizen.Wait(500)
                for j=1, #copsOnline, 1 do
                    local xPlayerx = copsOnline[j]
                    TriggerClientEvent('hw_atmrobbery:msgpolice', xPlayerx.source, coordP)
                end
                if act == 'hack' then
                    if inventory == 'oxinventory' then
                        exports.ox_inventory:RemoveItem(xPlayer.source, item, 1)
                    elseif inventory == 'default' then
                        xPlayer.removeInventoryItem(item, 1)
                    end
                    local embed = createEmbed("ATM Hacking Started", xPlayer.getName() .. ' has started hacking an ATM.', 16776960, "HW Scripts | Logs")
                    sendDiscordMessage(embed)

                    if Config.Debug then
                        print("^7[^1DEBUG^7] Player triggered ATM hack!")
                    end

                end
            else
                TriggerClientEvent('hw_atmrobbery:msgnocard', xPlayer.source)
            end
        end
    else
        TriggerClientEvent('hw_atmrobbery:msgnocops', xPlayer.source)
    end
end)

RegisterNetEvent('hw_atmrobbery:lootmoney_s')
AddEventHandler('hw_atmrobbery:lootmoney_s', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local stolemoney = math.random(35215, 45125)
    xPlayer.addAccountMoney('black_money', stolemoney)
    TriggerClientEvent('hw_atmrobbery:msglootmoney', xPlayer.source, stolemoney)
    local embed = createEmbed("ATM Money Received", xPlayer.getName() .. ' has received $' .. stolemoney .. ' from an ATM.', 65280, "HW Scripts | Logs")
    sendDiscordMessage(embed)

    if Config.Debug then
        print("^7[^1DEBUG^7] Player received money from ATM robbery!")
    end

end)

RegisterNetEvent('hw_atmrobbery:tracking_s')
AddEventHandler('hw_atmrobbery:tracking_s', function(coordsPt)
    local xPlayer = ESX.GetPlayerFromId(source)
    local trackingMessage = xPlayer.getName() .. ' is being tracked at coordinates: ' .. json.encode(coordsPt)
    local embed = createEmbed("Player Tracking", trackingMessage, 3447003, "HW Scripts | Logs")
    sendDiscordMessage(embed)
    trackingP(coordsPt)

    if Config.Debug then
        print("^7[^1DEBUG^7] Player tracking active!")
    end

end)
