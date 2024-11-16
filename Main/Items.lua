local _, Addon = ...
local Core = Addon.Core
local Items = Addon.Items
local Functions = Addon.Functions
local ProfileManager = Addon.ProfileManager
local ItemManager = Addon.ItemManager
local UI = Addon.UI
local Assets = Addon.Assets
local Colors = Addon.Colors
local Events = Addon.Events2

----------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------

--------------------------------------------
-- UPDATE ITEMS IN PROFILE ON EVENT
--------------------------------------------

function Events:GET_ITEM_INFO_RECEIVED(ItemID, Success)
    if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then return end
    if (not Success or not ItemID) then return end
    if (UI:IsVisible("ItemManager")) then return end
    if (not ProfileManager:HasItemsInProfile()) then return end
    
    local ItemName, ItemLink, _, _, _, _, _, _, _, ItemIcon = C_Item.GetItemInfo(ItemID)
    if (not ItemName or not ItemLink or not ItemIcon) then return end

    ItemName = string.lower(ItemName)
    ItemsToAdd = {}
    ItemsToDelete = {}

    for ProfileName, ProfileTable in next, LootAlarmLocalDB.Profiles, nil do
        for ProfileItemName, ProfileItem in next, LootAlarmLocalDB.Profiles[ProfileName].Items, nil do
            if (not ProfileItem.IsKnown and not ProfileItem.IsWildcard) then
                
                if (string.lower(ProfileItemName) == ItemName or ProfileItem.ID == ItemID) then
                    
                    if (not ItemsToAdd[ProfileName]) then
                        ItemsToAdd[ProfileName] = {}
                    end

                    ItemsToAdd[ProfileName][ItemName] = {}
                    ItemsToAdd[ProfileName][ItemName].IsKnown = true
                    ItemsToAdd[ProfileName][ItemName].ID = ItemID
                    ItemsToAdd[ProfileName][ItemName].Name = ItemName
                    ItemsToAdd[ProfileName][ItemName].Icon = ItemIcon
                    ItemsToAdd[ProfileName][ItemName].Link = ItemLink

                    if (not ItemsToDelete[ProfileName]) then
                        ItemsToDelete[ProfileName] = {}
                    end

                    tinsert(ItemsToDelete[ProfileName], ProfileItemName)

                end

            end
        end
    end

    Items:UpdateItems(ItemsToDelete, ItemsToAdd)
end

--------------------------------------------
-- UPDATE UNKNOWN ITEMS (INDEPENDENT)
--------------------------------------------

function Items:UpdateUnknownItems()
    ItemsToAdd = {}
    ItemsToDelete = {}

    for ProfileName, ProfileTable in next, LootAlarmLocalDB.Profiles, nil do
        for ProfileItemName, ProfileItem in next, LootAlarmLocalDB.Profiles[ProfileName].Items, nil do
            if (not ProfileItem.IsKnown and not ProfileItem.IsWildcard) then

                local RequestValue = Functions:Condition(ProfileItem.ID > 0, ProfileItem.ID, ProfileItemName)
                local ItemName, ItemLink, _, _, _, _, _, _, _, ItemIcon = C_Item.GetItemInfo(RequestValue)
                if (ItemName and ItemLink and ItemIcon) then

                    local ItemID = Items:GetItemIDByLink(ItemLink)
                    if (ItemID > 0) then
                        
                        if (not ItemsToAdd[ProfileName]) then
                            ItemsToAdd[ProfileName] = {}
                        end

                        ItemsToAdd[ProfileName][ItemName] = {}
                        ItemsToAdd[ProfileName][ItemName].IsKnown = true
                        ItemsToAdd[ProfileName][ItemName].ID = ItemID
                        ItemsToAdd[ProfileName][ItemName].Name = ItemName
                        ItemsToAdd[ProfileName][ItemName].Icon = ItemIcon
                        ItemsToAdd[ProfileName][ItemName].Link = ItemLink

                        if (not ItemsToDelete[ProfileName]) then
                            ItemsToDelete[ProfileName] = {}
                        end

                        tinsert(ItemsToDelete[ProfileName], ProfileItemName)

                    end

                end
            end
        end
    end

    Items:UpdateItems(ItemsToDelete, ItemsToAdd)
end

function Items:UpdateItems(ItemsToDelete, ItemsToAdd)
    if (Functions:IsEmptyTable(ItemsToDelete)) then return end

    for ProfileName, Items in next, ItemsToDelete, nil do
        for Key, ItemName in next, Items, nil do
            LootAlarmLocalDB.Profiles[ProfileName].Items[ItemName] = nil
        end
    end

    for ProfileName, ItemTable in next, ItemsToAdd, nil do
        for ItemName, Item in next, ItemTable, nil do
            LootAlarmLocalDB.Profiles[ProfileName].Items[ItemName] = Item
            Functions:PrintAddon("Updated item "..Item.Link.." in profile "..Functions:PrintColor(ProfileName, Colors.blue)..".")
        end
    end
end

----------------------------------------------------------------------------------------
-- BAG ITEMS
----------------------------------------------------------------------------------------

