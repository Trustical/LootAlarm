local AddonName, Addon = ...
local Core = Addon.Core
local Initialize = Addon.Initialize
local Functions = Addon.Functions
local Assets = Addon.Assets
local UI = Addon.UI
local ProfileManager = Addon.ProfileManager
local Items = Addon.Items
local Colors = Addon.Colors

function Initialize:Init()
    Initialize:Settings()
    Initialize:Assets()
    Initialize:GUI()
    Initialize:Profiles()
    Initialize:Items()
    Initialize:Done()
end

function Initialize:Settings()
    if (not LootAlarmGlobalDB) then LootAlarmGlobalDB = {} end
    
    if (not LootAlarmLocalDB) then LootAlarmLocalDB = {} end
    if (not LootAlarmLocalDB.Profiles) then LootAlarmLocalDB.Profiles = {} end
    if (not LootAlarmLocalDB.Settings) then LootAlarmLocalDB.Settings = {} end

    if (not LootAlarmLocalDB.Settings.LoadedProfile) then LootAlarmLocalDB.Settings.LoadedProfile = "" end
    if (not LootAlarmLocalDB.Settings.MinimapIconPosition) then LootAlarmLocalDB.Settings.MinimapIconPosition = 180 end

    if (LootAlarmLocalDB.Settings.IsAddonEnabled == nil) then LootAlarmLocalDB.Settings.IsAddonEnabled = true end

    if (LootAlarmLocalDB.Settings.ShowLootFrame == nil) then LootAlarmLocalDB.Settings.ShowLootFrame = true end
    if (LootAlarmLocalDB.Settings.AutoHideLootFrame == nil) then LootAlarmLocalDB.Settings.AutoHideLootFrame = true end
    if (LootAlarmLocalDB.Settings.ShowChatMessage == nil) then LootAlarmLocalDB.Settings.ShowChatMessage = true end
    if (LootAlarmLocalDB.Settings.PlaySound == nil) then LootAlarmLocalDB.Settings.PlaySound = true end
    if (LootAlarmLocalDB.Settings.JiggleLogo == nil) then LootAlarmLocalDB.Settings.JiggleLogo = true end
    if (LootAlarmLocalDB.Settings.ShowItemIDs == nil) then LootAlarmLocalDB.Settings.ShowItemIDs = false end
    if (LootAlarmLocalDB.Settings.ShowTooltipItems == nil) then LootAlarmLocalDB.Settings.ShowTooltipItems = true end
    if (LootAlarmLocalDB.Settings.AutoConfirmBoP == nil) then LootAlarmLocalDB.Settings.AutoConfirmBoP = false end
    if (LootAlarmLocalDB.Settings.FastLoot == nil) then LootAlarmLocalDB.Settings.FastLoot = false end

    if (LootAlarmLocalDB.Settings.MarkItemsInBags == nil) then LootAlarmLocalDB.Settings.MarkItemsInBags = true end
    LootAlarmLocalDB.Settings.MarkItemsInBags = Functions:Condition(Core.IsRetail, false, LootAlarmLocalDB.Settings.MarkItemsInBags)
end

function Initialize:Assets()
    for SoundFileName, SoundFilePath in next, Assets.Sounds, nil do
        MuteSoundFile(Assets.Sounds[SoundFileName])
        PlaySoundFile(Assets.Sounds[SoundFileName])
        UnmuteSoundFile(Assets.Sounds[SoundFileName])
    end

    local Preloader = CreateFrame("Button", nil, UIParent)
    Preloader:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    Preloader:SetSize(0, 0)

    for ImageFileName, ImageFilePath in next, Assets.Images, nil do
        Preloader:SetNormalTexture(ImageFilePath)
    end

    Preloader:Hide()
end

function Initialize:GUI()
    UI:CreateLootFrame()
    UI:CreateProfileManager()
    UI:CreateItemManager()
    UI:CreateExportManager()
    UI:CreateSettings()
    UI:CreateProfileManagerTitleButtons()
    UI:CreateDialog()
    UI:CreateDialogTextbox()
    UI:CreateMinimapIcon()
end

function Initialize:Profiles()
    if (strlen(LootAlarmLocalDB.Settings.LoadedProfile) > 0) then
        local IsProfileLoaded = ProfileManager:LoadProfile(LootAlarmLocalDB.Settings.LoadedProfile)
        if (IsProfileLoaded) then
            Functions:PrintAddon("Loaded profile "..Functions:PrintColor(LootAlarmLocalDB.Settings.LoadedProfile, "Blue")..".")
        end
    end

    ProfileManager:UpdateProfileList()
    C_Timer.After(3.5, function() Items:UpdateUnknownItems() end)
end

function Initialize:Items()
    Items:SetContainerHook()
end

function Initialize:Done()
    local AddonVersion = C_AddOns.GetAddOnMetadata(AddonName, "Version")
    Functions:PrintAddon("Initialized. (v"..AddonVersion..")")

    if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then
        Functions:PrintAddon("All alarms are "..Functions:PrintColor("disabled", Colors.red)..".")
    end
end