local repairCost = 500 -- Cena za opravu
local washCost = 100   -- Cena za umytí

lib.callback.register('npcMechanic:pay', function(source, action)
    local playerId = source
    local cost = (action == 'repair') and repairCost or washCost
    local success = exports.ox_inventory:RemoveItem(playerId, 'money', cost)

    if success then
        return true
    else
        return false
    end
end)