local function UpdateContainerItems(Self)
    local ContainerID = Self:GetID()
	local ContainerFrameName = Self:GetName()
	local SlotID = 1
	local SlotFrame = _G[ContainerFrameName.."Item"..SlotID]

	while (SlotFrame) do
        local IsItemMarkable = SlotFrame.hasItem and Items:IsItemMarkable(SlotFrame, ContainerID, SlotFrame:GetID())
        if (IsItemMarkable) then
            Items:MarkContainerItem(SlotFrame, ContainerID, SlotFrame:GetID())
		else
			Items:UnmarkContainerItem(SlotFrame, ContainerID, SlotFrame:GetID())
		end

		SlotID = SlotID + 1
		SlotFrame = _G[ContainerFrameName.."Item"..SlotID]
	end
end

function Items:SetContainerHook()
    if (Core.IsRetail) then return end
    hooksecurefunc("ContainerFrame_Update", UpdateContainerItems)
end

function Items:IsItemMarkable(SlotFrame, ContainerID, SlotID)
    if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then return false end
    if (not LootAlarmLocalDB.Settings.MarkItemsInBags) then return false end
    if (not ProfileManager:HasItemsInProfile()) then return false end

    local ContainerInfo = C_Container.GetContainerItemInfo(ContainerID, SlotID)
    if (not ContainerInfo) then return false end

    local ItemLink = ContainerInfo.hyperlink
    if (not ItemLink) then return false end

    local ItemID = ContainerInfo.itemID
    if (not ItemID) then ItemID = Items:GetItemIDByLink(ItemLink) end
    if (ItemID == 0) then return false end

    local ItemName = Items:GetItemNameByLink(ItemLink)
    if (not ItemName) then return false end

    for ProfileItemName, ProfileItem in next, LootAlarmLocalDB.Profiles[LootAlarmLocalDB.Settings.LoadedProfile].Items, nil do
            
        if (string.lower(ProfileItemName) == string.lower(ItemName)) then
            return true
        elseif (ItemID == ProfileItem.ID) then
            return true
        elseif (ItemLink == ProfileItem.Link) then
            return true
        end

    end

    return false
end

function Items:MarkContainerItem(SlotFrame, ContainerID, SlotID)
    local CustomSlotFrameName = UI:FrameName(SlotFrame:GetName().."S"..SlotID)
    local CustomSlotFrame = _G[CustomSlotFrameName]

    if (CustomSlotFrame) then
        CustomSlotFrame:Show()
    else
        local Frame = CreateFrame("Frame", CustomSlotFrameName, SlotFrame, "BackdropTemplate")
        Frame:SetPoint("TOPLEFT", SlotFrame, "TOPLEFT", 0, 0)
        Frame:SetPoint("BOTTOMRIGHT", SlotFrame, "BOTTOMRIGHT", 0, 0)
        Frame:SetBackdrop(UI.Backdrop)
        Frame:SetBackdropColor(UI:HexToRGB("#000", 0))
        Frame:SetBackdropBorderColor(UI:HexToRGB("#fffb00"))

        local FrameBG = CreateFrame("Frame", CustomSlotFrameName..".BG", Frame, "BackdropTemplate")
        FrameBG:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
        FrameBG:SetSize(16, 16)
        FrameBG:SetBackdrop(UI.Backdrop)
        FrameBG:SetBackdropColor(UI:HexToRGB("#000", 0.5))
        FrameBG:SetBackdropBorderColor(UI:HexToRGB("#fffb00", 0.5))

        local Label = FrameBG:CreateFontString(CustomSlotFrameName..".Label", "OVERLAY")
        Label:SetPoint("CENTER", FrameBG, "CENTER", 0, 0)
        Label:SetFont(Assets.Fonts["Asap.ttf"], 10)
        Label:SetTextColor(UI:HexToRGB("#ffffff"))
        Label:SetShadowOffset(1, -1)
        Label:SetShadowColor(0, 0, 0, 0.5)
        Label:SetText(Core.AddonNameShort)
    end
end

function Items:UnmarkContainerItem(SlotFrame, ContainerID, SlotID)
    local CustomSlotFrame = _G[UI:FrameName(SlotFrame:GetName().."S"..SlotID)]
    if (CustomSlotFrame) then
        CustomSlotFrame:Hide()
    end
end

----------------------------------------------------------------------------------------
-- HELPER
----------------------------------------------------------------------------------------

function Items:GetItemNameByLink(ItemLink)
    local ItemString = string.match(ItemLink, "item[%-?%d:]+")
    if (not ItemString) then return "" end

	local _, ItemName = strsplit(":", ItemString)
    return Functions:Condition(ItemName, ItemName, "")
end

function Items:GetItemIDByLink(ItemLink)
    local ItemID = C_Item.GetItemInfoInstant(ItemLink)
    if (ItemID) then
        return ItemID
    end

    local ItemID = string.match(ItemLink, "item:(%d+)")
    return Functions:Condition(ItemID, tonumber(ItemID), 0)
end

function Items:GetItemID(ItemNameOrIDOrLink)
    if (not ItemNameOrIDOrLink) then return 0 end

    if (Functions:StartsWith(ItemNameOrIDOrLink, "|")) then
        ItemID = Items:GetItemIDByLink(ItemNameOrIDOrLink)
        if (ItemID > 0) then
            return ItemID
        end
    else
        local ItemID = C_Item.GetItemInfoInstant(ItemNameOrIDOrLink)
        if (ItemID) then
            return ItemID
        end
    end

    local ItemName, ItemLink = C_Item.GetItemInfo(ItemNameOrIDOrLink)
    if (ItemLink) then
        ItemID = string.match(ItemLink, "item:(%d+)")
        if (ItemID) then
            return tonumber(ItemID)
        end
    end

    return 0
end