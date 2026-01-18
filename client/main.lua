local PlayerData = {}
local Framework = nil

if GetResourceState('es_extended') == 'started' then
    Framework = 'esx'
    local ESX = exports.es_extended:getSharedObject()
    
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
    end)

    RegisterNetEvent('esx:setJob', function(job)
        PlayerData.job = job
    end)
    
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'qb'
    local QBCore = exports['qb-core']:GetCoreObject()
    
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)

    RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
        PlayerData.gang = GangInfo
    end)
end

local function HasAccess(groups)
    if not groups then return true end
    if not next(groups) then return true end

    if Framework == 'esx' and PlayerData.job then
        if groups[PlayerData.job.name] and PlayerData.job.grade >= groups[PlayerData.job.name] then
            return true
        end
    end

    if Framework == 'qb' then
        if PlayerData.job and groups[PlayerData.job.name] and PlayerData.job.grade.level >= groups[PlayerData.job.name] then
            return true
        end
        if PlayerData.gang and groups[PlayerData.gang.name] and PlayerData.gang.grade.level >= groups[PlayerData.gang.name] then
            return true
        end
    end

    return false
end

local function OpenStash(stashId)
    if exports.ox_inventory:openInventory('stash', stashId) == false then
        lib.notify({description = 'Cant open the ', type = 'error'})
    end
end

CreateThread(function()
    Wait(1000)
    if Framework == 'esx' and not PlayerData.job then 
        local ESX = exports.es_extended:getSharedObject()
        PlayerData = ESX.GetPlayerData()
    elseif Framework == 'qb' and not PlayerData.job then
        local QBCore = exports['qb-core']:GetCoreObject()
        PlayerData = QBCore.Functions.GetPlayerData()
    end

    for i, stash in ipairs(Config.Stashes) do
        
        if Config.InteractionType == 'target' then
            -- OX TARGET LOGIC
            exports.ox_target:addBoxZone({
                coords = stash.coords,
                size = vec3(1.5, 1.5, 2.0),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = 'open_stash_' .. stash.id,
                        icon = 'fa-solid fa-box-open',
                        label = 'Open ' .. stash.label,
                        onSelect = function()
                            OpenStash(stash.id)
                        end,
                        canInteract = function(entity, distance, coords, name)
                            return HasAccess(stash.groups)
                        end
                    }
                }
            })

        else
            local point = lib.points.new({
                coords = stash.coords,
                distance = Config.DrawDistance,
                stashData = stash
            })
        
            function point:onEnter()
                if HasAccess(self.stashData.groups) then
                    lib.showTextUI('[E] - ' .. self.stashData.label)
                end
            end
        
            function point:onExit()
                lib.hideTextUI()
            end
        
            function point:nearby()
                if HasAccess(self.stashData.groups) then
                    if IsControlJustReleased(0, Config.TextUIKey) then
                        OpenStash(self.stashData.id)
                    end
                end
            end
        end
    end
end)
