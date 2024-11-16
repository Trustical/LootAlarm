local _, Addon = ...
local Core = Addon.Core
local ItemManager = Addon.ItemManager
local Functions = Addon.Functions
local Assets = Addon.Assets
local UI = Addon.UI
local ProfileManager = Addon.ProfileManager
local Colors = Addon.Colors

ItemManager.CurrentItems = {}
ItemManager.CurrentProfileName = ""
ItemManager.IsNewProfile = true

function ItemManager:LoadProfile(IsNewProfile)
    ItemManager.IsNewProfile = IsNewProfile
    ItemManager.CurrentItems = {}
    ItemManager.CurrentProfileName = ""

    if (ItemManager.IsNewProfile) then return end
        
    ItemManager.CurrentProfileName = LootAlarmLocalDB.Settings.LoadedProfile

    for ItemName, ItemTable in next, LootAlarmLocalDB.Profiles[ItemManager.CurrentProfileName].Items, nil do
        ItemManager.CurrentItems[ItemName] = {}
        for ItemProperty, ItemValue in next, LootAlarmLocalDB.Profiles[ItemManager.CurrentProfileName].Items[ItemName], nil do
            ItemManager.CurrentItems[ItemName][ItemProperty] = ItemValue
        end
    end
end

function ItemManager:DisplayItemManager(IsNewProfile)
    ItemManager:ResetItemManager()
    ItemManager:LoadProfile(IsNewProfile)
    ItemManager:UpdateItemList()

    UI:Show("ItemManager")
end

function ItemManager:ResetItemManager()
    UI:RemoveAllScrollItems("IMItemsScroll")
    UI:Show("IMItemsScrollIsEmptyLabel")
    UI:SetText("IMSearchResultItemTextTop", Functions:PrintColor("Enter an item name or id.", "Grey"))
    UI:SetPoint("IMSearchResultItemTextTop", { "LEFT", "IMSearchResultIcon", "LEFT", 60, 9 })
    UI:Show("IMSearchResultItemTextBottom")
    UI:SetNormalTexture("IMSearchResultIcon", 134400)
    UI:SetBackdropBorderColor("IMSearchResult", "#46413e", 0.3)
    UI:DisableButton("IMAddButton")
    UI:SetText("IMSearch.Textbox", "")
end

function ItemManager:AddItem(Item)
    if (ItemManager:ItemAlreadyExists(Item.Name)) then
        Functions:PrintAddon("Item "..Functions:PrintColor(Item.Name, Colors.blue).." already exists.", "Error")
        return
    end

    ItemManager.CurrentItems[Item.Name] = {}
    ItemManager.CurrentItems[Item.Name].ID = Item.ID
    ItemManager.CurrentItems[Item.Name].Name = Item.Name
    ItemManager.CurrentItems[Item.Name].Link = Item.Link
    ItemManager.CurrentItems[Item.Name].Icon = Item.Icon
    ItemManager.CurrentItems[Item.Name].IsKnown = Item.IsKnown
    ItemManager.CurrentItems[Item.Name].IsWildcard = Item.IsWildcard

    ItemManager:UpdateItemList()
end

function ItemManager:DeleteItem(ItemName)
    for ProfileItemName, Value in next, ItemManager.CurrentItems, nil do
        if (ProfileItemName == ItemName) then
            ItemManager.CurrentItems[ItemName] = nil
            break
        end
    end

    ItemManager:UpdateItemList()
end

function ItemManager:SaveProfile(NewProfileName)
    local ProfileName = Functions:Condition(NewProfileName, NewProfileName, ItemManager.CurrentProfileName)

    if (ItemManager.IsNewProfile and not NewProfileName) then
        ItemManager:EnterProfileName()
        return
    end

    if (not LootAlarmLocalDB.Profiles[ProfileName]) then
        LootAlarmLocalDB.Profiles[ProfileName] = {}
    end

    LootAlarmLocalDB.Profiles[ProfileName].Items = ItemManager.CurrentItems

    UI:Hide("ItemManager")
    ProfileManager:LoadProfile(ProfileName)
    ProfileManager:UpdateProfileList()
end

