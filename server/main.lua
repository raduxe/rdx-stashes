local function RegisterStashes()
    for _, stash in ipairs(Config.Stashes) do
        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight)
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        RegisterStashes()
        print('^2[Stash System] ^7Stashes registered successfully.')
    end
end)
