-- ✉️ Insert your Discord webhook URL here

ESX = exports["es_extended"]:getSharedObject()
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1121137503248855050/r3hxGk2ucXDN_KbcQAFLT2-5o-tIYhPfcbJ9mxo5Hb_pF0wPcGG7ABLwaGJ4olR8KxBu"

function sendRentalLogToDiscord(playerName, identifier, vehicleModel, plate, price)
    local time = os.date("%Y-%m-%d %H:%M:%S")

    local embed = {
        {
            ["color"] = 16776960,
            ["title"] = "🚗 Vehicle Rented",
            ["description"] = string.format(
                "**Player:** %s\n**Identifier:** %s\n**Vehicle:** %s\n**Plate:** %s\n**Price:** $%s\n**Timestamp:** %s",
                playerName, identifier, vehicleModel, plate, price, time
            ),
            ["footer"] = { ["text"] = "ys_carrental Logs" }
        }
    }

    PerformHttpRequest(DISCORD_WEBHOOK, function() end, 'POST', json.encode({
        username = "Car Rental",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback("ys_carrental:tryPayment", function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false)
        return
    end

    local bank = xPlayer.getAccount("bank").money

    if bank >= amount then
        xPlayer.removeAccountMoney("bank", amount)

        sendRentalLogToDiscord(
            xPlayer.getName(),
            xPlayer.getIdentifier(),
            Config.VehicleModel or "Unknown",
            Config.PlateText or "UNKNOWN",
            amount
        )

        cb(true)
    else
        cb(false)
    end
end)