function ItemManager:EnterProfileName()
    local FrameSettings = {}
    FrameSettings.Title = Core.AddonName..": Save Profile"
    FrameSettings.Text = "Enter your profile name:"
    FrameSettings.LeftButtonText = "Save"
    FrameSettings.RightButtonText = "Cancel"
    UI:DisplayDialogTextbox(FrameSettings)

    UI:SetScript("OnClick", "DialogTextboxFrame.LeftButton", function(Self, Button)
        local EnteredProfileName = UI:GetText("DialogTextboxFrame.Textbox.Textbox")

        if (strlen(EnteredProfileName) == 0) then
            Functions:PrintAddon("Please enter a profile name.", "Error")
            return
        end

        if (ProfileManager:ProfileExists(EnteredProfileName)) then
            Functions:PrintAddon("This profile name already exists.", "Error")
            return
        end

        UI:Hide("DialogTextboxFrame")
        ItemManager:SaveProfile(EnteredProfileName)
    end)
end

function ItemManager:ItemAlreadyExists(ItemName)
    for ProfileItemName, Value in next, ItemManager.CurrentItems, nil do
        if (ProfileItemName == ItemName) then return true end
    end

    return false
end

function ItemManager:GetOrderedItemNames()
    local OrderedList = {}
    for ItemName in pairs(ItemManager.CurrentItems) do
        tinsert(OrderedList, ItemName)
    end

    table.sort(OrderedList)

    return OrderedList
end

function ItemManager:UpdateElements()
    if (Functions:IsEmptyTable(ItemManager.CurrentItems)) then
        UI:DisableButton("IMSaveButton")
        UI:DisableButton("IMExportButton")
        UI:Show("IMItemsScrollIsEmptyLabel")
    else
        UI:EnableButton("IMSaveButton")
        UI:EnableButton("IMExportButton")
        UI:Hide("IMItemsScrollIsEmptyLabel")
    end
end

function ItemManager:UpdateItemList()
    ItemManager:UpdateElements()
    UI:RemoveAllScrollItems("IMItemsScroll")

    local i = 0
    for Key, ItemName in next, ItemManager:GetOrderedItemNames(), nil do
        -- Vars

        i = i + 1
        local FrameName = "IMScrollItem"..i
        local ItemID = ItemManager.CurrentItems[ItemName].ID
        local ItemLink = ItemManager.CurrentItems[ItemName].Link
        local ItemIcon = ItemManager.CurrentItems[ItemName].Icon
        local IsWildcard = ItemManager.CurrentItems[ItemName].IsWildcard
        local ItemInfo = "Item ID: "..Functions:Condition(ItemID == 0, "Unknown", ItemID)

        if (IsWildcard) then
            ItemIcon = 134393 -- White card
            ItemInfo = "Wildcard"
        end

        -- Create profile/scroll item

        local FrameSettings = {}
        FrameSettings.Name = FrameName
        FrameSettings.ScrollFrameName = "IMItemsScroll"
        FrameSettings.Title = Functions:Condition(strlen(ItemLink) > 0, ItemLink, ItemName)
        FrameSettings.Info = ItemInfo
        FrameSettings.Icon = ItemIcon
        
        FrameSettings.CustomIcons = {}
        FrameSettings.CustomIcons[1] = {}
        FrameSettings.CustomIcons[1].Name = "Delete"
        FrameSettings.CustomIcons[1].AssetName = "Trash.blp"
        FrameSettings.CustomIcons[1].AssetHoverName = "Trash-Hover.blp"
        FrameSettings.CustomIcons[1].Size = { 20, 20 }
        FrameSettings.CustomIcons[1].Point1 = { "RIGHT", FrameName, "RIGHT", -10, 0 }

        UI:CreateScrollItem(FrameSettings)

        -- Add Tooltip to icon

        if (IsWildcard) then

            local TooltipText = { "Wildcards are not updated." }
            UI:SetCustomTooltip(FrameName..".Icon", "Wildcard", TooltipText)

        elseif (ItemID == 0) then

            local TooltipText = {
                "Item is updated as soon",
                "as your character has",
                "the required information",
                "about this item.",
            }
            UI:SetCustomTooltip(FrameName..".Icon", "Unknown", TooltipText)

        else

            UI:SetItemTooltip(FrameName..".Icon", ItemID)
            
        end

        -- Delete item

        UI:SetScript("OnClick", FrameName..".Delete", function(Self, Button)
            ItemManager:DeleteItem(ItemName)
        end)

    end
end