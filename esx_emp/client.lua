local empActive = false

-- kleine Hilfsfunktion für Meldungen
local function Notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

CreateThread(function()
    while true do
        Wait(500) -- öfter prüfen
        local player = PlayerPedId()
        local veh = GetVehiclePedIsIn(player, false)

        if veh ~= 0 and (GetPedInVehicleSeat(veh, -1) == player) then
            if IsThisModelAPlane(GetEntityModel(veh)) or IsThisModelAHeli(GetEntityModel(veh)) then
                local coords = GetEntityCoords(player)
                local inZone = false

                for _, zone in pairs(Config.EMPZones) do
                    if #(coords - zone.coords) < zone.radius then
                        inZone = true
                        break
                    end
                end

                if inZone then
                    if not empActive then
                        empActive = true
                        Notify(Config.Locale.emp_triggered)
                    end
                    -- Motor immer wieder killen
                    SetVehicleEngineOn(veh, false, true, true)
                    SetVehicleUndriveable(veh, true)
                else
                    if empActive then
                        empActive = false
                        Notify(Config.Locale.emp_released)
                    end
                    -- Motor normalisiern (optional)
                    SetVehicleUndriveable(veh, false)
                end
            end
        else
            empActive = false
        end
    end
end)
