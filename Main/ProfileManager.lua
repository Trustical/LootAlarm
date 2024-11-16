local _, Addon = ...
local Core = Addon.Core
local Functions = Addon.Functions
local ProfileManager = Addon.ProfileManager
local ItemManager = Addon.ItemManager
local ExportManager = Addon.ExportManager
local UI = Addon.UI
local Colors = Addon.Colors
local Items = Addon.Items

function ProfileManager:IsProfileLoaded()
    return strlen(LootAlarmLocalDB.Settings.LoadedProfile) > 0 and LootAlarmLocalDB.Profiles[LootAlarmLocalDB.Settings.LoadedProfile]
end

function ProfileManager:HasItemsInProfile()
    return ProfileManager:IsProfileLoaded() and Functions:CountTable(LootAlarmLocalDB.Profiles[LootAlarmLocalDB.Settings.LoadedProfile].Items) > 0
end

function ProfileManager:GeProfileItems()
    return Functions:Condition(ProfileManager:IsProfileLoaded(), LootAlarmLocalDB.Profiles[LootAlarmLocalDB.Settings.LoadedProfile].Items, {})
end

function ProfileManager:ProfileExists(ProfileName)
    return LootAlarmLocalDB.Profiles[ProfileName]
end

function ProfileManager:LoadProfile(ProfileName)
    if (not ProfileManager:ProfileExists(ProfileName)) then
        Functions:PrintAddon("Profile "..Functions:PrintColor(ProfileName, Colors.blue).." does not exist.", "Error")
        return false
    end

    LootAlarmLocalDB.Settings.LoadedProfile = ProfileName

    return true
end

function ProfileManager:UnloadProfile()
    LootAlarmLocalDB.Settings.LoadedProfile = ""
end

function ProfileManager:RenameProfile(OldProfileName, NewProfileName)
    if (not ProfileManager:ProfileExists(OldProfileName)) then return end

    if (not NewProfileName) then
        ProfileManager:EnterProfileName(OldProfileName)
        return
    end

    if (OldProfileName == NewProfileName) then return end

    LootAlarmLocalDB.Profiles[NewProfileName] = LootAlarmLocalDB.Profiles[OldProfileName]
    LootAlarmLocalDB.Profiles[OldProfileName] = nil

    if (LootAlarmLocalDB.Settings.LoadedProfile == OldProfileName) then
        ProfileManager:LoadProfile(NewProfileName)
    end

    ProfileManager:UpdateProfileList()
end

function ProfileManager:EnterProfileName(OldProfileName)
    local FrameSettings = {}
    FrameSettings.Title = Core.AddonName..": Rename Profile"
    FrameSettings.Text = "Enter your new profile name:"
    FrameSettings.TextboxText = OldProfileName
    FrameSettings.HighlightTextboxText = true
    FrameSettings.LeftButtonText = "Save"
    FrameSettings.RightButtonText = "Cancel"
    UI:DisplayDialogTextbox(FrameSettings)

    UI:SetScript("OnClick", "DialogTextboxFrame.LeftButton", function(Self, Button)
        local EnteredProfileName = UI:GetText("DialogTextboxFrame.Textbox.Textbox")

        if (strlen(EnteredProfileName) == 0) then
            Functions:PrintAddon("Please enter a profile name.", "Error")
            return
        end

        if (EnteredProfileName == OldProfileName) then
            UI:Hide("DialogTextboxFrame")
            return
        end

        if (ProfileManager:ProfileExists(EnteredProfileName)) then
            Functions:PrintAddon("This profile name already exists.", "Error")
            return
        end

        UI:Hide("DialogTextboxFrame")
        ProfileManager:RenameProfile(OldProfileName, EnteredProfileName)
    end)
end

function ProfileManager:CopyProfile(ProfileName)
    if (not ProfileManager:ProfileExists(ProfileName)) then return end

    local Copy = " (Copy 1)"
    local i = 1
    while (LootAlarmLocalDB.Profiles[ProfileName..Copy]) do
        i = i + 1
        Copy = " (Copy "..i..")"
    end

    LootAlarmLocalDB.Profiles[ProfileName..Copy] = {}
    LootAlarmLocalDB.Profiles[ProfileName..Copy].Items = {}

    for ItemName, Item in next, LootAlarmLocalDB.Profiles[ProfileName].Items, nil do
        LootAlarmLocalDB.Profiles[ProfileName..Copy].Items[ItemName] = Item
    end

    ProfileManager:UpdateProfileList()
end

function ProfileManager:DeleteProfile(ProfileName, ConfirmDeletion)
    if (not ProfileManager:ProfileExists(ProfileName)) then return end

    if (not ConfirmDeletion) then
        ProfileManager:ConfirmDeletion(ProfileName)
        return
    end

    if (LootAlarmLocalDB.Settings.LoadedProfile == ProfileName) then
        ProfileManager:UnloadProfile()
    end

    LootAlarmLocalDB.Profiles[ProfileName] = nil

    ProfileManager:UpdateProfileList()
end

function ProfileManager:ConfirmDeletion(ProfileName)
    local FrameSettings = {}
    FrameSettings.Title = Core.AddonName..": Confirm Deletion"
    FrameSettings.Text = "Do you really want to delete "..Functions:PrintColor(ProfileName, Colors.blue).."?"
    FrameSettings.LeftButtonText = "Delete"
    FrameSettings.RightButtonText = "Cancel"
    UI:DisplayDialog(FrameSettings)

    UI:SetScript("OnClick", "DialogFrame.LeftButton", function(Self, Button)
        UI:Hide("DialogFrame")
        ProfileManager:DeleteProfile(ProfileName, true)
    end)
end

