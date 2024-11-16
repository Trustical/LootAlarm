local AddonName, Addon = ...
local Core = Addon.Core
local Initialize = Addon.Initialize
local Functions = Addon.Functions
local Assets = Addon.Assets
local UI = Addon.UI
local ProfileManager = Addon.ProfileManager
local ItemManager = Addon.ItemManager
local ExportManager = Addon.ExportManager
local Colors = Addon.Colors
local Events = Addon.Events1
local Items = Addon.Items

--------------------------------------------
-- CREATE LOOT FRAME
--------------------------------------------

function UI:CreateLootFrame()
    local FrameSettings = {}
    FrameSettings.Name = "LootFrame"
    FrameSettings.Size = { 450, 100 }
    FrameSettings.Point1 = { "TOP", UIParent, "TOP", 0, -100 }
    FrameSettings.IsStandalone = true
    UI:CreateFrame(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "LFTitle"
    FrameSettings.Text = Core.AddonName
    FrameSettings.ParentFrameName = "LootFrame"
    FrameSettings.Point1 = { "TOPLEFT", "LootFrame", "TOPLEFT", 0, 20 }
    FrameSettings.Point2 = { "TOPRIGHT", "LootFrame", "TOPRIGHT", 0, 0 }
    FrameSettings.FontColor = "#fff"
    FrameSettings.FontSize = 15
    UI:CreateLabel(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "LFLogo"
    FrameSettings.ParentFrameName = "LootFrame"
    FrameSettings.Point1 = { "CENTER", "LFTitle", "CENTER", 0, 32 }
    FrameSettings.Size = { 32, 32 }
    FrameSettings.AssetName = "Logo.blp"
    UI:CreateImageButton(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "LFCheck"
    FrameSettings.ParentFrameName = "LootFrame"
    FrameSettings.Point1 = { "RIGHT", "LootFrame", "RIGHT", 0, 0 }
    FrameSettings.Size = { 100, 100 }
    FrameSettings.AssetName = "Check.blp"
    FrameSettings.AssetHoverName = "Check-Hover.blp"
    UI:CreateImageButton(FrameSettings)
    UI:SetScript("OnClick", "LFCheck", function(Self, Button) UI:Hide("LootFrame") end)
    UI:SetScript("OnEnter", "LFCheck", function(Self) UI:SetNormalTexture(Self, Assets.Images["Check-Hover.blp"]) end)
    UI:SetScript("OnLeave", "LFCheck", function(Self) UI:SetNormalTexture(Self, Assets.Images["Check.blp"]) end)

    -- Single Alert

    FrameSettings = {}
    FrameSettings.Name = "LFSingleAlarmIcon"
    FrameSettings.ParentFrameName = "LootFrame"
    FrameSettings.Point1 = { "LEFT", "LootFrame", "LEFT", 20, 0 }
    FrameSettings.Size = { 60, 60 }
    FrameSettings.Icon = 134400
    UI:CreateIconButton(FrameSettings)
    UI:SetScript("OnLeave", "LFSingleAlarmIcon", function(Self) GameTooltip:Hide() end)

    FrameSettings = {}
    FrameSettings.Name = "LFSingleAlarmItemName"
    FrameSettings.Text = "[ITEM_NAME]"
    FrameSettings.ParentFrameName = "LFSingleAlarmIcon"
    FrameSettings.Point1 = { "LEFT", "LFSingleAlarmIcon", "RIGHT", 20, 0 }
    FrameSettings.Point2 = { "RIGHT", "LFCheck", "LEFT", -20, 0 }
    FrameSettings.FontSize = 20
    UI:CreateLabel(FrameSettings)
    
    FrameSettings = {}
    FrameSettings.Name = "LFSingleAlarmInfo"
    FrameSettings.Text = "[ITEM_INFOjkf döasjflö ajskdl]"
    FrameSettings.ParentFrameName = "LFSingleAlarmIcon"
    FrameSettings.Point1 = { "LEFT", "LFSingleAlarmItemName", "BOTTOMLEFT", 0, -10 }
    FrameSettings.Point2 = { "RIGHT", "LFSingleAlarmItemName", "RIGHT", 0, 0 }
    FrameSettings.FontSize = 10
    FrameSettings.FontColor = "#969696"
    UI:CreateLabel(FrameSettings)

    -- Multi Alert

    for i = 1, 10 do
        FrameSettings = {}
        FrameSettings.Name = "LFMultiAlarmIcon"..i
        FrameSettings.ParentFrameName = "LootFrame"
        FrameSettings.Size = { 25, 25 }
        FrameSettings.Icon = 134400

        if (i == 1) then
            FrameSettings.Point1 = { "TOPLEFT", "LootFrame", "TOPLEFT", 25, -25 }
        else
            FrameSettings.Point1 = { "TOPLEFT", "LFMultiAlarmIcon"..(i - 1), "TOPLEFT", 0, -30 }
        end

        UI:CreateIconButton(FrameSettings)
        UI:SetScript("OnLeave", "LFMultiAlarmIcon"..i, function(Self) GameTooltip:Hide() end)
        UI:Hide("LFMultiAlarmIcon"..i)

        FrameSettings = {}
        FrameSettings.Name = "LFMultiAlarmItemName"..i
        FrameSettings.Text = "[ITEM_NAME_"..i.."]"
        FrameSettings.ParentFrameName = "LFMultiAlarmIcon"..i
        FrameSettings.Point1 = { "LEFT", "LFMultiAlarmIcon"..i, "LEFT", 30, 0 }
        FrameSettings.Point2 = { "RIGHT", "LFCheck", "LEFT", -20, 0 }
        FrameSettings.FontSize = 20
        FrameSettings.Align = "Left"
        UI:CreateLabel(FrameSettings)
        UI:Hide("LFMultiAlarmItemName"..i)
    end

    -- Progress bar

    FrameSettings = {}
    FrameSettings.Name = "LFProgressBarBG"
    FrameSettings.ParentFrameName = "LootFrame"
    FrameSettings.Size = { 0, 5 }
    FrameSettings.Point1 = { "TOPLEFT", "LootFrame", "BOTTOMLEFT", 0, -2 }
    FrameSettings.Point2 = { "TOPRIGHT", "LootFrame", "BOTTOMRIGHT", 0, 0 }
    UI:CreateFrame(FrameSettings)
    UI:Hide("LFProgressBarBG")

    FrameSettings = {}
    FrameSettings.Name = "LFProgressBar"
    FrameSettings.ParentFrameName = "LFProgressBarBG"
    FrameSettings.Size = { 0, 5 }
    FrameSettings.Point1 = { "TOPLEFT", "LFProgressBarBG", "TOPLEFT", 0, 0 }
    UI:CreateFrame(FrameSettings)
    UI:SetBackdropColor("LFProgressBar", Colors.green)
end

--------------------------------------------
-- CREATE PROFILE MANAGER FRAME
--------------------------------------------

function UI:CreateProfileManager()
    local FrameSettings = {}
    FrameSettings.Name = "ProfileManager"
    FrameSettings.Title = Core.AddonName
    FrameSettings.Size = { 300, 400 }
    UI:CreateMainFrame(FrameSettings)
    UI:SetScript("OnHide", FrameSettings.Name, function() UI:HideContextMenus() end)

    FrameSettings = {}
    FrameSettings.Name = "PMScroll"
    FrameSettings.ParentFrameName = "ProfileManager"
    FrameSettings.Point1 = { "TOPLEFT", "ProfileManager", "TOPLEFT", 10, -40 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "ProfileManager", "BOTTOMRIGHT", -27, 10 }
    UI:CreateScrollFrame(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "PMIsEmptyButton"
    FrameSettings.ParentFrameName = "PMScroll"
    FrameSettings.Size = { 32, 32 }
    FrameSettings.Point1 = { "CENTER", 0, 20 }
    FrameSettings.AssetName = "Plus.blp"
    FrameSettings.AssetHoverName = "Plus-Hover.blp"
    UI:CreateImageButton(FrameSettings)

    UI:SetScript("OnClick", "PMIsEmptyButton", function(Self, Button)
        ItemManager:DisplayItemManager(true)
    end)

    FrameSettings = {}
    FrameSettings.Name = "PMIsEmptyLabel"
    FrameSettings.ParentFrameName = "PMIsEmptyButton"
    FrameSettings.Text = "Create a profile."
    FrameSettings.Point1 = { "CENTER", 0, -35 }
    FrameSettings.FontSize = 16
    FrameSettings.FontColor = Colors.grey
    UI:CreateLabel(FrameSettings)
end

--------------------------------------------
-- CREATE ITEM MANAGER FRAME
--------------------------------------------

function UI:CreateItemManager()
    local SearchedItem = {}

    local function SetPreviewItem()
        UI:SetText("IMSearchResultItemTextTop", Functions:PrintColor(SearchedItem.Link.." ("..SearchedItem.ID..")", "Grey"))
        UI:SetPoint("IMSearchResultItemTextTop", { "LEFT", "IMSearchResultIcon", "LEFT", 60, 0 })
        UI:Hide("IMSearchResultItemTextBottom")
        UI:SetNormalTexture("IMSearchResultIcon", SearchedItem.Icon)
        UI:SetItemTooltip("IMSearchResultIcon", SearchedItem.ID)
        UI:SetBackdropBorderColor("IMSearchResult", Colors.green)
    end

    local function ResetPreviewItem()
        UI:SetText("IMSearchResultItemTextTop", Functions:PrintColor("Enter an item name or id.", "Grey"))
        UI:SetPoint("IMSearchResultItemTextTop", { "LEFT", "IMSearchResultIcon", "LEFT", 60, 9 })
        UI:Show("IMSearchResultItemTextBottom")
        UI:SetNormalTexture("IMSearchResultIcon", 134400)
        UI:UnsetTooltip("IMSearchResultIcon")
        UI:SetBackdropBorderColor("IMSearchResult", "#46413e", 0.3)
    end

    local function AddItemToProfile()
        if (Functions:IsEmptyTable(SearchedItem)) then return end

        UI:DisableButton("IMAddButton")
        UI:SetText("IMSearch.Textbox", "")
        ResetPreviewItem()
        ItemManager:AddItem(SearchedItem)
        SearchedItem = {}
    end

    local function GetAndSetSearchedItem(SearchText)
        local IsSearchedByItemID = tonumber(SearchText)
        local ItemID = 0
        local ItemName, ItemLink, _, _, _, _, _, _, _, ItemIcon = C_Item.GetItemInfo(SearchText)

        if (ItemLink) then
            ItemID = Items:GetItemIDByLink(ItemLink)
        elseif (ItemName) then
            ItemID = C_Item.GetItemInfoInstant(ItemName)
        end

        if (not ItemID and IsSearchedByItemID) then
            ItemID = tonumber(SearchText)
        end

        SearchedItem.ID = Functions:Condition(ItemID and tonumber(ItemID), ItemID, 0)
        SearchedItem.IsKnown = SearchedItem.ID > 0
        SearchedItem.ID = Functions:Condition(SearchedItem.ID == 0 and tonumber(SearchText), tonumber(SearchText), SearchedItem.ID)
        SearchedItem.Name = Functions:Condition(ItemName and strlen(ItemName) > 0, ItemName, SearchText)
        SearchedItem.Icon = Functions:Condition(ItemIcon and strlen(ItemIcon) > 0, ItemIcon, 134400)
        SearchedItem.Link = Functions:Condition(ItemLink and strlen(ItemLink) > 0, ItemLink, "")
        SearchedItem.IsWildcard = Functions:StringContains(SearchedItem.Name, "*")
    end

    function Events:GET_ITEM_INFO_RECEIVED(ItemID, Success)
        if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then return end
        if (not Success or not ItemID) then return end
        if (UI:GetText("IMSearch.Textbox") == tostring(ItemID)) then
            GetAndSetSearchedItem(ItemID)
            SetPreviewItem()
        end
    end
    
    local FrameSettings = {}
    FrameSettings.Name = "ItemManager"
    FrameSettings.Title = Core.AddonName..": Item Manager"
    FrameSettings.Size = { 500, 500 }
    UI:CreateMainFrame(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "IMSearch"
    FrameSettings.ParentFrameName = "ItemManager"
    FrameSettings.Point1 = { "TOPLEFT", "ItemManager", "TOPLEFT", 10, -40 }
    FrameSettings.Point2 = { "RIGHT", "ItemManager", "RIGHT", -115, 0 }
    FrameSettings.Placeholder = "Search item..."
    UI:CreateTextbox(FrameSettings)

        UI:SetScript("OnShow", "IMSearch.Textbox", function(Self, Button)
            Self:SetText(Functions:PrintColor("Search item...", "Grey"))
        end)

    FrameSettings = {}
    FrameSettings.Name = "IMAddButton"
    FrameSettings.Text = "Add"
    FrameSettings.ParentFrameName = "ItemManager"
    FrameSettings.Point1 = { "TOPRIGHT", "IMSearch", "TOPRIGHT", 105, 0 }
    FrameSettings.IsDisabled = true
    UI:CreateButton(FrameSettings)

        UI:SetScript("OnClick", "IMAddButton", function(Self, Button)
            AddItemToProfile()
        end)

    FrameSettings = {}
    FrameSettings.Name = "IMSearchResult"
    FrameSettings.ParentFrameName = "ItemManager"
    FrameSettings.Point1 = { "TOPLEFT", "IMSearch", "TOPLEFT", 0, -40 }
    FrameSettings.Point2 = { "RIGHT", "ItemManager", "RIGHT", -10, 0 }
    FrameSettings.Size = { 0, 75 }
    UI:CreateFrame(FrameSettings)

        FrameSettings = {}
        FrameSettings.Name = "IMSearchResultIcon"
        FrameSettings.ParentFrameName = "IMSearchResult"
        FrameSettings.Size = { 40, 40 }
        FrameSettings.Point1 = { "LEFT", "IMSearchResult", "LEFT", 20, 0 }
        UI:CreateIconButton(FrameSettings)

        FrameSettings = {}
        FrameSettings.Name = "IMSearchResultItemTextTop"
        FrameSettings.ParentFrameName = "IMSearchResult"
        FrameSettings.Text = "Enter an item name or id."
        FrameSettings.Point1 = { "LEFT", "IMSearchResultIcon", "LEFT", 60, 9 }
        FrameSettings.FontSize = 16
        FrameSettings.FontColor = Colors.grey
        UI:CreateLabel(FrameSettings)

        FrameSettings = {}
        FrameSettings.Name = "IMSearchResultItemTextBottom"
        FrameSettings.ParentFrameName = "IMSearchResult"
        FrameSettings.Text = "Why is the item not found?"
        FrameSettings.Point1 = { "LEFT", "IMSearchResultIcon", "LEFT", 60, -9 }
        FrameSettings.FontSize = 12
        FrameSettings.FontColor = Colors.blue
        UI:CreateLabel(FrameSettings)

        local TooltipText = {
            "Items unknown to the character may only be available at a later time.",
            Core.AddonName.." will update it as soon as possible.\n",
            Functions:PrintColor("Alternatively, try entering the ID.", Colors.green).."\n",
            Functions:PrintColor("You can still add the item.", Colors.blue),
            Functions:PrintColor("Your alarm will still be triggered.", Colors.blue)
        }
        UI:SetCustomTooltip(FrameSettings.Name, "Why is the item not found?", TooltipText)

    UI:SetScript("OnKeyUp", "IMSearch.Textbox", function(Self, Key)
        local SearchText = UI:GetText(Self)
        if (strlen(SearchText) == 0) then ResetPreviewItem(); UI:DisableButton("IMAddButton"); return end

        UI:EnableButton("IMAddButton")

        GetAndSetSearchedItem(SearchText)

        if (Key == "ENTER") then
            AddItemToProfile()
            return
        end

        if (SearchedItem.IsKnown) then
            SetPreviewItem()
        else
            ResetPreviewItem()
        end
    end)

    FrameSettings = {}
    FrameSettings.Name = "IMItemsScroll"
    FrameSettings.ParentFrameName = "ItemManager"
    FrameSettings.Point1 = { "TOPLEFT", "IMSearchResult", "TOPLEFT", 0, 0 -UI:GetHeight("IMSearchResult") - 5 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "ItemManager", "BOTTOMRIGHT", -30, 60 }
    UI:CreateScrollFrame(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "IMItemsScrollIsEmptyLabel"
    FrameSettings.ParentFrameName = "IMItemsScroll"
    FrameSettings.Text = "Add some items."
    FrameSettings.Point1 = { "CENTER", 0, 0 }
    FrameSettings.FontSize = 16
    FrameSettings.FontColor = Colors.grey
    UI:CreateLabel(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "IMSaveButton"
    FrameSettings.Text = "Save"
    FrameSettings.ParentFrameName = "ItemManager"
    FrameSettings.Point1 = { "TOPLEFT", "IMItemsScroll", "TOPLEFT", 0, -UI:GetHeight("IMItemsScroll") - 5 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "ItemManager", "BOTTOMRIGHT", -UI:GetWidth("IMItemsScroll") / 2 - 25, 10 }
    FrameSettings.IsDisabled = true
    UI:CreateButton(FrameSettings)

    UI:SetScript("OnClick", "IMSaveButton", function(Self, Button)
        ItemManager:SaveProfile()
    end)
    
    FrameSettings = {}
    FrameSettings.Name = "IMExportButton"
    FrameSettings.Text = "Export"
    FrameSettings.ParentFrameName = "ItemManager"
    FrameSettings.Point1 = { "TOPLEFT", "IMSaveButton", "TOPRIGHT", 10, 0 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "ItemManager", "BOTTOMRIGHT", -10, 10 }
    FrameSettings.IsDisabled = true
    UI:CreateButton(FrameSettings)

    UI:SetScript("OnClick", "IMExportButton", function(Self, Button)
        ExportManager:DisplayExportManager()
    end)
end

--------------------------------------------
-- CREATE IMPORT MANAGER
--------------------------------------------

function UI:CreateExportManager()
    local FrameSettings = {}
    FrameSettings.Name = "ExportManager"
    FrameSettings.Title = Core.AddonName..": Import/Export Profile"
    FrameSettings.Size = { 500, 300 }
    UI:CreateMainFrame(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "ExportManager.Textbox"
    FrameSettings.ParentFrameName = "ExportManager"
    FrameSettings.Point1 = { "TOPLEFT", "ExportManager", "TOPLEFT", 10, -40 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "ExportManager", "BOTTOMRIGHT", -30, 60 }
    UI:CreateMultiLineTextbox(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "EMOptionsButton"
    FrameSettings.Text = "[OPTION]"
    FrameSettings.ParentFrameName = "ExportManager"
    FrameSettings.Point1 = { "TOPLEFT", "ExportManager.Textbox", "BOTTOMLEFT", 0, -10 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "ExportManager", "BOTTOMRIGHT", -10, 10 }
    UI:CreateButton(FrameSettings)
end

--------------------------------------------
-- CREATE SETTINGS FRAME
--------------------------------------------

function UI:CreateSettings()
    local TooltipText

    local FrameSettings = {}
    FrameSettings.Name = "Settings"
    FrameSettings.Title = Core.AddonName..": Settings"
    FrameSettings.Size = { 300, 352 } -- +30
    UI:CreateMainFrame(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsShowLootFrame"
    FrameSettings.Text = "Show Loot Frame"
    FrameSettings.ParentFrameName = "Settings"
    FrameSettings.Point1 = { "TOPLEFT", "Settings", "TOPLEFT", 10, -40 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.ShowLootFrame)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.ShowLootFrame = Self:GetChecked()
    end)
    TooltipText = { "Notifies you when an item from the", "selected profile is dropped." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsAutoHideLootFrame"
    FrameSettings.Text = "Auto-Hide Loot Frame"
    FrameSettings.ParentFrameName = "CheckSettingsShowLootFrame"
    FrameSettings.Point1 = { "TOPLEFT", "CheckSettingsShowLootFrame", "TOPLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.AutoHideLootFrame)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.AutoHideLootFrame = Self:GetChecked()
    end)
    TooltipText = { "Makes the notification disappear", "automatically after a few seconds." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsShowChatMessage"
    FrameSettings.Text = "Show Chat Message"
    FrameSettings.ParentFrameName = "CheckSettingsAutoHideLootFrame"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsAutoHideLootFrame", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.ShowChatMessage)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.ShowChatMessage = Self:GetChecked()
    end)
    TooltipText = { "Shows you a message in chat when an item", "is dropped from the selected profile." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsPlaySound"
    FrameSettings.Text = "Play Sound"
    FrameSettings.ParentFrameName = "CheckSettingsShowChatMessage"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsShowChatMessage", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.PlaySound)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.PlaySound = Self:GetChecked()
    end)
    TooltipText = { "Plays a short \"BAM\" sound when an item", "from the selected profile is dropped." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsJiggleLogo"
    FrameSettings.Text = "Jiggle Logo"
    FrameSettings.ParentFrameName = "CheckSettingsPlaySound"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsPlaySound", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.JiggleLogo)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.JiggleLogo = Self:GetChecked()
    end)
    TooltipText = { "Makes the logo on the loot frame vibrate." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsShowItemIDs"
    FrameSettings.Text = "Show Item ID's in Tooltips"
    FrameSettings.ParentFrameName = "CheckSettingsJiggleLogo"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsJiggleLogo", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.ShowItemIDs)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.ShowItemIDs = Self:GetChecked()
    end)
    TooltipText = { "Shows the item id in your item tooltips." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsShowTooltipItems"
    FrameSettings.Text = "Show Profile Items as Tooltip"
    FrameSettings.ParentFrameName = "CheckSettingsShowItemIDs"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsShowItemIDs", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.ShowTooltipItems)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.ShowTooltipItems = Self:GetChecked()
        ProfileManager:UpdateProfileList()
    end)
    TooltipText = { "Shows you all items in the profile", "when you move the mouse over the item label." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsAutoConfirmBoP"
    FrameSettings.Text = "Auto-Confirm BoP Items"
    FrameSettings.ParentFrameName = "CheckSettingsShowTooltipItems"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsShowTooltipItems", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.AutoConfirmBoP)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.AutoConfirmBoP = Self:GetChecked()
        ProfileManager:UpdateProfileList()
    end)
    TooltipText = { "Confirms all BoP drops", "automatically when looting." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsFastLoot"
    FrameSettings.Text = "Fast-Loot"
    FrameSettings.ParentFrameName = "CheckSettingsAutoConfirmBoP"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsAutoConfirmBoP", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.FastLoot)
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.FastLoot = Self:GetChecked()
        ProfileManager:UpdateProfileList()
    end)
    TooltipText = { "Loot incredibly fast!" }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)

    FrameSettings = {}
    FrameSettings.Name = "CheckSettingsMarkItemsInBags"
    FrameSettings.Text = "Mark Items in Bags"
    FrameSettings.ParentFrameName = "CheckSettingsFastLoot"
    FrameSettings.Point1 = { "BOTTOMLEFT", "CheckSettingsFastLoot", "BOTTOMLEFT", 0, -30 }
    UI:CreateCheckbox(FrameSettings)
    UI:SetChecked(FrameSettings.Name, LootAlarmLocalDB.Settings.MarkItemsInBags)
    if (Core.IsRetail) then UI:DisableCheckbox(FrameSettings.Name) end
    UI:SetScript("OnClick", FrameSettings.Name, function(Self, Button)
        LootAlarmLocalDB.Settings.MarkItemsInBags = Self:GetChecked()
    end)
    TooltipText = { "Marks looted items in your bag", "from the selected profile." }
    UI:SetCustomTooltip(FrameSettings.Name, FrameSettings.Text, TooltipText)
end

--------------------------------------------
-- CREATE PROFILE MANAGER TITLE BUTTONS
--------------------------------------------

function UI:CreateProfileManagerTitleButtons()
    local FrameSettings = {}
    FrameSettings.Name = "ButtonSettings"
    FrameSettings.ParentFrameName = "ProfileManager"
    FrameSettings.Size = { 16, 16 }
    FrameSettings.Point1 = { "LEFT", "ProfileManager.CloseButton", "LEFT", -28, 0 }
    FrameSettings.AssetName = "Settings.blp"
    FrameSettings.AssetHoverName = "Settings-Hover.blp"
    UI:CreateImageButton(FrameSettings)

    UI:SetScript("OnClick", "ButtonSettings", function(Self, Button)
        UI:Toggle("Settings")
    end)

    local FrameSettings = {}
    FrameSettings.Name = "ButtonImport"
    FrameSettings.ParentFrameName = "ProfileManager"
    FrameSettings.Size = { 16, 16 }
    FrameSettings.Point1 = { "LEFT", "ButtonSettings", "LEFT", -28, 0 }
    FrameSettings.AssetName = "Import.blp"
    FrameSettings.AssetHoverName = "Import-Hover.blp"
    UI:CreateImageButton(FrameSettings)

    UI:SetScript("OnClick", "ButtonImport", function(Self, Button)
        ExportManager:DisplayImportManager()
    end)

    FrameSettings = {}
    FrameSettings.Name = "ButtonCreateProfile"
    FrameSettings.ParentFrameName = "ProfileManager"
    FrameSettings.Size = { 16, 16 }
    FrameSettings.Point1 = { "LEFT", "ButtonImport", "LEFT", -28, 0 }
    FrameSettings.AssetName = "Plus.blp"
    FrameSettings.AssetHoverName = "Plus-Hover.blp"
    UI:CreateImageButton(FrameSettings)

    UI:SetScript("OnClick", "ButtonCreateProfile", function(Self, Button)
        ItemManager:DisplayItemManager(true)
    end)
end

--------------------------------------------
-- CREATE DIALOGS
--------------------------------------------

function UI:CreateDialog()
    local FrameSettings = {}
    FrameSettings.Name = "DialogFrame"
    FrameSettings.Title = "[TITLE]"
    FrameSettings.Size = { 300, 150 }
    UI:CreateMainFrame(FrameSettings)

    UI:SetScript("OnKeyUp", "DialogFrame", function(Self, Key)
        if (Key ~= "ESCAPE") then return end
        UI:Hide("DialogFrame")
    end)

    FrameSettings = {}
    FrameSettings.Name = "DialogFrame.Label"
    FrameSettings.Text = "[TEXT]"
    FrameSettings.ParentFrameName = "DialogFrame"
    FrameSettings.Point1 = { "TOPLEFT", "DialogFrame", "TOPLEFT", 15, -50 }
    FrameSettings.Point2 = { "TOPRIGHT", "DialogFrame", "TOPRIGHT", -15, 0 }
    FrameSettings.FontSize = 16
    UI:CreateLabel(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "DialogFrame.LeftButton"
    FrameSettings.Text = "[LBTN]"
    FrameSettings.ParentFrameName = "DialogFrame"
    FrameSettings.Point1 = { "BOTTOMLEFT", "DialogFrame.Label", "BOTTOMLEFT", 0, -60 }
    UI:CreateButton(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "DialogFrame.RightButton"
    FrameSettings.Text = "[RBTN]"
    FrameSettings.ParentFrameName = "DialogFrame"
    FrameSettings.Point1 = { "BOTTOMRIGHT", "DialogFrame.Label", "BOTTOMRIGHT", 0, -60 }
    UI:CreateButton(FrameSettings)
end

function UI:CreateDialogTextbox()
    local FrameSettings = {}
    FrameSettings.Name = "DialogTextboxFrame"
    FrameSettings.Title = "[TITLE]"
    FrameSettings.Size = { 300, 150 }
    UI:CreateMainFrame(FrameSettings)

    UI:SetScript("OnKeyUp", "DialogTextboxFrame", function(Self, Key)
        if (Key ~= "ESCAPE") then return end
        UI:Hide("DialogTextboxFrame")
    end)

    FrameSettings = {}
    FrameSettings.Name = "DialogTextboxFrame.Label"
    FrameSettings.Text = "[TEXT]"
    FrameSettings.ParentFrameName = "DialogTextboxFrame"
    FrameSettings.Point1 = { "TOPLEFT", "DialogTextboxFrame", "TOPLEFT", 15, -50 }
    FrameSettings.Point2 = { "TOPRIGHT", "DialogTextboxFrame", "TOPRIGHT", -15, 0 }
    FrameSettings.FontSize = 16
    UI:CreateLabel(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "DialogTextboxFrame.Textbox"
    FrameSettings.ParentFrameName = "DialogTextboxFrame"
    FrameSettings.Point1 = { "BOTTOMLEFT", "DialogTextboxFrame.Label", "BOTTOMLEFT", 0, -60 }
    FrameSettings.Point2 = { "BOTTOMRIGHT", "DialogTextboxFrame", "BOTTOMRIGHT", -10, 0 }
    UI:CreateTextbox(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "DialogTextboxFrame.LeftButton"
    FrameSettings.Text = "[LBTN]"
    FrameSettings.ParentFrameName = "DialogTextboxFrame"
    FrameSettings.Point1 = { "BOTTOMLEFT", "DialogTextboxFrame.Textbox", "BOTTOMLEFT", 0, -50 }
    UI:CreateButton(FrameSettings)

    FrameSettings = {}
    FrameSettings.Name = "DialogTextboxFrame.RightButton"
    FrameSettings.Text = "[RBTN]"
    FrameSettings.ParentFrameName = "DialogTextboxFrame"
    FrameSettings.Point1 = { "BOTTOMRIGHT", "DialogTextboxFrame.Textbox", "BOTTOMRIGHT", 0, -50 }
    UI:CreateButton(FrameSettings)

    UI:SetScript("OnKeyUp", "DialogTextboxFrame.Textbox.Textbox", function(Self, Key)
        if (Key ~= "ENTER") then return end
        UI:Click("DialogTextboxFrame.LeftButton")
    end)
end

--------------------------------------------
-- TOGGLE UI'S
--------------------------------------------

function UI:ToggleAddon()
    LootAlarmLocalDB.Settings.IsAddonEnabled = not LootAlarmLocalDB.Settings.IsAddonEnabled

    if (LootAlarmLocalDB.Settings.IsAddonEnabled) then
        UI.Minimap.icon = Assets.Images["Logo-Minimap.blp"]
        UI:SetText("ProfileManager.Title", Core.AddonName)
        UI:SetTextColor("ProfileManager.Title", "#ffd100")

        Functions:PrintAddon("All alarms are now "..Functions:PrintColor("enabled", Colors.green)..".")
    else
        UI.Minimap.icon = Assets.Images["Logo-Minimap-Disabled.blp"]
        UI:SetText("ProfileManager.Title", Core.AddonName.." "..Functions:PrintColor("(Disabled)", Colors.red))
        UI:SetTextColor("ProfileManager.Title", "#ffd100")

        Functions:PrintAddon("All alarms are now "..Functions:PrintColor("disabled", Colors.red)..".")
    end
end

function UI:Toggle(FrameName)
    if (UI:IsVisible(FrameName)) then
        UI:Hide(FrameName)
    else
        UI:Show(FrameName)
    end
end