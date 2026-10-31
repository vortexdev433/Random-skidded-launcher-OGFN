-- llobregatpd_hud (QB-HUD style)

-- /testchaleco: equipa un chaleco de prueba al 100% para verificar la barra de armadura del HUD.
-- Solo admins (grupo admin/superadmin/owner/mod de ESX).
RegisterNetEvent('llobregatpd_hud:darChalecoPrueba')
AddEventHandler('llobregatpd_hud:darChalecoPrueba', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local grupo = xPlayer.getGroup()
    if grupo == 'admin' or grupo == 'superadmin' or grupo == 'owner' or grupo == 'mod' then
        TriggerClientEvent('llobregatpd_hud:client:darChalecoPrueba', src)
    else
        xPlayer.showNotification('No tienes permiso para usar /testchaleco')
    end
end)