function ProfileManager:GetOrderedProfileNames()
    local OrderedProfileNames = {}
    for ProfileName in pairs(LootAlarmLocalDB.Profiles) do
        tinsert(OrderedProfileNames, ProfileName)
    end

    table.sort(OrderedProfileNames)

    return OrderedProfileNames
end

function ProfileManager:UpdateElements()
    if (Functions:IsEmptyTable(LootAlarmLocalDB.Profiles)) then
        UI:Show("PMIsEmptyButton", true)
    else
        UI:Hide("PMIsEmptyButton")
    end
end

function ProfileManager:UpdateProfileList()
    ProfileManager:UpdateElements()
    UI:RemoveAllScrollItems("PMScroll")

    local i = 0
    for Key, ProfileName in next, ProfileManager:GetOrderedProfileNames(), nil do
        -- Vars

        i = i + 1
        local CountItems = Functions:CountTable(LootAlarmLocalDB.Profiles[ProfileName].Items)
        local FrameName = "ScrollItem"..i

        -- Functions

        local function SelectProfile()
            if (LootAlarmLocalDB.Settings.LoadedProfile == ProfileName) then return end

            local IsProfileLoaded = ProfileManager:LoadProfile(ProfileName)
            if (IsProfileLoaded) then
                UI:MarkScrollItem("PMScroll", FrameName)
            end
        end

        -- Profile/scroll item

        local FrameSettings = {}
        FrameSettings.Name = FrameName
        FrameSettings.ScrollFrameName = "PMScroll"
        FrameSettings.Title = ProfileName
        FrameSettings.Info = tostring(CountItems).." item"..Functions:Condition(CountItems > 1, "s", "")
        FrameSettings.CustomIcons = {}

        local CustomIcon = {}
        CustomIcon.Name = "Delete"
        CustomIcon.AssetName = "Trash.blp"
        CustomIcon.AssetHoverName = "Trash-Hover.blp"
        CustomIcon.Size = { 16, 16 }
        CustomIcon.Point1 = { "RIGHT", FrameName, "RIGHT", -10, 0 }
        tinsert(FrameSettings.CustomIcons, CustomIcon)

        CustomIcon = {}
        CustomIcon.Name = "Rename"
        CustomIcon.AssetName = "Pen.blp"
        CustomIcon.AssetHoverName = "Pen-Hover.blp"
        CustomIcon.Size = { 16, 16 }
        CustomIcon.Point1 = { "RIGHT", FrameName, "RIGHT", -35, 0 }
        tinsert(FrameSettings.CustomIcons, CustomIcon)

        UI:CreateScrollItem(FrameSettings)

        -- Show items as tooltip

        if (LootAlarmLocalDB.Settings.ShowTooltipItems) then
            local TooltipItems = {}
            local i = 1

            for ItemName, Item in next, LootAlarmLocalDB.Profiles[ProfileName].Items, nil do
                tinsert(TooltipItems, Functions:PrintIcon(Item.Icon).." "..Functions:Condition(strlen(Item.Link) > 0, Item.Link, Item.Name))

                if (i == 30) then
                    tinsert(TooltipItems, "\n+ "..(CountItems - i).." more items...")
                    break
                end

                i = i + 1
            end

            UI:SetCustomTooltip(FrameName..".Info", nil, TooltipItems, true)
        else
            UI:UnsetTooltip(FrameName..".Info", true)
        end

        -- Context menu

        FrameSettings = {}
        FrameSettings.ClickFrameName = FrameName
        FrameSettings.Items = {}

        local Item = {}
        Item.Text = "Edit Profile..."
        Item.Func = function(Self, Button) SelectProfile(); ItemManager:DisplayItemManager() end
        tinsert(FrameSettings.Items, Item)

        Item = {}
        Item.Text = "Rename Profile..."
        Item.Func = function(Self, Button) ProfileManager:RenameProfile(ProfileName) end
        tinsert(FrameSettings.Items, Item)

        Item = {}
        Item.Text = "Copy Profile..."
        Item.Func = function(Self, Button) ProfileManager:CopyProfile(ProfileName) end
        tinsert(FrameSettings.Items, Item)

        Item = {}
        Item.Text = "Export Profile..."
        Item.Func = function(Self, Button)
            SelectProfile()
            ItemManager:LoadProfile()
            ExportManager:DisplayExportManager()
        end
        tinsert(FrameSettings.Items, Item)

        Item = {}
        Item.Text = "-"
        tinsert(FrameSettings.Items, Item)

        Item = {}
        Item.Text = "Delete Profile"
        Item.Func = function(Self, Button) ProfileManager:DeleteProfile(ProfileName) end
        tinsert(FrameSettings.Items, Item)

        UI:CreateContextMenu(FrameSettings)

        -- Mark loaded profile

        if (LootAlarmLocalDB.Settings.LoadedProfile == ProfileName) then
            UI:MarkScrollItem("PMScroll", FrameName, true)
        end

        -- Select profile / Show context menu

        UI:SetScript("OnMouseUp", FrameName, function(Self, Button)
            if (Button == "LeftButton") then
                SelectProfile()
            elseif (Button == "RightButton") then
                UI:ShowContextMenu(FrameName)
            end
        end)

        -- Edit profile

        UI:SetScript("OnDoubleClick", FrameName, function(Self, Button)
            ItemManager:DisplayItemManager()
        end)

        -- Rename profile

        UI:SetScript("OnClick", FrameName..".Rename", function(Self, Button)
            ProfileManager:RenameProfile(ProfileName)
        end)

        -- Delete profile

        UI:SetScript("OnClick", FrameName..".Delete", function(Self, Button)
            ProfileManager:DeleteProfile(ProfileName)
        end)

    end
end