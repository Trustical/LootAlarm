local _, Addon = ...
local Functions = Addon.Functions
local ProfileManager = Addon.ProfileManager

----------------------------------------------------------------------------------------
-- API
----------------------------------------------------------------------------------------

LootAlarm = {}

--------------------------------------------
-- INIT
--------------------------------------------

function LootAlarm:IsInitialized()
    return Addon.ProfileManager ~= nil
end

--------------------------------------------
-- ACTIVE PROFILE
--------------------------------------------

function LootAlarm:HasItemInActiveProfile(ItemNameOrID)
    if (not ItemNameOrID) then return false end
    return ProfileManager:GetProfileItem(ItemNameOrID) ~= nil
end

function LootAlarm:GetActiveProfileName()
    return LootAlarmLocalDB.Settings.LoadedProfile
end